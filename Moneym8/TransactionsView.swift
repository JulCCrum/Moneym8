//
//  TransactionsView.swift
//  Moneym8
//

import SwiftUI

extension String {
    var color: Color {
        switch self {
        case "Rent": return .blue
        case "Food": return .green
        case "Transportation": return .orange
        case "Other": return .purple
        default: return .gray
        }
    }
    
    var emoji: String {
        switch self {
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

struct TransactionsView: View {
    @Binding var isExpanded: Bool
    @Binding var isBlurred: Bool
    
    @ObservedObject var viewModel: TransactionViewModel
    
    @State private var selectedSort: SortOption = .dateDesc
    @Environment(\.colorScheme) var colorScheme
    
    enum SortOption: String, CaseIterable {
        case dateDesc = "Latest First"
        case dateAsc = "Oldest First"
        case amountDesc = "Amount: High to Low"
        case amountAsc = "Amount: Low to High"
        case category = "Category"
    }
    
    // Use ExpenseTransaction instead of Transaction
    private var sortedTransactions: [ExpenseTransaction] {
        viewModel.transactions.sorted { first, second in
            switch selectedSort {
            case .dateDesc:
                // newest first
                return first.date > second.date
            case .dateAsc:
                // oldest first
                return first.date < second.date
            case .amountDesc:
                // high to low
                return first.amount > second.amount
            case .amountAsc:
                // low to high
                return first.amount < second.amount
            case .category:
                // alphabetical by category
                return first.category < second.category
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Transactions")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 15)
                .padding(.leading)
                .padding(.bottom, 20)
            
            // Sorting Menu
            Menu {
                Picker("Sort by", selection: $selectedSort) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            } label: {
                HStack {
                    Text(selectedSort.rawValue)
                    Image(systemName: "chevron.down")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(colorScheme == .dark
                            ? Color.gray.opacity(0.3)
                            : Color.gray.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.leading)
            .padding(.bottom, 20)
            
            // Transactions List
            List {
                ForEach(sortedTransactions) { transaction in
                    TransactionRow(
                        expenseTransaction: transaction,
                        viewModel: viewModel
                    )
                    .listRowBackground(Color.clear)
                }
                .onDelete { indexSet in
                    let toDelete = indexSet.map { sortedTransactions[$0] }
                    for transaction in toDelete {
                        // remove from the main array
                        viewModel.removeTransaction(transaction)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .blur(radius: isBlurred ? 10 : 0)
        .overlay(
            Group {
                if isBlurred {
                    Color.black.opacity(0.01)
                        .onTapGesture {
                            withAnimation {
                                isExpanded = false
                                isBlurred = false
                            }
                        }
                }
            }
        )
    }
}

#Preview {
    TransactionsView(
        isExpanded: .constant(false),
        isBlurred: .constant(false),
        viewModel: TransactionViewModel()
    )
}
