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
    
    // Editing states
    @State private var amount: String = ""
    @State private var selectedCategory: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var isIncome: Bool = false
    
    let expenseCategories = ["Rent", "Food", "Transportation", "Other"]
    let incomeCategories = ["Salary", "Investment", "Gift", "Other"]
    
    var categories: [String] {
        isEditing ? (isIncome ? incomeCategories : expenseCategories) : []
    }
    
    private var displayAmount: String {
        if isEditing {
            let amountValue = Double(amount) ?? 0
            return isIncome ?
                "+$\(String(format: "%.2f", amountValue))" :
                "$\(String(format: "%.2f", amountValue))"
        } else {
            return transaction.formattedAmount
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Transaction Details")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                        .font(.title2)
                }
            }
            .padding()
            
            // Icon and Amount
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 72, height: 72)
                    if isEditing {
                        Text("?")
                            .font(.system(size: 32))
                            .foregroundColor(.red)
                    } else {
                        Text(categoryEmoji)
                            .font(.system(size: 32))
                    }
                }
                
                if isEditing {
                    Text(displayAmount)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(isIncome ? .green : .red)
                        .onTapGesture {
                            // Add tap gesture if needed
                        }
                } else {
                    Text(displayAmount)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(transaction.isIncome ? .green : .red)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            
            // Details
            VStack(alignment: .leading, spacing: 32) {
                // Type (Moved to top of details)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Type")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    if isEditing {
                        Menu {
                            Button(action: {
                                isIncome = true
                                selectedCategory = "Salary" // Default income category
                            }) {
                                Text("Income")
                            }
                            Button(action: {
                                isIncome = false
                                selectedCategory = "Food" // Default expense category
                            }) {
                                Text("Expense")
                            }
                        } label: {
                            HStack {
                                Text(isIncome ? "Income" : "Expense")
                                    .font(.body)
                                    .foregroundColor(.blue)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        Text(transaction.isIncome ? "Income" : "Expense")
                            .font(.body)
                    }
                }
                
                // Category
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    if isEditing {
                        Menu {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedCategory)
                                    .font(.body)
                                    .foregroundColor(.blue)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        Text(transaction.category)
                            .font(.body)
                    }
                }
                
                // Date
                VStack(alignment: .leading, spacing: 4) {
                    Text("Date")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    if isEditing {
                        DatePicker("", selection: $date, displayedComponents: [.date])
                            .labelsHidden()
                    } else {
                        Text(formatDate(transaction.date))
                            .font(.body)
                    }
                }
                
                // Time
                VStack(alignment: .leading, spacing: 4) {
                    Text("Time")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    if isEditing {
                        DatePicker("", selection: $date, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                    } else {
                        Text(formatTime(transaction.date))
                            .font(.body)
                    }
                }
                
                // Note
                VStack(alignment: .leading, spacing: 4) {
                    Text("Note")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    if isEditing {
                        TextField("Add a note", text: $note)
                            .font(.body)
                    } else if let transactionNote = transaction.note {
                        Text(transactionNote)
                            .font(.body)
                    } else {
                        Text("Add a note")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Bottom Buttons
            VStack(spacing: 12) {
                if isEditing {
                    Button(action: {
                        saveChanges()
                        isEditing = false
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Save Transaction")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        isEditing = false
                        resetToOriginalValues()
                    }) {
                        HStack {
                            Image(systemName: "xmark")
                            Text("Cancel")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    }
                } else {
                    Button(action: {
                        isEditing = true
                        resetToOriginalValues()
                    }) {
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
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color(uiColor: .systemGray6))
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
    
    private func resetToOriginalValues() {
        amount = String(format: "%.2f", transaction.amount)
        selectedCategory = transaction.category
        date = transaction.date
        note = transaction.note ?? ""
        isIncome = transaction.isIncome
    }
    
    private func saveChanges() {
        guard let newAmount = Double(amount) else { return }
        
        let updatedTransaction = Transaction(
            id: transaction.id,
            amount: newAmount,
            isIncome: isIncome,
            date: date,
            category: selectedCategory,
            note: note.isEmpty ? nil : note
        )
        
        if let index = viewModel.transactions.firstIndex(where: { $0.id == transaction.id }) {
            viewModel.transactions[index] = updatedTransaction
        }
    }
    
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
    
    private var categoryColor: Color {
        let category = isEditing ? selectedCategory : transaction.category
        switch category {
        case "Rent": return .blue
        case "Food": return .green
        case "Transportation": return .orange
        case "Other": return .purple
        default: return .gray
        }
    }
    
    private var categoryEmoji: String {
        let category = isEditing ? selectedCategory : transaction.category
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
