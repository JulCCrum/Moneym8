//
//  Transaction.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/27/24.
//

import Foundation

struct Transaction: Identifiable {
    let id = UUID()
    let amount: Double
    let isIncome: Bool
    let date: Date
    let category: String
    
    init(amount: Double, isIncome: Bool, date: Date, category: String) {
        self.amount = amount
        self.isIncome = isIncome
        self.date = date
        self.category = category
    }
    
    var signedAmount: Double {
        isIncome ? amount : -amount
    }
}
