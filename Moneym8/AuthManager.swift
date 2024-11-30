//
//  AuthManager.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/23/24.
//

import SwiftUI

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    static let shared = AuthManager()
    
    // Simple email/password authentication
    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        
        // For demo purposes, accept any non-empty email/password
        if !email.isEmpty && !password.isEmpty {
            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.isLoading = false
            }
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid email or password"
                self.isLoading = false
            }
            throw AuthError.signInError("Invalid credentials")
        }
    }
    
    func signUpWithEmail(email: String, password: String) async throws {
        isLoading = true
        
        // For demo purposes, accept any non-empty email/password
        if !email.isEmpty && !password.isEmpty {
            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.isLoading = false
            }
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid email or password"
                self.isLoading = false
            }
            throw AuthError.signInError("Invalid credentials")
        }
    }
    
    func signOut() {
        isAuthenticated = false
    }
}

enum AuthError: LocalizedError {
    case signInError(String)
    
    var errorDescription: String? {
        switch self {
        case .signInError(let message):
            return message
        }
    }
}
