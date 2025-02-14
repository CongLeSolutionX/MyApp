//
//  ViewController.swift
//  MyApp
//
//  Created by Cong Le on 12/15/24.
//

import UIKit

class ThemableViewController: ThemedViewController {
    let themeSwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupThemeSwitch()
    }

    private func setupThemeSwitch() {
        view.addSubview(themeSwitch)
        themeSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            themeSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            themeSwitch.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            
        ])

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
