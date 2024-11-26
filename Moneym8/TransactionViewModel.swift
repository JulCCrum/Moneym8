//
//  TransactionViewModel.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/27/24.
//
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    private let db = Firestore.firestore()
    
    init() {
        loadTransactions()
    }
    
    func addTransaction(_ transaction: Transaction) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Add to local array
        transactions.append(transaction)
        
        // Save to Firebase
        db.collection("users")
            .document(userId)
            .collection("transactions")
            .document(transaction.id)
            .setData([
                "id": transaction.id,
                "amount": transaction.amount,
                "isIncome": transaction.isIncome,
                "date": transaction.date,
                "category": transaction.category,
                "note": transaction.note ?? ""
            ]) { error in
                if let error = error {
                    print("Error saving transaction: \(error.localizedDescription)")
                }
            }
    }
    
    func loadTransactions() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users")
            .document(userId)
            .collection("transactions")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error loading transactions: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self?.transactions = documents.compactMap { doc in
                    let data = doc.data()
                    return Transaction(
                        id: data["id"] as? String ?? UUID().uuidString,
                        amount: data["amount"] as? Double ?? 0.0,
                        isIncome: data["isIncome"] as? Bool ?? false,
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                        category: data["category"] as? String ?? "Other",
                        note: data["note"] as? String
                    )
                }
            }
    }
    
    // Keep your existing helper functions
    func getExpenses() -> [Transaction] {
        transactions.filter { !$0.isIncome }
    }
    
    func getIncome() -> [Transaction] {
        transactions.filter { $0.isIncome }
    }
    
    func getCategoryTotal(category: String) -> Double {
        transactions
            .filter { $0.category == category && !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
    }
}
