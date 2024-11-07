import SwiftUI

struct AddIncomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TransactionViewModel
    @State private var amount: String = ""
    @State private var selectedCategory: String = "Salary"
    @State private var date: Date = Date()
    @State private var note: String = ""
    
    let categories = ["Salary", "Investment", "Gift", "Other"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Amount Section
            VStack(alignment: .leading, spacing: 4) {
                Text("AMOUNT")
                    .font(.caption)
                    .foregroundColor(.gray)
                HStack {
                    Text("$")
                        .foregroundColor(.gray)
                    TextField("0", text: $amount)
                        .keyboardType(.decimalPad)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            }
            
            // Category Section
            VStack(alignment: .leading, spacing: 4) {
                Text("CATEGORY")
                    .font(.caption)
                    .foregroundColor(.gray)
                HStack {
                    Text(selectedCategory)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .onTapGesture {
                    // Show category picker
                }
            }
            
            // Date Section
            VStack(alignment: .leading, spacing: 4) {
                Text("DATE")
                    .font(.caption)
                    .foregroundColor(.gray)
                DatePicker("", selection: $date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .labelsHidden()
            }
            
            // Note Section
            VStack(alignment: .leading, spacing: 4) {
                Text("NOTE (OPTIONAL)")
                    .font(.caption)
                    .foregroundColor(.gray)
                TextField("Add a note", text: $note)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(uiColor: .systemGray6))
        .navigationTitle("Add Income")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
            leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("Save") {
                saveIncome()
            }
        )
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
        presentationMode.wrappedValue.dismiss()
    }
}
