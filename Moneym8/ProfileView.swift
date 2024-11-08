import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top, 15)
                
                VStack(spacing: 12) {
                    NavigationLink {
                        InsightsView()
                    } label: {
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
                    
                    NavigationLink {
                        HelpView()
                    } label: {
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
                    
                    NavigationLink {
                        PreferencesView()
                    } label: {
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
                    
                    NavigationLink {
                        SubscriptionView()
                    } label: {
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
                    
                    NavigationLink {
                        AboutView()
                    } label: {
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
}

#Preview {
    ProfileView()
}
