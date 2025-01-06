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
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("• Advanced Analytics")
                            Spacer()
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.purple)
                        }
                        HStack {
                            Text("• Custom Notifications")
                            Spacer()
                            Image(systemName: "bell.fill")
                                .foregroundColor(.purple)
                        }
                        HStack {
                            Text("• Cloud Backup")
                            Spacer()
                            Image(systemName: "icloud.fill")
                                .foregroundColor(.purple)
                        }
                        HStack {
                            Text("• Export Reports")
                            Spacer()
                            Image(systemName: "doc.fill")
                                .foregroundColor(.purple)
                        }
                    }
                    .padding(.vertical, 8)
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

#Preview {
    SubscriptionView()
}
