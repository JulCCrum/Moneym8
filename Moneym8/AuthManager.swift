// AuthManager.swift
// Moneym8
//
// Created by chase Crummedyo on 11/23/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var showAuthentication: Bool = false
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    static let shared = AuthManager()
    
    private init() {
        if Auth.auth().currentUser != nil {
            isAuthenticated = true
        }
        
        // Newly added
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            // Wrap in MainActor.run or DispatchQueue.main.async
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    func checkAuthenticationState() {
        if Auth.auth().currentUser != nil {
            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.showAuthentication = false
            }
        } else {
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
        }
    }
    
    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            // Use MainActor.run for main thread updates
            await MainActor.run {
                isAuthenticated = true
                isLoading = false
                showAuthentication = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
            throw error
        }
    }
    
    // Similarly for signUpWithEmail
    func signUpWithEmail(email: String, password: String) async throws {
        isLoading = true
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
            await MainActor.run {
                isAuthenticated = true
                isLoading = false
                showAuthentication = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
            throw error
        }
    }

    func signInAnonymously() async throws {
        isLoading = true
        do {
            let result = try await Auth.auth().signInAnonymously()
            await MainActor.run {
                isAuthenticated = true
                isLoading = false
            }
            print("Signed in anonymously with user ID: \(result.user.uid)")
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
            throw error
        }
    }

    func isAnonymousUser() -> Bool {
        return Auth.auth().currentUser?.isAnonymous ?? false
    }

    func promptForAccountCreation() {
        if isAnonymousUser() {
            showAuthentication = true
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            showAuthentication = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // Keep existing methods (deleteAllUserData, exportUserData, archiveUserAccount)
    func deleteAllUserData() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let batch = db.batch()
        let snapshot = try await db.collection("users").document(userId)
            .collection("transactions")
            .getDocuments()
        
        for document in snapshot.documents {
            batch.deleteDocument(document.reference)
        }
        
        try await batch.commit()
    }
    
    func exportUserData() async throws -> Data {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let snapshot = try await db.collection("users").document(userId)
            .collection("transactions")
            .getDocuments()
        
        // Create CSV header
        var csvString = "Date,Amount,Type,Category,Note\n"
        
        // Add each transaction to CSV
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        for document in snapshot.documents {
            let data = document.data()
            
            // Format date
            let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
            let dateStr = dateFormatter.string(from: date)
            
            // Get other fields
            let amount = data["amount"] as? Double ?? 0.0
            let isIncome = data["isIncome"] as? Bool ?? false
            let category = data["category"] as? String ?? ""
            let note = data["note"] as? String ?? ""
            
            // Escape fields that might contain commas
            let escapedCategory = category.contains(",") ? "\"\(category)\"" : category
            let escapedNote = note.contains(",") ? "\"\(note)\"" : note
            
            // Format the row
            let row = [
                dateStr,
                String(format: "%.2f", amount),
                isIncome ? "Income" : "Expense",
                escapedCategory,
                escapedNote
            ].joined(separator: ",")
            
            csvString += row + "\n"
        }
        
        return csvString.data(using: .utf8) ?? Data()
    }
    
    func archiveUserAccount() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // Get all user data
        let snapshot = try await db.collection("users").document(userId)
            .collection("transactions")
            .getDocuments()
        
        // Create archive data
        let archiveData: [String: Any] = [
            "userId": userId,
            "deletedAt": FieldValue.serverTimestamp(),
            "email": Auth.auth().currentUser?.email ?? "",
            "totalTransactions": snapshot.documents.count,
            "lastActiveDate": FieldValue.serverTimestamp(),
            "transactions": snapshot.documents.map { $0.data() }
        ]
        
        // Store in archived_accounts collection
        try await db.collection("archived_accounts").document(userId).setData(archiveData)
        
        // Delete user's active data
        try await deleteAllUserData()
        
        // Delete the auth account
        try await Auth.auth().currentUser?.delete()
        
        // Sign out
        try Auth.auth().signOut()
        isAuthenticated = false
    }
}
