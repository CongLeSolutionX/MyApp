//
//  PalettePickerView.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

// MARK: - PalettePickerView.swift

import SwiftUI

struct PalettePickerView: View {
    @Binding var selected: PaletteType

    var body: some View {
        Picker("Color Palette", selection: $selected) {
            ForEach(PaletteType.allCases) { palette in
                Text(palette.rawValue).tag(palette)
            }
        }
        .pickerStyle(.segmented)
    }
}
