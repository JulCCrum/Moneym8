import SwiftUI

class UserProfile: ObservableObject {
    @Published var name: String = ""
    @Published var financialGoal: String = ""
    @Published var incomeType: String = ""
    @Published var riskTolerance: String = ""
    @Published var spendingAwareness: String = ""
    @Published var timeHorizon: String = ""

    func updateProfile(name: String, financialGoal: String, incomeType: String, riskTolerance: String, spendingAwareness: String, timeHorizon: String) {
        self.name = name
        self.financialGoal = financialGoal
        self.incomeType = incomeType
        self.riskTolerance = riskTolerance
        self.spendingAwareness = spendingAwareness
        self.timeHorizon = timeHorizon
    }
}

struct ProfileView: View {
    @ObservedObject var userProfile = UserProfile()
    @State private var isEditing = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 10) // Adjust the top padding to move the title higher
                    .padding(.leading)

                List {
                    NavigationLink(destination: InsightsView(userProfile: userProfile, isEditing: $isEditing)) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                            Text("Insights")
                        }
                    }
                    NavigationLink(destination: ProfileHelpView()) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.orange)
                            Text("Help")
                        }
                    }
                    NavigationLink(destination: PreferencesView()) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.green)
                            Text("Preferences")
                        }
                    }
                    NavigationLink(destination: SubscriptionView()) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.purple)
                            Text("Subscription")
                        }
                    }
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.gray)
                            Text("About")
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }
}

struct InsightsView: View {
    @ObservedObject var userProfile: UserProfile
    @Binding var isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Insights")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    isEditing.toggle()
                }) {
                    Image(systemName: isEditing ? "checkmark" : "pencil")
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)

            Group {
                Text("Name: ")
                    .font(.headline)
                if isEditing {
                    TextField("Enter your name", text: $userProfile.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(userProfile.name)
                        .font(.body)
                }

                Text("Financial Goal: ")
                    .font(.headline)
                if isEditing {
                    TextField("Enter your financial goal", text: $userProfile.financialGoal)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(userProfile.financialGoal)
                        .font(.body)
                }

                Text("Income Type: ")
                    .font(.headline)
                if isEditing {
                    TextField("Enter your income type", text: $userProfile.incomeType)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(userProfile.incomeType)
                        .font(.body)
                }

                Text("Risk Tolerance: ")
                    .font(.headline)
                if isEditing {
                    TextField("Enter your risk tolerance", text: $userProfile.riskTolerance)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(userProfile.riskTolerance)
                        .font(.body)
                }

                Text("Spending Awareness: ")
                    .font(.headline)
                if isEditing {
                    TextField("Enter your spending awareness", text: $userProfile.spendingAwareness)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(userProfile.spendingAwareness)
                        .font(.body)
                }

                Text("Time Horizon: ")
                    .font(.headline)
                if isEditing {
                    TextField("Enter your time horizon", text: $userProfile.timeHorizon)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(userProfile.timeHorizon)
                        .font(.body)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 30)
    }
}

struct ProfileHelpView: View {
    var body: some View {
        VStack {
            Text("Help")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Text("Here you can find help and resources about using the app.")
                .padding()
            Spacer()
        }
    }
}

struct PreferencesView: View {
    var body: some View {
        VStack {
            Text("Preferences")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Text("Set your preferences here.")
                .padding()
            Spacer()
        }
    }
}

struct SubscriptionView: View {
    var body: some View {
        VStack {
            Text("Subscription")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Text("Manage your subscription here.")
                .padding()
            Spacer()
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack {
            Text("About")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Text("Information about the app and its creators.")
                .padding()
            Spacer()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
