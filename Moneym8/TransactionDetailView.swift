//
//  TransactionDetailView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/5/24.
//
import SwiftUI

struct TransactionDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    let transaction: Transaction
    @State private var showingDeleteAlert = false
    @State private var isEditing = false
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Transaction Details")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                        .font(.title2)
                }
            }
            .padding()
            
            // Transaction Icon and Amount
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 72, height: 72)
                    Text(categoryEmoji)
                        .font(.system(size: 32))
                }
                
                Text(transaction.formattedAmount)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(transaction.isIncome ? .green : .red)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            
            // Details List
            VStack(spacing: 24) {
                DetailRow(title: "Category", value: transaction.category)
                DetailRow(title: "Date", value: formatDate(transaction.date))
                DetailRow(title: "Time", value: formatTime(transaction.date))
                if let note = transaction.note {
                    DetailRow(title: "Note", value: note)
                }
                DetailRow(title: "Type", value: transaction.isIncome ? "Income" : "Expense")
            }
            .padding()
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: { isEditing = true }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit Transaction")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Button(action: { showingDeleteAlert = true }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Transaction")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .sheet(isPresented: $isEditing) {
            EditTransactionView(viewModel: viewModel, transaction: transaction)
        }
        .alert("Delete Transaction", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let index = viewModel.transactions.firstIndex(where: { $0.id == transaction.id }) {
                    viewModel.transactions.remove(at: index)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this transaction? This action cannot be undone.")
        }
    }
    
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
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
        }
    }
}
