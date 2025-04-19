////
////  ColorPaletteDemoView.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import SwiftUI
//
//// MARK: - Data Models
//
//struct ColorItem: Identifiable, Equatable {
//    let id = UUID()
//    let name: String
//    let color: Color
//    let hexCode: String
//}
//
//// MARK: - Utility: Extract Hex String from Color
//
//extension Color {
//    // Helper to get hex code for display / copying purposes
//    func toHex() -> String {
//        // Convert Color to UIColor, then extract components
//        #if os(iOS)
//        let uiColor = UIColor(self)
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        var alpha: CGFloat = 0
//        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//        return String(format: "#%02X%02X%02X",
//                      Int(red * 255),
//                      Int(green * 255),
//                      Int(blue * 255))
//        #else
//        return "#FFFFFF" // fallback
//        #endif
//    }
//}
//
//// MARK: - Main View
//
//struct ColorPaletteDemoView: View {
//    // Mock data: all colors
//    let displayP3Colors: [ColorItem] = [
//        ColorItem(name: "Vibrant Red", color: Color(.displayP3, red: 1.0, green: 0.1, blue: 0.1), hexCode: ""),
//        ColorItem(name: "Lush Green", color: Color(.displayP3, red: 0.1, green: 0.9, blue: 0.2), hexCode: ""),
//        ColorItem(name: "Deep Blue", color: Color(.displayP3, red: 0.1, green: 0.2, blue: 0.95), hexCode: ""),
//        ColorItem(name: "Bright Magenta", color: Color(.displayP3, red: 0.95, green: 0.1, blue: 0.8), hexCode: "")
//    ]
//    
//    let extendedRangeColors: [ColorItem] = [
//        ColorItem(name: "Ultra White (>1.0)", color: Color(.sRGB, white: 1.1), hexCode: ""),
//        ColorItem(name: "Intense Red (>1.0)", color: Color(.sRGB, red: 1.2, green: 0, blue: 0), hexCode: ""),
//        ColorItem(name: "Deeper Than Black (<0.0)", color: Color(.sRGB, white: -0.1), hexCode: "")
//    ]
//    
//    let hsbColors: [ColorItem] = [
//        ColorItem(name: "Sunshine Yellow", color: Color(hue: 0.15, saturation: 0.9, brightness: 1.0), hexCode: ""),
//        ColorItem(name: "Sky Blue", color: Color(hue: 0.6, saturation: 0.7, brightness: 0.9), hexCode: ""),
//        ColorItem(name: "Forest Green", color: Color(hue: 0.35, saturation: 0.8, brightness: 0.6), hexCode: ""),
//        ColorItem(name: "Fiery Orange", color: Color(hue: 0.08, saturation: 1.0, brightness: 1.0), hexCode: "")
//    ]
//    
//    let grayscaleColors: [ColorItem] = [
//        ColorItem(name: "Light Gray", color: Color(white: 0.8), hexCode: ""),
//        ColorItem(name: "Medium Gray", color: Color(white: 0.5), hexCode: ""),
//        ColorItem(name: "Dark Gray", color: Color(white: 0.2), hexCode: "")
//    ]
//
//    // State for selected color to show detail / copy action
//    @State private var selectedColor: ColorItem?
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                colorSection(title: "Display P3 Colors", colors: displayP3Colors)
//                colorSection(title: "Extended Range Colors", colors: extendedRangeColors)
//                colorSection(title: "HSB Colors", colors: hsbColors)
//                colorSection(title: "Grayscale Colors", colors: grayscaleColors)
//
//                if let selected = selectedColor {
//                    ColorDetailView(colorItem: selected)
//                        .transition(.move(edge: .bottom))
//                }
//
//                Spacer()
//            }
//            .padding()
//            .animation(.easeInOut, value: selectedColor)
//            .navigationTitle("Color Palettes & Demo")
//        }
//    }
//
//    // Helper: Panel for each section
//    func colorSection(title: String, colors: [ColorItem]) -> some View {
//        VStack(alignment: .leading) {
//            Text(title)
//                .font(.title2)
//                .padding(.bottom, 5)
//            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
//                ForEach(colors) { item in
//                    ColorSquareView(colorItem: item) {
//                        // On tap toggle selection
//                        withAnimation {
//                            selectedColor = item
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Color Square View
//
//struct ColorSquareView: View {
//    let colorItem: ColorItem
//    let onTap: () -> Void
//    @State private var isCopied = false
//
//    var body: some View {
//        VStack {
//            Rectangle()
//                .fill(colorItem.color)
//                .frame(height: 50)
//                .cornerRadius(8)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                )
//                .onTapGesture {
//                    onTap()
//                }
//                .contextMenu {
//                    Button(action: {
//                        UIPasteboard.general.string = colorItem.hexCode
//                        isCopied = true
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            isCopied = false
//                        }
//                    }) {
//                        Label("Copy Hex Code", systemImage: "doc.on.doc")
//                    }
//                }
//            Text(colorItem.name)
//                .font(.caption)
//                .multilineTextAlignment(.center)
//                .lineLimit(2)
//                .padding(.top, 2)
//            if isCopied {
//                Text("Copied!")
//                    .font(.caption2)
//                    .foregroundColor(.green)
//            }
//        }
//    }
//}
//
//// MARK: - Color Detail View with Hex and Copy Button
//
//struct ColorDetailView: View {
//    let colorItem: ColorItem
//    @State private var isCopied = false
//
//    var body: some View {
//        VStack(alignment: .center, spacing: 10) {
//            RoundedRectangle(cornerRadius: 12)
//                .fill(colorItem.color)
//                .frame(height: 150)
//                .shadow(radius: 4)
//
//            Text(colorItem.name)
//                .font(.headline)
//
//            // Display the hex code
//            HStack {
//                TextField("Hex Code", text: .constant(colorItem.hexCode))
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .disabled(true)
//                Button(action: {
//                    UIPasteboard.general.string = colorItem.hexCode
//                    isCopied = true
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
//                        isCopied = false
//                    }
//                }) {
//                    Image(systemName: "doc.on.doc")
//                        .font(.title2)
//                }
//            }
//            if isCopied {
//                Text("Hex code copied")
//                    .font(.caption)
//                    .foregroundColor(.green)
//            }
//            Spacer()
//        }
//        .padding()
//        .background(Color(UIColor.systemBackground))
//        .cornerRadius(12)
//        .shadow(radius: 8)
//        .padding()
//    }
//}
//
//// MARK: - Entry Point for Live Preview / App
////
////@main
////struct ColorPalettesApp: App {
////    var body: some Scene {
////        WindowGroup {
////            NavigationView {
////                ColorPaletteDemoView()
////            }
////        }
////    }
////}
//
//// MARK: - Preview
//
//struct ColorPaletteDemoView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ColorPaletteDemoView()
//        }
//    }
//}
