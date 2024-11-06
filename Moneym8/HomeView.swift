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
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
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
                            .background(selectedTimePeriod == period ? Color.gray.opacity(0.3) : Color.clear)
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
                            .foregroundColor(.gray)
                        Text("$\(Int(viewModel.getCategoryTotal(category: "Rent")))")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)

                    VStack {
                        Text("Food")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("$\(Int(viewModel.getCategoryTotal(category: "Food")))")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                HStack {
                    VStack {
                        Text("Transportation")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("$\(Int(viewModel.getCategoryTotal(category: "Transportation")))")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)

                    VStack {
                        Text("Other")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("$\(Int(viewModel.getCategoryTotal(category: "Other")))")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.1))
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
