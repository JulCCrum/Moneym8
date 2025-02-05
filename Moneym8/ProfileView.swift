//
//  ProfileView.swift
//  Moneym8
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: TransactionViewModel
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
                ForEach([
                    ("Insights", "chart.bar.fill", Color.blue, $showInsights),
                    ("Help", "questionmark", Color.orange, $showHelp),
                    ("Preferences", "gearshape.fill", Color.green, $showPreferences),
                    ("Subscription", "creditcard.fill", Color.purple, $showSubscription),
                    ("About", "info", Color.gray, $showAbout)
                ], id: \.0) { item in
                    Button(action: { item.3.wrappedValue = true }) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(item.2.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                Image(systemName: item.1)
                                    .foregroundColor(item.2)
                            }
                            Text(item.0)
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
            .listStyle(PlainListStyle())
        }
        .fullScreenCover(isPresented: $showInsights) {
            InsightsView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showHelp) {
            HelpView()
        }
        .fullScreenCover(isPresented: $showPreferences) {
            PreferencesView()
        }
        .fullScreenCover(isPresented: $showSubscription) {
            SubscriptionView()
        }
        .fullScreenCover(isPresented: $showAbout) {
            AboutView()
        }
    }
}

#Preview {
    ProfileView(viewModel: TransactionViewModel())
}
