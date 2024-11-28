////
////  AnimatedRetroMeshGradientView.swift
////  MyApp
////
////  Created by Cong Le on 11/27/24.
////
//
//import SwiftUI
//
//struct AnimatedRetroMeshGradientView: View {
//    // Retro 80s color palette
//    private let retroColors: [Color] = [
//        Color(red: 255/255, green: 105/255, blue: 180/255), // Hot Pink
//        Color(red:   0/255, green: 128/255, blue: 128/255), // Teal
//        Color(red: 191/255, green:  64/255, blue: 191/255), // Electric Purple
//        Color(red: 255/255, green: 255/255, blue:   0/255), // Neon Yellow
//        Color(red:   0/255, green:   0/255, blue:   0/255), // Black
//        Color(red: 255/255, green: 140/255, blue:   0/255), // Sunset Orange
//        Color(red:  51/255, green: 255/255, blue: 153/255), // Miami Green
//        Color(red:   0/255, green: 127/255, blue: 255/255), // Synthwave Blue
//        Color(red: 255/255, green:   0/255, blue: 204/255)  // Cyber Pink
//    ]
//    
//    // State variables for colors and points
//    @State private var colors: [Color] = []
//    @State private var points: [CGPoint] = []
//    
//    // Timer for triggering animations
//    private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
//    
//    // Initialization
//    init() {
//        // Initialize with random colors and points
//        _colors = State(initialValue: Self.generateRandomColors())
//        _points = State(initialValue: Self.generateRandomPoints())
//    }
//    
//    var body: some View {
//        if #available(iOS 18, *) {
//            GeometryReader { geometry in
//                MeshGradient(
//                    colors: colors,
//                    points: points,
//                    meshType: .bilinear
//                )
//                .animation(.easeInOut(duration: 4), value: colors)
//                .animation(.easeInOut(duration: 4), value: points)
//                .onReceive(timer) { _ in
//                    // Update colors and points with animation
//                    withAnimation {
//                        colors = Self.generateRandomColors()
//                        points = Self.generateRandomPoints()
//                    }
//                }
//                .edgesIgnoringSafeArea(.all)
//            }
//        } else {
//            Text("MeshGradient requires iOS 18.0 or later.")
//                .font(.headline)
//                .padding()
//        }
//    }
//    
//    // Static methods to generate random colors and points
//    private static func generateRandomColors() -> [Color] {
//        (0..<9).map { _ in
//            let colorIndex = Int.random(in: 0..<9)
//            return Self().retroColors[colorIndex]
//        }
//    }
//    
//    private static func generateRandomPoints() -> [CGPoint] {
//        (0..<9).map { _ in
//            CGPoint(x: CGFloat.random(in: 0...1), y: CGFloat.random(in: 0...1))
//        }
//    }
//}
//
//#Preview {
//    AnimatedRetroMeshGradientView()
//}
