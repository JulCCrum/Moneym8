//
//  AnalyticsManager.swift
//  Moneym8
//
//  Created by chase Crummedyo on 3/18/25.
//

import Foundation
import FirebaseAnalytics

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    // MARK: - Onboarding Events
    
    func trackOnboardingStarted() {
        Analytics.logEvent("onboarding_started", parameters: nil)
    }
    
    func trackOnboardingCompleted() {
        Analytics.logEvent("onboarding_completed", parameters: nil)
        Analytics.setUserProperty("true", forName: "completed_onboarding")
    }
    
    func trackOnboardingSkipped() {
        Analytics.logEvent("onboarding_skipped", parameters: nil)
        Analytics.setUserProperty("false", forName: "completed_onboarding")
    }
    
    func trackQuestionAnswered(questionId: String, answer: String, timeSpent: TimeInterval) {
        Analytics.logEvent("question_answered", parameters: [
            "question_id": questionId,
            "answer": answer,
            "time_spent": timeSpent
        ])
    }
    
    func trackQuestionSkipped(questionId: String) {
        Analytics.logEvent("question_skipped", parameters: [
            "question_id": questionId
        ])
    }
    
    func trackQuestionChanged(questionId: String, oldAnswer: String, newAnswer: String) {
        Analytics.logEvent("question_answer_changed", parameters: [
            "question_id": questionId,
            "old_answer": oldAnswer,
            "new_answer": newAnswer
        ])
    }
    
    // MARK: - Transaction Events
    
    func trackFirstTransactionAdded(daysSinceInstall: Int, completedOnboarding: Bool) {
        Analytics.logEvent("first_transaction_added", parameters: [
            "days_since_install": daysSinceInstall,
            "completed_onboarding": completedOnboarding
        ])
    }
    
    func trackTransactionAdded(amount: Double, category: String, isIncome: Bool) {
        Analytics.logEvent("transaction_added", parameters: [
            "amount": amount,
            "category": category,
            "is_income": isIncome
        ])
    }
    
    // MARK: - App Usage Events
    
    func trackScreenView(screenName: String, screenClass: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass
        ])
    }
    
    func trackButtonClick(buttonName: String, screenName: String) {
        Analytics.logEvent("button_click", parameters: [
            "button_name": buttonName,
            "screen_name": screenName
        ])
    }
    
    func trackAppOpen() {
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }
    
    func trackSessionDuration(duration: TimeInterval) {
        Analytics.logEvent("session_ended", parameters: [
            "duration": duration
        ])
    }
    
    // MARK: - User Properties
    
    func setUserFinancialGoal(_ goal: String) {
        Analytics.setUserProperty(goal, forName: "financial_goal")
    }
    
    func setUserIncomeType(_ incomeType: String) {
        Analytics.setUserProperty(incomeType, forName: "income_type")
    }
    
    func setUserSpendingHabit(_ habit: String) {
        Analytics.setUserProperty(habit, forName: "spending_habit")
    }
    
    func setUserFocusArea(_ area: String) {
        Analytics.setUserProperty(area, forName: "focus_area")
    }
}
