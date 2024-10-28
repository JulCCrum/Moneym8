import SwiftUI
import Foundation

struct AddIncomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TransactionViewModel
    
    @State private var amount: String = ""
    @State private var selectedCategory: String = "Salary"
    @State private var date: Date = Date()
    @State private var note: String = ""
    
    let categories = ["Salary", "Investment", "Gift", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                // Amount Section
                Section(header: Text("Amount")) {
                    TextField("$", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                // Category Section
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                // Date Section
                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                // Note Section
                Section(header: Text("Note (Optional)")) {
                    TextField("Add a note", text: $note)
                }
            }
            .navigationTitle("Add Income")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveIncome()
                }
            )
        }
    }
    
    private func saveIncome() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            return
        }
        
        let transaction = Transaction(
            amount: amountValue,
            isIncome: true,
            date: date,
            category: selectedCategory
        )
        
        viewModel.addTransaction(transaction)
        print("Saved income: \(transaction)")
        
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddIncomeView(viewModel: TransactionViewModel())
}
