//
//  TransactionViewModel.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/27/24.
//
//
//
//
//  TransactionViewModel.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/27/24.
//

import Foundation
import SwiftUI

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    init() {
        // First try to load saved transactions
        loadTransactions()
        
        // If no saved transactions exist, add initial test data
        if transactions.isEmpty {
            transactions = [
                Transaction(amount: 500, isIncome: false, date: Date(), category: "Rent"),
                Transaction(amount: 300, isIncome: false, date: Date(), category: "Food"),
                Transaction(amount: 150, isIncome: false, date: Date(), category: "Transportation"),
                Transaction(amount: 200, isIncome: false, date: Date(), category: "Other")
            ]
            saveTransactions() // Save the initial data
        }
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        objectWillChange.send()
        saveTransactions()
    }
    
    private func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: "SavedTransactions")
        }
    }
    
    private func loadTransactions() {
        if let savedTransactions = UserDefaults.standard.data(forKey: "SavedTransactions"),
           let decodedTransactions = try? JSONDecoder().decode([Transaction].self, from: savedTransactions) {
            transactions = decodedTransactions
        }
    }
    
    func getExpenses() -> [Transaction] {
        transactions.filter { !$0.isIncome }
    }
    
    func getIncome() -> [Transaction] {
        transactions.filter { $0.isIncome }
    }
    
    func getTransactions(forCategory category: String) -> [Transaction] {
        transactions.filter { $0.category == category }
    }
    
    func getCategoryTotal(category: String) -> Double {
        let total = transactions
            .filter { $0.category == category && !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
        print("Category \(category): \(total)") // Debug print
        return total
    }
    
    func removeTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions.remove(at: index)
            saveTransactions()
        }
    }
}
