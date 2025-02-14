//
//  BaseTheme.swift
//  MyApp
//
//  Created by Cong Le on 12/15/24.
//

import UIKit

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
