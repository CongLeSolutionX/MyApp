//
//  SamplePalettes.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

// MARK: - SamplePalettes.swift

import SwiftUI

struct ColorItem: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

struct ColorPalettes {
    static let displayP3: [ColorItem] = [
        .init(name: "Vibrant Red", color: Color(.displayP3, red: 1.0, green: 0.1, blue: 0.1)),
        .init(name: "Lush Green", color: Color(.displayP3, red: 0.1, green: 0.9, blue: 0.2)),
        .init(name: "Deep Blue", color: Color(.displayP3, red: 0.1, green: 0.2, blue: 0.95)),
        .init(name: "Bright Magenta", color: Color(.displayP3, red: 0.95, green: 0.1, blue: 0.8))
    ]

    static let extendedRange: [ColorItem] = [
        .init(name: "Ultra White", color: Color(.sRGB, white: 1.1)),
        .init(name: "Intense Red", color: Color(.sRGB, red: 1.2, green: 0, blue: 0)),
        .init(name: "Deeper Than Black", color: Color(.sRGB, white: -0.1))
    ]

    static let hsb: [ColorItem] = [
        .init(name: "Sunshine Yellow", color: Color(hue: 0.15, saturation: 0.9, brightness: 1.0)),
        .init(name: "Sky Blue", color: Color(hue: 0.6, saturation: 0.7, brightness: 0.9)),
        .init(name: "Forest Green", color: Color(hue: 0.35, saturation: 0.8, brightness: 0.6)),
        .init(name: "Fiery Orange", color: Color(hue: 0.08, saturation: 1.0, brightness: 1.0))
    ]

    static let grayscale: [ColorItem] = [
        .init(name: "Light Gray", color: Color(white: 0.8)),
        .init(name: "Medium Gray", color: Color(white: 0.5)),
        .init(name: "Dark Gray", color: Color(white: 0.2))
    ]

    static func colors(for palette: PaletteType) -> [ColorItem] {
        switch palette {
        case .displayP3: return displayP3
        case .extendedRange: return extendedRange
        case .hsb: return hsb
        case .grayscale: return grayscale
        }
    }
}
