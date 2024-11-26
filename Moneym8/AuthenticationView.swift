//
//  AuthenticationView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/23/24.
//

import SwiftUI
import FirebaseAuth

struct AuthenticationView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 20) {
            // App Logo
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.appGreen)
            
            Text("Moneym8")
                .font(.largeTitle)
                .bold()
            
            // Email/Password Fields
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Sign In/Up Button
            Button(action: {
                Task {
                    do {
                        if isSignUp {
                            try await authManager.signUpWithEmail(email: email, password: password)
                        } else {
                            try await authManager.signInWithEmail(email: email, password: password)
                        }
                    } catch {
                        showError = true
                    }
                }
            }) {
                Text(isSignUp ? "Create Account" : "Sign In")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appGreen)
                    .cornerRadius(10)
            }
            
            // Toggle between Sign In and Sign Up
            Button(action: { isSignUp.toggle() }) {
                Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Create one")
                    .foregroundColor(.appGreen)
            }
        }
        .padding()
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authManager.errorMessage ?? "An error occurred")
        }
    }
}
