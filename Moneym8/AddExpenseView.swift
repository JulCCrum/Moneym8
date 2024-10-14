import SwiftUI

struct AddExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Text("Add Expense Form")
                // Add form fields for expense entry here
            }
            .navigationTitle("Add Expense")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
