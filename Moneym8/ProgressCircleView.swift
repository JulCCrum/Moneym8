import SwiftUI

struct ProgressCircleView: View {
    @ObservedObject var viewModel: TransactionViewModel
    let timeframe: String
    
    private let monthlyBudget: Double = 2000  // Example budget
    
    private var totalSpent: Double {
        let categories = ["Rent", "Food", "Transportation", "Other"]
        return categories.reduce(0) { total, category in
            total + viewModel.getCategoryTotal(category: category)
        }
    }
    
    private var percentage: Double {
        min((totalSpent / monthlyBudget) * 100, 100)
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 15)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: percentage / 100)
                .stroke(
                    percentage > 90 ? Color.red :
                    percentage > 75 ? Color.orange :
                    Color.green,
                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: percentage)
            
            // Center text
            VStack(spacing: 5) {
                Text("\(Int(percentage))%")
                    .font(.title)
                    .fontWeight(.bold)
                Text("of budget")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("$\(Int(totalSpent))/$\(Int(monthlyBudget))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 150, height: 150)
    }
}

#Preview {
    let viewModel = TransactionViewModel()
    return ProgressCircleView(viewModel: viewModel, timeframe: "1M")
}
