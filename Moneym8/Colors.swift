//
//  Colors.swift
//  Moneym8
//
//  Created by chase Crummedyo on 11/9/24.
//
import SwiftUI

extension Color {

    // MARK: - Single-Parameter Hex Initializer
    //  Renamed to init(hexString:) to avoid collisions with the dynamic init(light:dark:)
    init(hexString: String) {
        let hex = hexString
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // #RGB (12-bit)
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )
        case 6: // #RRGGBB (24-bit)
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        case 8: // #AARRGGBB (32-bit)
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        default:
            (a, r, g, b) = (255, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - Dynamic Light/Dark Initializer
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(
            light: UIColor(light),
            dark:  UIColor(dark)
        ))
    }

    // MARK: - Brand & Dynamic Colors
    
    /// A brand green color from hex: #01a624
    static let appGreen = Color(hexString: "01a624")
    
    /// Example of a dynamic color that changes in Light vs. Dark mode.
    static let appBackground = Color(
        light: .white,
        dark: .black
    )
    
    static let appCardBackground = Color(
        light: .white,
        dark: Color(hexString: "1d1f1d") // <--- Notice hexString
    )
    
    static let appText = Color(
        light: .black,
        dark: .white
    )
    
    static let appSecondaryText = Color(
        light: .gray,
        dark: Color(hexString: "a0a0a0")
    )
    
    // Buttons / UI Element Colors
    static let appDropdownBackground = Color(
        light: Color(hexString: "f0f0f0"),
        dark:  Color(hexString: "2c2c2c")
    )
    
    static let appNavigationButton = Color(
        light: .black,
        dark: .white
    )
    
    // Category Summary Box Colors
    static let rentBox = Color(
        light: Color.blue.opacity(0.3),
        dark:  Color.blue.opacity(0.3)
    )
    
    static let foodBox = Color(
        light: Color.green.opacity(0.3),
        dark:  Color.green.opacity(0.3)
    )
    
    static let transportationBox = Color(
        light: Color.orange.opacity(0.3),
        dark:  Color.orange.opacity(0.3)
    )
    
    static let otherBox = Color(
        light: Color.purple.opacity(0.3),
        dark:  Color.purple.opacity(0.3)
    )
    
    // Floating Action Button Colors
    static let floatingActionButtonIcon = Color(
        light: .black,
        dark: .white
    )
    
    static let floatingActionButtonBackground = Color(
        light: .black,
        dark: Color(hexString: "404040")
    )
    
    // Tab Bar Icons
    static let tabBarSelected = Color(
        light: .black,
        dark: .white
    )
    
    static let tabBarUnselected = Color(
        light: .gray,
        dark: Color(hexString: "808080")
    )
}

// MARK: - UIColor Extension
extension UIColor {
    /// A convenience initializer that picks `light` or `dark`
    /// depending on the current userInterfaceStyle.
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return dark
            default:
                return light
            }
        }
    }
}
