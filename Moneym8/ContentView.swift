//
//  ContentView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/11/24.
//
//
import SwiftUI

struct ContentView: View {
    @StateObject private var transactionViewModel = TransactionViewModel()
    @State private var selectedTab = 1
    @State private var isExpanded = false
    @State private var isBlurred = false
    @State private var showAddExpense = false
    @State private var showAddIncome = false
    @State private var showHelp = false
    
    var body: some View {
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
            
            ProfileView()
                .tabItem {
                    VStack {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                }
                .tag(2)
        }
        .overlay(
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
        )
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView(viewModel: transactionViewModel)
        }
        .sheet(isPresented: $showAddIncome) {
            AddIncomeView(viewModel: transactionViewModel)
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
        .accentColor(.black)
    }
    
    private func handleButtonTap(_ index: Int) {
        withAnimation {
            isExpanded = false
            isBlurred = false
        }
        switch index {
        case 0: showAddExpense = true
        case 1: showAddIncome = true
        case 2: showHelp = true
        default: break
        }
    }
}

#Preview {
    ContentView()
}
