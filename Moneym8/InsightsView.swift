//
//  InsightsView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/8/24.
import SwiftUI

struct InsightsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("Insights and Analytics")
                }
                
                Section(header: Text("SPENDING OVERVIEW")) {
                    HStack {
                        Text("Total Spending")
                        Spacer()
                        Text("$1,150.00")
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        Text("Total Income")
                        Spacer()
                        Text("$2,000.00")
                            .foregroundColor(.green)
                    }
                }
                
                Section(header: Text("CATEGORY BREAKDOWN")) {
                    CategoryRow(name: "Rent", amount: 500, color: .blue)
                    CategoryRow(name: "Food", amount: 300, color: .green)
                    CategoryRow(name: "Transportation", amount: 150, color: .orange)
                    CategoryRow(name: "Other", amount: 200, color: .purple)
                }
                
                Section(header: Text("MONTHLY TRENDS")) {
                    Text("Spending is 15% higher than last month")
                        .foregroundColor(.red)
                    Text("Most expensive category: Rent")
                    Text("Fastest growing category: Food")
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct CategoryRow: View {
    let name: String
    let amount: Double
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(name)
            Spacer()
            Text("$\(String(format: "%.2f", amount))")
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    InsightsView()
}
