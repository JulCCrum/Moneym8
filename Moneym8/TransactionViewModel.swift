//
//  TransactionViewModel.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/27/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

/// Your custom struct that was previously named 'Transaction'.
/// Renamed to avoid collision with Firestore.Transaction.
struct ExpenseTransaction: Codable, Identifiable {
    @DocumentID var id: String?     // Firestore document ID
    var amount: Double
    var isIncome: Bool
    var date: Date
    var category: String
    var note: String?
}

class TransactionViewModel: ObservableObject {
    // Now we store an array of ExpenseTransaction (not Transaction)
    @Published var transactions: [ExpenseTransaction] = []
    
    private var db = Firestore.firestore()
    
    init() {
        listenToTransactions()
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
                
                // Decode each document into an ExpenseTransaction
                self.transactions = documents.compactMap { doc in
                    try? doc.data(as: ExpenseTransaction.self)
                }
            }
    }
    
    /// Add a new ExpenseTransaction to Firestore.
    func addTransaction(_ transaction: ExpenseTransaction) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            // 'addDocument(from:)' uses Codable to encode your ExpenseTransaction
            _ = try db.collection("users").document(userId)
                .collection("transactions")
                .addDocument(from: transaction)
        } catch {
            print("Error adding transaction: \(error)")
        }
    }
    
    /// Delete a transaction from Firestore if it has a valid document ID.
    func removeTransaction(_ transaction: ExpenseTransaction) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if let transactionId = transaction.id {
            db.collection("users").document(userId)
                .collection("transactions")
                .document(transactionId)
                .delete()
        }
    }
    
    /// Returns only the transactions where isIncome == false.
    func getExpenses() -> [ExpenseTransaction] {
        transactions.filter { !$0.isIncome }
    }
    
    /// Returns only the transactions where isIncome == true.
    func getIncome() -> [ExpenseTransaction] {
        transactions.filter { $0.isIncome }
    }
    
    /// Returns all transactions matching the given category.
    func getTransactions(forCategory category: String) -> [ExpenseTransaction] {
        transactions.filter { $0.category == category }
    }
    
    /// Returns the total spent in a specific category (only counting expenses).
    func getCategoryTotal(category: String) -> Double {
        let total = transactions
            .filter { $0.category == category && !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
        
        print("Category \(category): \(total)")
        return total
    }
}
