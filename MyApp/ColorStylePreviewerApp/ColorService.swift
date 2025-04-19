//
//  ColorService.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

// MARK: - ColorService.swift

import SwiftUI

struct ColorService {
    static func hexString(from color: Color) -> String? {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        let success = uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)

        guard success else { return nil }

        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
