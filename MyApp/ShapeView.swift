//
//  ShapeView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI

// --- Core Protocols ---

// Shape: Base protocol for 2D shapes. Requires path(in:) method.
// InsettableShape: A shape that can be inset. Inherits from Shape.
// ShapeStyle: Defines how to fill or stroke a shape (Colors, Gradients, etc.).

// --- Concrete Shape Examples ---

struct BasicShapesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Basic Shapes").font(.title)
            
            Rectangle()
                .fill(.blue)
                .frame(width: 100, height: 50)
                .overlay(Text("Rectangle").foregroundColor(.white))
            
            Circle()
                .stroke(.red, lineWidth: 5)
                .frame(width: 50, height: 50)
                .overlay(Text("Circle"))
            
            Ellipse()
                .fill(.green)
                .frame(width: 100, height: 50)
                .overlay(Text("Ellipse").foregroundColor(.white))
            
            Capsule()
                .fill(.orange)
                .frame(width: 120, height: 50)
                .overlay(Text("Capsule").foregroundColor(.white))
            
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(.purple, lineWidth: 3)
                .frame(width: 150, height: 50)
                .overlay(Text("RoundedRectangle"))
            
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: 10,
                        bottomLeading: 0,
                        bottomTrailing: 20,
                        topTrailing: 5
                    ),
                    style: .continuous
                )
                .fill(.cyan)
                .frame(width: 150, height: 50)
                .overlay(Text("UnevenRounded").font(.caption).foregroundColor(.white))
            }
        }
        .padding()
    }
}

// --- Path Example ---

struct CustomPathView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Path").font(.title)
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 100, y: 0))
                path.addQuadCurve(to: CGPoint(x: 50, y: 100), control: CGPoint(x: 125, y: 25))
                path.addLine(to: CGPoint(x: 0, y: 100))
                path.closeSubpath() // Closes back to (0,0)
            }
            .fill(.yellow)
            .frame(height: 100)
            .overlay(Text("Custom Path (Fill)"))
            
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 100, y: 50))
                path.addArc(center: CGPoint(x: 100, y: 100),
                            radius: 50,
                            startAngle: .degrees(270),
                            endAngle: .degrees(90),
                            clockwise: true) // Note: clockwise in user space is counter-clockwise on screen
            }
            .stroke(.indigo, lineWidth: 4)
            .frame(height: 150)
            .overlay(Text("Custom Path (Stroke)"))
        }
        .padding()
    }
}

// --- Shape Transformations ---

struct TransformedShapesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Transformed Shapes").font(.title)
            
            // OffsetShape
            Circle()
                .fill(.red.opacity(0.5))
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .offset(x: 15, y: 15) // Creates OffsetShape internally
                        .fill(.blue.opacity(0.5))
                        .frame(width: 50, height: 50)
                        .overlay(Text("Offset"))
                )
                .frame(width: 80, height: 80) // Frame for visualizing original position
            
            // RotatedShape
            Rectangle()
                .fill(.green.opacity(0.5))
                .frame(width: 60, height: 40)
                .rotationEffect(.degrees(30), anchor: .center) // Creates RotatedShape internally
                .overlay(Text("Rotated"))
                .frame(width: 80, height: 80)
            
            // ScaledShape
            Capsule()
                .fill(.purple.opacity(0.5))
                .frame(width: 80, height: 30)
                .scaleEffect(0.7, anchor: .center) // Creates ScaledShape internally
                .overlay(Text("Scaled"))
                .frame(width: 100, height: 50)
            
            // TransformedShape (usually via Path)
            let transform = CGAffineTransform(rotationAngle: .pi / 6).scaledBy(x: 0.8, y: 0.8)
            Path(ellipseIn: CGRect(x: 0, y: 0, width: 60, height: 40))
                .applying(transform) // Creates TransformedShape path element
                .fill(.orange.opacity(0.5))
                .overlay(Text("Transformed Path"))
                .frame(width: 80, height: 80)
            
            
        }
        .padding()
    }
}

// --- ContainerRelativeShape Example ---
struct ContainerRelativeShapeDemo: View {
    var body: some View {
        HStack {
            Text("Uses Container Shape")
                .padding()
                .background {
                    // This shape adapts to the container's shape
                    ContainerRelativeShape().fill(.gray.opacity(0.4))
                }
        }
        .containerShape(Capsule()) // Define the container shape
        .padding()
    }
}

// --- AnyShape Example ---
struct AnyShapeDemo: View {
    @State private var useCircle = true
    
    var shape: AnyShape {
        if useCircle {
            return AnyShape(Circle())
        } else {
            return AnyShape(Rectangle())
        }
    }
    
    var body: some View {
        VStack {
            Text("AnyShape").font(.title2)
            shape
                .fill(.mint)
                .frame(width: 100, height: 100)
                .onTapGesture {
                    withAnimation {
                        useCircle.toggle()
                    }
                }
        }
        .padding()
    }
}


// --- ShapeStyle Examples ---

struct ShapeStylesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Shape Styles").font(.title)
            
            // Color
            Rectangle().fill(Color(red: 0.9, green: 0.3, blue: 0.4, opacity: 0.8))
                .frame(width: 100, height: 30)
                .overlay(Text("Color").foregroundColor(.white))
            
            // Gradients
            Rectangle().fill(
                LinearGradient(gradient: Gradient(colors: [.blue, .white]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
            .frame(width: 100, height: 30)
            .overlay(Text("LinearGradient"))
            
            Circle().fill(
                RadialGradient(gradient: Gradient(colors: [.orange, .red]),
                               center: .center,
                               startRadius: 5,
                               endRadius: 25)
            )
            .frame(width: 50, height: 50)
            .overlay(Text("Radial"))
            
            Circle().fill(
                AngularGradient(gradient: Gradient(colors: [.green, .blue, .purple, .green]),
                                center: .center)
            )
            .frame(width: 50, height: 50)
            .overlay(Text("Angular"))
            
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
                Ellipse().fill(
                    EllipticalGradient(gradient: Gradient(colors: [.yellow, .green]),
                                       center: .center,
                                       startRadiusFraction: 0.1,
                                       endRadiusFraction: 0.5)
                )
                .frame(width: 100, height: 50)
                .overlay(Text("Elliptical"))
            }
            
            // ImagePaint
            Rectangle()
                .fill(
                    ImagePaint(image: Image(systemName: "leaf.fill"),
                               sourceRect: CGRect(x: 0, y: 0, width: 1, height: 1),
                               scale: 0.2)
                )
                .frame(width: 100, height: 50)
                .overlay(Text("ImagePaint"))
            
            // Material (shown over a background)
            ZStack {
                Color.indigo
                Text("Background Text")
                    .padding()
                    .background(.regularMaterial) // iOS 15+
            }
            .frame(width: 150, height: 50)
            .cornerRadius(8)
            .overlay(Text("Material"))
            
            
            // HierarchicalShapeStyle (applied to foreground)
            VStack(alignment: .leading) {
                Label("Primary", systemImage: "1.circle")
                Label("Secondary", systemImage: "2.circle").foregroundStyle(.secondary) // iOS 15+
                Label("Tertiary", systemImage: "3.circle").foregroundStyle(.tertiary) // iOS 15+
                Label("Quaternary", systemImage: "4.circle").foregroundStyle(.quaternary) // iOS 15+
                // .quinary requires iOS 16+ or macOS 12+
                if #available(iOS 16.0, macOS 13.0, *) { // Note: macOS version constraint adjusted
                    Label("Quinary", systemImage: "5.circle").foregroundStyle(.quinary)
                }
            }
            .foregroundStyle(.blue) // Base style
            .padding(5)
            .border(Color.gray)
            .overlay(Text("Hierarchical Styles").font(.caption).offset(y: -55))
            
            
            // Semantic Styles
            HStack {
                Rectangle().fill(.background).frame(width: 20, height: 20).border(Color.primary) // iOS 14+
                Rectangle().fill(.foreground).frame(width: 20, height: 20).border(Color.secondary) // iOS 13+
                Rectangle().fill(.tint).frame(width: 20, height: 20).border(Color.primary) // iOS 15+
                if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) { // Using 14.0 for macOS
                    Rectangle().fill(.separator).frame(width: 20, height: 20).border(Color.secondary) // iOS 17+
                }
            }
            .overlay(Text("Semantic Styles").font(.caption).offset(y: -20))
            
            
            // AnyShapeStyle
            let anyStyle: AnyShapeStyle = Bool.random() ? AnyShapeStyle(.red) : AnyShapeStyle(LinearGradient(colors: [.green, .black], startPoint: .top, endPoint: .bottom))
            Rectangle()
                .fill(anyStyle) // iOS 15+
                .frame(width: 100, height: 30)
                .overlay(Text("AnyShapeStyle"))
        }
        .padding()
    }
}

// --- InsettableShape Example ---

struct InsettableShapeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("InsettableShape").font(.title)
            
            Text("Stroke vs StrokeBorder") .font(.headline)
            HStack {
                Circle()
                    .stroke(.blue, lineWidth: 10) // Stroke outside/inside bounds
                    .frame(width: 50, height: 50)
                    .overlay(Text("stroke"))
                
                Circle()
                    .strokeBorder(.red, lineWidth: 10) // Stroke inside bounds
                    .frame(width: 50, height: 50)
                    .overlay(Text("border"))
            }
            
            let exampleShape = RoundedRectangle(cornerRadius: 10)
            exampleShape
                .strokeBorder(.green, lineWidth: 5)
                .frame(width: 100, height: 50)
                .overlay(Text("Insettable"))
            
            
        }
        .padding()
    }
}

// --- Main ContentView ---

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                BasicShapesView()
                Divider()
                CustomPathView()
                Divider()
                TransformedShapesView()
                Divider()
                ContainerRelativeShapeDemo()
                Divider()
                AnyShapeDemo()
                Divider()
                ShapeStylesView()
                Divider()
                InsettableShapeView()
            }
            .padding()
        }
        .navigationTitle("Shapes & Styles")
    }
}


// --- Preview ---

#Preview {
    NavigationView {
        ContentView()
    }
}
