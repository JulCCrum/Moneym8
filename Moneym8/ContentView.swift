//
//  ContentView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/11/24.
//

import SwiftUI
import SwiftData

@Model
final class Expense {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var category: String
    var date: Date
    
    init(amount: Double, category: String, date: Date = Date()) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.date = date
    }
}

struct LargerTabItem: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .environment(\.symbolVariants, isSelected ? .fill : .none)
            .font(.system(size: 16))  // Increase font size
            .foregroundColor(isSelected ? .black : .gray)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var expenses: [Expense]
    @State private var showingAddExpense = false
    @State private var selectedTab = 1
    @State private var showingOverlay = false
    @State private var overlayButtonsScale: CGFloat = 0
    @State private var fabRotation: Double = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Text("Home")
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)
                    .modifier(LargerTabItem(isSelected: selectedTab == 0))
                
                NavigationView {
                    List {
                        ForEach(expenses) { expense in
                            ExpenseRow(expense: expense)
                        }
                        .onDelete(perform: deleteExpenses)
                    }
                    .navigationTitle("Expenses")
                }
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                    Text("Expenses")
                }
                .tag(1)
                .modifier(LargerTabItem(isSelected: selectedTab == 1))
                
                Text("Profile")
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(2)
                    .modifier(LargerTabItem(isSelected: selectedTab == 2))
            }
            .tint(.black)
            .blur(radius: showingOverlay ? 10 : 0)
            
            if showingOverlay {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            // Overlay buttons
                            ForEach(0..<3) { index in
                                OverlayButton(icon: iconForIndex(index), color: .black, action: {
                                    actionForIndex(index)
                                })
                                .offset(offsetForIndex(index))
                                .scaleEffect(overlayButtonsScale)
                            }
                        }
                        .frame(width: 200, height: 200)
                        .padding(.trailing, 20)
                        .padding(.bottom, 80)
                    }
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: toggleOverlay) {
                        Image(systemName: "plus")
                            .font(.title.weight(.semibold))
                            .padding()
                            .background(Color(hex: "01a624"))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4, x: 0, y: 4)
                            .rotationEffect(.degrees(fabRotation))
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 80)
                }
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showingOverlay)
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(modelContext: _modelContext)
        }
    }
    
    private func deleteExpenses(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(expenses[index])
            }
        }
    }
    
    private func toggleOverlay() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showingOverlay.toggle()
            fabRotation = showingOverlay ? 45 : 0  // Corrected to 45 degrees
            overlayButtonsScale = showingOverlay ? 1 : 0
        }
    }
    
    private func offsetForIndex(_ index: Int) -> CGSize {
        let angles: [CGFloat] = [.pi, 3 * .pi / 4, .pi / 2]  // Correct angles for the second quadrant
        let radius: CGFloat = 70
        return CGSize(
            width: cos(angles[index]) * radius,
            height: sin(angles[index]) * radius
        )
    }
    
    private func iconForIndex(_ index: Int) -> String {
        switch index {
        case 0: return "minus"
        case 1: return "plus"
        case 2: return "questionmark"
        default: return ""
        }
    }
    
    private func actionForIndex(_ index: Int) {
        switch index {
        case 0:
            showingAddExpense = true
            toggleOverlay()
        case 1:
            // Add income action
            toggleOverlay()
        case 2:
            // Help action
            toggleOverlay()
        default:
            break
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            Text(expense.category)
            Spacer()
            Text("$\(expense.amount, specifier: "%.2f")")
        }
    }
}

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var amount = ""
    @State private var category = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                TextField("Category", text: $category)
                
                Button("Save") {
                    if let amountDouble = Double(amount) {
                        let newExpense = Expense(amount: amountDouble, category: category)
                        modelContext.insert(newExpense)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Expense.self, inMemory: true)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct OverlayButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22))  // Keep icon size the same
                .foregroundColor(.white)
                .frame(width: 45, height: 45)  // Reduce button size by 25%
                .background(color)
                .clipShape(Circle())
                .shadow(radius: 3, x: 0, y: 3)  // Slightly reduced shadow to match smaller size
        }
    }
}
