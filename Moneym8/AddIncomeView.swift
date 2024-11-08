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
        VStack(alignment: .leading, spacing: 32) {
            // Amount Section
            VStack(alignment: .leading, spacing: 4) {
                Text("AMOUNT")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
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
                    .background(Color.white)
                    .cornerRadius(10)
                }
            }
            
            // Date Section
            VStack(alignment: .leading, spacing: 4) {
                Text("DATE")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                HStack {
                    DatePicker("", selection: $date, displayedComponents: [.date])
                        .labelsHidden()
                    DatePicker("", selection: $date, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            }
            
            // Note Section
            VStack(alignment: .leading, spacing: 4) {
                Text("NOTE (OPTIONAL)")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                TextField("Add a note", text: $note)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: {
                    saveIncome()
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Save Transaction")
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
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
            }
        }
        .padding(24)
        .background(Color(uiColor: .systemGray6))
        .navigationTitle("Add Income")
        .navigationBarItems(leading: EmptyView(), trailing: EmptyView())
    }
    
    private func saveIncome() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            return
        }
        
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

#Preview {
    AddIncomeView(viewModel: TransactionViewModel())
}
