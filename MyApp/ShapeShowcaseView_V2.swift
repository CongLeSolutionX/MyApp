////
////  ShapeShowcaseView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/12/25.
////
//
//import SwiftUI
//
//// Main ContentView to showcase various shapes and styles
//struct ShapeShowcaseView: View {
//    @State private var rotationAngle: Double = 0
//    @State private var scaleFactor: CGFloat = 1.0
//    @State private var trimEnd: CGFloat = 1.0
//    
//    // Example path - demonstrates Path drawing capabilities
//    var customPath: Path {
//        Path { path in
//            path.move(to: CGPoint(x: 50, y: 0)) // Start point
//            path.addLine(to: CGPoint(x: 100, y: 100)) // Add Line
//            // Add quadratic curve
//            path.addQuadCurve(to: CGPoint(x: 0, y: 100), control: CGPoint(x: 50, y: 150))
//            // Add cubic curve
//            path.addCurve(to: CGPoint(x: 50, y: 0), control1: CGPoint(x: 0, y: 50), control2: CGPoint(x: 50, y: 50))
//            path.closeSubpath() // Close the shape
//        }
//    }
//    
//    // Example Path using other shapes
//    var compositePath: Path {
//        Path { path in
//            // Add a rectangle subpath
//            path.addRect(CGRect(x: 10, y: 10, width: 80, height: 80))
//            // Add an ellipse subpath
//            path.addEllipse(in: CGRect(x: 30, y: 30, width: 40, height: 60))
//            // Add another path
//            let subPath = Path(roundedRect: CGRect(x: 50, y: 50, width: 50, height: 50), cornerRadius: 10)
//            path.addPath(subPath, transform: .init(translationX: 20, y: 0))
//        }
//    }
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 35) { // Increased spacing
//                
//                // --- Basic Shapes ---
//                SectionHeader(title: "Basic Shapes")
//                AdaptiveHStack { // Use AdaptiveHStack for better responsiveness
//                    Rectangle()
//                        .fill(.blue)
//                        .frame(width: 60, height: 60) // Slightly larger
//                        .overlay(ShapeLabel("Rectangle"))
//                    
//                    Circle()
//                        .fill(.red)
//                        .frame(width: 60, height: 60)
//                        .overlay(ShapeLabel("Circle"))
//                    
//                    Ellipse()
//                        .fill(.green)
//                        .frame(width: 90, height: 60)
//                        .overlay(ShapeLabel("Ellipse"))
//                    
//                    Capsule(style: .continuous) // Specify style explicitly
//                        .fill(.orange)
//                        .frame(width: 90, height: 60)
//                        .overlay(ShapeLabel("Capsule\n(Continuous)"))
//                    
//                    Capsule(style: .circular)
//                        .fill(.purple)
//                        .frame(width: 90, height: 60)
//                        .overlay(ShapeLabel("Capsule\n(Circular)"))
//                }
//                
//                AdaptiveHStack {
//                    RoundedRectangle(cornerRadius: 15, style: .continuous) // Specify style
//                        .fill(.cyan)
//                        .frame(width: 90, height: 60)
//                        .overlay(ShapeLabel("RoundedRect"))
//                    
//                    // Uneven Rounded Rectangle (iOS 16+)
//                    if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
//                        UnevenRoundedRectangle(
//                            cornerRadii: .init(
//                                topLeading: 5,
//                                bottomLeading: 20,
//                                bottomTrailing: 5,
//                                topTrailing: 20
//                            ),
//                            style: .continuous
//                        )
//                        .fill(.mint)
//                        .frame(width: 90, height: 60)
//                        .overlay(ShapeLabel("Uneven"))
//                    } else {
//                        Text("UnevenRoundedRectangle\nrequires iOS 16+").font(.caption).frame(width: 90, height: 60)
//                    }
//                    
//                    // ContainerRelativeShape (iOS 14+)
//                    if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
//                        ZStack { // Example container
//                            RoundedRectangle(cornerRadius: 10).fill(.gray.opacity(0.2))
//                            ContainerRelativeShape()
//                                .inset(by: 5) // Inset from container
//                                .fill(.pink)
//                                .overlay(ShapeLabel("Container\nRelative"))
//                        }
//                        .frame(width: 90, height: 60)
//                        .containerShape(RoundedRectangle(cornerRadius: 10)) // Define container shape
//                    } else {
//                        Text("ContainerRelativeShape\nrequires iOS 14+").font(.caption).frame(width: 90, height: 60)
//                    }
//                }
//                
//                Divider()
//                
//                // --- Path ---
//                SectionHeader(title: "Path")
//                HStack {
//                    VStack {
//                        customPath
//                            .stroke(.indigo, lineWidth: 3)
//                            .background(customPath.fill(.indigo.opacity(0.1))) // Add light fill
//                            .frame(width: 100, height: 150)
//                        Text("Custom Path (Drawing)").font(.caption)
//                    }
//                    Spacer() // Pushes paths apart
//                    VStack{
//                        Path(CGRect(x: 0, y: 0, width: 100, height: 100)) // Path from CGRect
//                            .stroke(.black, lineWidth: 1)
//                            .background(Path(ellipseIn: CGRect(x: 10, y: 10, width: 80, height: 80)).fill(.teal.opacity(0.5))) // Path from Ellipse
//                            .frame(width: 100, height: 100)
//                        Text("Path (Init)").font(.caption)
//                    }
//                    Spacer() // Pushes paths apart
//                    VStack{
//                        compositePath // Demonstrate adding other paths/shapes
//                            .stroke(.brown, lineWidth: 2)
//                            .frame(width: 120, height: 120)
//                        Text("Composite Path").font(.caption)
//                    }
//                }.frame(height: 170)
//                
//                Divider()
////                
////                // --- Filling Shapes ---
////                SectionHeader(title: "Fills with ShapeStyle")
////                AdaptiveHStack {
////                    ShapeFillExample(shape: Circle(), style: AnyShapeStyle(.blue), description: "Color")
////                    ShapeFillExample(shape: Rectangle(), style: AnyShapeStyle(.linearGradient(colors: [.yellow, .red], startPoint: .topLeading, endPoint: .bottomTrailing)), description: "Linear")
////                    ShapeFillExample(shape: Ellipse(), style: AnyShapeStyle(.radialGradient(colors: [.blue, .black], center: .center, startRadius: 5, endRadius: 25)), description: "Radial")
////                    
////                    // Conditional compilation for newer styles
////                    if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
////                        ShapeFillExample(
////                            shape: Capsule(),
////                            style: AnyShapeStyle(
////                                .angularGradient( // Using the ShapeStyle extension
////                                    colors: [.green, .blue, .purple, .green],
////                                    center: .center,
////                                    startAngle: .degrees(0),   // <<< Added
////                                    endAngle: .degrees(360)  // <<< Added
////                                                )
////                            ),
////                            description: "Angular"
////                        )
////                        
////                        ShapeFillExample(shape: RoundedRectangle(cornerRadius: 5), style: AnyShapeStyle(.ellipticalGradient(colors: [.orange, .indigo], center: .bottom, startRadiusFraction: 0.1, endRadiusFraction: 0.6)), description: "Elliptical")
////                        
////                        // Material requires a background to show effect
////                        ZStack {
////                            Image(systemName: "photo.fill") // Example Background
////                                .resizable().scaledToFill().frame(width: 80, height: 60).opacity(0.5)
////                            ShapeFillExample(shape: Circle(), style: AnyShapeStyle(.thinMaterial), description: "Material")
////                        }.frame(width: 80, height: 60) // Container for Material
////                    }
////                    
////                    // Foreground/Background/Tint Styles
////                    ShapeFillExample(shape: StarShape(), style: AnyShapeStyle(.foreground), description: "Foreground Style").foregroundColor(.pink) // Context color
////                    
////                    ShapeFillExample(shape: StarShape(), style: AnyShapeStyle(.background), description: "Background Style") // Context specific
////                    if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
////                        ShapeFillExample(shape: StarShape(), style: AnyShapeStyle(.tint), description: "Tint Style").tint(.green) // Context tint
////                    }
////                    
////                    // Hierarchical Styles (iOS 15+)
////                    if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
////                        VStack {
////                            ShapeFillExample(shape: StarShape(smoothness: 0.5), style: AnyShapeStyle(.primary), description: "Primary")
////                            ShapeFillExample(shape: StarShape(smoothness: 0.5), style: AnyShapeStyle(.secondary), description: "Secondary")
////                            ShapeFillExample(shape: StarShape(smoothness: 0.5), style: AnyShapeStyle(.tertiary), description: "Tertiary")
////                        }.foregroundStyle(.purple) // Base style for hierarchy
////                            .frame(width:80) // Layout adjustment for VStack
////                        
////                    }
////                }
////                
////                Divider()
////                
////                // --- Strokes ---
////                SectionHeader(title: "Strokes with ShapeStyle")
////                AdaptiveHStack {
////                    ShapeStrokeExample(shape: Rectangle(), style: AnyShapeStyle(.orange), strokeStyle: StrokeStyle(lineWidth: 5), description: "Simple Stroke\n(Color)")
////                    ShapeStrokeExample(
////                        shape: Circle(),
////                        style: AnyShapeStyle(.linearGradient(colors: [.mint, .cyan], startPoint: .top, endPoint: .bottom)),
////                        strokeStyle: StrokeStyle(lineWidth: 6, lineCap: .round, dash: [10, 5]),
////                        description: "Dashed Stroke\n(Gradient)"
////                    )
////                }
////                
////                Divider()
////                
////                // --- Stroke Borders (for InsettableShape) ---
////                SectionHeader(title: "Stroke Borders (InsettableShape)")
////                AdaptiveHStack {
////                    ShapeStrokeBorderExample(
////                        shape: Capsule(style: .circular),
////                        style: AnyShapeStyle(.teal),
////                        strokeStyle: StrokeStyle(lineWidth: 8),
////                        description: "Capsule Border\n(Color)"
////                    )
////                    ShapeStrokeBorderExample(
////                        shape: RoundedRectangle(cornerRadius: 12),
////                        style: AnyShapeStyle(.foreground), // Use foreground color
////                        strokeStyle: StrokeStyle(lineWidth: 4, lineJoin: .round, dash: [2, 4, 6, 4], dashPhase: 10),
////                        description: "RoundedRect\nBorder (Fg)"
////                    ).foregroundColor(.indigo) // Set foreground for the border
////                    
////                }
////                
////                Divider()
////                
////                // --- Shape Transforms ---
////                SectionHeader(title: "Shape Transforms")
////                VStack(alignment: .leading, spacing: 20) {
////                    TransformExample(label: "Offset", shape: Rectangle().fill(.brown)) { shape in
////                        shape.offset(x: 25, y: 15)
////                    }
////                    TransformExample(label: "Scale", shape: Ellipse().fill(.magenta)) { shape in
////                        shape.scale(scaleFactor, anchor: .bottomTrailing)
////                            .animation(.easeInOut, value: scaleFactor)
////                            .onTapGesture { scaleFactor = (scaleFactor == 1.0 ? 1.5 : 1.0) }
////                            .overlay(Text("Tap").font(.caption2)) // Indication
////                    }
////                    TransformExample(label: "Rotation", shape: RoundedRectangle(cornerRadius: 5).fill(.yellow)) { shape in
////                        shape.rotation(.degrees(rotationAngle), anchor: .center)
////                            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotationAngle)
////                            .onAppear { rotationAngle = 360 }
////                    }
////                    TransformExample(label: "Affine Transform", shape: Circle().fill(.gray)) { shape in
////                        shape.transform(.init(rotationAngle: .pi / 6).concatenating(.init(scaleX: 1.3, y: 0.7)).concatenating(.init(translationX: 10, y: 5)))
////                    }
////                }
////                
////                Divider()
////                
////                // --- Trim ---
////                SectionHeader(title: "Trim")
////                VStack {
////                    HStack {
////                        Circle()
////                            .trim(from: 0, to: trimEnd)
////                            .stroke(.blue, style: StrokeStyle(lineWidth: 5, lineCap: .round)) // Rounded cap
////                            .frame(width: 100, height: 100)
////                        
////                        Path { path in // Trim custom path
////                            path.move(to: CGPoint(x: 0, y: 50))
////                            path.addCurve(to: CGPoint(x: 100, y: 50), control1: CGPoint(x: 40, y: 0), control2: CGPoint(x: 60, y: 100))
////                        }
////                        .trim(from: 0.1, to: trimEnd)
////                        .stroke(.green, lineWidth: 4)
////                        .frame(width: 100, height: 100)
////                        
////                    }
////                    Text("Tap shapes to Trim (Currently: \(trimEnd, specifier: "%.2f"))").font(.caption)
////                }
////                .frame(maxWidth: .infinity)
////                .onTapGesture {
////                    withAnimation(.easeInOut(duration: 1.0)) {
////                        trimEnd = (trimEnd == 1.0 ? Double.random(in: 0.1...0.9) : 1.0)
////                    }
////                }
////                
////                Divider()
////                
////                // --- InsettableShape ---
////                SectionHeader(title: "InsettableShape .inset(by:)")
////                AdaptiveHStack {
////                    ZStack {
////                        Rectangle().stroke(.gray, dashed: [2,2])
////                        Rectangle()
////                            .inset(by: 10) // Creates an inset Rectangle
////                            .fill(.red.opacity(0.5))
////                    }.frame(width: 70, height: 70)
////                        .overlay(ShapeLabel("Inset\nRect"))
////                    
////                    ZStack {
////                        Circle().stroke(.gray, dashed: [2,2])
////                        Circle()
////                            .inset(by: 5)
////                            .stroke(.green, lineWidth: 2)
////                    }.frame(width: 70, height: 70)
////                        .overlay(ShapeLabel("Inset\nCirc"))
////                    
////                    ZStack {
////                        Capsule(style: .circular).stroke(.gray, dashed: [2,2])
////                        Capsule(style: .circular)
////                            .inset(by: 8)
////                            .fill(.blue.opacity(0.6))
////                    }.frame(width: 90, height: 50)
////                        .overlay(ShapeLabel("Inset\nCapsule"))
////                }
////                
//            } // End Main VStack
//            .padding()
//        } // End ScrollView
//        .navigationTitle("SwiftUI Shapes") // Add a title if used within NavigationView
//    }
//}
//
//// --- Helper Views for Showcase ---
//
//struct SectionHeader: View {
//    let title: String
//    var body: some View {
//        Text(title)
//            .font(.headline)
//            .padding(.vertical, 5)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(Color.gray.opacity(0.1)) // Subtle background
//    }
//}
//
//struct ShapeLabel: View {
//    let text: String
//    init(_ text: String) { self.text = text }
//    var body: some View {
//        Text(text)
//            .font(.caption)
//            .multilineTextAlignment(.center)
//            .padding(2)
//            .background(.black.opacity(0.5)) // Background for readability
//            .foregroundColor(.white)
//            .cornerRadius(3)
//    }
//}
//
//// Helper to demonstrate fills easily
//struct ShapeFillExample<S: Shape, SS: ShapeStyle>: View {
//    let shape: S
//    let style: SS
//    let description: String
//    
//    var body: some View {
//        shape
//            .fill(style)
//            .frame(width: 80, height: 60) // Consistent size
//            .overlay(ShapeLabel(description))
//            .overlay( // Add subtle border for clarity
//                shape.stroke(.gray.opacity(0.5), lineWidth: 0.5)
//            )
//    }
//}
//// Helper to demonstrate strokes easily
//struct ShapeStrokeExample<S: Shape, SS: ShapeStyle>: View {
//    let shape: S
//    let style: SS
//    let strokeStyle: StrokeStyle
//    let description: String
//    
//    var body: some View {
//        shape
//            .stroke(style, style: strokeStyle)
//            .frame(width: 80, height: 60)
//            .overlay(ShapeLabel(description))
//            .background( // Add faint background shape for context
//                shape.fill(.gray.opacity(0.1))
//            )
//    }
//}
//
//// Helper to demonstrate stroke borders easily
//struct ShapeStrokeBorderExample<S: InsettableShape, SS: ShapeStyle>: View {
//    let shape: S
//    let style: SS
//    let strokeStyle: StrokeStyle
//    let description: String
//    
//    var body: some View {
//        shape
//            .strokeBorder(style, style: strokeStyle)
//            .frame(width: 80, height: 60)
//            .overlay(ShapeLabel(description))
//            .background( // Add faint background shape for context
//                shape.fill(.gray.opacity(0.1))
//            )
//    }
//}
//
//// Helper to demonstrate transforms easily
//struct TransformExample<S: Shape, T: View>: View {
//    let label: String
//    let shape: S
//    let transform: (S) -> T // Closure applies the transform
//    
//    var body: some View {
//        HStack {
//            Text("\(label):").frame(width: 120, alignment: .trailing)
//            ZStack { // Use ZStack to show original position with border
//                shape
//                    .stroke(.gray.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [2])) // Dashed indicating original space
//                    .frame(width: 60, height: 40) // Original frame
//                
//                transform(shape) // Apply the transform to the original shape
//                    .frame(width: 60, height: 40) // Apply same frame for positioning context
//                
//            }.frame(width: 100, height: 60) // Container to hold transformed shape
//        }
//    }
//}
//
//// Helper for responsive horizontal layout
//struct AdaptiveHStack<Content: View>: View {
//    @Environment(\.horizontalSizeClass) var horizontalSizeClass
//    let content: Content
//    
//    init(@ViewBuilder content: () -> Content) {
//        self.content = content()
//    }
//    
//    var body: some View {
//        if horizontalSizeClass == .compact {
//            VStack(alignment: .center, spacing: 20) { content }
//                .frame(maxWidth:.infinity)
//        } else {
//            HStack(alignment: .top, spacing: 20) { content }
//                .frame(maxWidth:.infinity)
//        }
//    }
//}
//
//// --- Custom Shape Used in Examples ---
//struct StarShape: View {
//    // Using View to easily apply styles, could also be just a Shape
//    let points: Int
//    let smoothness: CGFloat // Adjust for pointedness
//    
//    init(points: Int = 5, smoothness: CGFloat = 0.4) {
//        self.points = points
//        self.smoothness = smoothness.clamped(to: 0...1) // Ensure smoothness is between 0 and 1
//    }
//    
//    var body: some View {
//        StarPath(points: points, smoothness: smoothness) // Internal Path-based shape
//    }
//    
//    // Inner struct conforming to Shape for the path logic
//    private struct StarPath: Shape {
//        let points: Int
//        let smoothness: CGFloat
//        
//        func path(in rect: CGRect) -> Path {
//            guard points >= 2 else { return Path() }
//            
//            let center = CGPoint(x: rect.midX, y: rect.midY)
//            let outerRadius = min(rect.width, rect.height) / 2
//            let innerRadius = outerRadius * smoothness
//            
//            let angleIncrement = .pi * 2 / CGFloat(points)
//            
//            var path = Path()
//            
//            for i in 0..<points {
//                let angle = CGFloat(i) * angleIncrement - .pi / 2
//                let outerPoint = CGPoint(
//                    x: center.x + outerRadius * cos(angle),
//                    y: center.y + outerRadius * sin(angle)
//                )
//                
//                let innerAngle = angle + angleIncrement / 2
//                let innerPoint = CGPoint(
//                    x: center.x + innerRadius * cos(innerAngle),
//                    y: center.y + innerRadius * sin(innerAngle)
//                )
//                
//                if i == 0 {
//                    path.move(to: outerPoint)
//                } else {
//                    path.addLine(to: outerPoint)
//                }
//                path.addLine(to: innerPoint)
//            }
//            path.closeSubpath()
//            return path
//        }
//    }
//}
//
//// --- Helper Extensions ---
//extension CGFloat {
//    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
//        return CGFloat.min(CGFloat.max(self, range.lowerBound), range.upperBound)
//    }
//}
//
//// --- Preview ---
//#Preview {
//    NavigationView {
//        ShapeShowcaseView()
//    }
//}
