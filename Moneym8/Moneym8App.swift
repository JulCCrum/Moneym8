//
//  Moneym8App.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/11/24.
//

import SwiftUI
import SwiftData

@main
struct Moneym8App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView() // Set HomeView as the initial view instead of ContentView
        }
        .modelContainer(sharedModelContainer)
    }
}
