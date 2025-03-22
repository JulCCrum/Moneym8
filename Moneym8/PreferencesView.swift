//
//  PreferencesView.swift
//  Moneym8
//
//  Updated for Wage History

import SwiftUI

struct PreferencesView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isDarkMode") private var isDarkMode = false
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var viewModel: TransactionViewModel
    
    @State private var showExportAlert = false
    @State private var showDeleteDataAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var showDeleteAccountConfirmation = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Wage related states
    @State private var showAddWageSheet = false
    @State private var showWageHistory = false
    @State private var newWageAmount: String = ""
    @State private var wageStartDate: Date = Date()
    @State private var previousWagePrompt = false
    
    init(viewModel: TransactionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Preferences")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
            
            List {
                Section(header: Text("GENERAL")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    Toggle("Notifications", isOn: .constant(true))
                        .tint(.green)
                }
                
                Section(header: Text("DISPLAY")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .tint(.green)
                }
                
                Section(header: Text("CURRENCY")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    Text("USD ($)")
                }
                
                Section(header: Text("WORK VALUE DISPLAY")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    
                    Toggle("Show time cost of purchases", isOn: Binding(
                        get: { viewModel.showWageCost },
                        set: { _ in viewModel.toggleWageCostDisplay() }
                    ))
                    .tint(.green)
                    
                    HStack {
                        Text("Current hourly wage")
                        Spacer()
                        Text("$\(String(format: "%.2f", viewModel.getCurrentWage()))")
                            .foregroundColor(.gray)
                    }
                    
                    Button("Add New Wage") {
                        showAddWageSheet = true
                    }
                    .foregroundColor(.blue)
                    
                    Button("View Wage History") {
                        showWageHistory = true
                    }
                    .foregroundColor(.blue)
                }
                
                Section(header: Text("BUDGET")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    HStack {
                        Text("Monthly Budget")
                        Spacer()
                        TextField("Enter budget", value: $viewModel.totalBudget, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: viewModel.totalBudget) { _, newValue in
                                viewModel.updateTotalBudget(newValue)
                            }
                    }
                }
                
                Section(header: Text("DATA")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    Button("Export Data") {
                        Task {
                            await exportData()
                        }
                    }
                    .foregroundColor(.blue)
                    
                    Button("Clear All Data") {
                        showDeleteDataAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("ACCOUNT")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))) {
                    Button("Delete Account") {
                        showDeleteAccountAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .preferredColorScheme(isDarkMode ? .dark : .light)
        // Add New Wage Sheet
        .sheet(isPresented: $showAddWageSheet) {
            AddWageView(viewModel: viewModel)
        }
        // Wage History Sheet
        .sheet(isPresented: $showWageHistory) {
            WageHistoryView(viewModel: viewModel)
        }
        // Export Data Alert
        .alert("Export Data", isPresented: $showExportAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Export") {
                Task {
                    await exportData()
                }
            }
        } message: {
            Text("Do you want to export all your transaction data?")
        }
        // Delete Data Alert
        .alert("Clear All Data", isPresented: $showDeleteDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await deleteData()
                }
            }
        } message: {
            Text("Are you sure you want to delete all your data? This action cannot be undone.")
        }
        // Delete Account Initial Alert
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Continue", role: .destructive) {
                showDeleteAccountConfirmation = true
            }
        } message: {
            Text("Would you like to export your data before deleting your account?")
        }
        // Delete Account Confirmation Alert
        .alert("Confirm Delete Account", isPresented: $showDeleteAccountConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Account", role: .destructive) {
                Task {
                    await deleteAccount()
                }
            }
        } message: {
            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
        }
        // Error Alert
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func exportData() async {
        do {
            let csvData = try await authManager.exportUserData()
            
            // Create a temporary URL for the CSV file
            let tempDirectoryURL = FileManager.default.temporaryDirectory
            let fileURL = tempDirectoryURL.appendingPathComponent("moneym8_transactions.csv")
            
            // Write the CSV data to the file
            try csvData.write(to: fileURL)
            
            // Present the share sheet on the main thread
            await MainActor.run {
                let activityVC = UIActivityViewController(
                    activityItems: [fileURL],
                    applicationActivities: nil
                )
                
                // Find the currently visible view controller
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    var currentVC = rootVC
                    while let presentedVC = currentVC.presentedViewController {
                        currentVC = presentedVC
                    }
                    
                    // For iPad
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        activityVC.popoverPresentationController?.sourceView = currentVC.view
                        activityVC.popoverPresentationController?.sourceRect = CGRect(x: currentVC.view.bounds.midX, y: currentVC.view.bounds.midY, width: 0, height: 0)
                    }
                    
                    currentVC.present(activityVC, animated: true)
                }
            }
        }
        catch {
            await MainActor.run {
                errorMessage = "Failed to export data: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    private func deleteData() async {
        do {
            try await authManager.deleteAllUserData()
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func deleteAccount() async {
        do {
            try await authManager.archiveUserAccount()
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// Add Wage View - for adding a new wage entry
struct AddWageView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    
    @State private var hourlyWage: String = ""
    @State private var startDate: Date = Date()
    @State private var askAboutPreviousWage = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Hourly Wage")) {
                    TextField("Amount (e.g., 15.00)", text: $hourlyWage)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Start Date")) {
                    DatePicker("From", selection: $startDate, displayedComponents: [.date])
                }
                
                if startDate < Date() && !viewModel.wageHistory.isEmpty {
                    Section {
                        Toggle("Had a different wage before this?", isOn: $askAboutPreviousWage)
                    }
                }
            }
            .navigationTitle("Add New Wage")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveWage() }
            )
            .alert("Previous Wage", isPresented: $askAboutPreviousWage) {
                Button("No, use this wage") {
                    askAboutPreviousWage = false
                    saveWage(applyToPast: true)
                }
                Button("Yes, I'll add it") {
                    askAboutPreviousWage = false
                    saveWage(applyToPast: false)
                }
            } message: {
                Text("Would you like to apply this wage to all previous transactions or add another wage for the past?")
            }
        }
    }
    
    private func saveWage(applyToPast: Bool = false) {
        guard let wageValue = Double(hourlyWage), wageValue > 0 else { return }
        
        let newWage = WageHistory(
            hourlyWage: wageValue,
            startDate: startDate,
            endDate: nil // This is the current wage
        )
        
        viewModel.addWageHistory(newWage)
        dismiss()
    }
}

// Wage History View - for viewing and editing wage history
struct WageHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.wageHistory.sorted(by: { $0.startDate > $1.startDate })) { wage in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("$\(String(format: "%.2f", wage.hourlyWage))/hr")
                                .font(.headline)
                            
                            Text(formatDateRange(start: wage.startDate, end: wage.endDate))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        if wage.endDate == nil {
                            Text("Current")
                                .font(.caption)
                                .padding(4)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    // Delete wage history entries
                    let toDelete = indexSet.map { viewModel.wageHistory.sorted(by: { $0.startDate > $1.startDate })[$0] }
                    for wage in toDelete {
                        if let index = viewModel.wageHistory.firstIndex(where: { $0.id == wage.id }) {
                            viewModel.modelContext.delete(viewModel.wageHistory[index])
                        }
                    }
                    // Save changes
                    try? viewModel.modelContext.save()
                    viewModel.loadWageHistory()
                }
            }
            .navigationTitle("Wage History")
            .navigationBarItems(
                leading: Button("Done") { dismiss() }
            )
        }
    }
    
    private func formatDateRange(start: Date, end: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let startStr = dateFormatter.string(from: start)
        
        if let end = end {
            let endStr = dateFormatter.string(from: end)
            return "\(startStr) to \(endStr)"
        } else {
            return "From \(startStr)"
        }
    }
}

#Preview {
    PreferencesView(viewModel: TransactionViewModel())
}
