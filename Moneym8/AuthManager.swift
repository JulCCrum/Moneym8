//
//  AuthManager.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/23/24.
//
import SwiftUI
import FirebaseAuth  // Make sure this import is at the top

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    static let shared = AuthManager()
    
    func signInWithEmail(email: String, password: String) async throws {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            // Remove 'let result =' since we're not using it
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
            // Remove 'let result =' since we're not using it
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
}
