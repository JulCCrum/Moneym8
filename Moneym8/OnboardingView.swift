//
//  OnboardingView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/16/24.

import SwiftUI
import FirebaseAnalytics
import SwiftData

struct OnboardingView: View {
    @EnvironmentObject private var authManager: AuthManager
    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var currentQuestionIndex = 0
    @State private var selectedOption: String? = nil
    @State private var customAnswer: String = ""
    @State private var startTime = Date()
    @State private var answers: [String: String] = [:]
    @State private var showSkipAlert = false
    
    private let questions = [
        Question(id: "brings_to_app", prompt: "What brings you to the app?", options: ["Track expenses", "Save money", "Pay off debt", "Build better habits", "Other"], allowsCustomInput: true),
        Question(id: "financial_goal", prompt: "What's your primary financial goal right now?", options: ["Save for something specific", "Build an emergency fund", "Pay off debt", "Track spending better", "Grow wealth/investments", "Other"], allowsCustomInput: true),
        Question(id: "income_situation", prompt: "How would you describe your income situation?", options: ["Regular salary", "Multiple income streams", "Irregular/freelance income", "Looking for work", "Other"], allowsCustomInput: true),
        Question(id: "spending_habits", prompt: "How would you rate your current spending habits?", options: ["I spend more than I should", "I'm generally careful", "I'm very frugal", "I don't really track it", "Other"], allowsCustomInput: true),
        Question(id: "budget_experience", prompt: "Have you tried budgeting before?", options: ["First time trying", "Tried but didn't stick", "Currently budgeting", "Never needed to", "Other"], allowsCustomInput: true),
        Question(id: "focus_area", prompt: "Which area of your finances needs the most attention?", options: ["Daily expenses", "Large purchases", "Savings", "Investments", "Debt management", "Other"], allowsCustomInput: true),
        Question(id: "budget_problem", prompt: "If you have budgeted in the past, what's your biggest problem with budgeting?", options: ["Being consistent / staying on track", "Looking at my bank account", "I haven't tried", "Other"], allowsCustomInput: true)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                progressBar
                    .padding(.top, 10)
                
                // Use a single conditional view with dynamic height
                Group {
                    if currentQuestionIndex == 0 {
                        welcomeView
                    } else if currentQuestionIndex <= questions.count {
                        questionView(for: questions[currentQuestionIndex - 1])
                    } else {
                        completionView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Center content vertically and horizontally
                
                navigationButtons
                    .background(Color(.systemBackground))
                    .padding(.bottom, geometry.safeAreaInsets.bottom) // Respect bottom safe area
            }
            .edgesIgnoringSafeArea(.all) // Ensure full screen coverage
        }
        .onAppear {
            AnalyticsManager.shared.trackOnboardingStarted()
            Task {
                try? await authManager.signInAnonymously()
            }
        }
        .alert("Skip Onboarding?", isPresented: $showSkipAlert) {
            Button("Continue Onboarding", role: .cancel) { }
            Button("Skip", role: .destructive) {
                AnalyticsManager.shared.trackOnboardingSkipped()
                dismiss()
            }
        } message: {
            Text("You can always update your preferences later in settings.")
        }
    }
    
    // MARK: - View Components
    
    private var progressBar: some View {
        HStack {
            let progressWidth = CGFloat((currentQuestionIndex + 1)) * (UIScreen.main.bounds.width - 40) / CGFloat(questions.count + 1)
            
            Capsule()
                .frame(width: progressWidth, height: 4)
                .foregroundColor(.appGreen)
                .animation(.easeInOut, value: currentQuestionIndex)
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var navigationButtons: some View {
        HStack {
            ZStack {
                if currentQuestionIndex > 0 && currentQuestionIndex <= questions.count {
                    backButton
                }
            }
            .frame(width: 100)
            
            Spacer()
            
            ZStack {
                if currentQuestionIndex <= questions.count {
                    skipButton
                }
            }
            .frame(width: 100)
            
            Spacer()
            
            ZStack {
                if canProceed {
                    nextButton
                }
            }
            .frame(width: 100)
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    
    private var backButton: some View {
        Button(action: {
            previousQuestion()
        }) {
            HStack {
                Image(systemName: "arrow.left")
                Text("Back")
            }
            .foregroundColor(.gray)
        }
    }
    
    private var skipButton: some View {
        Button(action: {
            showSkipAlert = true
        }) {
            Text("Skip")
                .foregroundColor(.gray)
        }
    }
    
    private var nextButton: some View {
        Button(action: {
            nextQuestion()
        }) {
            HStack {
                let buttonText = currentQuestionIndex == questions.count ? "Finish" : "Next"
                Text(buttonText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Image(systemName: "arrow.right")
            }
            .frame(minWidth: 85)
            .padding()
            .background(Color.appGreen)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var canProceed: Bool {
        (currentQuestionIndex == 0) ||
        (currentQuestionIndex > 0 && currentQuestionIndex <= questions.count &&
            (selectedOption != nil || (selectedOption == "Other" && !customAnswer.isEmpty)))
    }
    
    var welcomeView: some View {
        VStack(spacing: 30) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.appGreen)
                .padding(.top, 40)
            
            Text("Congratulations!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You've taken the first step to improve your finances!")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Let's get to know you better so we can customize your experience.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
    }
    
    func questionView(for question: Question) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question.prompt)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 20)
            
            LazyVStack(spacing: 8) {
                ForEach(question.options, id: \.self) { option in
                    OptionButton(
                        option: option,
                        isSelected: selectedOption == option
                    ) {
                        let oldAnswer = selectedOption
                        selectedOption = option
                        
                        if let oldAnswer = oldAnswer {
                            AnalyticsManager.shared.trackQuestionChanged(
                                questionId: question.id,
                                oldAnswer: oldAnswer,
                                newAnswer: option
                            )
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            if selectedOption == "Other" {
                HStack {
                    TextField("Tell us more...", text: $customAnswer)
                        .padding()
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
    
    var completionView: some View {
        VStack(spacing: 25) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("You're all set!")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Thanks for sharing your financial goals with us.")
                .font(.body)
                .multilineTextAlignment(.center)
            
            Text("We've customized the app based on your answers. Let's start tracking your finances!")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: 300) // Limits width to ensure content fits, centered
    }
    
    // MARK: - Navigation Logic
    
    private func nextQuestion() {
        if currentQuestionIndex > 0 && currentQuestionIndex <= questions.count {
            let question = questions[currentQuestionIndex - 1]
            
            if let selectedOption = selectedOption {
                let finalAnswer: String
                if selectedOption == "Other" && !customAnswer.isEmpty {
                    finalAnswer = customAnswer
                } else {
                    finalAnswer = selectedOption
                }
                
                answers[question.id] = finalAnswer
                
                let timeSpent = Date().timeIntervalSince(startTime)
                AnalyticsManager.shared.trackQuestionAnswered(
                    questionId: question.id,
                    answer: finalAnswer,
                    timeSpent: timeSpent
                )
                
                switch question.id {
                case "financial_goal":
                    AnalyticsManager.shared.setUserFinancialGoal(finalAnswer)
                case "income_situation":
                    AnalyticsManager.shared.setUserIncomeType(finalAnswer)
                case "spending_habits":
                    AnalyticsManager.shared.setUserSpendingHabit(finalAnswer)
                case "focus_area":
                    AnalyticsManager.shared.setUserFocusArea(finalAnswer)
                default:
                    break
                }
            }
        }
        
        withAnimation {
            currentQuestionIndex += 1
            selectedOption = nil
            customAnswer = ""
            startTime = Date()
        }
        
        if currentQuestionIndex > questions.count {
            AnalyticsManager.shared.trackOnboardingCompleted()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
            }
        }
    }
    
    private func previousQuestion() {
        withAnimation {
            currentQuestionIndex -= 1
            
            if currentQuestionIndex > 0 {
                let savedAnswer = answers[questions[currentQuestionIndex - 1].id] ?? ""
                if questions[currentQuestionIndex - 1].options.contains(savedAnswer) {
                    selectedOption = savedAnswer
                    customAnswer = ""
                } else {
                    selectedOption = "Other"
                    customAnswer = savedAnswer
                }
            } else {
                selectedOption = nil
                customAnswer = ""
            }
            
            startTime = Date()
        }
    }
}

struct Question {
    let id: String
    let prompt: String
    let options: [String]
    var allowsCustomInput: Bool = false
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
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isSelected ? Color.appGreen : Color(.tertiarySystemBackground))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(viewModel: TransactionViewModel(modelContext: try! ModelContainer(for: Schema([
            ExpenseTransaction.self,
            RecurringTransaction.self,
            Item.self
        ])).mainContext))
            .environmentObject(AuthManager.shared)
            .preferredColorScheme(.dark)
    }
}
