//
//  OnboardingView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/16/24.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentQuestionIndex = 0
    @State private var selectedOption: String? = nil
    @State private var showNextButton = false

    private let questions = [
        Question(prompt: "What's your primary financial goal right now?", options: ["Save Money", "Pay Off Debt", "Build Emergency Fund", "Plan for a Major Purchase"]),
        Question(prompt: "How would you describe your income?", options: ["Consistent (e.g., monthly salary)", "Unpredictable (e.g., side hustles)"]),
        Question(prompt: "How comfortable are you with financial risks?", options: ["Risk Averse", "Moderate Risk", "High Risk"]),
        Question(prompt: "How well do you know your spending habits?", options: ["Very Well", "Somewhat Aware", "Not Sure"]),
        Question(prompt: "What's your time horizon for reaching this goal?", options: ["Less than 6 months", "6 to 12 months", "More than a year"])
    ]

    var body: some View {
        VStack {
            // Progress Indicator
            HStack {
                Capsule()
                    .frame(width: CGFloat((currentQuestionIndex + 1) * 60), height: 4)
                    .foregroundColor(.black)
                    .animation(.easeInOut, value: currentQuestionIndex)
                Spacer()
            }
            .padding(.horizontal)

            // Question Prompt
            Text(questions[currentQuestionIndex].prompt)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 30)
                .padding(.horizontal)
                .multilineTextAlignment(.leading)

            // Question Options
            VStack(alignment: .leading, spacing: 20) {
                ForEach(questions[currentQuestionIndex].options, id: \..self) { option in
                    OptionButton(option: option, isSelected: selectedOption == option) {
                        selectedOption = option
                        showNextButton = true
                    }
                }
            }
            .padding(.top, 40)
            .padding(.horizontal)

            Spacer()

            // Back and Next Buttons Side by Side
            HStack(spacing: 20) {
                if currentQuestionIndex > 0 {
                    Button(action: {
                        if currentQuestionIndex > 0 {
                            currentQuestionIndex -= 1
                            selectedOption = nil
                            showNextButton = false
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                }

                if showNextButton {
                    Button(action: {
                        if currentQuestionIndex < questions.count - 1 {
                            currentQuestionIndex += 1
                            selectedOption = nil
                            showNextButton = false
                        }
                    }) {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .padding(.bottom, 20)
    }
}

struct Question {
    let prompt: String
    let options: [String]
}

struct OptionButton: View {
    let option: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                Text(option)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .black)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(isSelected ? Color.black : Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
