import SwiftUI

struct TransactionsView: View {
    @Binding var isExpanded: Bool
    @Binding var isBlurred: Bool
    @ObservedObject var viewModel: TransactionViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    HStack {
                        Text("Transactions")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                        Spacer()
                    }
                    Spacer()
                }
                .blur(radius: isBlurred ? 10 : 0)
                
                if isBlurred {
                    Color.black.opacity(0.01)
                        .onTapGesture {
                            withAnimation {
                                isExpanded = false
                                isBlurred = false
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    TransactionsView(
        isExpanded: .constant(false),
        isBlurred: .constant(false),
        viewModel: TransactionViewModel()
    )
}
