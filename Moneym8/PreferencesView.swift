//
//  PreferencesView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/8/24.
import SwiftUI

struct PreferencesView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Preferences")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
            
            List {
                Section(header: Text("GENERAL")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    Toggle("Notifications", isOn: .constant(true))
                        .tint(.green) // Explicitly set toggle color
                }
                
                Section(header: Text("DISPLAY")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .tint(.green) // Explicitly set toggle color
                }
                
                Section(header: Text("CURRENCY")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    Text("USD ($)")
                }
                
                Section(header: Text("DATA")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    Button("Export Data") {
                        // Handle export
                    }
                    .foregroundColor(.blue)
                    
                    Button("Clear All Data") {
                        // Handle clear
                    }
                    .foregroundColor(.red)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    PreferencesView()
}
