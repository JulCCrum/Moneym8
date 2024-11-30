//
//  Transaction.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/27/24.

import Foundation

struct Transaction: Identifiable, Codable {
    let id: String
    let amount: Double
    let isIncome: Bool
    let date: Date
    let category: String
    var note: String?
    
    // Add computed property for formatting
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
