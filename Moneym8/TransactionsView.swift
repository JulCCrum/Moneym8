//
//  TransactionsView.swift
//  Moneym8
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
        VStack(alignment: .leading, spacing: 0) {
            Text("Transactions")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 15)
                .padding(.leading)
                .padding(.bottom, 20)
            
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
                .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.leading)
            .padding(.bottom, 20)
            
            List {
                ForEach(sortedTransactions) { transaction in
                    TransactionRow(transaction: transaction, viewModel: viewModel)
                        .listRowBackground(Color.clear)
                }
                .onDelete { indexSet in
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
    let transaction: Transaction
    @ObservedObject var viewModel: TransactionViewModel
    @State private var showingDetail = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            HStack {
                ZStack {
                    Circle()
                        .fill(transaction.category.color.opacity(colorScheme == .dark ? 1 : 0.1))
                        .frame(width: 40, height: 40)
                    Text(transaction.category.emoji)
                }
                
                VStack(alignment: .leading) {
                    Text(transaction.category)
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text(formatDate(transaction.date))
                        .font(.caption)
                        .foregroundColor(Color(hex: "808080"))
                }
                
                Spacer()
                
                Text(transaction.formattedAmount)
                    .font(.headline)
                    .foregroundColor(transaction.isIncome ? .green : .red)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showingDetail) {
            TransactionDetailView(viewModel: viewModel, transaction: transaction)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
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
