//
//  AboutView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/8/24.
//
import SwiftUI

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("Moneym8")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Version 1.0.0")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                
                Section(header: Text("App Info")) {
                    LabeledContent("Developer", value: "Your Name")
                    LabeledContent("Released", value: "2024")
                    LabeledContent("Framework", value: "SwiftUI")
                }
                
                Section(header: Text("Links")) {
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                    Link("Contact Support", destination: URL(string: "https://example.com/support")!)
                }
                
                Section(header: Text("Legal")) {
                    Text("© 2024 Your Company. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("About")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    AboutView()
}
