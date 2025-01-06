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
                ForEach(sortedTransactions) { expenseTransaction in
                    TransactionRow(
                        expenseTransaction: expenseTransaction,
                        viewModel: viewModel
                    )
                    .listRowBackground(Color.clear)
                }
                .onDelete { indexSet in
                    let toDelete = indexSet.map { sortedTransactions[$0] }
                    for expenseTransaction in toDelete {
                        // remove from the main array
                        if let idx = viewModel.transactions.firstIndex(where: {
                            $0.id == expenseTransaction.id
                        }) {
                            viewModel.transactions.remove(at: idx)
                        }
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
                        .fill(expenseTransaction.category.color.opacity(
                            colorScheme == .dark ? 1 : 0.1
                        ))
                        .frame(width: 40, height: 40)
                    
                    Text(expenseTransaction.category.emoji)
                }
                
                VStack(alignment: .leading) {
                    Text(expenseTransaction.category)
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text(formatDate(expenseTransaction.date))
                        .font(.caption)
                        .foregroundColor(Color(hex: "808080"))
                }
                
                Spacer()
                
                Text(expenseTransaction.formattedAmount)
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
}

// A helper extension to format the amount with currency style
extension ExpenseTransaction {
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// A helper to convert hex string to Color
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xFF0000) >> 16
        let g = (rgbValue & 0x00FF00) >> 8
        let b = (rgbValue & 0x0000FF)
        
        self = Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsView(
            isExpanded: .constant(false),
            isBlurred: .constant(false),
            viewModel: TransactionViewModel()
        )
    }
}
