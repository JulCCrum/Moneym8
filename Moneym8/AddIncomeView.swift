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
    @State private var isIncome: Bool = true
    @State private var isRecurring: Bool = false
    @State private var recurringFrequency: RecurringFrequency = .monthly
    @FocusState private var amountIsFocused: Bool
    @FocusState private var noteIsFocused: Bool
    
    let expenseCategories = ["Rent", "Food", "Transportation", "Other"]
    let incomeCategories = ["Salary", "Investment", "Gift", "Other"]
    
    var categories: [String] {
        isIncome ? incomeCategories : expenseCategories
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Add Transaction")
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
            
            // Transaction Type
            VStack(alignment: .leading, spacing: 8) {
                Text("TYPE")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                
                Picker("Transaction Type", selection: $isIncome) {
                    Text("Expense").tag(false)
                    Text("Income").tag(true)
                }
                .pickerStyle(.segmented)
                .onChange(of: isIncome) { oldValue, newValue in
                    selectedCategory = categories[0]
                }
            }
            
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
            
            // Recurring Option
            VStack(alignment: .leading, spacing: 8) {
                Toggle("RECURRING", isOn: $isRecurring)
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                
                if isRecurring {
                    Picker("Frequency", selection: $recurringFrequency) {
                        Text("Daily").tag(RecurringFrequency.daily)
                        Text("Weekly").tag(RecurringFrequency.weekly)
                        Text("Monthly").tag(RecurringFrequency.monthly)
                        Text("Yearly").tag(RecurringFrequency.yearly)
                    }
                    .pickerStyle(.segmented)
                }
            }
            
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
        
        if isRecurring {
            let recurringTransaction = RecurringTransaction(
                amount: amountValue,
                isIncome: isIncome,
                startDate: date,
                category: selectedCategory,
                frequency: recurringFrequency,
                note: note.isEmpty ? nil : note
            )
            viewModel.addRecurringTransaction(recurringTransaction)
        } else {
            let transaction = ExpenseTransaction(
                amount: amountValue,
                isIncome: isIncome,
                date: date,
                category: selectedCategory,
                note: note.isEmpty ? nil : note
            )
            viewModel.addTransaction(transaction)
        }
        
        dismiss()
    }
}

struct AddIncomeView_Previews: PreviewProvider {
    static var previews: some View {
        AddIncomeView(viewModel: TransactionViewModel())
    }
}
