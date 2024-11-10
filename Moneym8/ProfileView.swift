//
//  ProfileView.swift
//  Moneym8
//
import SwiftUI

struct ProfileView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
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
                Button(action: { showInsights = true }) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                        }
                        Text("Insights")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .foregroundColor(isDarkMode ? .white : .black)
                .listRowBackground(Color.clear)
                
                Button(action: { showHelp = true }) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: "questionmark")
                                .foregroundColor(.orange)
                        }
                        Text("Help")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .foregroundColor(isDarkMode ? .white : .black)
                .listRowBackground(Color.clear)
                
                Button(action: { showPreferences = true }) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.green)
                        }
                        Text("Preferences")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .foregroundColor(isDarkMode ? .white : .black)
                .listRowBackground(Color.clear)
                
                Button(action: { showSubscription = true }) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.purple.opacity(0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.purple)
                        }
                        Text("Subscription")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .foregroundColor(isDarkMode ? .white : .black)
                .listRowBackground(Color.clear)
                
                Button(action: { showAbout = true }) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: "info")
                                .foregroundColor(.gray)
                        }
                        Text("About")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .foregroundColor(isDarkMode ? .white : .black)
                .listRowBackground(Color.clear)
            }
            .listStyle(PlainListStyle())
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .sheet(isPresented: $showInsights) {
            InsightsView()
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
        .sheet(isPresented: $showPreferences) {
            PreferencesView()
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
