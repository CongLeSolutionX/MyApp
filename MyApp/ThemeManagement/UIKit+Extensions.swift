//
//  UIView+Extensions.swift
//  MyApp
//
//  Created by Cong Le on 12/15/24.

import UIKit


extension UIView {
    func applyUIViewTheme() {
        backgroundColor = ThemeManager.shared.currentTheme.backgroundColor
        layer.cornerRadius = ThemeManager.shared.currentTheme.cornerRadius
        tintColor = ThemeManager.shared.currentTheme.tintColor
    }
}

extension UILabel {
    @objc func applyUILabelTheme() {
        textColor = ThemeManager.shared.currentTheme.textColor
        font = ThemeManager.shared.currentTheme.font
    }
}


extension UIButton {
    @objc func applyUIButtonTheme() {
        setTitleColor(ThemeManager.shared.currentTheme.textColor, for: .normal)
        backgroundColor = ThemeManager.shared.currentTheme.backgroundColor
        titleLabel?.font = ThemeManager.shared.currentTheme.font
        layer.cornerRadius = ThemeManager.shared.currentTheme.cornerRadius
        tintColor = ThemeManager.shared.currentTheme.tintColor
    }
}
