//
//  LineChartView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/25/24.
//

import SwiftUI
import Charts

struct LineChartView: View {
    let timeframe: String
    
    var filteredData: [(String, Double)] {
        switch timeframe {
        case "1D":
            return [
                ("9AM", 500),
                ("12PM", 700),
                ("3PM", 600),
                ("6PM", 800)
            ]
        case "1W":
            return [
                ("Mon", 500),
                ("Wed", 600),
                ("Fri", 750),
                ("Sun", 800)
            ]
        case "1Y":
            return [
                ("Jan", 500),
                ("Mar", 600),
                ("Jun", 800),
                ("Sep", 900),
                ("Dec", 1200)
            ]
        default: // 1M (default case)
            return [
                ("Week 1", 500),
                ("Week 2", 600),
                ("Week 3", 700),
                ("Week 4", 800)
            ]
        }
    }
    
    var body: some View {
        Chart {
            // Gradient area under the line
            ForEach(filteredData, id: \.0) { item in
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
            
            // Main line
            ForEach(filteredData, id: \.0) { item in
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
            }
        }
        .chartYAxis(.hidden)
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}

#Preview {
    LineChartView(timeframe: "1M")
        .padding()
}
