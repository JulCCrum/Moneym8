import SwiftUI

struct SankeyChartView: View {
    @ObservedObject var viewModel: TransactionViewModel
    let timeframe: String
    
    private var incomeTotal: Double {
        viewModel.getIncome().reduce(0) { $0 + $1.amount }
    }
    
    // Define category info with emojis
    private let categoryInfo: [(category: String, emoji: String)] = [
        ("Rent", "🏠"),
        ("Food", "🍽️"),
        ("Transportation", "🚗"),
        ("Other", "💡")
    ]
    
    private var expenseCategories: [(category: String, amount: Double)] {
        categoryInfo.map { info in
            (info.category, viewModel.getCategoryTotal(category: info.category))
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw flows from income to each category
                ForEach(expenseCategories, id: \.category) { category in
                    Path { path in
                        let startX = geometry.size.width * 0.1
                        let endX = geometry.size.width * 0.9
                        let startY = geometry.size.height * 0.5
                        let endY = categoryYPosition(for: category.category, in: geometry)
                        
                        path.move(to: CGPoint(x: startX, y: startY))
                        path.addCurve(
                            to: CGPoint(x: endX, y: endY),
                            control1: CGPoint(x: geometry.size.width * 0.4, y: startY),
                            control2: CGPoint(x: geometry.size.width * 0.6, y: endY)
                        )
                    }
                    .stroke(getColor(for: category.category),
                           style: StrokeStyle(lineWidth: strokeWidth(for: category.amount)))
                    .opacity(0.7)
                }
                
                // Income emoji on the left
                Text("💰")
                    .font(.title)
                    .position(x: geometry.size.width * 0.1,
                             y: geometry.size.height * 0.5)
                
                // Category emojis on the right
                ForEach(categoryInfo, id: \.category) { info in
                    Text(info.emoji)
                        .font(.title2)
                        .position(
                            x: geometry.size.width * 0.9,
                            y: categoryYPosition(for: info.category, in: geometry)
                        )
                }
            }
        }
        .padding()
    }
    
    private func categoryYPosition(for category: String, in geometry: GeometryProxy) -> Double {
        let categories = categoryInfo.map { $0.category }
        if let index = categories.firstIndex(of: category) {
            let spacing = geometry.size.height / Double(categories.count + 1)
            return spacing * Double(index + 1)
        }
        return geometry.size.height * 0.5
    }
    
    private func strokeWidth(for amount: Double) -> Double {
        let maxWidth: Double = 40
        let minWidth: Double = 10
        let total = expenseCategories.reduce(0) { $0 + $1.amount }
        let proportion = amount / total
        return max(minWidth, proportion * maxWidth)
    }
    
    private func getColor(for category: String) -> Color {
        switch category {
        case "Rent": return .blue
        case "Food": return .green
        case "Transportation": return .orange
        case "Other": return .purple
        default: return .gray
        }
    }
}

#Preview {
    let viewModel = TransactionViewModel()
    return SankeyChartView(viewModel: viewModel, timeframe: "1M")
}
