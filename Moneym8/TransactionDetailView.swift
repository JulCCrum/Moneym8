//
//  TransactionDetailView.swift
//  Moneym8
//

import SwiftUI

struct TransactionDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    let transaction: Transaction
    
    @State private var amount: String = ""
    @State private var selectedCategory: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var isIncome: Bool = false
    @State private var showingDeleteAlert = false
    @FocusState private var amountIsFocused: Bool
    
    let expenseCategories = ["Rent", "Food", "Transportation", "Other"]
    let incomeCategories = ["Salary", "Investment", "Gift", "Other"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header with X button
            HStack {
                Text("Transaction Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                ZStack {
                    Circle()
                        .fill(.clear)
                        .frame(width: 32, height: 32)
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.gray)
                }
                .onTapGesture {
                    dismiss()
                }
            }
            .padding(.top)
            
            // Icon and Amount
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(categoryColor(for: selectedCategory))
                        .frame(width: 72, height: 72)
                    Text(categoryEmoji(for: selectedCategory))
                        .font(.system(size: 32))
                }
                
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(isIncome ? .green : .red)
                    .multilineTextAlignment(.center)
                    .focused($amountIsFocused)
            }
            .padding(.vertical, 24)
            
            // Details Section
            GroupBox(label: Text("DETAILS").foregroundColor(.gray)) {
                VStack(spacing: 16) {
                    // Type Picker
                    HStack {
                        Text("Type")
                        Spacer()
                        Picker("Type", selection: $isIncome) {
                            Text("Expense").tag(false)
                            Text("Income").tag(true)
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(.horizontal, 8)
                    
                    Divider()
                    
                    // Category Picker
                    HStack {
                        Text("Category")
                        Spacer()
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(isIncome ? incomeCategories : expenseCategories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(.horizontal, 8)
                    
                    Divider()
                    
                    // Date
                    HStack {
                        Text("Date")
                        Spacer()
                        DatePicker("", selection: $date, displayedComponents: [.date])
                            .labelsHidden()
                        DatePicker("", selection: $date, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                    }
                    .padding(.horizontal, 8)
                    
                    Divider()
                    
                    // Note
                    TextField("Add a note", text: $note)
                        .padding(.horizontal, 8)
                }
            }
            .padding(.horizontal)
            
            Spacer(minLength: 20)
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: { saveChanges() }) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Save Transaction")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                
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
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .onAppear {
            amount = String(format: "%.2f", transaction.amount)
            selectedCategory = transaction.category
            date = transaction.date
            note = transaction.note ?? ""
            isIncome = transaction.isIncome
        }
        .alert("Delete Transaction", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.removeTransaction(transaction)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this transaction? This action cannot be undone.")
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    amountIsFocused = false
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }
        
        let updatedTransaction = Transaction(
            id: transaction.id,
            amount: amountValue,
            isIncome: isIncome,
            date: date,
            category: selectedCategory,
            note: note.isEmpty ? nil : note
        )
        
        viewModel.removeTransaction(transaction)
        viewModel.addTransaction(updatedTransaction)
        dismiss()
    }
    
    private func categoryColor(for category: String) -> Color {
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
    
    private func categoryEmoji(for category: String) -> String {
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
