//
//  TransactionViewModel.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/27/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ExpenseTransaction: Codable, Identifiable {
    @DocumentID var id: String?     // Firestore document ID
    var amount: Double
    var isIncome: Bool
    var date: Date
    var category: String
    var note: String?
}

enum RecurringFrequency: String, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

struct RecurringTransaction: Codable, Identifiable {
    @DocumentID var id: String?
    var amount: Double
    var isIncome: Bool
    var startDate: Date
    var category: String
    var frequency: RecurringFrequency
    var note: String?
}

class TransactionViewModel: ObservableObject {
    @Published var transactions: [ExpenseTransaction] = []
    @Published var recurringTransactions: [RecurringTransaction] = []
    @Published var categoryBudgets: [String: Double] = [:]
    @Published var activeCategories: Set<String>
    @Published var totalBudget: Double = UserDefaults.standard.double(forKey: "totalBudget")

    // Add a method to update the budget
    func updateTotalBudget(_ newValue: Double) {
        totalBudget = newValue
        UserDefaults.standard.set(newValue, forKey: "totalBudget")
    }
    
    private var db = Firestore.firestore()
    private let initialCategories = ["Rent", "Food", "Transportation", "Other"]
    private let maxCategories = 5
    
    var categories: [String] {
        Array(activeCategories).sorted()
    }
    
    init() {
        // Initialize with default categories
        if let savedCategories = UserDefaults.standard.array(forKey: "activeCategories") as? [String] {
            activeCategories = Set(savedCategories)
        } else {
            activeCategories = Set(initialCategories)
            UserDefaults.standard.set(initialCategories, forKey: "activeCategories")
        }
        
        loadSavedBudgets()
        listenToTransactions()
        listenToRecurringTransactions()
    }
    
    private func loadSavedBudgets() {
        // Load all saved budgets for active categories
        for category in activeCategories {
            if let savedBudget = UserDefaults.standard.object(forKey: "budget_\(category)") as? Double {
                categoryBudgets[category] = savedBudget
            } else {
                categoryBudgets[category] = 0 // Default budget of 0 for new categories
            }
        }
    }
    
    func addCategory(_ category: String) -> Bool {
        guard activeCategories.count < maxCategories else { return false }
        activeCategories.insert(category)
        categoryBudgets[category] = 0
        saveCategoryChanges()
        return true
    }
    
    func removeCategory(_ category: String) {
        activeCategories.remove(category)
        categoryBudgets.removeValue(forKey: category)
        saveCategoryChanges()
    }
    
    private func saveCategoryChanges() {
        UserDefaults.standard.set(Array(activeCategories), forKey: "activeCategories")
    }
    
    private func listenToTransactions() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId)
            .collection("transactions")
            .order(by: "date", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.transactions = documents.compactMap { doc in
                    try? doc.data(as: ExpenseTransaction.self)
                }
            }
    }
    
    private func listenToRecurringTransactions() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId)
            .collection("recurring_transactions")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching recurring transactions: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.recurringTransactions = documents.compactMap { doc in
                    try? doc.data(as: RecurringTransaction.self)
                }
            }
    }
    
    func addTransaction(_ transaction: ExpenseTransaction) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            _ = try db.collection("users").document(userId)
                .collection("transactions")
                .addDocument(from: transaction)
        } catch {
            print("Error adding transaction: \(error)")
        }
    }
    
    func addRecurringTransaction(_ transaction: RecurringTransaction) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            _ = try db.collection("users").document(userId)
                .collection("recurring_transactions")
                .addDocument(from: transaction)
        } catch {
            print("Error adding recurring transaction: \(error)")
        }
    }
    
    func removeTransaction(_ transaction: ExpenseTransaction) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if let transactionId = transaction.id {
            db.collection("users").document(userId)
                .collection("transactions")
                .document(transactionId)
                .delete()
        }
    }
    
    func removeRecurringTransaction(_ transaction: RecurringTransaction) {
        guard let userId = Auth.auth().currentUser?.uid,
              let transactionId = transaction.id else { return }
        
        db.collection("users").document(userId)
            .collection("recurring_transactions")
            .document(transactionId)
            .delete()
    }
    
    func getExpenses() -> [ExpenseTransaction] {
        transactions.filter { !$0.isIncome }
    }
    
    func getIncome() -> [ExpenseTransaction] {
        transactions.filter { $0.isIncome }
    }
    
    func getTransactions(forCategory category: String) -> [ExpenseTransaction] {
        transactions.filter { $0.category == category }
    }
    
    func getCategoryTotal(category: String) -> Double {
        let total = transactions
            .filter { $0.category == category && !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
        
        print("Category \(category): \(total)")
        return total
    }
    
    var averageMonthlySpending: Double {
        let calendar = Calendar.current
        guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) else { return 0 }
        
        let monthlyTotals = transactions
            .filter { !$0.isIncome }
            .filter { $0.date >= oneMonthAgo }
            .reduce(0) { $0 + $1.amount }
        
        return monthlyTotals
    }
    
    var averageMonthlyIncome: Double {
        let calendar = Calendar.current
        guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) else { return 0 }
        
        let monthlyTotals = transactions
            .filter { $0.isIncome }
            .filter { $0.date >= oneMonthAgo }
            .reduce(0) { $0 + $1.amount }
        
        return monthlyTotals
    }
    
    func budget(for category: String) -> Double {
        categoryBudgets[category] ?? 0
    }
    
    func monthlySpending(for category: String) -> Double {
        let calendar = Calendar.current
        guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) else { return 0 }
        
        return transactions
            .filter { !$0.isIncome && $0.category == category }
            .filter { $0.date >= oneMonthAgo }
            .reduce(0) { $0 + $1.amount }
    }
    
    func setBudget(for category: String, amount: Double) {
        categoryBudgets[category] = amount
        UserDefaults.standard.set(amount, forKey: "budget_\(category)")
    }
}
