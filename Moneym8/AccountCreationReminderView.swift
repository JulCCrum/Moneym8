//
//  AccountCreationReminderView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 3/18/25.
//

import SwiftUI

struct AccountCreationReminderView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var authManager: AuthManager
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "icloud.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 40)
            
            Text("Save Your Data?")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Great job adding your first transaction! Would you like to create an account to securely back up your data?")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                Button(action: {
                    // Show the authentication view
                    authManager.showAuthentication = true
                    isPresented = false
                }) {
                    Text("Create Account")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    // Track that the user skipped
                    AnalyticsManager.shared.trackButtonClick(
                        buttonName: "skip_account_creation",
                        screenName: "account_creation_reminder"
                    )
                    isPresented = false
                }) {
                    Text("Maybe Later")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.gray)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    // Track that the user will continue with anonymous account
                    AnalyticsManager.shared.trackButtonClick(
                        buttonName: "continue_anonymous",
                        screenName: "account_creation_reminder"
                    )
                    
                    // Set a flag to not show this again
                    UserDefaults.standard.set(true, forKey: "hasSkippedAccountCreation")
                    isPresented = false
                }) {
                    Text("Continue without Account")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .padding()
        .onAppear {
            AnalyticsManager.shared.trackScreenView(
                screenName: "account_creation_reminder",
                screenClass: "AccountCreationReminderView"
            )
        }
    }
}

struct AccountCreationReminderView_Previews: PreviewProvider {
    static var previews: some View {
        AccountCreationReminderView(isPresented: .constant(true))
            .environmentObject(AuthManager.shared)
    }
}
