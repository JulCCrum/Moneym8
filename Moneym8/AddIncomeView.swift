import SwiftUI

struct AddIncomeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Text("Add Income Form")
                // Add form fields for income entry here
            }
            .navigationTitle("Add Income")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
