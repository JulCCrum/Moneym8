//
//  HomeView.swift
//  Moneym8
//

import SwiftUI
import Charts

enum ChartType: String, CaseIterable {
    case line = "Line Graph"
    case bar = "Bar Graph"
    case progress = "Progress Circle"
}

struct HomeView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var selectedChart: ChartType = .bar
    @State private var selectedTimePeriod: String = "1M"
    @Environment(\.colorScheme) var colorScheme

    private let categoryColors = [
        "Rent": (light: Color.blue.opacity(0.9), dark: Color(hex: "0039CB")),
        "Food": (light: Color.green.opacity(0.9), dark: Color(hex: "2E7D32")),
        "Transportation": (light: Color.orange.opacity(0.9), dark: Color(hex: "F57C00")),
        "Other": (light: Color.purple.opacity(0.9), dark: Color(hex: "7B1FA2"))
    ]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Home")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 15)
                .padding(.leading)
                .padding(.bottom, 15)
            
            Menu {
                Picker("Select Chart Type", selection: $selectedChart) {
                    ForEach(ChartType.allCases, id: \.self) { chart in
                        Text(chart.rawValue).tag(chart)
                    }
                }
            } label: {
                HStack {
                    Text(selectedChart.rawValue)
                    Image(systemName: "chevron.down")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.leading)

            HStack {
                Spacer()
                switch selectedChart {
                case .line:
                    LineChartView(viewModel: viewModel, timeframe: selectedTimePeriod)
                        .frame(height: 200)
                        .padding()
                case .bar:
                    BarChartView(viewModel: viewModel, timeframe: selectedTimePeriod)
                        .frame(height: 200)
                        .padding()
                case .progress:
                    ProgressCircleView(viewModel: viewModel)
                        .frame(height: 200)
                        .padding()
                }
                Spacer()
            }

            HStack(spacing: 30) {
                ForEach(["1D", "1W", "1M", "1Y"], id: \.self) { period in
                    Button(action: {
                        selectedTimePeriod = period
                    }) {
                        Text(period)
                            .frame(width: 40, height: 40)
                            .background(
                                selectedTimePeriod == period ?
                                (colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3)) :
                                Color.clear
                            )
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)

            Spacer()
        }
    }
}

struct CategorySummaryBox: View {
    let category: String
    let amount: Double
    let color: Color

    var body: some View {
        VStack {
            Text(category)
                .font(.subheadline)
                .foregroundColor(.white)
            Text("$\(Int(amount))")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .cornerRadius(10)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: TransactionViewModel())
    }
}
