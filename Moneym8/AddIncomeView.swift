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
    @FocusState private var amountIsFocused: Bool
    @FocusState private var noteIsFocused: Bool
    
    let categories = ["Salary", "Investment", "Gift", "Other"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header with X button
            HStack {
                Text("Add Income")
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
                    .focused($noteIsFocused)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(10)
                    .foregroundColor(.primary)
            }
            
            Spacer(minLength: 20)
            
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
    
    private func saveIncome() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        // Create an ExpenseTransaction instead of Transaction
        let incomeTransaction = ExpenseTransaction(
            amount: amountValue,
            isIncome: true,
            date: date,
            category: selectedCategory,
            note: note.isEmpty ? nil : note
        )
        
        // Add it via the ViewModel
        viewModel.addTransaction(incomeTransaction)
        
        // Dismiss after saving
        dismiss()
    }
}

struct AddIncomeView_Previews: PreviewProvider {
    static var previews: some View {
        AddIncomeView(viewModel: TransactionViewModel())
    }
}
