// FirebaseConfig.swift

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class FirebaseConfig {
    static var isConfigured = false
    
    static func configure() {
        // Prevent multiple initialization
        guard !isConfigured else { return }
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Set isConfigured flag
        isConfigured = true
        
        print("Firebase has been configured successfully")
    }
    
    // Helper method to get Firestore instance
    static func getFirestore() -> Firestore {
        if !isConfigured {
            configure()
        }
        return Firestore.firestore()
    }
    
    // Helper method to get current user
    static func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
}
