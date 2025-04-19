//
//  ColorPalette.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

// MARK: - ColorPalette.swift

import SwiftUI

enum PaletteType: String, CaseIterable, Identifiable {
    case displayP3 = "Display P3"
    case extendedRange = "Extended Range"
    case hsb = "HSB"
    case grayscale = "Grayscale"

    var id: String { rawValue }
}
