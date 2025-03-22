// ProfileView.swift
// Moneym8
//
// Created by chase Crummedyo on [Date]

import SwiftUI
import SwiftData

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthManager
    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showInsights = false
    @State private var showHelp = false
    @State private var showPreferences = false
    @State private var showSubscription = false
    @State private var showAbout = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 15)
                .padding(.leading)
                .padding(.bottom, 20)
            
            List {
                // Profile menu items
                ProfileMenuItem(
                    title: "Insights",
                    icon: "chart.bar.fill",
                    color: .blue,
                    action: { showInsights = true }
                )
                
                ProfileMenuItem(
                    title: "Help",
                    icon: "questionmark",
                    color: .orange,
                    action: { showHelp = true }
                )
                
                ProfileMenuItem(
                    title: "Preferences",
                    icon: "gearshape.fill",
                    color: .green,
                    action: { showPreferences = true }
                )
                
                ProfileMenuItem(
                    title: "Subscription",
                    icon: "creditcard.fill",
                    color: .purple,
                    action: { showSubscription = true }
                )
                
                ProfileMenuItem(
                    title: "About",
                    icon: "info",
                    color: .gray,
                    action: { showAbout = true }
                )
                
                // Sync option
                // In ProfileView.swift
                // In ProfileView.swift, modify the Sync button to show authentication status
                Button(action: {
                    authManager.showAuthentication = true
                }) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: "icloud.fill")
                                .foregroundColor(.blue)
                        }
                        VStack(alignment: .leading) {
                            Text("Sync with Account")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            if authManager.isAuthenticated {
                                Text("Signed in")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                Text("Not signed in")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .listRowBackground(Color.clear)
                .padding(.vertical, 8)
            }
            .listStyle(PlainListStyle())
        }
        .fullScreenCover(isPresented: $showInsights) {
            InsightsView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showHelp) {
            HelpView()
        }
        .fullScreenCover(isPresented: $showPreferences) {
            PreferencesView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showSubscription) {
            SubscriptionView()
        }
        .fullScreenCover(isPresented: $showAbout) {
            AboutView()
        }
    }
}

// Helper view for menu items
struct ProfileMenuItem: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .foregroundColor(color)
                }
                Text(title)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .listRowBackground(Color.clear)
        .padding(.vertical, 8)
    }
}

#Preview {
    ProfileView(viewModel: TransactionViewModel())
        .environmentObject(AuthManager.shared)
}
