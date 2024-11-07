import SwiftUI

struct AddExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TransactionViewModel
    @State private var amount: String = ""
    @State private var selectedCategory: String = "Food"
    @State private var date: Date = Date()
    @State private var note: String = ""
    
    let categories = ["Rent", "Food", "Transportation", "Other"]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Form Content
                VStack(alignment: .leading, spacing: 32) {
                    // Amount Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AMOUNT")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        HStack {
                            Text("$")
                                .foregroundColor(.gray)
                            TextField("0", text: $amount)
                                .keyboardType(.decimalPad)
                        }
                        .font(.system(size: 17))
                    }
                    
                    // Category Section
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
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .font(.system(size: 17))
                        }
                    }
                    
                    // Date Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DATE")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .font(.system(size: 17))
                    }
                    
                    // Note Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOTE (OPTIONAL)")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        TextField("Add a note", text: $note)
                            .font(.system(size: 17))
                    }
                }
                .padding(24)
                
                Spacer()
                
                // Bottom Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        saveExpense()
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
                        presentationMode.wrappedValue.dismiss()
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
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.large)
            // Remove the navigation bar buttons since we now have the bottom buttons
            .navigationBarItems(leading: EmptyView(), trailing: EmptyView())
        }
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            return
        }
        
        let transaction = Transaction(
            amount: amountValue,
            isIncome: false,
            date: date,
            category: selectedCategory,
            note: note.isEmpty ? nil : note
        )
        
        viewModel.addTransaction(transaction)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddExpenseView(viewModel: TransactionViewModel())
}
