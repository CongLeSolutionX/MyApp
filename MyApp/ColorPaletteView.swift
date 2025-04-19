////
////  ColorPaletteView.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import SwiftUI
//
//// --- Model ---
//
//// A simple Color model to handle accessible details
//struct ColorDetail: Identifiable, Hashable {
//    var id = UUID()
//    let name: String
//    let color: Color
//    let rgbValues: (Double, Double, Double)
//    let description: String
//}
//
//// --- Data Source ---
//
//extension ColorDetail {
//    static let sampleData: [ColorDetail] = [
//        .init(name: "Vibrant Red", color: DisplayP3Palette.vibrantRed, rgbValues: (1.0, 0.1, 0.1), description: "A vibrant red perfect for attention-grabbing accents."),
//        .init(name: "Lush Green", color: DisplayP3Palette.lushGreen, rgbValues: (0.1, 0.9, 0.2), description: "A lush green ideal for outdoor themes."),
//        .init(name: "Deep Blue", color: DisplayP3Palette.deepBlue, rgbValues: (0.1, 0.2, 0.95), description: "A deep, calming blue suitable for relaxation."),
//        // Add more ColorDetail objects as needed
//    ]
//}
//
//// --- View ---
//
//struct ColorPaletteView: View {
//    @State private var favorites = Set<ColorDetail>()
//    @State private var selectedColor: ColorDetail? = nil
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                ColorSelectionView
//                FavoriteColorsView
//                Spacer()
//            }
//            .navigationTitle("Enhanced Color Palettes")
//            .padding()
//        }
//    }
//    
//    private var ColorSelectionView: some View {
//        VStack(alignment: .leading) {
//            Text("Color Selection")
//                .font(.headline)
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack {
//                    ForEach(ColorDetail.sampleData) { colorDetail in
//                        VStack {
//                            Rectangle()
//                                .fill(colorDetail.color)
//                                .frame(width: 100, height: 100)
//                                .cornerRadius(10)
//                            Button(action: {
//                                withAnimation {
//                                    toggleFavorite(for: colorDetail)
//                                }
//                            }) {
//                                Image(systemName: favorites.contains(colorDetail) ? "heart.fill" : "heart")
//                                    .foregroundColor(favorites.contains(colorDetail) ? .red : .gray)
//                            }
//                            .padding(.top, 5)
//                            
//                            Text(colorDetail.name)
//                                .font(.caption)
//                        }
//                        .onTapGesture {
//                            withAnimation {
//                                selectedColor = colorDetail
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .padding()
//        .background(RoundedRectangle(cornerRadius: 8).fill(Color(white: 0.95)))
//    }
//    
//    private var FavoriteColorsView: some View {
//        VStack(alignment: .leading) {
//            Text("Favorite Colors")
//                .font(.headline)
//            
//            if favorites.isEmpty {
//                Text("No favorites yet.")
//                    .foregroundColor(.gray)
//                    .padding(.top)
//            } else {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack {
//                        ForEach(Array(favorites)) { colorDetail in
//                            VStack {
//                                Rectangle()
//                                    .fill(colorDetail.color)
//                                    .frame(width: 80, height: 80)
//                                    .cornerRadius(8)
//                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
//                                
//                                Text(colorDetail.name)
//                                    .font(.caption)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .padding()
//        .background(RoundedRectangle(cornerRadius: 8).fill(Color(white: 0.95)))
//    }
//    
//    private func toggleFavorite(for color: ColorDetail) {
//        if favorites.contains(color) {
//            favorites.remove(color)
//        } else {
//            favorites.insert(color)
//        }
//    }
//}
//
//// --- Preview ---
//
//#Preview {
//    ColorPaletteView()
//}
