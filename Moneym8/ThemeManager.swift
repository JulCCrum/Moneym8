//
//  ThemeManager.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/8/24.
//
import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false {
        didSet {
            applyTheme()
        }
    }
    
    @AppStorage("isSystemTheme") var isSystemTheme: Bool = true {
        didSet {
            applyTheme()
        }
    }
    
    init() {
        applyTheme()
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
        isSystemTheme = false
    }
    
    func useSystemTheme() {
        isSystemTheme = true
    }
    
    private func applyTheme() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = isSystemTheme ?
                    .unspecified : (isDarkMode ? .dark : .light)
            }
        }
    }
}
