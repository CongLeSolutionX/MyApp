//
//  SynthwaveView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct SynthwaveView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: - Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.9, green: 0.2, blue: 0.5), // Pink/Fuchsia
                        Color(red: 0.3, green: 0.1, blue: 0.6), // Dark Purple
                        Color.black
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // MARK: - Sun/Glow
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.8, blue: 0.4, opacity: 0.8), // Light Yellow
                                Color(red: 1.0, green: 0.5, blue: 0.0, opacity: 0.0)  // Fade to Transparent Orange
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.2
                        )
                    )
                    .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.65) // Position near-ish the horizon
                    .blur(radius: 20)

                // MARK: - Planets and Moons (Simplified)

                // Large Planet
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.4, green: 0.2, blue: 0.8), // Dark Purple
                                Color(red: 0.7, green: 0.3, blue: 0.9)  // Lighter Purple
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.2)
                    .shadow(color: .purple, radius: 15, x: 0, y: 0)

                // Smaller Moons (simplified as circles with basic colors)
                Group {
                    Circle()
                        .fill(Color(red: 0.9, green: 0.5, blue: 0.7)) // Pinkish
                        .frame(width: geometry.size.width * 0.05, height: geometry.size.width * 0.05)
                        .position(x: geometry.size.width * 0.7, y: geometry.size.height * 0.15)
                        .shadow(color: .pink, radius: 5, x: 0, y: 0)
                    
                    Circle()
                        .fill(Color(red: 0.6, green: 0.4, blue: 0.7)) // Lighter Purple
                        .frame(width: geometry.size.width * 0.08, height: geometry.size.width * 0.08)
                        .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.1)
                        .shadow(color: .purple, radius: 8, x: 0, y: 0)
                }
                
                // MARK: - Horizontal Grid Lines
                VStack(spacing: 20) {
                    ForEach(0..<10) { _ in
                        Rectangle()
                            .fill(
                                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.6), .pink.opacity(0.6)]), startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(height: 1)
                            .frame(maxWidth: geometry.size.width * 0.9)
                            .opacity(0.7)
                    }
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.2)

                // MARK: - Cityscape (Simplified)
                VStack {
                    Spacer()  // Push the cityscape to the bottom
                    HStack(spacing: 4) {
                        ForEach(0..<15) { _ in
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.1, green: 0.4, blue: 0.6), // Dark Teal/Blue
                                            Color(red: 0.2, green: 0.1, blue: 0.4)   // Darker Purple
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: geometry.size.width * 0.05, height: CGFloat.random(in: 50...150)) // Varying heights
                                .shadow(color: .black, radius: 2, x:0, y:0)
                        }
                    }
                    .padding(.bottom, 20) // Add some padding from the very bottom
                }

                // MARK: - Road and Car (Simplified)
                VStack {
                    Spacer()
                    // Road
                    ZStack {
                        // Main Road
                        GeometryReader { roadGeometry in
                            Path { path in
                                path.move(to: CGPoint(x: roadGeometry.size.width * 0.45, y: 0))
                                path.addLine(to: CGPoint(x: roadGeometry.size.width * 0.55, y: 0))
                                path.addLine(to: CGPoint(x: roadGeometry.size.width, y: roadGeometry.size.height))
                                path.addLine(to: CGPoint(x: 0, y: roadGeometry.size.height))
                                path.closeSubpath()
                            }
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        Gradient.Stop(color: Color(red: 0.6, green: 0.1, blue: 0.4), location: 0),     // Dark Pink
                                        Gradient.Stop(color: Color.black, location: 0.8)    //Fade to Black
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            
                            // Road Lines
                            Path { path in
                                path.move(to: CGPoint(x: roadGeometry.size.width * 0.5, y: 0))
                                path.addLine(to: CGPoint(x: roadGeometry.size.width * 0.5, y: roadGeometry.size.height))
                            }
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 10]))
                            .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.0)) // Yellow
                            
                            
                        }
                    }
                    .frame(height: geometry.size.height * 0.3) // Road occupies lower 30%

                    // Car (Very Simplified)
                    Rectangle()
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [.cyan, .purple]), startPoint: .leading, endPoint: .trailing))
                    .frame(width: 60, height: 30)
                    .offset(y: -20) // Position the car slightly above the road
                    .shadow(radius: 5)

                }

                // MARK: - Flying Objects/UFOs
                Group{
                    drawUFO(at: CGPoint(x: geometry.size.width * 0.2, y: geometry.size.height * 0.3), size: geometry.size, in: geometry)
                    drawUFO(at: CGPoint(x: geometry.size.width * 0.8, y: geometry.size.height * 0.4), size: geometry.size, in: geometry)
                    drawUFO(at: CGPoint(x: geometry.size.width * 0.4, y: geometry.size.height * 0.25), size: geometry.size, in: geometry)
                    drawUFO(at: CGPoint(x: geometry.size.width * 0.6, y: geometry.size.height * 0.35), size: geometry.size, in: geometry)
                    drawUFO(at: CGPoint(x: geometry.size.width * 0.1, y: geometry.size.height * 0.1), size: geometry.size, in: geometry)
                    
                }
                
            }
        }
    }
    // MARK: - UFO Helper Function
    func drawUFO(at position: CGPoint, size: CGSize, in geometry: GeometryProxy) -> some View {
        ZStack{
            Ellipse()
                .fill(Color.gray.opacity(0.7))
                .frame(width: size.width * 0.08, height: size.width * 0.04)
                .shadow(color: .black, radius: 2, x: 0, y: 0)
            
            Ellipse()
                .fill(Color.white.opacity(0.8))
                .frame(width: size.width * 0.04, height: size.width * 0.02)
                .offset(y: -size.width * 0.01)
        }
        .position(position)
    }
}

struct SynthwaveView_Previews: PreviewProvider {
    static var previews: some View {
        SynthwaveView()
    }
}
