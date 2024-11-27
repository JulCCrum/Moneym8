//
//  AuthManager.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/23/24.
//
import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit

@MainActor
class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    fileprivate var currentNonce: String?
    
    static let shared = AuthManager()
    
    init() {
        // Set up authentication state listener
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    // MARK: - Email Authentication
    func signUpWithEmail(email: String, password: String) async throws {
        isLoading = true
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
            self.isAuthenticated = true
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
            self.isAuthenticated = true
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.configError("Firebase configuration error")
        }
        
        func getRootViewController() -> UIViewController? {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                return nil
            }
            return rootViewController
        }
        
        guard let rootViewController = getRootViewController() else {
            throw AuthError.configError("No root view controller found")
        }
        
        isLoading = true
        
        do {
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.signInError("Failed to get ID token")
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            self.user = authResult.user
            self.isAuthenticated = true
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Apple Sign In
    func startAppleSignIn() -> ASAuthorizationAppleIDRequest {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        return request
    }
    
    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async throws {
        isLoading = true
        
        do {
            guard case .success(let authorization) = result else {
                throw AuthError.signInError("Apple sign in failed")
            }
            
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let nonce = currentNonce,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                throw AuthError.signInError("Invalid Apple credentials")
            }
            
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            self.user = authResult.user
            self.isAuthenticated = true
            self.isLoading = false
            
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Helper Methods
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

enum AuthError: LocalizedError {
    case configError(_ message: String)
    case signInError(_ message: String)
    
    var errorDescription: String? {
        switch self {
        case .configError(let message), .signInError(let message):
            return message
        }
    }
}
