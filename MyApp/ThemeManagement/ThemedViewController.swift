//
//  ThemedViewController.swift
//  MyApp
//
//  Created by Cong Le on 12/15/24.
//

import UIKit

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

        // Layout code here...
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
    
    
//    func toggleTheme(_ sender: UISwitch) {
//        if sender.isOn {
//            ThemeManager.shared.currentTheme = DarkTheme()
//        } else {
//            ThemeManager.shared.currentTheme = LightTheme()
//        }
//    }

}
