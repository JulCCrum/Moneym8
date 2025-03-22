//Created by chase Crummedyo on 10/27/24.
//
//  FloatingActionButtons.swift
//  Moneym8
//
import SwiftUI

struct FloatingActionButtons: View {
    let isExpanded: Bool
    let isBlurred: Bool
    let handleButtonTap: (Int) -> Void
    let toggleExpanded: () -> Void
    private let buttons = ["sparkles", "plus", "questionmark"] // Changed "minus" to "sparkles" for AI/Plaid preview
    @Environment(\.colorScheme) var colorScheme
    @State private var showNewFeatureAlert = false // Add state for showing feature preview alert
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        ForEach(buttons.indices, id: \.self) { index in
                            Button {
                                if index == 0 { // Special handling for the first button (previously minus)
                                    showNewFeatureAlert = true // Show preview alert instead
                                } else {
                                    handleButtonTap(index)
                                }
                            } label: {
                                Image(systemName: buttons[index])
                                    .frame(width: 44, height: 44)
                                    .background(index == 0 ? Color.purple : (colorScheme == .dark ? Color(hex: "404040") : .black))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .offset(x: isExpanded ? CGFloat(cos(Double(index) * .pi / 4 + .pi)) * 80 : 0,
                                    y: isExpanded ? CGFloat(sin(Double(index) * .pi / 4 + .pi)) * 80 : 0)
                            .opacity(isExpanded ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(index) * 0.05), value: isExpanded)
                        }
                        
                        Button {
                            toggleExpanded()
                        } label: {
                            Image(systemName: "plus")
                                .rotationEffect(.degrees(isExpanded ? 45 : 0))
                                .frame(width: 56, height: 56)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .offset(x: -geometry.size.width / 10, y: -15)
                    .padding(.bottom, 60)
                }
            }
            .alert("Coming Soon!", isPresented: $showNewFeatureAlert) {
                Button("Cool!", role: .cancel) { }
            } message: {
                Text("We're excited to announce two new features coming to Moneym8:\n\n• AI-powered financial insights\n• Plaid integration for automatic transaction import")
            }
        }
    }
}
