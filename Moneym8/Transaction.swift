//
//  Transaction.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/27/24.
import Foundation
import FirebaseFirestore

struct Transaction: Identifiable, Codable {
    @DocumentID var id: String?
    let amount: Double
    let isIncome: Bool
    let date: Date
    let category: String
    var note: String?
    
    var formattedAmount: String {
        let prefix = isIncome ? "+" : "-"
        return "\(prefix)$\(String(format: "%.2f", amount))"
    }
    
    init(id: String = UUID().uuidString, amount: Double, isIncome: Bool, date: Date, category: String, note: String? = nil) {
        self.id = id
        self.amount = amount
        self.isIncome = isIncome
        self.date = date
        self.category = category
        self.note = note
    }
}
