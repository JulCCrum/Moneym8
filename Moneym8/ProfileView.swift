import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 15)
            
            VStack(spacing: 12) {
                NavigationLink(destination: InsightsView()) {
                    HStack(spacing: 12) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                        Text("Insights")
                            .font(.body)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.black.opacity(0.1))
                            .background(Color.white)
                    )
                    .cornerRadius(12)
                }
                
                NavigationLink(destination: HelpView()) {
                    HStack(spacing: 12) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                        Text("Help")
                            .font(.body)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.black.opacity(0.1))
                            .background(Color.white)
                    )
                    .cornerRadius(12)
                }
                
                NavigationLink(destination: PreferencesView()) {
                    HStack(spacing: 12) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.green)
                        Text("Preferences")
                            .font(.body)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.black.opacity(0.1))
                            .background(Color.white)
                    )
                    .cornerRadius(12)
                }
                
                NavigationLink(destination: SubscriptionView()) {
                    HStack(spacing: 12) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.purple)
                        Text("Subscription")
                            .font(.body)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.black.opacity(0.1))
                            .background(Color.white)
                    )
                    .cornerRadius(12)
                }
                
                NavigationLink(destination: AboutView()) {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                        Text("About")
                            .font(.body)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.black.opacity(0.1))
                            .background(Color.white)
                    )
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(uiColor: .systemBackground))
    }
}

// You'll need these basic views for the navigation links to work
struct InsightsView: View {
    var body: some View {
        Text("Insights")
    }
}
struct PreferencesView: View {
    var body: some View {
        Text("Preferences")
    }
}

struct SubscriptionView: View {
    var body: some View {
        Text("Subscription")
    }
}

struct AboutView: View {
    var body: some View {
        Text("About")
    }
}

#Preview {
    ProfileView()
}
