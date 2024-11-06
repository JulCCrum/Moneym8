//
//  EditTransactionView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/5/24.
//
import SwiftUI

struct EditTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    let transaction: Transaction
    
    @State private var amount: String = ""
    @State private var category: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Amount")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Category")) {
                    TextField("Category", text: $category)
                }
                
                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $date)
                }
                
                Section(header: Text("Note")) {
                    TextField("Add a note", text: $note)
                }
            }
            .navigationTitle("Edit Transaction")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    saveChanges()
                }
            )
            .onAppear {
                // Initialize form with existing transaction data
                amount = String(transaction.amount)
                category = transaction.category
                date = transaction.date
                note = transaction.note ?? ""
            }
        }
    }
    
    private func saveChanges() {
        guard let newAmount = Double(amount) else { return }
        
        let updatedTransaction = Transaction(
            id: transaction.id,
            amount: newAmount,
            isIncome: transaction.isIncome,
            date: date,
            category: category,
            note: note.isEmpty ? nil : note
        )
        
        if let index = viewModel.transactions.firstIndex(where: { $0.id == transaction.id }) {
            viewModel.transactions[index] = updatedTransaction
        }
        
        dismiss()
    }
}
