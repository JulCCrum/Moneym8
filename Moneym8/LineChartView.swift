//
//  LineChartView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/25/24.
//
import SwiftUI
import Charts

struct LineChartView: View {
    @ObservedObject var viewModel: TransactionViewModel
    let timeframe: String
    
    private var data: [(String, Double)] {
        let transactions = viewModel.transactions.sorted { $0.date < $1.date }
        let calendar = Calendar.current
        
        switch timeframe {
        case "1D":
            // Group by hour for today
            let todayStart = calendar.startOfDay(for: Date())
            let filteredTransactions = transactions.filter {
                calendar.isDate($0.date, inSameDayAs: Date())
            }
            var hourlyTotals: [(String, Double)] = []
            for hour in 0...23 {
                if let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: todayStart) {
                    let total = filteredTransactions
                        .filter { calendar.component(.hour, from: $0.date) == hour }
                        .reduce(0) { $0 + ($1.isIncome ? $1.amount : -$1.amount) }
                    let formatter = DateFormatter()
                    formatter.dateFormat = "ha"
                    hourlyTotals.append((formatter.string(from: date), total))
                }
            }
            return hourlyTotals
            
        case "1W":
            // Group by day for the week
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            let filteredTransactions = transactions.filter { $0.date >= weekAgo }
            var dailyTotals: [(String, Double)] = []
            for dayOffset in 0...6 {
                if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                    let total = filteredTransactions
                        .filter { calendar.isDate($0.date, inSameDayAs: date) }
                        .reduce(0) { $0 + ($1.isIncome ? $1.amount : -$1.amount) }
                    let formatter = DateFormatter()
                    formatter.dateFormat = "EEE"
                    dailyTotals.append((formatter.string(from: date), total))
                }
            }
            return dailyTotals.reversed()
            
        case "1M":
            // Group by week for the month
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
            let filteredTransactions = transactions.filter { $0.date >= monthAgo }
            var weeklyTotals: [(String, Double)] = []
            var weekOffset = 0
            while let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date()),
                  weekStart >= monthAgo {
                let weekTotal = filteredTransactions
                    .filter {
                        let weekOfTransaction = calendar.component(.weekOfYear, from: $0.date)
                        let weekOfStart = calendar.component(.weekOfYear, from: weekStart)
                        return weekOfTransaction == weekOfStart
                    }
                    .reduce(0) { $0 + ($1.isIncome ? $1.amount : -$1.amount) }
                weeklyTotals.append(("Week \(weekOffset + 1)", weekTotal))
                weekOffset += 1
            }
            return weeklyTotals.reversed()
            
        case "1Y":
            // Group by month for the year
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: Date())!
            let filteredTransactions = transactions.filter { $0.date >= yearAgo }
            var monthlyTotals: [(String, Double)] = []
            for monthOffset in 0...11 {
                if let date = calendar.date(byAdding: .month, value: -monthOffset, to: Date()) {
                    let total = filteredTransactions
                        .filter {
                            calendar.isDate($0.date, inSameMonth: date)
                        }
                        .reduce(0) { $0 + ($1.isIncome ? $1.amount : -$1.amount) }
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM"
                    monthlyTotals.append((formatter.string(from: date), total))
                }
            }
            return monthlyTotals.reversed()
            
        default:
            return []
        }
    }
    
    var body: some View {
        Chart {
            ForEach(data, id: \.0) { item in
                AreaMark(
                    x: .value("Time", item.0),
                    y: .value("Amount", item.1)
                )
                .foregroundStyle(
                    LinearGradient(
                        stops: [
                            .init(color: Color.green.opacity(0.2), location: 0),
                            .init(color: Color.green.opacity(0.05), location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
            
            ForEach(data, id: \.0) { item in
                LineMark(
                    x: .value("Time", item.0),
                    y: .value("Amount", item.1)
                )
                .foregroundStyle(Color.green)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
                AxisTick(stroke: StrokeStyle(lineWidth: 0))
                AxisValueLabel()
                    .foregroundStyle(.gray)
            }
        }
        .chartYAxis(.hidden)
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}

extension Calendar {
    func isDate(_ date1: Date, inSameMonth date2: Date) -> Bool {
        let components1 = dateComponents([.year, .month], from: date1)
        let components2 = dateComponents([.year, .month], from: date2)
        return components1.year == components2.year && components1.month == components2.month
    }
}
