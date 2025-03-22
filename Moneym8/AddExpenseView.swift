// AddExpenseView.swift
// Moneym8
//
// Created by chase Crummedyo on [Date]

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var amount: String = ""
    @State private var category: String = "Other"
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header with title and close button
            HStack {
                Text("Add Expense")
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
            
            // Amount field
            VStack(alignment: .leading, spacing: 8) {
                Text("AMOUNT")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                HStack {
                    Text("$")
                        .foregroundColor(.gray)
                    TextField("0", text: $amount)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.primary)
                }
                .font(.system(size: 24))
            }
            
            // Display work cost calculation if feature is enabled
            if viewModel.showWageCost {
                if let amountValue = Double(amount), amountValue > 0 {
                    HStack {
                        Image(systemName: "clock")
                        Text("\(viewModel.getWorkHoursCostFormatted(for: amountValue, at: date)) of work")
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                }
            }
            
            // Category picker
            VStack(alignment: .leading, spacing: 8) {
                Text("CATEGORY")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                Menu {
                    ForEach(viewModel.categories, id: \.self) { category in
                        Button(action: { self.category = category }) {
                            HStack {
                                Circle()
                                    .fill(getCategoryColor(category))
                                    .frame(width: 8, height: 8)
                                Text(category)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Circle()
                            .fill(getCategoryColor(category))
                            .frame(width: 8, height: 8)
                        Text(category)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Date picker
            VStack(alignment: .leading, spacing: 8) {
                Text("DATE")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(10)
            }
            
            // Note field
            VStack(alignment: .leading, spacing: 8) {
                Text("NOTE (OPTIONAL)")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                TextField("Add a note", text: $note)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(10)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Save & Cancel buttons
            VStack(spacing: 12) {
                Button(action: { saveExpense() }) {
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
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { dismiss() }) {
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
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            errorMessage = "Please enter a valid amount."
            showError = true
            return
        }
        
        let transaction = ExpenseTransaction(
            amount: amountValue,
            isIncome: false,
            date: date,
            category: category,
            note: note.isEmpty ? nil : note
        )
        viewModel.addTransaction(transaction)
        dismiss()
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category {
        case "Rent": return .blue
        case "Food": return .green
        case "Transportation": return .orange
        case "Other": return .purple
        default: return .gray
        }
    }
}

#Preview {
    AddExpenseView(viewModel: TransactionViewModel())
}
