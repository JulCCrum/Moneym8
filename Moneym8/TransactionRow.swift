// TransactionRow.swift
// Moneym8
//

import SwiftUI

struct TransactionRow: View {
    let expenseTransaction: ExpenseTransaction
    @ObservedObject var viewModel: TransactionViewModel
    @State private var showingDetail = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            HStack {
                ZStack {
                    Circle()
                        .fill(categoryColor(expenseTransaction.category).opacity(
                            colorScheme == .dark ? 1 : 0.1
                        ))
                        .frame(width: 40, height: 40)
                    
                    Text(categoryEmoji(expenseTransaction.category))
                }
                
                VStack(alignment: .leading) {
                    Text(expenseTransaction.category)
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    HStack {
                        Text(formatDate(expenseTransaction.date))
                            .font(.caption)
                            .foregroundColor(Color(hex: "808080"))
                        
                        // Show work hours cost if enabled and it's an expense
                        if viewModel.showWageCost && !expenseTransaction.isIncome {
                            Text("•")
                                .foregroundColor(Color(hex: "808080"))
                            HStack(spacing: 2) {
                                Image(systemName: "clock")
                                    .font(.system(size: 10))
                                Text(viewModel.getWorkHoursCostFormatted(for: expenseTransaction.amount, at: expenseTransaction.date))
                            }
                            .foregroundColor(Color(hex: "808080"))
                        }
                    }
                }
                
                Spacer()
                
                Text(viewModel.showWageCost && !expenseTransaction.isIncome ?
                    viewModel.getWorkHoursCostFormatted(for: expenseTransaction.amount, at: expenseTransaction.date) :
                    expenseTransaction.formattedAmount)
                    .font(.headline)
                    .foregroundColor(expenseTransaction.isIncome ? .green : .red)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showingDetail) {
            TransactionDetailView(
                viewModel: viewModel,
                expenseTransaction: expenseTransaction
            )
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func categoryColor(_ category: String) -> Color {
        switch category {
        case "Rent": return .blue
        case "Food": return .green
        case "Transportation": return .orange
        case "Other": return .purple
        case "Salary": return .blue
        case "Investment": return .green
        case "Gift": return .purple
        default: return .gray
        }
    }
    
    private func categoryEmoji(_ category: String) -> String {
        switch category {
        case "Rent": return "🏠"
        case "Food": return "🍽️"
        case "Transportation": return "🚗"
        case "Other": return "💡"
        case "Salary": return "💰"
        case "Investment": return "📈"
        case "Gift": return "🎁"
        default: return "💰"
        }
    }
}
