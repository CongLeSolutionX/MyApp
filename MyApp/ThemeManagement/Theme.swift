//
//  Theme.swift
//  MyApp
//
//  Created by Cong Le on 12/15/24.
//

import UIKit

protocol Theme {
    var backgroundColor: UIColor { get }
    var textColor: UIColor { get }
    var tintColor: UIColor { get }
    var font: UIFont { get }
    var cornerRadius: CGFloat { get }
}
