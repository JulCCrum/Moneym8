//
//  PreferencesView.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/8/24.

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

#Preview {
    PreferencesView(viewModel: TransactionViewModel())
}
