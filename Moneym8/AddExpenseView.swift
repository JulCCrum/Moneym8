//
//  AddExpenseView.swift
//  Moneym8
//
//  Created by chase Crummedyo on some date
//

import SwiftUI
import FirebaseFirestore

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    
    /// Your observable ViewModel; must be a class conforming to ObservableObject.
    @ObservedObject var viewModel: TransactionViewModel
    
    @State private var amount: String = ""
    @State private var selectedCategory: String = "Food"
    @State private var date: Date = Date()
    @State private var note: String = ""
    @FocusState private var amountIsFocused: Bool
    @FocusState private var noteIsFocused: Bool
    
    /// Example categories for the picker/menu
    let categories = ["Rent", "Food", "Transportation", "Other"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // Header
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
            
            // AMOUNT
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
                        .focused($amountIsFocused)
                }
                .font(.system(size: 24))
            }
            
            // CATEGORY
            VStack(alignment: .leading, spacing: 8) {
                Text("CATEGORY")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                
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
            
            // DATE
            VStack(alignment: .leading, spacing: 8) {
                Text("DATE")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                
                HStack {
                    // DatePicker for the date
                    DatePicker("", selection: $date, displayedComponents: [.date])
                        .labelsHidden()
                    
                    // DatePicker for the time
                    DatePicker("", selection: $date, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                }
                .padding(8)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(10)
            }
            
            // NOTE
            VStack(alignment: .leading, spacing: 8) {
                Text("NOTE (OPTIONAL)")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                
                TextField("Add a note", text: $note)
                    .focused($noteIsFocused)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(10)
                    .foregroundColor(.primary)
            }
            
            Spacer(minLength: 20)
            
            // Buttons
            VStack(spacing: 12) {
                // Save button
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
                
                // Cancel button
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
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    amountIsFocused = false
                    noteIsFocused = false
                }
            }
        }
    }
    
    /// Called when user taps "Save Transaction"
    private func saveExpense() {
        // Ensure a valid numeric amount
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        // Create your ExpenseTransaction instance
        let expenseTransaction = ExpenseTransaction(
            amount: amountValue,
            isIncome: false,
            date: date,
            category: selectedCategory,
            note: note.isEmpty ? nil : note
        )
        
        // Call the ViewModel to add the transaction to Firestore
        viewModel.addTransaction(expenseTransaction)
        
        // Dismiss the sheet
        dismiss()
    }
}

// MARK: - Preview

struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a mock or real TransactionViewModel here
        AddExpenseView(viewModel: TransactionViewModel())
    }
}
