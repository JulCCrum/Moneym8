//
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
        let totals = categories.map { category in
            (category, viewModel.getCategoryTotal(category: category))
        }
        print("Category Totals: \(totals)")
        return totals
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
                    AxisValueLabel()
                        .foregroundStyle(.gray)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.gray.opacity(0.2))
                    AxisTick(stroke: StrokeStyle(lineWidth: 0))
                    AxisValueLabel()
                }
            }
            
            // Custom centered legend
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
