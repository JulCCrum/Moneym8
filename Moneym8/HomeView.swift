import SwiftUI
import Charts

struct HomeView: View {
    var body: some View {
        VStack {
            // Title Section
            HStack {
                Text("Home")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 15)
                    .padding(.leading)
                Spacer()
            }

            // Graph Section
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
            .frame(height: 200)
            .padding()

            // Summary Section Below the Graph
            VStack(alignment: .leading, spacing: 20) {
                Text("Transaction Categories Summary")
                    .font(.headline)
                    .padding(.leading)

                HStack {
                    // Rent Summary Card
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

                    // Food Summary Card
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
                    // Transport Summary Card
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

                    // Other Summary Card
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
