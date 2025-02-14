//
//  ThemeManager.swift
//  MyApp
//
//  Created by Cong Le on 12/15/24.
//
import UIKit

//class ThemeManager {
//    static let shared = ThemeManager()
//
//    private init() { }
//
//    var currentTheme: Theme = LightTheme() {
//        didSet {
//            NotificationCenter.default.post(name: .themeDidChange, object: nil)
//        }
//    }
//}
class ThemeManager {
    static let shared = ThemeManager()

    private init() {
        loadTheme()
    }

    var currentTheme: Theme = LightTheme() {
        didSet {
            NotificationCenter.default.post(name: .themeDidChange, object: nil)
            saveTheme()
        }
    }

    private func saveTheme() {
        let themeName: String

        switch currentTheme {
        case is LightTheme:
            themeName = "Light"
        case is DarkTheme:
            themeName = "Dark"
        default:
            themeName = "Custom"
        }

        UserDefaults.standard.set(themeName, forKey: "SelectedTheme")
    }

    private func loadTheme() {
        let themeName = UserDefaults.standard.string(forKey: "SelectedTheme") ?? "Light"

        switch themeName {
        case "Light":
            currentTheme = LightTheme()
        case "Dark":
            currentTheme = DarkTheme()
        default:
            // Handle custom theme
            currentTheme = LightTheme()
        }
    }
}

// MARK: - Extension
extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}
