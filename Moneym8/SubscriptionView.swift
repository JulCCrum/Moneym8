//
//  SubscriptionView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/8/24.
//
import SwiftUI

struct SubscriptionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(spacing: 16) {
                        Text("🤖")
                            .font(.system(size: 60))
                        Text("Moneym8 Pro")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Unlock all features")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                
                Section(header: Text("Features Included")) {
                    FeatureRow(icon: "chart.bar.fill", text: "Advanced Analytics")
                    FeatureRow(icon: "bell.fill", text: "Custom Notifications")
                    FeatureRow(icon: "icloud.fill", text: "Cloud Backup")
                    FeatureRow(icon: "doc.fill", text: "Export Reports")
                }
                
                Section(header: Text("Subscription Options")) {
                    Button(action: {
                        // Handle monthly subscription
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Monthly")
                                .font(.headline)
                            Text("$10.00/month")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        // Handle yearly subscription
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Yearly")
                                .font(.headline)
                            Text("$100.00/year")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section {
                    Text("Subscriptions are automatically ended if not renewed as well as at the end of the 7 day free trial. There are no games, no tactics.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Subscription")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
            Text(text)
        }
    }
}

#Preview {
    SubscriptionView()
}
