import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
            }
            Spacer()
            
            // Add your profile view content here
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
