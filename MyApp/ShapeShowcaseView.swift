//
//  ShapeShowcaseView.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI

// Main ContentView to showcase various shapes and styles
struct ShapeShowcaseView: View {
    @State private var rotationAngle: Double = 0
    @State private var scaleFactor: CGFloat = 1.0
    @State private var trimEnd: CGFloat = 1.0

    // Example path
    var customPath: Path {
        Path { path in
            path.move(to: CGPoint(x: 50, y: 0))
            path.addLine(to: CGPoint(x: 100, y: 100))
            path.addQuadCurve(to: CGPoint(x: 0, y: 100), control: CGPoint(x: 50, y: 150))
            path.closeSubpath()
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {

                // --- Basic Shapes ---
                Group {
                    Text("Basic Shapes").font(.title).padding(.bottom)

                    HStack(spacing: 20) {
                        Rectangle()
                            .fill(.blue)
                            .frame(width: 50, height: 50)
                            .overlay(Text("Rect").foregroundColor(.white).font(.caption))

                        Circle()
                            .fill(.red)
                            .frame(width: 50, height: 50)
                             .overlay(Text("Circle").foregroundColor(.white).font(.caption))

                        Ellipse()
                            .fill(.green)
                            .frame(width: 80, height: 50)
                             .overlay(Text("Ellipse").foregroundColor(.white).font(.caption))

                        Capsule()
                            .fill(.orange)
                            .frame(width: 80, height: 50)
                             .overlay(Text("Capsule").foregroundColor(.white).font(.caption))
                        Capsule(style: .circular)
                            .fill(.purple)
                            .frame(width: 80, height: 50)
                             .overlay(Text("Circular").foregroundColor(.white).font(.caption))
                    }
                     .frame(maxWidth: .infinity) // Center the HStack

                    HStack(spacing: 20) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.cyan)
                            .frame(width: 80, height: 50)
                             .overlay(Text("Rounded").foregroundColor(.black).font(.caption))

                        // Uneven Rounded Rectangle (iOS 16+)
                        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                            UnevenRoundedRectangle(
                                topLeadingRadius: 5,
                                bottomLeadingRadius: 15,
                                bottomTrailingRadius: 5,
                                topTrailingRadius: 15,
                                style: .continuous
                            )
                            .fill(.mint)
                            .frame(width: 80, height: 50)
                             .overlay(Text("Uneven").foregroundColor(.black).font(.caption))
                        } else {
                            Text("UnevenRoundedRectangle requires iOS 16+").font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity) // Center the HStack
                }

                Divider()

                // --- Path ---
                Group {
                    Text("Path").font(.title).padding(.bottom)
                    customPath
                        .stroke(.indigo, lineWidth: 3)
                        .frame(height: 150)
                        .overlay(Text("Custom Path").font(.caption).offset(y: -60))
                }

                Divider()

                // --- Filling Shapes ---
                Group {
                    Text("Fills").font(.title).padding(.bottom)
                    HStack(spacing: 20) {
                        Circle().fill(.linearGradient(colors: [.yellow, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 50, height: 50)
                            .overlay(Text("Linear").font(.caption).foregroundColor(.black))

                        Circle().fill(.radialGradient(colors: [.blue, .black], center: .center, startRadius: 5, endRadius: 25))
                            .frame(width: 50, height: 50)
                            .overlay(Text("Radial").font(.caption).foregroundColor(.white))

                        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
                              Circle().fill(.angularGradient(colors: [.green, .blue, .purple, .green], center: .center))
                                .frame(width: 50, height: 50)
                                .overlay(Text("Angular").font(.caption).foregroundColor(.white))

                            // Material Fill (iOS 15+) - Needs a background to see the effect
                            ZStack {
                                LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom)
                                    .frame(width: 60, height: 60) // Background for Material
                                Circle()
                                    .fill(.regularMaterial)
                                    .frame(width: 50, height: 50)
                                    .overlay(Text("Material").font(.caption).foregroundColor(.primary))
                            } .frame(height: 60) // Container for Material demo

                        } else {
                             Text("Angular/Material requires iOS 15+/macOS 12+").font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                Divider()

                 // --- Strokes ---
                Group {
                    Text("Strokes").font(.title).padding(.bottom)
                    HStack(spacing: 20) {
                         Rectangle()
                            .stroke(.orange, lineWidth: 5)
                            .frame(width: 50, height: 50)
                            .overlay(Text("Simple").font(.caption))

                        Rectangle()
                            .stroke(
                                Color.purple,
                                style: StrokeStyle(
                                    lineWidth: 4,
                                    lineCap: .round,
                                    lineJoin: .miter,
                                    dash: [5, 5] // 5 points painted, 5 points empty
                                )
                            )
                            .frame(width: 50, height: 50)
                            .overlay(Text("Dashed").font(.caption))
                    }
                    .frame(maxWidth: .infinity)
                }

                Divider()

                // --- Stroke Borders (for InsettableShape) ---
                Group {
                     Text("Stroke Borders (InsettableShape)").font(.title).padding(.bottom)
                     HStack(spacing: 20) {
                        Capsule()
                            .strokeBorder(.teal, lineWidth: 8) // Border inside the shape
                            .frame(width: 80, height: 50)
                            .overlay(Text("Capsule Border").font(.caption))

                        RoundedRectangle(cornerRadius: 10)
                             .strokeBorder(
                                 .linearGradient(colors: [.mint, .cyan], startPoint: .leading, endPoint: .trailing),
                                 style: StrokeStyle(lineWidth: 5, dash: [10, 5])
                             )
                             .frame(width: 80, height: 50)
                             .overlay(Text("RR Border").font(.caption))
                     }
                     .frame(maxWidth: .infinity)
                }

                 Divider()

                // --- Shape Transforms ---
                Group {
                    Text("Transforms").font(.title).padding(.bottom)

                    VStack(spacing: 20) {
                         // Offset
                        HStack {
                            Text("Offset:")
                            Rectangle()
                                .fill(.brown)
                                .frame(width: 50, height: 30)
                                .offset(x: 20, y: 10)
                                .border(.gray) // Show original frame
                                .frame(width: 100, height: 50) // Container for context
                        }

                         // Scale
                         HStack {
                            Text("Scale:")
                            Rectangle()
                                .fill(.magenta)
                                .frame(width: 40, height: 40)
                                .scaleEffect(scaleFactor, anchor: .bottomTrailing)
                                .animation(.easeInOut, value: scaleFactor)
                                .onTapGesture { scaleFactor = (scaleFactor == 1.0 ? 1.5 : 1.0) }
                                .border(.gray)
                                .frame(width: 100, height: 60) // Container
                         }

                        // Rotation
                         HStack {
                            Text("Rotation:")
                            Rectangle()
                                .fill(.yellow)
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(rotationAngle))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotationAngle)
                                .onAppear { rotationAngle = 360 }
                                .border(.gray)
                                .frame(width: 100, height: 60) // Container
                         }

                        // Transform (Affine)
                        HStack {
                            Text("Affine Transform:")
                            Rectangle()
                                .fill(.gray)
                                .frame(width: 40, height: 40)
                                .transformEffect(.init(rotationAngle: .pi / 4).concatenating(.init(scaleX: 1.2, y: 0.8)))
                                .border(.gray)
                                .frame(width: 100, height: 60) // Container
                         }
                     }
                     .frame(maxWidth: .infinity, alignment: .leading)
                }

                Divider()

                // --- Trim ---
                Group {
                    Text("Trim").font(.title).padding(.bottom)
                     VStack {
                        Circle()
                            .trim(from: 0, to: trimEnd)
                            .stroke(.blue, lineWidth: 5)
                            .frame(width: 100, height: 100)
                            .animation(.easeInOut(duration: 1.5), value: trimEnd)
                            .onTapGesture { trimEnd = (trimEnd == 1.0 ? 0.25 : 1.0) }

                        Text("Tap circle to Trim (Currently: \(trimEnd, specifier: "%.2f"))").font(.caption)
                    }
                     .frame(maxWidth: .infinity)
                }

                 Divider()

                 // --- InsettableShape ---
                 Group {
                     Text("InsettableShape").font(.title).padding(.bottom)
                     HStack(spacing: 20) {
                         Rectangle()
                             .inset(by: 10) // Creates an inset Rectangle
                             .fill(.red.opacity(0.5))
                             .frame(width: 70, height: 70)
                             .border(.gray)
                             .overlay(Text("Inset Rect").font(.caption))

                         Circle()
                             .inset(by: 5)
                             .stroke(.green, lineWidth: 2)
                             .frame(width: 70, height: 70)
                             .border(.gray)
                              .overlay(Text("Inset Circ").font(.caption))
                     }
                     .frame(maxWidth: .infinity)
                 }

            } // End Main VStack
            .padding()
        } // End ScrollView
        .navigationTitle("SwiftUI Shapes") // Add a title if used within NavigationView
    }
}

// Simple Star Shape for demos
struct StarShape: Shape {
     let points: Int
     let smoothness: CGFloat // Adjust for pointedness

     init(points: Int = 5, smoothness: CGFloat = 0.4) {
         self.points = points
         self.smoothness = smoothness.clamped(to: 0...1) // Ensure smoothness is between 0 and 1
     }

     func path(in rect: CGRect) -> Path {
         guard points >= 2 else { return Path() }

         let center = CGPoint(x: rect.midX, y: rect.midY)
         let outerRadius = min(rect.width, rect.height) / 2
         let innerRadius = outerRadius * smoothness

         let angleIncrement = .pi * 2 / CGFloat(points)

         var path = Path()

         for i in 0..<points {
             let angle = CGFloat(i) * angleIncrement - .pi / 2
             let outerPoint = CGPoint(
                 x: center.x + outerRadius * cos(angle),
                 y: center.y + outerRadius * sin(angle)
             )

             let innerAngle = angle + angleIncrement / 2
             let innerPoint = CGPoint(
                 x: center.x + innerRadius * cos(innerAngle),
                 y: center.y + innerRadius * sin(innerAngle)
             )

             if i == 0 {
                 path.move(to: outerPoint)
             } else {
                 path.addLine(to: outerPoint)
             }
             path.addLine(to: innerPoint)
         }
         path.closeSubpath()
         return path
     }
 }

 extension CGFloat {
     func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
         return min(max(self, range.lowerBound), range.upperBound)
     }
 }

// Preview Provider
#Preview {
    NavigationView { // Wrap in NavigationView for title display
        ShapeShowcaseView()
    }
}
