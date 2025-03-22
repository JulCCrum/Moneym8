// TransactionViewModel.swift
// Moneym8
//
// Created by chase Crummedyo on 10/27/24.
//

import SwiftUI
import SwiftData
import FirebaseFirestore
import FirebaseAuth

@Model
class ExpenseTransaction: Codable {
    var id: String
    var amount: Double
    var isIncome: Bool
    var date: Date
    var category: String
    var note: String?

    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case isIncome
        case date
        case category
        case note
    }

    init(id: String = UUID().uuidString, amount: Double, isIncome: Bool, date: Date, category: String, note: String? = nil) {
        self.id = id
        self.amount = amount
        self.isIncome = isIncome
        self.date = date
        self.category = category
        self.note = note
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        amount = try container.decode(Double.self, forKey: .amount)
        isIncome = try container.decode(Bool.self, forKey: .isIncome)
        date = try container.decode(Date.self, forKey: .date)
        category = try container.decode(String.self, forKey: .category)
        note = try container.decodeIfPresent(String.self, forKey: .note)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(amount, forKey: .amount)
        try container.encode(isIncome, forKey: .isIncome)
        try container.encode(date, forKey: .date)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(note, forKey: .note)
    }
    
    var formattedAmount: String {
        let prefix = isIncome ? "+" : "-"
        return "\(prefix)$\(String(format: "%.2f", amount))"
    }
}

@Model
class RecurringTransaction: Codable {
    var id: String
    var amount: Double
    var isIncome: Bool
    var startDate: Date
    var category: String
    var frequency: String // Using String instead of enum for SwiftData compatibility
    var note: String?

    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case isIncome
        case startDate
        case category
        case frequency
        case note
    }

    init(id: String = UUID().uuidString, amount: Double, isIncome: Bool, startDate: Date, category: String, frequency: RecurringFrequency, note: String? = nil) {
        self.id = id
        self.amount = amount
        self.isIncome = isIncome
        self.startDate = startDate
        self.category = category
        self.frequency = frequency.rawValue
        self.note = note
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        amount = try container.decode(Double.self, forKey: .amount)
        isIncome = try container.decode(Bool.self, forKey: .isIncome)
        startDate = try container.decode(Date.self, forKey: .startDate)
        category = try container.decode(String.self, forKey: .category)
        frequency = try container.decode(String.self, forKey: .frequency)
        note = try container.decodeIfPresent(String.self, forKey: .note)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(amount, forKey: .amount)
        try container.encode(isIncome, forKey: .isIncome)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(category, forKey: .category)
        try container.encode(frequency, forKey: .frequency)
        try container.encodeIfPresent(note, forKey: .note)
    }
}

enum RecurringFrequency: String, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

@MainActor
class TransactionViewModel: ObservableObject {
    var modelContext: ModelContext
    private var db: Firestore?
    
    @Published var transactions: [ExpenseTransaction] = []
    @Published var recurringTransactions: [RecurringTransaction] = []
    @Published var categoryBudgets: [String: Double] = [:]
    @Published var activeCategories: Set<String>
    @Published var totalBudget: Double = UserDefaults.standard.double(forKey: "totalBudget")
    @Published var wageHistory: [WageHistory] = []
    @Published var showWageCost: Bool = UserDefaults.standard.bool(forKey: "showWageCost")
    
    // Move these properties inside the class
    @Published var showAccountCreationReminder = false
    @Published var isFirstTransaction = true
    @AppStorage("appInstallDate") private var appInstallDateString: String = ""
    
    // Added computed property for categories from activeCategories
    var categories: [String] {
        Array(activeCategories).sorted()
    }
    
    // Move this method inside the class
    private func checkFirstLaunch() {
        if appInstallDateString.isEmpty {
            appInstallDateString = ISO8601DateFormatter().string(from: Date())
        }
        
        // Set isFirstTransaction based on existing transactions
        isFirstTransaction = transactions.isEmpty
    }

    // Default initializer that creates a new ModelContext
    init() {
        let schema = Schema([ExpenseTransaction.self, RecurringTransaction.self, WageHistory.self, Item.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            self.modelContext = container.mainContext
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        
        // Initialize with default categories
        if let savedCategories = UserDefaults.standard.array(forKey: "activeCategories") as? [String] {
            activeCategories = Set(savedCategories)
        } else {
            activeCategories = Set(["Rent", "Food", "Transportation", "Other"])
            UserDefaults.standard.set(Array(activeCategories), forKey: "activeCategories")
        }
        
        loadSavedBudgets()
        loadLocalTransactions()
        loadLocalRecurringTransactions()
        loadWageHistory()
        
        // Add this call to check first launch
        checkFirstLaunch()
        
        // Optionally initialize Firebase if syncing is desired
        if Auth.auth().currentUser != nil {
            db = Firestore.firestore()
            listenToTransactions()
            listenToRecurringTransactions()
        }
    }

    // Constructor that takes a ModelContext directly
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // Initialize with default categories
        if let savedCategories = UserDefaults.standard.array(forKey: "activeCategories") as? [String] {
            activeCategories = Set(savedCategories)
        } else {
            activeCategories = Set(["Rent", "Food", "Transportation", "Other"])
            UserDefaults.standard.set(Array(activeCategories), forKey: "activeCategories")
        }
        
        loadSavedBudgets()
        loadLocalTransactions()
        loadLocalRecurringTransactions()
        loadWageHistory()
        
        // Add this call to check first launch
        checkFirstLaunch()
        
        // Optionally initialize Firebase if syncing is desired
        if Auth.auth().currentUser != nil {
            db = Firestore.firestore()
            listenToTransactions()
            listenToRecurringTransactions()
        }
    }
    
    // Add the missing updateTotalBudget method
    func updateTotalBudget(_ newValue: Double) {
        totalBudget = newValue
        UserDefaults.standard.set(newValue, forKey: "totalBudget")
    }
    
    private func loadSavedBudgets() {
        for category in activeCategories {
            if let savedBudget = UserDefaults.standard.object(forKey: "budget_\(category)") as? Double {
                categoryBudgets[category] = savedBudget
            } else {
                categoryBudgets[category] = 0 // Default budget of 0
            }
        }
    }
    
    func addCategory(_ category: String) -> Bool {
        guard activeCategories.count < 5 else { return false }
        activeCategories.insert(category)
        categoryBudgets[category] = 0
        saveCategoryChanges()
        return true
    }
    
    func removeCategory(_ category: String) {
        activeCategories.remove(category)
        categoryBudgets.removeValue(forKey: category)
        saveCategoryChanges()
    }
    
    private func saveCategoryChanges() {
        UserDefaults.standard.set(Array(activeCategories), forKey: "activeCategories")
    }
    
    // Load local transactions - simplified to avoid SwiftData issues
    private func loadLocalTransactions() {
        do {
            try resetModelIfNeeded()
            
            // Just initialize with an empty array for now
            transactions = []
            print("Initialized with empty transactions")
            
            // When app is stable, uncomment this to try fetching again
            /*
            var descriptor = FetchDescriptor<ExpenseTransaction>()
            descriptor.fetchLimit = 100
            transactions = try modelContext.fetch(descriptor)
            print("Successfully loaded \(transactions.count) transactions")
            */
        } catch {
            print("Error in loadLocalTransactions: \(error)")
            transactions = []
        }
    }
    
    private func resetModelIfNeeded() throws {
        let key = "model_reset_v1"
        if !UserDefaults.standard.bool(forKey: key) {
            print("Skipping database reset due to SwiftData issues")
            // Mark as done without attempting to reset
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    
    // Load local recurring transactions - simplified similarly
    private func loadLocalRecurringTransactions() {
        // Initialize with empty array for now
        recurringTransactions = []
        
        // When app is stable, uncomment this to try fetching again
        /*
        do {
            var descriptor = FetchDescriptor<RecurringTransaction>()
            descriptor.fetchLimit = 100
            recurringTransactions = try modelContext.fetch(descriptor)
        } catch {
            print("Error loading recurring transactions: \(error)")
            recurringTransactions = []
        }
        */
    }
    
    // Add local transaction
    func addTransaction(_ transaction: ExpenseTransaction) {
        modelContext.insert(transaction)
        saveLocalChanges()
        
        // Add to local array as well since fetch may be disabled
        transactions.append(transaction)
        
        // Track the transaction in analytics
        AnalyticsManager.shared.trackTransactionAdded(
            amount: transaction.amount,
            category: transaction.category,
            isIncome: transaction.isIncome
        )
        
        // Check if this is the first transaction
        if isFirstTransaction && transactions.count == 1 {
            isFirstTransaction = false
            
            // Calculate days since install
            let formatter = ISO8601DateFormatter()
            if let installDate = formatter.date(from: appInstallDateString) {
                let daysSinceInstall = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
                
                // Log analytics event
                AnalyticsManager.shared.trackFirstTransactionAdded(
                    daysSinceInstall: daysSinceInstall,
                    completedOnboarding: UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                )
                
                // If user is anonymous, show account creation reminder
                if Auth.auth().currentUser?.isAnonymous ?? false {
                    showAccountCreationReminder = true
                }
            }
        }
        
        // Optional: Sync with Firebase if user is authenticated
        if let db = db, let userId = Auth.auth().currentUser?.uid {
            do {
                _ = try db.collection("users").document(userId)
                    .collection("transactions")
                    .addDocument(from: transaction)
            } catch {
                print("Error syncing transaction to Firebase: \(error)")
            }
        }
    }
    
    // Add local recurring transaction
    func addRecurringTransaction(_ transaction: RecurringTransaction) {
        modelContext.insert(transaction)
        saveLocalChanges()
        
        // Add to local array as well
        recurringTransactions.append(transaction)
        
        // Optional: Sync with Firebase if user is authenticated
        if let db = db, let userId = Auth.auth().currentUser?.uid {
            do {
                _ = try db.collection("users").document(userId)
                    .collection("recurring_transactions")
                    .addDocument(from: transaction)
            } catch {
                print("Error syncing recurring transaction to Firebase: \(error)")
            }
        }
    }
    
    // Remove local transaction
    func removeTransaction(_ transaction: ExpenseTransaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            modelContext.delete(transactions[index])
            transactions.remove(at: index)
            saveLocalChanges()
            
            // Optional: Remove from Firebase if synced
            if let db = db, let userId = Auth.auth().currentUser?.uid {
                db.collection("users").document(userId)
                    .collection("transactions")
                    .document(transaction.id)
                    .delete()
            }
        }
    }
    
    // Remove local recurring transaction
    func removeRecurringTransaction(_ transaction: RecurringTransaction) {
        if let index = recurringTransactions.firstIndex(where: { $0.id == transaction.id }) {
            modelContext.delete(recurringTransactions[index])
            recurringTransactions.remove(at: index)
            saveLocalChanges()
            
            // Optional: Remove from Firebase if synced
            if let db = db, let userId = Auth.auth().currentUser?.uid {
                db.collection("users").document(userId)
                    .collection("recurring_transactions")
                    .document(transaction.id)
                    .delete()
            }
        }
    }
    
    private func saveLocalChanges() {
        do {
            try modelContext.save()
            // No need to load again, we're managing arrays manually
        } catch {
            print("Error saving local changes: \(error)")
        }
    }
    
    // Optional Firebase listeners (only if authenticated)
    private func listenToTransactions() {
        guard let userId = Auth.auth().currentUser?.uid, let db = db else { return }
        
        db.collection("users").document(userId)
            .collection("transactions")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let firebaseTransactions = documents.compactMap { doc in
                    try? doc.data(as: ExpenseTransaction.self)
                }
                
                // Merge Firebase data with local data (optional sync)
                guard let self = self else { return }
                for firebaseTransaction in firebaseTransactions {
                    if !self.transactions.contains(where: { $0.id == firebaseTransaction.id }) {
                        self.addTransaction(firebaseTransaction)
                    }
                }
            }
    }
    
    private func listenToRecurringTransactions() {
        guard let userId = Auth.auth().currentUser?.uid, let db = db else { return }
        
        db.collection("users").document(userId)
            .collection("recurring_transactions")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching recurring transactions: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let firebaseRecurring = documents.compactMap { doc in
                    try? doc.data(as: RecurringTransaction.self)
                }
                
                // Merge Firebase data with local data (optional sync)
                guard let self = self else { return }
                for firebaseRecurring in firebaseRecurring {
                    if !self.recurringTransactions.contains(where: { $0.id == firebaseRecurring.id }) {
                        self.addRecurringTransaction(firebaseRecurring)
                    }
                }
            }
    }
    
    // Existing methods (updated to use local data)
    func getExpenses() -> [ExpenseTransaction] {
        transactions.filter { !$0.isIncome }
    }
    
    func getIncome() -> [ExpenseTransaction] {
        transactions.filter { $0.isIncome }
    }
    
    func getTransactions(forCategory category: String) -> [ExpenseTransaction] {
        transactions.filter { $0.category == category }
    }
    
    func getCategoryTotal(category: String) -> Double {
        transactions
            .filter { $0.category == category && !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
    }
    
    var averageMonthlySpending: Double {
        let calendar = Calendar.current
        guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) else { return 0 }
        
        return transactions
            .filter { !$0.isIncome }
            .filter { $0.date >= oneMonthAgo }
            .reduce(0) { $0 + $1.amount }
    }
    
    var averageMonthlyIncome: Double {
        let calendar = Calendar.current
        guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) else { return 0 }
        
        return transactions
            .filter { $0.isIncome }
            .filter { $0.date >= oneMonthAgo }
            .reduce(0) { $0 + $1.amount }
    }
    
    func budget(for category: String) -> Double {
        categoryBudgets[category] ?? 0
    }
    
    func monthlySpending(for category: String) -> Double {
        let calendar = Calendar.current
        guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) else { return 0 }
        
        return transactions
            .filter { !$0.isIncome && $0.category == category }
            .filter { $0.date >= oneMonthAgo }
            .reduce(0) { $0 + $1.amount }
    }
    
    func setBudget(for category: String, amount: Double) {
        categoryBudgets[category] = amount
        UserDefaults.standard.set(amount, forKey: "budget_\(category)")
    }
    
    func syncWithFirebase() {
        // Only sync if user is authenticated with email/password
        if Auth.auth().currentUser != nil {
            db = Firestore.firestore()
            listenToTransactions()
            listenToRecurringTransactions()
            
            // Sync existing local data to Firebase
            for transaction in transactions {
                addTransaction(transaction)
            }
            for recurring in recurringTransactions {
                addRecurringTransaction(recurring)
            }
        }
    }
    
    func loadWageHistory() {
        // First try to load from UserDefaults
        if let wageData = UserDefaults.standard.array(forKey: "wageHistory") as? [[String: Any]] {
            wageHistory = wageData.compactMap { dict -> WageHistory? in
                guard
                    let idString = dict["id"] as? String,
                    let id = UUID(uuidString: idString),
                    let hourlyWage = dict["hourlyWage"] as? Double,
                    let startTimeInterval = dict["startDate"] as? TimeInterval
                else {
                    return nil
                }
                
                let startDate = Date(timeIntervalSince1970: startTimeInterval)
                let endDate: Date? = {
                    if let endTimeInterval = dict["endDate"] as? TimeInterval {
                        return Date(timeIntervalSince1970: endTimeInterval)
                    }
                    return nil
                }()
                
                return WageHistory(id: id, hourlyWage: hourlyWage, startDate: startDate, endDate: endDate)
            }
        } else {
            // Initialize with empty array for now due to SwiftData issues
            wageHistory = []
        }
        
        // Optionally listen for wage history from Firebase if authenticated
        listenForWageHistoryFromFirebase()
        
        // When app is stable, uncomment this
        /*
        do {
            let descriptor = FetchDescriptor<WageHistory>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
            wageHistory = try modelContext.fetch(descriptor)
        } catch {
            print("Error loading wage history: \(error)")
            wageHistory = []
        }
        */
    }

    func addWageHistory(_ wage: WageHistory) {
        // If this is set as current wage (no end date), update any existing current wage
        if wage.endDate == nil {
            for existingWage in wageHistory where existingWage.endDate == nil {
                existingWage.endDate = wage.startDate
            }
        }
        
        // Commented out the SwiftData insert for now to avoid the crash
        // modelContext.insert(wage)
        
        // Add to local array
        wageHistory.append(wage)
        
        // Save to UserDefaults as a temporary persistence solution
        saveWageHistoryToUserDefaults()
        
        // Sync to Firebase if user is authenticated
        syncWageHistoryToFirebase(wage)
    }
    
    private func saveWageHistoryToUserDefaults() {
        // Convert wage history to data that can be stored in UserDefaults
        let wageData = wageHistory.map { wage -> [String: Any] in
            var wageDict: [String: Any] = [
                "id": wage.id.uuidString,
                "hourlyWage": wage.hourlyWage,
                "startDate": wage.startDate.timeIntervalSince1970
            ]
            
            if let endDate = wage.endDate {
                wageDict["endDate"] = endDate.timeIntervalSince1970
            }
            
            return wageDict
        }
        
        UserDefaults.standard.set(wageData, forKey: "wageHistory")
    }
    
    private func syncWageHistoryToFirebase(_ wage: WageHistory) {
        // Only sync if user is authenticated with email/password
        if let db = db, let userId = Auth.auth().currentUser?.uid {
            // Convert WageHistory to dictionary for Firestore
            var wageData: [String: Any] = [
                "id": wage.id.uuidString,
                "hourlyWage": wage.hourlyWage,
                "startDate": Timestamp(date: wage.startDate)
            ]
            
            if let endDate = wage.endDate {
                wageData["endDate"] = Timestamp(date: endDate)
            }
            
            // Add to wage_history collection
            db.collection("users").document(userId)
                .collection("wage_history")
                .document(wage.id.uuidString)
                .setData(wageData) { error in
                    if let error = error {
                        print("Error syncing wage history to Firebase: \(error.localizedDescription)")
                    }
                }
        }
    }
    
    private func listenForWageHistoryFromFirebase() {
        guard let userId = Auth.auth().currentUser?.uid, let db = db else { return }
        
        db.collection("users").document(userId)
            .collection("wage_history")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching wage history: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let firebaseWageHistory = documents.compactMap { doc -> WageHistory? in
                    guard
                        let idString = doc.data()["id"] as? String,
                        let id = UUID(uuidString: idString),
                        let hourlyWage = doc.data()["hourlyWage"] as? Double,
                        let startDate = (doc.data()["startDate"] as? Timestamp)?.dateValue()
                    else {
                        return nil
                    }
                    
                    let endDate = (doc.data()["endDate"] as? Timestamp)?.dateValue()
                    
                    return WageHistory(id: id, hourlyWage: hourlyWage, startDate: startDate, endDate: endDate)
                }
                
                // Merge Firebase data with local data
                guard let self = self else { return }
                for firebaseWage in firebaseWageHistory {
                    if !self.wageHistory.contains(where: { $0.id == firebaseWage.id }) {
                        self.wageHistory.append(firebaseWage)
                        // Note: Not inserting into modelContext to avoid crashes
                    }
                }
                
                // Save updated wage history to UserDefaults
                self.saveWageHistoryToUserDefaults()
            }
    }

    func getCurrentWage() -> Double {
        // Find the wage history entry with no end date, or most recent end date
        if let currentWage = wageHistory.first(where: { $0.endDate == nil }) {
            return currentWage.hourlyWage
        } else if let mostRecentWage = wageHistory.sorted(by: { $0.startDate > $1.startDate }).first {
            return mostRecentWage.hourlyWage
        } else {
            return 0 // Default if no wage history exists
        }
    }

    func getWageAt(date: Date) -> Double {
        // Find the wage history entry that covers the given date
        for wage in wageHistory {
            if wage.startDate <= date && (wage.endDate == nil || wage.endDate! >= date) {
                return wage.hourlyWage
            }
        }
        return getCurrentWage() // Default to current wage if no specific entry exists
    }

    func getWorkHoursCost(for amount: Double, at date: Date) -> Double {
        let wage = getWageAt(date: date)
        if wage > 0 {
            return amount / wage
        }
        return 0
    }

    func getWorkHoursCostFormatted(for amount: Double, at date: Date) -> String {
        let hours = getWorkHoursCost(for: amount, at: date)
        
        if hours < 1 {
            // Convert to minutes if less than 1 hour
            let minutes = hours * 60
            return String(format: "%.0f min", minutes)
        } else if hours < 10 {
            // Show with 1 decimal place for clarity
            return String(format: "%.1f hrs", hours)
        } else {
            // Round to nearest hour for larger values
            return String(format: "%.0f hrs", hours)
        }
    }

    func toggleWageCostDisplay() {
        showWageCost.toggle()
        UserDefaults.standard.set(showWageCost, forKey: "showWageCost")
    }
}
