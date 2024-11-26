//
//  Moneym8App.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/11/24.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct Moneym8App: App {
    @StateObject private var transactionViewModel = TransactionViewModel()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var authManager = AuthManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    ContentView()
                        .environmentObject(themeManager)
                        .modelContainer(sharedModelContainer)
                        .tint(.appGreen)
                } else {
                    AuthenticationView()
                        .environmentObject(themeManager)
                        .modelContainer(sharedModelContainer)
                        .tint(.appGreen)
                }
            }
        }
    }
}
