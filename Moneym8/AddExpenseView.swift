import SwiftUI
import Foundation

struct AddExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var amount: String = ""
    @State private var selectedCategory: String = "Other"
    @State private var date: Date = Date()
    @State private var note: String = ""
    
    let categories = ["Rent", "Food", "Transportation", "Other"]
    
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
            .navigationTitle("Add Expense")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveExpense()
                }
            )
        }
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            // Show error if amount is invalid
            return
        }
        
        let transaction = Transaction(
            amount: amountValue,
            isIncome: false,
            date: date,
            category: selectedCategory
        )
        
        // Here we'll add code to save the transaction
        // For now, just print it
        print("Saved expense: \(transaction)")
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpenseView()
    }
}
