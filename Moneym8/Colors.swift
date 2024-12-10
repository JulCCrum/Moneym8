//
//  Colors.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/9/24.
//
//
import SwiftUI

extension Color {
    static let appGreen = Color(hex: "01a624")
    
    // Dynamic colors that change based on mode
    static let appBackground = Color(
        light: .white,
        dark: .black
    )
    
    static let appCardBackground = Color(
        light: .white,
        dark: Color(hex: "1d1f1d")
    )
    
    static let appText = Color(
        light: .black,
        dark: .white
    )
    
    static let appSecondaryText = Color(
        light: .gray,
        dark: Color(hex: "a0a0a0") // Lighter gray for dark mode
    )
    
    // Button and UI Element Colors
    static let appDropdownBackground = Color(
        light: Color(hex: "f0f0f0"),
        dark: Color(hex: "2c2c2c") // Lighter background for dropdowns in dark mode
    )
    
    static let appNavigationButton = Color(
        light: .black,
        dark: .white
    )
    
    // Category Summary Box Colors - Dark Mode
    static let rentBox = Color(
        light: Color.blue.opacity(0.3),
        dark: Color.blue.opacity(0.3)
    )
    
    static let foodBox = Color(
        light: Color.green.opacity(0.3),
        dark: Color.green.opacity(0.3)
    )
    
    static let transportationBox = Color(
        light: Color.orange.opacity(0.3),
        dark: Color.orange.opacity(0.3)
    )
    
    static let otherBox = Color(
        light: Color.purple.opacity(0.3),
        dark: Color.purple.opacity(0.3)
    )
    
    // Floating Action Button Colors
    static let floatingActionButtonIcon = Color(
        light: .black,
        dark: .white
    )
    
    static let floatingActionButtonBackground = Color(
        light: .black,
        dark: Color(hex: "404040") // Light gray for dark mode
    )
    
    // Tab Bar Icons
    static let tabBarSelected = Color(
        light: .black,
        dark: .white
    )
    
    static let tabBarUnselected = Color(
        light: .gray,
        dark: Color(hex: "808080")
    )
    
    // Helper to create color from hex
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Initialize with different colors for light/dark mode
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(
            light: UIColor(light),
            dark: UIColor(dark)
        ))
    }
}

extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light:
                return light
            case .dark:
                return dark
            case .unspecified:
                return light
            @unknown default:
                return light
            }
        }
    }
}
