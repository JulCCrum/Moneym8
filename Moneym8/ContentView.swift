// ContentView.swift
// Moneym8
//
// Created by chase Crummedyo on 10/11/24.
//

import SwiftUI
import FirebaseFirestore
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var transactionViewModel: TransactionViewModel
    @EnvironmentObject private var authManager: AuthManager
    @State private var selectedTab = 0
    @State private var isExpanded = false
    @State private var isBlurred = false
    @State private var showAddExpense = false
    @State private var showAddIncome = false
    @State private var showHelp = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(viewModel: transactionViewModel)
                    .tabItem {
                        VStack {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    }
                    .tag(0)
                
                TransactionsView(isExpanded: $isExpanded, isBlurred: $isBlurred, viewModel: transactionViewModel)
                    .tabItem {
                        VStack {
                            Image(systemName: "dollarsign.circle.fill")
                            Text("Transactions")
                        }
                    }
                    .tag(1)
                
                ProfileView(viewModel: transactionViewModel)
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
            
            // Floating action buttons as an overlay
            Group {
                if selectedTab == 1 {
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
        }
        .sheet(isPresented: $showAddExpense) {
            NavigationView {
                AddExpenseView(viewModel: transactionViewModel)
            }
        }
        .sheet(isPresented: $showAddIncome) {
            NavigationView {
                AddIncomeView(viewModel: transactionViewModel)
            }
        }
        .sheet(isPresented: $showHelp) {
            NavigationView {
                HelpView()
            }
        }
        .sheet(isPresented: $authManager.showAuthentication) {
            NavigationView {
                AuthenticationView()
            }
        }
        .sheet(isPresented: $transactionViewModel.showAccountCreationReminder) {
            AccountCreationReminderView(isPresented: $transactionViewModel.showAccountCreationReminder)
                .environmentObject(authManager)
        }
    }
    
    func handleButtonTap(_ index: Int) {
        withAnimation {
            isExpanded = false
            isBlurred = false
        }
        switch index {
        case 0:
            // First button (sparkles) is now handled directly in FloatingActionButtons
            break
        case 1:
            showAddIncome = true
        case 2:
            showHelp = true
        default:
            break
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TransactionViewModel(modelContext: try! ModelContainer(for: Schema([
            ExpenseTransaction.self,
            RecurringTransaction.self,
            Item.self
        ])).mainContext))
        .environmentObject(AuthManager.shared)
}
