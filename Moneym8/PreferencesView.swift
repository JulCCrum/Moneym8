//
//  PreferencesView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/8/24.
//
//
//  PreferencesView.swift
//  Moneym8
//
import SwiftUI

struct PreferencesView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)  // This sets the background color for the entire view
                
                List {
                    Section(header: Text("GENERAL")) {
                        Toggle("Notifications", isOn: .constant(true))
                    }
                    
                    Section(header: Text("DISPLAY")) {
                        Toggle("Dark Mode", isOn: $isDarkMode)
                    }
                    
                    Section(header: Text("CURRENCY")) {
                        Text("USD ($)")
                    }
                    
                    Section(header: Text("DATA")) {
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
                .scrollContentBackground(.hidden)  // This hides the default list background
            }
            .navigationTitle("Preferences")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onChange(of: isDarkMode) { oldValue, newValue in
            UserDefaults.standard.synchronize()
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
