//
//  HomeView.swift
//  Moneym8
//
//
//  HomeView.swift
//  Moneym8
//
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
    case sankey = "Sankey Diagram"
}

struct HomeView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var selectedChart: ChartType = .bar
    @State private var selectedTimePeriod: String = "1M"
    @Environment(\.colorScheme) var colorScheme

    // Define category colors
    private let categoryColors = [
        "Rent": (light: Color.blue.opacity(0.1), dark: Color(hex: "0039CB")), // Bright blue
        "Food": (light: Color.green.opacity(0.1), dark: Color(hex: "2E7D32")), // Bright green
        "Transportation": (light: Color.orange.opacity(0.1), dark: Color(hex: "F57C00")), // Bright orange
        "Other": (light: Color.purple.opacity(0.1), dark: Color(hex: "7B1FA2")) // Bright purple
    ]

    var body: some View {
        VStack(alignment: .leading) {
            // Title Section
            Text("Home")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 15)
                .padding(.leading)
                .padding(.bottom, 15)
            
            // Dropdown Button for Chart Type Selection
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
            .padding(.leading)

            // Chart Section - Centered
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
                    ProgressCircleView(viewModel: viewModel, timeframe: selectedTimePeriod)
                        .frame(height: 200)
                        .padding()
                case .sankey:
                    SankeyChartView(viewModel: viewModel, timeframe: selectedTimePeriod)
                        .frame(height: 200)
                        .padding()
                }
                Spacer()
            }

            // Time Period Selection - Centered
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
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)

            // Summary Section Below the Chart
            VStack(alignment: .leading, spacing: 20) {
                Text("Categories Summary")
                    .font(.headline)
                    .padding(.leading)

                HStack {
                    VStack {
                        Text("Rent")
                            .font(.subheadline)
                            .foregroundColor(colorScheme == .dark ? .white : .gray)
                        Text("$\(Int(viewModel.getCategoryTotal(category: "Rent")))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? categoryColors["Rent"]!.dark : categoryColors["Rent"]!.light)
                    .cornerRadius(10)

                    VStack {
                        Text("Food")
                            .font(.subheadline)
                            .foregroundColor(colorScheme == .dark ? .white : .gray)
                        Text("$\(Int(viewModel.getCategoryTotal(category: "Food")))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? categoryColors["Food"]!.dark : categoryColors["Food"]!.light)
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                HStack {
                    VStack {
                        Text("Transportation")
                            .font(.subheadline)
                            .foregroundColor(colorScheme == .dark ? .white : .gray)
                        Text("$\(Int(viewModel.getCategoryTotal(category: "Transportation")))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? categoryColors["Transportation"]!.dark : categoryColors["Transportation"]!.light)
                    .cornerRadius(10)

                    VStack {
                        Text("Other")
                            .font(.subheadline)
                            .foregroundColor(colorScheme == .dark ? .white : .gray)
                        Text("$\(Int(viewModel.getCategoryTotal(category: "Other")))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? categoryColors["Other"]!.dark : categoryColors["Other"]!.light)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding(.bottom, 20)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: TransactionViewModel())
    }
}
