//
//  FloatingActionButtons.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/27/24.
//
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
    private let buttons = ["minus", "plus", "questionmark"]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        ForEach(buttons.indices, id: \.self) { index in
                            Button {
                                handleButtonTap(index)
                            } label: {
                                Image(systemName: buttons[index])
                                    .frame(width: 44, height: 44)
                                    .background(colorScheme == .dark ? Color(hex: "404040") : .black)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(PlainButtonStyle()) // Add this line
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
                        .buttonStyle(PlainButtonStyle()) // Add this line
                    }
                    .offset(x: -geometry.size.width / 10, y: -15)
                    .padding(.bottom, 60)
                }
            }
        }
    }
}
