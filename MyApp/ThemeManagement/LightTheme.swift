//
//  LightTheme.swift
//  MyApp
//
//  Created by Cong Le on 12/15/24.
//

import UIKit

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

//    override var font: UIFont {
//        return UIFont.systemFont(ofSize: 16, weight: .regular)
//    }
    
    override var font: UIFont {
        return UIFont.preferredFont(forTextStyle: .body)
    }
}
