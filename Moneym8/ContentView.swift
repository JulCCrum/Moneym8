//
//  ContentView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/11/24.
//

import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @StateObject private var transactionViewModel = TransactionViewModel()

    @State private var selectedTab = 0  // Changed from 1 to 0
    @State private var isExpanded = false
    @State private var isBlurred = false
    @State private var showAddExpense = false
    @State private var showAddIncome = false
    @State private var showHelp = false

    @AppStorage("isDarkMode") private var isDarkMode = false

    // The Binding from SceneDelegate that indicates when to show AddExpenseView
    @Binding var showAddTransaction: Bool

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                HomeView(viewModel: transactionViewModel)
                    .tabItem {
                        VStack {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    }
                    .tag(0)
                
                TransactionsView(isExpanded: $isExpanded,
                                 isBlurred: $isBlurred,
                                 viewModel: transactionViewModel)
                .tabItem {
                    VStack {
                        Image(systemName: "dollarsign.circle.fill")
                        Text("Transactions")
                    }
                }
                .tag(1)
                
                ProfileView()
                    .tabItem {
                        VStack {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                    }
                    .tag(2)
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .tint(isDarkMode ? .white : .black)
        }
        .overlay(
            Group {
                if selectedTab == 1 {
                    // If user is on the Transactions tab, show floating buttons
                    FloatingActionButtons(
                        isExpanded: isExpanded,
                        isBlurred: isBlurred,
                        handleButtonTap: handleButtonTap,
                        toggleExpanded: {
                            withAnimation {
                                isExpanded.toggle()
                                isBlurred.toggle()
                            }
                        }
                    )
                }
            }
        )
        // The "Add Expense" sheet
        .sheet(isPresented: $showAddExpense) {
            NavigationView {
                AddExpenseView(viewModel: transactionViewModel)
            }
        }
        // The "Add Income" sheet
        .sheet(isPresented: $showAddIncome) {
            NavigationView {
                AddIncomeView(viewModel: transactionViewModel)
            }
        }
        // The "Help" sheet
        .sheet(isPresented: $showHelp) {
            NavigationView {
                HelpView()
            }
        }
        // Whenever showAddTransaction flips to true, showAddExpense = true
        .onChange(of: showAddTransaction) { oldVal, newVal in
            print("DEBUG: ContentView showAddTransaction changed to \(newVal)")
            if newVal {
                showAddExpense = true
                // reset after showing
                showAddTransaction = false
            }
        }
    }
    
    private func handleButtonTap(_ index: Int) {
        withAnimation {
            isExpanded = false
            isBlurred = false
        }
        switch index {
        case 0:
            showAddExpense = true
        case 1:
            showAddIncome = true
        case 2:
            showHelp = true
        default:
            break
        }
    }
}

// For SwiftUI previews
#Preview {
    ContentView(showAddTransaction: .constant(false))
}
