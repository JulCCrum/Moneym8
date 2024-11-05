import SwiftUI

struct TransactionsView: View {
    @Binding var isExpanded: Bool
    @Binding var isBlurred: Bool
    @ObservedObject var viewModel: TransactionViewModel
    @State private var selectedSort: SortOption = .dateDesc
    
    // Sort options
    enum SortOption: String, CaseIterable {
        case dateDesc = "Latest First"
        case dateAsc = "Oldest First"
        case amountDesc = "Amount: High to Low"
        case amountAsc = "Amount: Low to High"
        case category = "Category"
    }
    
    private var sortedTransactions: [Transaction] {
        viewModel.transactions.sorted { first, second in
            switch selectedSort {
            case .dateDesc:
                return first.date > second.date
            case .dateAsc:
                return first.date < second.date
            case .amountDesc:
                return first.amount > second.amount
            case .amountAsc:
                return first.amount < second.amount
            case .category:
                return first.category < second.category
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Sort Button
                HStack {
                    Text("Transactions")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // Sort Button
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
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                .padding()
                
                // Transactions List
                List {
                    ForEach(sortedTransactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                    .onDelete { indexSet in
                        // Convert the indexSet to the actual indices in the viewModel's transactions array
                        let transactionsToDelete = indexSet.map { sortedTransactions[$0] }
                        for transaction in transactionsToDelete {
                            if let index = viewModel.transactions.firstIndex(where: { $0.id == transaction.id }) {
                                viewModel.transactions.remove(at: index)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .blur(radius: isBlurred ? 10 : 0)
        }
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

// Keep the existing TransactionRow view code...
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            // Category Icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                Text(categoryEmoji)
            }
            
            // Transaction Details
            VStack(alignment: .leading) {
                Text(transaction.category)
                    .font(.headline)
                Text(formatDate(transaction.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Amount
            Text(formatAmount(transaction.amount, isIncome: transaction.isIncome))
                .font(.headline)
                .foregroundColor(transaction.isIncome ? .green : .red)
        }
        .padding(.vertical, 4)
    }
    
    // Helper functions remain the same...
    private var categoryColor: Color {
        switch transaction.category {
        case "Rent": return .blue
        case "Food": return .green
        case "Transportation": return .orange
        case "Other": return .purple
        default: return .gray
        }
    }
    
    private var categoryEmoji: String {
        switch transaction.category {
        case "Rent": return "🏠"
        case "Food": return "🍽️"
        case "Transportation": return "🚗"
        case "Other": return "💡"
        default: return "💰"
        }
    }
    
    private func formatAmount(_ amount: Double, isIncome: Bool) -> String {
        let prefix = isIncome ? "+" : "-"
        return "\(prefix)$\(String(format: "%.2f", amount))"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
