//
//  UIkitTheme.swift
//  MyApp
//
//  Created by Cong Le on 12/15/24.
//

import UIKit

// MARK: - Theme Protocol

protocol Theme {
    var backgroundColor: UIColor { get }
    var textColor: UIColor { get }
    var tintColor: UIColor { get }
    var font: UIFont { get }
    var cornerRadius: CGFloat { get }
}

// MARK: - BaseTheme Abstract Class

class BaseTheme: Theme {
    var backgroundColor: UIColor {
        fatalError("Subclasses need to implement the `backgroundColor` property.")
    }
    
    var textColor: UIColor {
        fatalError("Subclasses need to implement the `textColor` property.")
    }
    
    var tintColor: UIColor {
        fatalError("Subclasses need to implement the `tintColor` property.")
    }
    
    var font: UIFont {
        fatalError("Subclasses need to implement the `font` property.")
    }
    
    var cornerRadius: CGFloat {
        return 8.0
    }
}

// MARK: - LightTheme Class

class LightTheme: BaseTheme {
    override var backgroundColor: UIColor {
        return .white
    }
    
    override var textColor: UIColor {
        return .black
    }
    
    override var tintColor: UIColor {
        return UIColor.systemBlue
    }
    
    override var font: UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .regular)
    }
}

// MARK: - DarkTheme Class

class DarkTheme: BaseTheme {
    override var backgroundColor: UIColor {
        return UIColor(white: 0.1, alpha: 1.0)
    }
    
    override var textColor: UIColor {
        return .white
    }
    
    override var tintColor: UIColor {
        return UIColor.systemYellow
    }
    
    override var font: UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .regular)
    }
}

// MARK: - CustomTheme Class

class CustomTheme: Theme {
    let backgroundColor: UIColor
    let textColor: UIColor
    let tintColor: UIColor
    let font: UIFont
    let cornerRadius: CGFloat
    
    init(
        backgroundColor: UIColor,
        textColor: UIColor,
        tintColor: UIColor,
        font: UIFont,
        cornerRadius: CGFloat
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.tintColor = tintColor
        self.font = font
        self.cornerRadius = cornerRadius
    }
}

// MARK: - ThemeManager Singleton

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
            // Handle custom theme loading if necessary
            currentTheme = LightTheme()
        }
    }
}

// MARK: - Notification Name Extension

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}

// MARK: - UIView Extensions

extension UIView {
    func applyUIViewTheme() {
        backgroundColor = ThemeManager.shared.currentTheme.backgroundColor
        layer.cornerRadius = ThemeManager.shared.currentTheme.cornerRadius
        tintColor = ThemeManager.shared.currentTheme.tintColor
    }
}

// MARK: - UILabel Extensions

extension UILabel {
    @objc func applyUILabelTheme() {
        textColor = ThemeManager.shared.currentTheme.textColor
        font = ThemeManager.shared.currentTheme.font
        adjustsFontForContentSizeCategory = true
    }
}

// MARK: - UIButton Extensions

extension UIButton {
    @objc func applyUIButtonTheme() {
        setTitleColor(ThemeManager.shared.currentTheme.textColor, for: .normal)
        backgroundColor = ThemeManager.shared.currentTheme.backgroundColor
        titleLabel?.font = ThemeManager.shared.currentTheme.font
        layer.cornerRadius = ThemeManager.shared.currentTheme.cornerRadius
        tintColor = ThemeManager.shared.currentTheme.tintColor
    }
}

// MARK: - Themed View Controller

class ThemedViewController: UIViewController {
    // UI Elements
    let titleLabel = UILabel()
    let actionButton = UIButton(type: .system)
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyTheme()
        addThemeObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Add and layout UI elements
        view.addSubview(titleLabel)
        view.addSubview(actionButton)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout code here...
        // For example purposes, we'll just set frames
        titleLabel.frame = CGRect(x: 50, y: 100, width: 200, height: 40)
        actionButton.frame = CGRect(x: 50, y: 160, width: 200, height: 40)
        
        titleLabel.text = "Themed Label"
        actionButton.setTitle("Themed Button", for: .normal)
    }
    
    // MARK: - Theme Methods
    func applyTheme() {
        view.applyUIViewTheme()
        titleLabel.applyUILabelTheme()
        actionButton.applyUIButtonTheme()
    }
    
    private func addThemeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeTheme),
            name: .themeDidChange,
            object: nil
        )
    }
    
    @objc private func didChangeTheme() {
        UIView.animate(withDuration: 0.3) {
            self.applyTheme()
        }
    }
}

// MARK: - Example Usage

class ViewController: ThemedViewController {
    let themeSwitch = UISwitch()
    let themeSwitchLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupThemeSwitch()
    }
    
    private func setupThemeSwitch() {
        view.addSubview(themeSwitch)
        view.addSubview(themeSwitchLabel)
        themeSwitch.translatesAutoresizingMaskIntoConstraints = false
        themeSwitchLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout code...
        themeSwitch.frame = CGRect(x: 50, y: 220, width: 50, height: 30)
        themeSwitchLabel.frame = CGRect(x: 110, y: 220, width: 200, height: 30)
        
        themeSwitchLabel.text = "Dark Mode"
        themeSwitchLabel.applyUILabelTheme()
        
        themeSwitch.addTarget(self, action: #selector(toggleTheme(_:)), for: .valueChanged)
        
        // Set initial state based on current theme
        themeSwitch.isOn = ThemeManager.shared.currentTheme is DarkTheme
    }
    
    @objc func toggleTheme(_ sender: UISwitch) {
        if sender.isOn {
            ThemeManager.shared.currentTheme = DarkTheme()
        } else {
            ThemeManager.shared.currentTheme = LightTheme()
        }
    }
}

// MARK: - App Delegate (For SwiftUI-less Projects)
//
//@main
//class AppDelegate: UIResponder, UIApplicationDelegate {
//    var window: UIWindow?
//   
//    func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//    ) -> Bool {
//        let window = UIWindow(frame: UIScreen.main.bounds)
//        let viewController = ViewController()
//        
//        window.rootViewController = viewController
//        window.makeKeyAndVisible()
//        self.window = window
//        
//        return true
//    }
//}
