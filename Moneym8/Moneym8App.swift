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
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false
    
    init() {
        // Use the FirebaseConfig class to configure Firebase
        FirebaseConfig.configure()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ExpenseTransaction.self,
            RecurringTransaction.self,
            WageHistory.self,  // Add WageHistory to schema
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    ContentView()
                        .environmentObject(themeManager)
                        .environmentObject(transactionViewModel)
                        .environmentObject(authManager)
                        .modelContainer(sharedModelContainer)
                        .tint(.appGreen)
                        .onAppear {
                            if !hasCompletedOnboarding {
                                // Show onboarding after a short delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showOnboarding = true
                                }
                            }
                            
                            // Track app open event
                            AnalyticsManager.shared.trackAppOpen()
                        }
                        .sheet(isPresented: $showOnboarding, onDismiss: {
                            // Mark onboarding as completed when dismissed
                            hasCompletedOnboarding = true
                        }) {
                            OnboardingView(viewModel: transactionViewModel)
                                .environmentObject(authManager)
                        }
                } else {
                    AuthenticationView()
                        .environmentObject(authManager)
                }
            }
        }
    }
}
