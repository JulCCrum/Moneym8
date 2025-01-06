//
//  AuthManager.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/23/24.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
   @Published var isAuthenticated = false
   @Published var errorMessage: String?
   @Published var isLoading = false
   
   private var authStateHandle: AuthStateDidChangeListenerHandle?
   private let db = Firestore.firestore()
   
   private static var instance: AuthManager?
   
   static var shared: AuthManager {
       if instance == nil {
           instance = AuthManager()
       }
       return instance!
   }
   
   private init() {
       // Check if user is already authenticated
       if Auth.auth().currentUser != nil {
           isAuthenticated = true
       }
       
       // Setup auth state listener
       authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
           DispatchQueue.main.async {
               self?.isAuthenticated = user != nil
           }
       }
   }
   
   func signInWithEmail(email: String, password: String) async throws {
       await MainActor.run {
           isLoading = true
       }
       
       do {
           try await Auth.auth().signIn(withEmail: email, password: password)
           await MainActor.run {
               isAuthenticated = true
               isLoading = false
           }
       } catch {
           await MainActor.run {
               errorMessage = error.localizedDescription
               isLoading = false
           }
           throw error
       }
   }
   
   func signUpWithEmail(email: String, password: String) async throws {
       await MainActor.run {
           isLoading = true
       }
       
       do {
           try await Auth.auth().createUser(withEmail: email, password: password)
           await MainActor.run {
               isAuthenticated = true
               isLoading = false
           }
       } catch {
           await MainActor.run {
               errorMessage = error.localizedDescription
               isLoading = false
           }
           throw error
       }
   }

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
           let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
           let amount = data["amount"] as? Double ?? 0.0
           let isIncome = data["isIncome"] as? Bool ?? false
           let category = data["category"] as? String ?? ""
           let note = data["note"] as? String ?? ""
           
           // Format the row, properly escaping fields
           let row = [
               dateFormatter.string(from: date),
               String(format: "%.2f", amount),
               isIncome ? "Income" : "Expense",
               category,
               note.replacingOccurrences(of: ",", with: ";")
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
       await MainActor.run {
           isAuthenticated = false
       }
   }
   
   func signOut() {
       do {
           try Auth.auth().signOut()
           isAuthenticated = false
       } catch {
           errorMessage = error.localizedDescription
       }
   }
   
   deinit {
       if let handle = authStateHandle {
           Auth.auth().removeStateDidChangeListener(handle)
       }
   }
}
