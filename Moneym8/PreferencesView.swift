//
//  PreferencesView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/8/24.
//
import SwiftUI

struct PreferencesView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isDarkMode = false
    @State private var useFaceID = false
    @State private var defaultCurrency = "USD"
    @State private var notificationsEnabled = true
    
    let currencies = ["USD", "EUR", "GBP", "CAD", "AUD"]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }
                
                Section(header: Text("Security")) {
                    Toggle("Use Face ID", isOn: $useFaceID)
                }
                
                Section(header: Text("Currency")) {
                    Picker("Default Currency", selection: $defaultCurrency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    if notificationsEnabled {
                        Text("You'll receive notifications about your spending limits and budget goals")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Preferences")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    PreferencesView()
}
