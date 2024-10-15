//
//  ContentView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/11/24.
//
//
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1 // 0: Home, 1: Expenses, 2: Profile
    @State private var isExpanded = false
    @State private var isBlurred = false
    @State private var showAddExpense = false
    @State private var showAddIncome = false
    @State private var showHelp = false
    private let buttons = ["minus", "plus", "questionmark"]
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    VStack {
                        Image(systemName: "house.fill")
                            .foregroundColor(selectedTab == 0 ? .black : .gray)
                        Text("Home")
                    }
                }
                .tag(0)
            
            TransactionsView(isExpanded: $isExpanded, isBlurred: $isBlurred)
                .tabItem {
                    VStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(selectedTab == 1 ? .black : .gray)
                        Text("Transactions")
                    }
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    VStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(selectedTab == 2 ? .black : .gray)
                        Text("Profile")
                    }
                }
                .tag(2)
        }
        .accentColor(.black) // This sets the color for the selected tab text
        .overlay(
            GeometryReader { geometry in
                if selectedTab == 1 { // Only show floating action buttons on Transactions tab
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack {
                                ForEach(buttons.indices, id: \.self) { index in
                                    Button(action: {
                                        handleButtonTap(index)
                                    }) {
                                        Image(systemName: buttons[index])
                                            .frame(width: 44, height: 44)
                                            .background(Color.black)
                                            .foregroundColor(.white)
                                            .clipShape(Circle())
                                    }
                                    .offset(x: isExpanded ? CGFloat(cos(Double(index) * .pi / 4 + .pi)) * 80 : 0,
                                            y: isExpanded ? CGFloat(sin(Double(index) * .pi / 4 + .pi)) * 80 : 0)
                                    .opacity(isExpanded ? 1 : 0)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(index) * 0.05), value: isExpanded)
                                }
                                Button(action: {
                                    withAnimation {
                                        isExpanded.toggle()
                                        isBlurred.toggle()
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .rotationEffect(.degrees(isExpanded ? 45 : 0))
                                        .frame(width: 56, height: 56)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 10)
                                }
                            }
                            .offset(x: -geometry.size.width / 10, y: -15)
                            .padding(.bottom, 60)
                        }
                    }
                }
            }
        )
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView()
        }
        .sheet(isPresented: $showAddIncome) {
            AddIncomeView()
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
    }
    
    private func handleButtonTap(_ index: Int) {
        withAnimation {
            isExpanded = false
            isBlurred = false
        }
        switch index {
        case 0: // Minus button
            showAddExpense = true
        case 1: // Plus button
            showAddIncome = true
        case 2: // Question mark button
            showHelp = true
        default:
            break
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
