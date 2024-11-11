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
        VStack(alignment: .leading, spacing: -15) {
            // Header
            HStack {
                Text("Subscription")
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
                
                Section(header: Text("FEATURES INCLUDED")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    FeatureRow(icon: "chart.bar.fill", text: "Advanced Analytics")
                    FeatureRow(icon: "bell.fill", text: "Custom Notifications")
                    FeatureRow(icon: "icloud.fill", text: "Cloud Backup")
                    FeatureRow(icon: "doc.fill", text: "Export Reports")
                }
                
                Section(header: Text("SUBSCRIPTION OPTIONS")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Monthly")
                            .font(.headline)
                        Text("$10.00/month")
                            .foregroundColor(.gray)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Handle monthly subscription
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Yearly")
                            .font(.headline)
                        Text("$100.00/year")
                            .foregroundColor(.gray)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Handle yearly subscription
                    }
                }
                
                Section {
                    Text("Subscriptions are automatically ended if not renewed as well as at the end of the 7 day free trial. There are no games, no tactics.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .background(Color(uiColor: .systemGroupedBackground))
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
