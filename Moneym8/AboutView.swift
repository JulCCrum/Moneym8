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
        VStack(alignment: .leading, spacing: -15) {
            // Header
            HStack {
                Text("About")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
            
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
                
                Section(header: Text("APP INFO")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    LabeledContent("Developer", value: "Your Name")
                    LabeledContent("Released", value: "2024")
                    LabeledContent("Framework", value: "SwiftUI")
                }
                
                Section(header: Text("LINKS")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    Link("Privacy Policy", destination: URL(string: "https://www.jackpotautomations.fyi/PrivacyPolicy.html")!)
                        .foregroundColor(.blue)
                    Link("Terms of Service", destination: URL(string: "https://www.jackpotautomations.fyi/TermsofService.html")!)
                        .foregroundColor(.blue)
                    Button("Contact Support") {
                        if let url = URL(string: "mailto:info@jackpotautomations.fyi") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                Section(header: Text("LEGAL")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    Text("© 2024 Jackpot Automations LLC. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

#Preview {
    AboutView()
}
