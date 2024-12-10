//
//  AuthManager.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/23/24.
//
import SwiftUI
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    static let shared = AuthManager()
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // Add this to check for existing auth state
        if Auth.auth().currentUser != nil {
            isAuthenticated = true
        }
        
        // Add auth state listener and store the handle
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
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    deinit {
        // Remove the listener when the AuthManager is deallocated
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
