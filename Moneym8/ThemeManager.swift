//
//  ThemeManager.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/8/24.
//
import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") private(set) var isDarkMode: Bool = false
    @AppStorage("isSystemTheme") private(set) var isSystemTheme: Bool = true
    
    func toggleDarkMode() {
        isDarkMode.toggle()
        isSystemTheme = false
        applyTheme()
    }
    
    func useSystemTheme() {
        isSystemTheme = true
        applyTheme()
    }
    
    private func applyTheme() {
        // For iOS 13 and later, this will automatically handle the theme
        // based on our isDarkMode and isSystemTheme settings
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = isSystemTheme ? .unspecified : (isDarkMode ? .dark : .light)
            }
        }
    }
}
