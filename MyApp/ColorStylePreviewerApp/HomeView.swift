////
////  HomeView.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//// MARK: - HomeView.swift
//
//import SwiftUI
//
//struct HomeView: View {
//    @State private var selectedPalette: PaletteType = .displayP3
//    @State private var selectedColor: ColorItem? = nil
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                PalettePickerView(selected: $selectedPalette)
//
//                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 15) {
//                    ForEach(ColorPalettes.colors(for: selectedPalette)) { colorItem in
//                        ColorCell(colorItem: colorItem) {
//                            selectedColor = colorItem
//                        }
//                    }
//                }
//
//                if let selected = selectedColor {
//                    ColorDetailPreview(colorItem: selected)
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Color Style Previewer")
//        .sheet(item: $selectedColor) { color in
//            ColorDetailSheet(colorItem: color)
//        }
//    }
//}
