//  BarChartView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/28/24.
//
import SwiftUI
import Charts

struct BarChartView: View {
    @ObservedObject var viewModel: TransactionViewModel
    let timeframe: String
    
    private var categoryTotals: [(category: String, amount: Double)] {
        let categories = ["Rent", "Food", "Transportation", "Other"]
        let calendar = Calendar.current
        
        // Filter transactions based on timeframe
        let filteredTransactions: [ExpenseTransaction] = {
            switch timeframe {
            case "1D":
                return viewModel.transactions.filter {
                    calendar.isDate($0.date, inSameDayAs: Date())
                }
            case "1W":
                guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return [] }
                return viewModel.transactions.filter { $0.date >= weekAgo }
            case "1M":
                guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) else { return [] }
                return viewModel.transactions.filter { $0.date >= monthAgo }
            case "1Y":
                guard let yearAgo = calendar.date(byAdding: .year, value: -1, to: Date()) else { return [] }
                return viewModel.transactions.filter { $0.date >= yearAgo }
            default:
                return []
            }
        }()
        
        // Calculate totals for each category using filtered transactions
        return categories.map { category in
            let total = filteredTransactions
                .filter { $0.category == category && !$0.isIncome }
                .reduce(0) { $0 + $1.amount }
            return (category, total)
        }
    }
    
    var body: some View {
        VStack {
            Chart {
                ForEach(categoryTotals, id: \.category) { item in
                    BarMark(
                        x: .value("Category", item.category),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(getBackgroundColor(for: item.category))
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
                    AxisTick(stroke: StrokeStyle(lineWidth: 0))
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.gray.opacity(0.2))
                    AxisTick(stroke: StrokeStyle(lineWidth: 0))
                    AxisValueLabel()
                        .foregroundStyle(.gray)
                }
            }
            
            // Legend at bottom
            HStack(spacing: 15) {
                ForEach(categoryTotals, id: \.category) { item in
                    HStack(spacing: 5) {
                        Circle()
                            .fill(getBackgroundColor(for: item.category))
                            .frame(width: 8, height: 8)
                        Text(item.category)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.top, 5)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .padding(.vertical)
    }
    
    private func getBackgroundColor(for category: String) -> Color {
        switch category {
        case "Rent": return Color.blue
        case "Food": return Color.green
        case "Transportation": return Color.orange
        case "Other": return Color.purple
        default: return Color.gray
        }
    }
}
