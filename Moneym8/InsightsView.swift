//
//  InsightsView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/8/24.
import SwiftUI

struct InsightsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: -15) {
            // Header
            HStack {
                Text("Insights")
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
                    Text("Insights and Analytics")
                        .font(.body)
                }
                
                Section(header: Text("SPENDING OVERVIEW")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    HStack {
                        Text("Total Spending")
                            .font(.body)
                        Spacer()
                        Text("$1,150.00")
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        Text("Total Income")
                            .font(.body)
                        Spacer()
                        Text("$2,000.00")
                            .foregroundColor(.green)
                    }
                }
                
                Section(header: Text("CATEGORY BREAKDOWN")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    CategoryRow(name: "Rent", amount: 500, color: .blue)
                    CategoryRow(name: "Food", amount: 300, color: .green)
                    CategoryRow(name: "Transportation", amount: 150, color: .orange)
                    CategoryRow(name: "Other", amount: 200, color: .purple)
                }
                
                Section(header: Text("MONTHLY TRENDS")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    Text("Spending is 15% higher than last month")
                        .foregroundColor(.red)
                        .font(.body)
                    Text("Most expensive category: Rent")
                        .font(.body)
                    Text("Fastest growing category: Food")
                        .font(.body)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .background(Color(uiColor: .systemGroupedBackground))
        }
        .background(Color(uiColor: .systemGroupedBackground))
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
                .font(.body)
            Spacer()
            Text("$\(String(format: "%.2f", amount))")
                .foregroundColor(.gray)
                .font(.body)
        }
    }
}

#Preview {
    InsightsView()
}
