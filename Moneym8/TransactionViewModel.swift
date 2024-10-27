//
//  TransactionViewModel.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/27/24.
//
import Foundation

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    // Add a new transaction
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
    }
    
    // Get all expenses
    func getExpenses() -> [Transaction] {
        transactions.filter { !$0.isIncome }
    }
    
    // Get all income
    func getIncome() -> [Transaction] {
        transactions.filter { $0.isIncome }
    }
    
    // Get transactions for a specific category
    func getTransactions(forCategory category: String) -> [Transaction] {
        transactions.filter { $0.category == category }
    }
    
    // Calculate total for a category
    func getCategoryTotal(category: String) -> Double {
        transactions
            .filter { $0.category == category && !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
    }
}
