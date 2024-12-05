//
//  AddIncomeView.swift
//  Moneym8
//

import SwiftUI

struct AddIncomeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    @State private var amount: String = ""
    @State private var selectedCategory: String = "Salary"
    @State private var date: Date = Date()
    @State private var note: String = ""
    
    let categories = ["Salary", "Investment", "Gift", "Other"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 24) {
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
                                Button(action: { selectedCategory = category }) {
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
                            DatePicker("", selection: $date, displayedComponents: [.date])
                                .labelsHidden()
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
                            .padding()
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(10)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 12) {
                        Button(action: { saveIncome() }) {
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
            }
            .navigationTitle("Add Income")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func saveIncome() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        let transaction = Transaction(
            amount: amountValue,
            isIncome: true,
            date: date,
            category: selectedCategory,
            note: note.isEmpty ? nil : note
        )
        
        viewModel.addTransaction(transaction)
        dismiss()
    }
}
