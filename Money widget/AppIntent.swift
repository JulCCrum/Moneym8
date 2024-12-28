//
//  AppIntent.swift
//  Money widget
//
//  Created by chase Crummedyo on 12/16/24.
//

import AppIntents
import WidgetKit

struct AddTransactionIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Transaction"
    static var description = IntentDescription("Add a new transaction")

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
