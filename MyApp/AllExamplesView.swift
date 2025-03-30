//
//  AllExamplesView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI

// MARK: - Miscellaneous Examples

@available(iOS 18.0, *)
struct MiscellaneousExamplesView: View {
    // Consolidated state properties
    @State private var redactionReason: RedactionReasons = []
    @State private var legibilityWeight: LegibilityWeight? = .regular
    @State private var colorSchemeContrast: ColorSchemeContrast = .standard
    @State private var controlSize: ControlSize = .regular
    @State private var dynamicTypeSize: DynamicTypeSize = .large
    @State private var shapeRole: ShapeRole = .fill
    @State private var backgroundProminence: BackgroundProminence = .standard
    #if os(iOS) || os(tvOS) || os(visionOS)
    @State private var materialAppearance: MaterialActiveAppearance = .automatic
    #endif
    @State private var textSelectabilityEnabled = true
    
    // Angle and Content Mode Examples
    @State private var rotationAngle: Angle = .degrees(0)
    @State private var imageContentMode: ContentMode = .fit
    
    private var controlSizes: [ControlSize] = [.mini, .small, .regular, .large, .extraLarge]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Enum Demonstrations
                Group {
                    Text("Axis & Axis.Set").font(.headline)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0..<5, id: \.self) { index in
                                Text("Item \(index)")
                            }
                        }
                    }
                    .frame(height: 50)
                    .border(Color.gray)
                    Text("ScrollView(.horizontal) uses Axis.horizontal")
                        .font(.caption)
                    
                    Text("LayoutDirectionBehavior").font(.headline)
                    MirroredShape()
                        .stroke(.orange, lineWidth: 2)
                        .frame(width: 100, height: 50)
                        .environment(\.layoutDirection, .rightToLeft)
                    Text("Shape can mirror via LayoutDirectionBehavior")
                        .font(.caption)
                }
                
                // Struct Examples
                Group {
                    Text("Angle").font(.headline)
                    Rectangle()
                        .fill(.purple)
                        .frame(width: 50, height: 50)
                        .rotationEffect(rotationAngle)
                        .onTapGesture {
                            withAnimation { rotationAngle += .degrees(45) }
                        }
                    Text("Tap rect to rotate by 45 degrees.")
                        .font(.caption)
                    
//                    Text("FillStyle & StrokeStyle").font(.headline)
//                    HStack {
//                        Circle()
//                            .fill(.red, style: FillStyle(eoFill: true))
//                            .frame(width: 50, height: 50)
//                            .overlay(Text("eoFill"))
//                        Circle()
//                            .stroke(.blue, style: StrokeStyle(lineWidth: 5, dash: [10, 5]))
//                            .frame(width: 50, height: 50)
//                            .overlay(Text("dash"))
//                    }
//                    
//                    Text("LocalizedStringKey").font(.headline)
//                    Text("Hello, World!")
//                        .font(.body)
//                    
//                    let key = LocalizedStringKey("greeting_key")
//                    Text(key)
//                        .font(.body)
//                    Text("Uses Localizable.strings if key exists.")
//                        .font(.caption)
//                    
//                    #if swift(>=5.10)
//                    if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
//                        Text("TimeDataSource").font(.headline)
//                        Text(.currentDate, format: .dateTime)
//                        Text("Displays live updating time.")
//                            .font(.caption)
//                    }
//                    #endif
//                    
//                    #if os(iOS) || os(macOS)
//                    if #available(iOS 15.0, macOS 12.0, *) {
//                        Text("TextSelectability").font(.headline)
//                        Text("This text is \(textSelectabilityEnabled ? "Enabled" : "Disabled") for selection.")
//                            .textSelection(textSelectabilityEnabled ? .enabled : .disabled)
//                            .onTapGesture { textSelectabilityEnabled.toggle() }
//                        Text("Tap text to toggle selectability.")
//                            .font(.caption)
//                    }
//                    #endif
//                    
//                    #if swift(>=5.10)
//                    if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
//                        Text("TextVariantPreference").font(.headline)
//                        Text(Date.now, format: .dateTime.year().month().day())
//                            .textVariant(.sizeDependent)
//                        Text("Uses .sizeDependent text variant preference.")
//                            .font(.caption)
//                    }
//                    #endif
                } // End Structs Group
            }
            .padding()
        }
    }
}

// MARK: - Type-Erased Wrappers Examples

struct TypeErasedExamplesView: View {
    @State private var showCircle = true
    @State private var useHStack = true
    @Namespace private var ns

    @ViewBuilder
    var conditionalView: some View {
        if showCircle {
            AnyView(Circle().fill(.blue).frame(width: 50, height: 50))
        } else {
            AnyView(Rectangle().fill(.green).frame(width: 50, height: 50))
        }
    }
    
    var conditionalShape: AnyShape {
        showCircle ? AnyShape(Circle()) : AnyShape(Rectangle())
    }
    
    var conditionalLayout: AnyLayout {
        useHStack ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())
    }
    
    var wrappedGesture: AnyGesture<Void> {
        AnyGesture(TapGesture().onEnded { print("AnyGesture Tapped") })
    }
    
    var wrappedStyle: AnyShapeStyle {
        showCircle ? AnyShapeStyle(.blue) : AnyShapeStyle(.green)
    }
    
    var wrappedGradient: AnyGradient {
        AnyGradient(Gradient(colors: showCircle ? [.blue, .white] : [.green, .white]))
    }
    
    var wrappedTransition: AnyTransition {
        showCircle ? AnyTransition.slide : AnyTransition.opacity
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Type-Erased Wrappers").font(.headline)
            
            HStack {
                Text("AnyView:")
                conditionalView
                Button("Toggle View") { showCircle.toggle() }
            }
            
            HStack {
                Text("AnyShape:")
                conditionalShape
                    .fill(.orange)
                    .frame(width: 50, height: 50)
                Button("Toggle Shape") { showCircle.toggle() }
            }
            
            HStack {
                Text("AnyLayout:")
                conditionalLayout {
                    Text("Item 1")
                    Text("Item 2")
                }
                .border(Color.red)
                Button("Toggle Layout") { useHStack.toggle() }
            }
            
            VStack {
                Text("AnyGesture:")
                    .gesture(wrappedGesture)
                Text("(Tap me)")
                    .foregroundStyle(.gray)
            }
            
            HStack {
                Text("AnyShapeStyle:")
                Rectangle()
                    .fill(wrappedStyle)
                    .frame(width: 50, height: 50)
                Button("Toggle Style") { showCircle.toggle() }
            }
            
            HStack {
                Text("AnyGradient:")
                Rectangle()
                    .fill(.linearGradient(wrappedGradient,
                                          startPoint: .top,
                                          endPoint: .bottom))
                    .frame(width: 100, height: 50)
                Button("Toggle Gradient") { showCircle.toggle() }
            }
            
            VStack {
                Text("AnyTransition:")
                if showCircle {
                    Text("Transitioning View")
                        .transition(wrappedTransition)
                        .matchedGeometryEffect(id: "tView", in: ns)
                }
                Button("Toggle Transitioning View") {
                    withAnimation { showCircle.toggle() }
                }
            }
        }
        .padding()
    }
}

// MARK: - Helper Structs Examples

struct NonAnimatingShape: Shape, Animatable {
    typealias AnimatableData = EmptyAnimatableData
    var animatableData: EmptyAnimatableData {
        get { EmptyAnimatableData() }
        set { }
    }
    
    func path(in rect: CGRect) -> Path {
        Path(rect)
    }
}

struct DebugBorderModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if DEBUG
        content.border(Color.red)
        #else
        content
        #endif
    }
}

struct HelperStructsExamplesView: View {
    @State private var showDebugBorder = false
    
    var tupleContent: some View {
        Group {
            Text("Part 1 of Tuple")
            Text("Part 2 of Tuple")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Helper Structs").font(.headline)
            
            Text("TupleView:")
            VStack {
                tupleContent
            }
            .border(Color.purple)
            Text("VStack implicitly uses TupleView via @ViewBuilder")
                .font(.caption)
            
            Text("ModifiedContent & DebugBorderModifier:")
            Text("Original")
                .modifier(DebugBorderModifier())
                .onTapGesture { showDebugBorder.toggle() }
            Text("Text with DebugBorderModifier applied (Tap to toggle)")
                .font(.caption)
            
            Text("EmptyModifier Example:")
            if showDebugBorder {
                Text("Has conditional Red Border (Debug)")
                    .modifier(DebugBorderModifier())
            } else {
                Text("No conditional Red Border (Release or Toggled Off)")
                    .modifier(DebugBorderModifier())
            }
            
            Text("EmptyAnimatableData Example:")
            NonAnimatingShape()
                .fill(.cyan)
                .frame(width: 100, height: 30)
            Text("NonAnimatingShape uses EmptyAnimatableData")
                .font(.caption)
            
            Text("EmptyVisual/HoverEffect Placeholder:")
            Text("These act as base examples for effect modifiers.")
                .foregroundStyle(.gray)
                .font(.caption)
        }
        .padding()
    }
}

// MARK: - Helper Shape for LayoutDirectionBehavior

struct MirroredShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
    }
    
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    var layoutDirectionBehavior: LayoutDirectionBehavior {
        .mirrors
    }
}

// MARK: - Main Container

@available(iOS 18.0, *)
struct AllExamplesView: View {
    var body: some View {
        TabView {
            MiscellaneousExamplesView()
                .tabItem { Label("Misc", systemImage: "list.bullet") }
            TypeErasedExamplesView()
                .tabItem { Label("Type Erased", systemImage: "rectangle.stack") }
            HelperStructsExamplesView()
                .tabItem { Label("Helpers", systemImage: "wrench.and.screwdriver") }
        }
    }
}

// MARK: - Preview

#Preview {
    if #available(iOS 18.0, *) {
        AllExamplesView()
    } else {
        Text("This example requires iOS 18.0 or later.")
    }
}
