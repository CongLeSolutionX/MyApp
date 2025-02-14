//
//  DarkTheme.swift
//  MyApp
//
//  Created by Cong Le on 12/15/24.
//

import UIKit

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

//    override var font: UIFont {
//        return UIFont.systemFont(ofSize: 16, weight: .regular)
//    }
    override var font: UIFont {
        return UIFont.preferredFont(forTextStyle: .body)
    }
}
