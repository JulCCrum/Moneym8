//
//  TransactionViewModel.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/27/24.
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    private var db = Firestore.firestore()
    
    init() {
        listenToTransactions()
    }
    
    private func listenToTransactions() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("transactions")
            .order(by: "date", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.transactions = documents.compactMap { document in
                    try? document.data(as: Transaction.self)
                }
            }
    }
    
    func addTransaction(_ transaction: Transaction) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            _ = try db.collection("users").document(userId)
                .collection("transactions")
                .addDocument(from: transaction)
        } catch {
            print("Error adding transaction: \(error)")
        }
    }
    
    func removeTransaction(_ transaction: Transaction) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if let transactionId = transaction.id {
            db.collection("users").document(userId)
                .collection("transactions")
                .document(transactionId)
                .delete()
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
        print("Category \(category): \(total)")
        return total
    }
}
