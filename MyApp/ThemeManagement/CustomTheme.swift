//
//  CustomTheme.swift
//  MyApp
//
//  Created by Cong Le on 12/15/24.
//

import UIKit

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
