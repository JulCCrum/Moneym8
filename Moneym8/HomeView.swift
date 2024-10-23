import SwiftUI
import Charts

enum ChartType: String, CaseIterable {
    case line = "Line Graph"
    case bar = "Bar Graph"
    case progress = "Progress Circle"
    case sankey = "Sankey Diagram"
}

struct HomeView: View {
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
                    Image(systemName: "chevron.down") // Add downward caret icon
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
                    LineChartView()
                        .frame(height: 200)
                        .padding()
                case .bar:
                    BarChartView()
                        .frame(height: 200)
                        .padding()
                case .progress:
                    ProgressCircleView()
                        .frame(height: 200)
                        .padding()
                case .sankey:
                    SankeyChartView()
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
                            .clipShape(Circle()) // Keep buttons circular
                    }
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity) // Make HStack take full width
            .multilineTextAlignment(.center) // Center align the HStack contents

            // Summary Section Below the Chart
            VStack(alignment: .leading, spacing: 20) {
                Text("Transaction Categories Summary")
                    .font(.headline)
                    .padding(.leading)

                HStack {
                    VStack {
                        Text("Rent")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("$500")
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
                        Text("$300")
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
                        Text("Transport")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("$150")
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
                        Text("$200")
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

            Spacer() // Pushes content to the top
        }
        .padding(.bottom, 20) // Padding at the bottom for spacing
    }
}

// MARK: - Subviews for Different Charts

struct LineChartView: View {
    // Sample data - you can replace with your actual data
    let data: [(String, Double)] = [
        ("Jan", 50),
        ("Feb", 50),
        ("Mar", 50),
        ("Apr", 85),
        ("May", 85),
        ("Jun", 85)
    ]
    
    var body: some View {
        Chart {
            // Area mark for the gradient fill
            ForEach(data, id: \.0) { item in
                AreaMark(
                    x: .value("Month", item.0),
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
                .interpolationMethod(.catmullRom) // Smooth curve
            }
            
            // Line mark for the main line
            ForEach(data, id: \.0) { item in
                LineMark(
                    x: .value("Month", item.0),
                    y: .value("Amount", item.1)
                )
                .foregroundStyle(Color.green)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom) // Smooth curve
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
                AxisTick(stroke: StrokeStyle(lineWidth: 0))
                AxisValueLabel() // This will show the labels
            }
        }
        .chartYAxis(.hidden) // Hides the y-axis completely
    }
}

struct BarChartView: View {
    var body: some View {
        Chart {
            BarMark(
                x: .value("Category", "Rent"),
                y: .value("Amount", 500)
            )
            BarMark(
                x: .value("Category", "Food"),
                y: .value("Amount", 300)
            )
            BarMark(
                x: .value("Category", "Transport"),
                y: .value("Amount", 150)
            )
            BarMark(
                x: .value("Category", "Other"),
                y: .value("Amount", 200)
            )
        }
    }
}

struct ProgressCircleView: View {
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.green, lineWidth: 15)
                .rotationEffect(.degrees(-90))
                .frame(width: 150, height: 150)
            
            Text("75%")
                .font(.title)
                .fontWeight(.bold)
        }
    }
}

struct SankeyChartView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Placeholder for Sankey Diagram paths
                Path { path in
                    let startX = geometry.size.width * 0.1
                    let startY = geometry.size.height * 0.3
                    let endX = geometry.size.width * 0.9
                    let endY = geometry.size.height * 0.7

                    path.move(to: CGPoint(x: startX, y: startY))
                    path.addCurve(to: CGPoint(x: endX, y: endY),
                                  control1: CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.1),
                                  control2: CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.9))
                }
                .stroke(Color.blue, lineWidth: 8)
                .opacity(0.5)

                // Add more paths to represent different flows in the Sankey diagram
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
