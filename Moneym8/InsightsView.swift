//
//  InsightsView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/8/24.

import SwiftUI

struct InsightsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TransactionViewModel
    @State private var editingBudgets: [String: String] = [:]
    @State private var showAddCategory = false
    @State private var showMaxCategoriesAlert = false
    @State private var newCategoryName = ""
    @FocusState private var focusedField: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: -15) {
            // Header
            HStack {
                Text("Insights")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
            
            List {
                Section(header: Text("SPENDING OVERVIEW")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    HStack {
                        Text("Average Monthly Spending")
                            .font(.body)
                        Spacer()
                        Text(viewModel.averageMonthlySpending.formatted(.currency(code: "USD")))
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        Text("Average Monthly Income")
                            .font(.body)
                        Spacer()
                        Text(viewModel.averageMonthlyIncome.formatted(.currency(code: "USD")))
                            .foregroundColor(.green)
                    }
                }
                
                Section(header: HStack {
                    Text("MONTHLY BUDGETS")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                    Spacer()
                    if viewModel.activeCategories.count < 5 {
                        Button(action: {
                            showAddCategory = true
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                        }
                    }
                }) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        HStack {
                            Circle()
                                .fill(getCategoryColor(category))
                                .frame(width: 8, height: 8)
                            Text(category)
                                .font(.body)
                            Spacer()
                            VStack(alignment: .trailing) {
                                HStack {
                                    Text("$")
                                    TextField("Budget",
                                            text: budgetBinding(for: category),
                                            onEditingChanged: { editing in
                                                if !editing {
                                                    saveBudget(for: category)
                                                }
                                            })
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .focused($focusedField, equals: category)
                                        .frame(width: 80)
                                }
                                .foregroundColor(.gray)
                                Text("\(viewModel.monthlySpending(for: category).formatted(.currency(code: "USD"))) spent")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                ProgressView(value: min(viewModel.monthlySpending(for: category) / max(viewModel.budget(for: category), 1), 1))
                                    .tint(viewModel.monthlySpending(for: category) > viewModel.budget(for: category) ? .red : .green)
                                    .frame(width: 100)
                            }
                            
                            Button(action: {
                                viewModel.removeCategory(category)
                            }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .onAppear {
            // Initialize editing budgets with current values
            for category in viewModel.categories {
                editingBudgets[category] = String(format: "%.0f", viewModel.budget(for: category))
            }
        }
        .alert("Add Category", isPresented: $showAddCategory) {
            TextField("Category Name", text: $newCategoryName)
            Button("Cancel", role: .cancel) {
                newCategoryName = ""
            }
            Button("Add") {
                if !newCategoryName.isEmpty {
                    if viewModel.addCategory(newCategoryName) {
                        newCategoryName = ""
                    } else {
                        showMaxCategoriesAlert = true
                    }
                }
            }
        } message: {
            Text("Enter a name for the new category")
        }
        .alert("Maximum Categories Reached", isPresented: $showMaxCategoriesAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You can have a maximum of 5 categories. Please remove a category before adding a new one.")
        }
    }
    
    private func budgetBinding(for category: String) -> Binding<String> {
        Binding(
            get: { editingBudgets[category] ?? "" },
            set: { editingBudgets[category] = $0 }
        )
    }
    
    private func saveBudget(for category: String) {
        if let budgetString = editingBudgets[category],
           let budget = Double(budgetString) {
            viewModel.setBudget(for: category, amount: budget)
        }
    }
}

private func getCategoryColor(_ category: String) -> Color {
    switch category {
    case "Rent": return .blue
    case "Food": return .green
    case "Transportation": return .orange
    case "Other": return .purple
    default: return .gray
    }
}

#Preview {
    InsightsView(viewModel: TransactionViewModel())
}
