//
//  ContentView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/11/24.
//
//
import SwiftUI

struct ContentView: View {
    @State private var isExpanded = false
    @State private var isBlurred = false
    @State private var showAddExpense = false
    @State private var showAddIncome = false
    @State private var showHelp = false
    private let buttons = ["minus", "plus", "questionmark"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    HStack {
                        Text("Expenses")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                        Spacer()
                    }
                    Spacer()
                    
                    // Bottom navigation
                    HStack(spacing: 80) {
                        VStack {
                            Image(systemName: "house.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Home")
                                .font(.caption)
                        }
                        VStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Expenses")
                                .font(.caption)
                        }
                        VStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Profile")
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
                .blur(radius: isBlurred ? 10 : 0)
                
                // Floating action buttons
                VStack {
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
                            .offset(x: isExpanded ? CGFloat(cos(Double(index) * .pi / 4 + .pi)) * 80 + 125 : 0,
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
                        .offset(x: 125, y: 0)
                    }
                    .padding()
                    .offset(y: -geometry.size.height * 0.12) // Adjust this value to fine-tune the vertical position
                }
            }
        }
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
