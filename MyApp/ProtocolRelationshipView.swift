//
//  ProtocolRelationshipView.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI

/// A view component representing a core protocol.
struct ProtocolView: View {
    let name: String
    var inheritsFrom: String? = nil
    var conformsTo: [String]? = nil // Protocols this one conforms to

    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.system(.title3, design: .monospaced).bold())
                .padding(.vertical, 2)
                .padding(.horizontal, 8)
                .background(Color.blue.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .cornerRadius(5)

            if let inherits = inheritsFrom {
                Text("Inherits From: \(inherits)")
                     .font(.caption)
                     .foregroundColor(.gray)
                     .padding(.leading, 15)
            }
             if let protocols = conformsTo, !protocols.isEmpty {
                 HStack(alignment: .top, spacing: 4) {
                    Text("Conforms To:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    VStack(alignment: .leading) {
                         ForEach(protocols, id: \.self) { proto in
                             Text("• \(proto)")
                                 .font(.caption.italic())
                                 .foregroundColor(.gray)
                         }
                     }
                 }
                 .padding(.leading, 15)
            }
        }
        .padding(.bottom, 5) // Space below each protocol entry
    }
}

/// A view component representing a concrete type that conforms to a protocol.
struct ConcreteTypeView: View {
    let name: String
    let protocolName: String

    var body: some View {
        HStack {
             Text("↳") // Simple visual indicator of relationship
                .foregroundColor(.gray)
            Text(name)
                 .font(.system(.body, design: .monospaced))
                 .padding(4)
                 .background(Color.green.opacity(0.15))
                 .cornerRadius(4)
            Text("(\(protocolName))")
                .font(.caption)
                .foregroundColor(.gray)

        }
         .padding(.leading, 20) // Indent concrete types
    }
}

/// A view component to represent dependencies (uses relationships).
struct DependencyView: View {
    let consumer: String
    let dependencies: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(consumer) uses:")
                .font(.caption.bold())
                .foregroundColor(.orange)
            ForEach(dependencies, id: \.self) { dep in
                Text("  • \(dep)")
                    .font(.caption)
                    .foregroundColor(.orange.opacity(0.8))
            }
        }
        .padding(.leading, 20)
    }
}

/// Main view demonstrating the protocol relationships.
struct ProtocolRelationshipView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {

                Text("SwiftUI Key Protocols & Relationships")
                    .font(.largeTitle)
                    .padding(.bottom)

                // --- Core Protocols ---
                VStack(alignment: .leading, spacing: 10) {
                    Text("Core Protocols").font(.title2).padding(.bottom, 5)

                    ProtocolView(name: "View", conformsTo: []) // Base protocol
                    ProtocolView(name: "DynamicProperty", conformsTo: []) // Fundamental for state management
                    ProtocolView(name: "Animatable", conformsTo: ["DynamicProperty"])
                    ProtocolView(name: "Shape", conformsTo: ["Animatable", "View"])
                    ProtocolView(name: "InsettableShape", inheritsFrom: "Shape")
                    ProtocolView(name: "Layout", conformsTo: ["Animatable"])
                    ProtocolView(name: "Gesture") // Associated Type: Value
                    ProtocolView(name: "ShapeStyle", conformsTo: ["Sendable"]) // Associated Type: Resolved
                    ProtocolView(name: "ViewModifier") // Associated Type: Body
                    ProtocolView(name: "EnvironmentalModifier", inheritsFrom: "ViewModifier")
                    ProtocolView(name: "PreferenceKey") // Associated Type: Value

                }
                Divider()

                 // --- Concrete Views ---
                 VStack(alignment: .leading, spacing: 5) {
                     Text("Concrete Views").font(.title2)
                     Text("(Conform to View)").font(.subheadline).foregroundColor(.gray).padding(.bottom, 5)

                     ConcreteTypeView(name: "Text", protocolName: "View")
                     ConcreteTypeView(name: "Image", protocolName: "View")
                     ConcreteTypeView(name: "Button", protocolName: "View")
                     ConcreteTypeView(name: "HStack", protocolName: "View")
                     ConcreteTypeView(name: "VStack", protocolName: "View")
                     ConcreteTypeView(name: "ZStack", protocolName: "View")
                     ConcreteTypeView(name: "List", protocolName: "View")
                     ConcreteTypeView(name: "Spacer", protocolName: "View")
                     ConcreteTypeView(name: "Color", protocolName: "View & ShapeStyle") // Conforms to multiple
                     ConcreteTypeView(name: "LinearGradient", protocolName: "View & ShapeStyle")
                     ConcreteTypeView(name: "RadialGradient", protocolName: "View & ShapeStyle")
                     ConcreteTypeView(name: "AngularGradient", protocolName: "View & ShapeStyle")
                     ConcreteTypeView(name: "ModifiedContent", protocolName: "View & ViewModifier") // Conditional conformance
                     ConcreteTypeView(name: "TupleView", protocolName: "View")
                     ConcreteTypeView(name: "ForEach", protocolName: "View")
                     ConcreteTypeView(name: "Group", protocolName: "View")
                     ConcreteTypeView(name: "GeometryReader", protocolName: "View")
                     ConcreteTypeView(name: "ScrollView", protocolName: "View") // Not explicitly listed but common
                     ConcreteTypeView(name: "Canvas", protocolName: "View")
                     ConcreteTypeView(name: "TimelineView", protocolName: "View") // Not listed, but relevant
                     ConcreteTypeView(name: "EmptyView", protocolName: "View")
                     ConcreteTypeView(name: "AnyView", protocolName: "View")
                 }
                 Divider()

                 // --- Concrete Shapes ---
                 VStack(alignment: .leading, spacing: 5) {
                     Text("Concrete Shapes").font(.title2)
                     Text("(Conform to Shape / InsettableShape)").font(.subheadline).foregroundColor(.gray).padding(.bottom, 5)

                     ConcreteTypeView(name: "Rectangle", protocolName: "InsettableShape")
                     ConcreteTypeView(name: "Circle", protocolName: "InsettableShape")
                     ConcreteTypeView(name: "Ellipse", protocolName: "InsettableShape")
                     ConcreteTypeView(name: "Capsule", protocolName: "InsettableShape")
                     ConcreteTypeView(name: "RoundedRectangle", protocolName: "InsettableShape")
                     ConcreteTypeView(name: "UnevenRoundedRectangle", protocolName: "InsettableShape")
                     ConcreteTypeView(name: "Path", protocolName: "Shape")
                     ConcreteTypeView(name: "OffsetShape", protocolName: "Shape")
                     ConcreteTypeView(name: "RotatedShape", protocolName: "Shape")
                     ConcreteTypeView(name: "ScaledShape", protocolName: "Shape")
                     ConcreteTypeView(name: "TransformedShape", protocolName: "Shape")
                     ConcreteTypeView(name: "ContainerRelativeShape", protocolName: "InsettableShape")
                     ConcreteTypeView(name: "AnyShape", protocolName: "Shape")
                 }
                 Divider()

                 // --- Concrete ShapeStyles ---
                 VStack(alignment: .leading, spacing: 5) {
                     Text("Concrete ShapeStyles").font(.title2)
                     Text("(Conform to ShapeStyle)").font(.subheadline).foregroundColor(.gray).padding(.bottom, 5)

                     ConcreteTypeView(name: "Color", protocolName: "ShapeStyle & View")
                     ConcreteTypeView(name: "LinearGradient", protocolName: "ShapeStyle & View")
                     ConcreteTypeView(name: "RadialGradient", protocolName: "ShapeStyle & View")
                     ConcreteTypeView(name: "AngularGradient", protocolName: "ShapeStyle & View")
                     ConcreteTypeView(name: "EllipticalGradient", protocolName: "ShapeStyle & View")
                     ConcreteTypeView(name: "ImagePaint", protocolName: "ShapeStyle")
                     ConcreteTypeView(name: "Material", protocolName: "ShapeStyle")
                     ConcreteTypeView(name: "ForegroundStyle", protocolName: "ShapeStyle")
                     ConcreteTypeView(name: "BackgroundStyle", protocolName: "ShapeStyle")
                     ConcreteTypeView(name: "TintShapeStyle", protocolName: "ShapeStyle")
                     ConcreteTypeView(name: "HierarchicalShapeStyle", protocolName: "ShapeStyle")
                     ConcreteTypeView(name: "SeparatorShapeStyle", protocolName: "ShapeStyle")
                     ConcreteTypeView(name: "AnyShapeStyle", protocolName: "ShapeStyle")
                     ConcreteTypeView(name: "Shader", protocolName: "ShapeStyle") // Added based on documentation
                 }
                 Divider()

                // --- Concrete Layouts ---
                 VStack(alignment: .leading, spacing: 5) {
                     Text("Concrete Layouts").font(.title2)
                     Text("(Conform to Layout)").font(.subheadline).foregroundColor(.gray).padding(.bottom, 5)

                     ConcreteTypeView(name: "HStackLayout", protocolName: "Layout")
                     ConcreteTypeView(name: "VStackLayout", protocolName: "Layout")
                     ConcreteTypeView(name: "ZStackLayout", protocolName: "Layout")
                     ConcreteTypeView(name: "AnyLayout", protocolName: "Layout")
                     // GridStackLayout etc could be added if specified
                 }
                 Divider()

                 // --- Concrete Gestures ---
                 VStack(alignment: .leading, spacing: 5) {
                     Text("Concrete Gestures").font(.title2)
                     Text("(Conform to Gesture)").font(.subheadline).foregroundColor(.gray).padding(.bottom, 5)

                     ConcreteTypeView(name: "TapGesture", protocolName: "Gesture")
                     ConcreteTypeView(name: "LongPressGesture", protocolName: "Gesture") // Assumed, common
                     ConcreteTypeView(name: "DragGesture", protocolName: "Gesture") // Assumed, common
                     ConcreteTypeView(name: "MagnificationGesture", protocolName: "Gesture") // Assumed, common
                     ConcreteTypeView(name: "RotationGesture", protocolName: "Gesture") // Assumed, common
                     ConcreteTypeView(name: "SimultaneousGesture", protocolName: "Gesture")
                     ConcreteTypeView(name: "ExclusiveGesture", protocolName: "Gesture")
                    // ConcreteTypeView(name: "SequenceGesture", protocolName: "Gesture") // Assumed, common
                     ConcreteTypeView(name: "AnyGesture", protocolName: "Gesture")
                     ConcreteTypeView(name: "_EndedGesture", protocolName: "Gesture") // Internal but illustrative
                     ConcreteTypeView(name: "_ChangedGesture", protocolName: "Gesture") // Internal but illustrative
                     ConcreteTypeView(name: "_MapGesture", protocolName: "Gesture") // Internal but illustrative
                 }
                 Divider()

                 // --- Concrete ViewModifiers ---
                 VStack(alignment: .leading, spacing: 5) {
                      Text("Concrete ViewModifiers").font(.title2)
                      Text("(Conform to ViewModifier)").font(.subheadline).foregroundColor(.gray).padding(.bottom, 5)
                      ConcreteTypeView(name: "EmptyModifier", protocolName: "ViewModifier")
                      ConcreteTypeView(name: "ModifiedContent", protocolName: "View & ViewModifier")
                     // Many modifiers return `some View`, implicitly using internal types conforming to ViewModifier
                 }
                 Divider()

                 // --- Dynamic Properties ---
                 VStack(alignment: .leading, spacing: 5) {
                     Text("Property Wrappers").font(.title2)
                     Text("(Conform to DynamicProperty or related)").font(.subheadline).foregroundColor(.gray).padding(.bottom, 5)

                     ConcreteTypeView(name: "@State", protocolName: "DynamicProperty")
                     ConcreteTypeView(name: "@Binding", protocolName: "DynamicProperty")
                     ConcreteTypeView(name: "@StateObject", protocolName: "DynamicProperty")
                     ConcreteTypeView(name: "@ObservedObject", protocolName: "DynamicProperty")
                     ConcreteTypeView(name: "@EnvironmentObject", protocolName: "DynamicProperty")
                     ConcreteTypeView(name: "@Environment", protocolName: "DynamicProperty")
                     ConcreteTypeView(name: "@Namespace", protocolName: "DynamicProperty")
                    // ConcreteTypeView(name: "@GestureState", protocolName: "DynamicProperty") // Assumed
                     ConcreteTypeView(name: "@FocusState", protocolName: "DynamicProperty") // Assumed
                     ConcreteTypeView(name: "@ScaledMetric", protocolName: "DynamicProperty")
                     ConcreteTypeView(name: "@Bindable", protocolName: "propertyWrapper") // Observation framework, related concept
                 }
                 Divider()

                 // --- Notable Dependencies ---
                 VStack(alignment: .leading, spacing: 10) {
                     Text("Notable Dependencies").font(.title2).padding(.bottom, 5)
                     DependencyView(consumer: "Text", dependencies: ["Font", "Color", "LocalizedStringKey", "AttributedString", "FormatStyle"])
                     DependencyView(consumer: "Image", dependencies: ["UIImage / NSImage", "CGImage", "ImageResource", "SF Symbols names"])
                     DependencyView(consumer: "Gesture Modifiers", dependencies: ["Gesture types", "GestureMask"])
                     DependencyView(consumer: "Shape Modifiers", dependencies: ["ShapeStyle", "StrokeStyle", "FillStyle"])
                     DependencyView(consumer: "Animation Modifiers", dependencies: ["Animation", "Transaction", "Spring", "UnitCurve"])
                     DependencyView(consumer: "Layout Containers", dependencies: ["Alignment", "HorizontalAlignment", "VerticalAlignment", "ViewDimensions", "LayoutSubview", "ProposedViewSize"])
                     DependencyView(consumer: "TimelineView", dependencies: ["TimelineSchedule"])
                     DependencyView(consumer: "Canvas", dependencies: ["GraphicsContext"])
                     DependencyView(consumer: "Text Selectability", dependencies: ["TextSelectability"])
                    // DependencyView(consumer: "Accessibility", dependencies: ["AXChartDescriptorRepresentable", "AccessibilityTraits", "AccessibilityHeadingLevel", etc."]) // Broad category
                 }

            }
            .padding()
        }
    }
}

#Preview {
    NavigationView { // Add navigation for title display in preview
        ProtocolRelationshipView()
    }
}
