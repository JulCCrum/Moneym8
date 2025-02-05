//  FirebaseConfig.swift
//  Moneym8

import FirebaseCore
import FirebaseFirestore

class FirebaseConfig {
    static func configure() {
        // Simple Firebase configuration without DeviceCheck options
        FirebaseApp.configure()
        
        // Configure Firestore settings
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
    }
}
