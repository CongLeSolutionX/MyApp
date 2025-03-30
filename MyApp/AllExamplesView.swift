//
//  AllExamplesView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI

// MARK: - Miscellaneous Enums & Structs Examples

@available(iOS 18.0, *)
struct MiscellaneousExamplesView: View {
    @State private var redactionReason: RedactionReasons = []
    @State private var legibilityWeight: LegibilityWeight? = .regular
    @State private var colorSchemeContrast: ColorSchemeContrast = .standard // Placeholder, read from env
    @State private var controlSize: ControlSize = .regular
    @State private var dynamicTypeSize: DynamicTypeSize = .large // Placeholder, read from env
    @State private var shapeRole: ShapeRole = .fill // Informational
    @State private var backgroundProminence: BackgroundProminence = .standard // Placeholder, read from env
    #if os(iOS) || os(tvOS) || os(visionOS)
    @State private var materialAppearance: MaterialActiveAppearance = .automatic // Placeholder, read from env
    #endif
    @State private var textSelectabilityEnabled = true

    // Angle Example State
    @State private var rotationAngle: Angle = .degrees(0)

    // ContentMode Example State
    @State private var imageContentMode: ContentMode = .fit

    // ControlSize State for Picker
    private var controlSizes: [ControlSize] = [.mini, .small, .regular, .large, .extraLarge]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // --- Enums ---

                Group { // <--- Error occurred here
                    Text("Axis & Axis.Set").font(.headline)
                    ScrollView(.horizontal) { // Axis Example
                        HStack {
                            ForEach(0..<5) { Text("Item \($0)") }
                        }
                    }
                    .frame(height: 50)
                    .border(Color.gray)
                    Text("ScrollView(.horizontal) uses Axis.horizontal")
                        .font(.caption)

                    // ... (Many other enum examples) ...

                    Text("LayoutDirectionBehavior").font(.headline)
                    // Applied implicitly or with .layoutDirectionBehavior modifier
                    MirroredShape()
                        .stroke(.orange, lineWidth: 2)
                        .frame(width: 100, height: 50)
                        .environment(\.layoutDirection, .rightToLeft) // Example env change
                    Text("Shape can mirror via LayoutDirectionBehavior")
                        .font(.caption)

                } // <--- ADD THIS CLOSING BRACE

//                // --- Structs ---
//
//                Group {
//                    Text("Angle").font(.headline)
//                    Rectangle()
//                        .fill(.purple)
//                        .frame(width: 50, height: 50)
//                        .rotationEffect(rotationAngle) // Angle Example
//                        .onTapGesture {
//                            withAnimation {
//                                rotationAngle += .degrees(45)
//                            }
//                        }
//                    Text("Tap rect to rotate by 45 degrees.")
//                        .font(.caption)
//
//                    Text("FillStyle & StrokeStyle").font(.headline)
//                    HStack {
//                        Circle()
//                            .fill(.red, style: FillStyle(eoFill: true)) // FillStyle example
//                            .frame(width: 50, height: 50)
//                            .overlay(Text("eoFill"))
//                        Circle()
//                            .stroke(.blue, style: StrokeStyle(lineWidth: 5, dash: [10, 5])) // StrokeStyle example
//                            .frame(width: 50, height: 50)
//                            .overlay(Text("dash"))
//
//                    }
//
//                    Text("LocalizedStringKey").font(.headline)
//                    // Implicitly creates LocalizedStringKey for localization
//                    Text("Hello, World!")
//                        .font(.body)
//                    // Explicit creation if needed (e.g., from a variable)
//                    let key = LocalizedStringKey("greeting_key")
//                    Text(key)
//                        .font(.body)
//                    Text("Uses Localizable.strings if key exists.")
//                        .font(.caption)
//
//                    // TimeDataSource - Requires iOS 18+
//                    #if swift(>=5.10)
//                    if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
//                        Text("TimeDataSource").font(.headline)
//                        // Example usage (conceptual, needs specific FormatStyle)
//                        Text(.currentDate, format: .dateTime)
//                        Text("Displays live updating time.")
//                            .font(.caption)
//                    }
//                    #endif
//
//                    // TextSelectability - Requires iOS 15+ , macOS 12+ etc.
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
//
//                    // TextVariantPreference - Requires iOS 18+
//                    #if swift(>=5.10)
//                    if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
//                        Text("TextVariantPreference").font(.headline)
//                        Text(Date.now, format: .dateTime.year().month().day())
//                            .textVariant(.sizeDependent) // Example usage
//                        Text("Uses .sizeDependent text variant preference.")
//                            .font(.caption)
//                    }
//                    #endif
//
//                } // End Structs Group

            } // End Main VStack
            .padding()
        } // End ScrollView
    }
}

// MARK: - Type-Erased Wrappers Examples

struct TypeErasedExamplesView: View {
    @State private var showCircle = true
    @State private var useHStack = true
    @Namespace private var ns // For AnyTransition demo needing namespace

    @ViewBuilder
    var conditionalView: some View {
        if showCircle {
            AnyView(Circle().fill(.blue).frame(width: 50, height: 50)) // AnyView
        } else {
            AnyView(Rectangle().fill(.green).frame(width: 50, height: 50))
        }
    }

    var conditionalShape: AnyShape {
        if showCircle {
            AnyShape(Circle()) // AnyShape
        } else {
            AnyShape(Rectangle())
        }
    }

    var conditionalLayout: AnyLayout {
         useHStack ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout()) // AnyLayout
    }

    var wrappedGesture: AnyGesture<Void> {
        AnyGesture(TapGesture().onEnded { print("AnyGesture Tapped") }) // AnyGesture
    }

    var wrappedStyle: AnyShapeStyle {
         showCircle ? AnyShapeStyle(.blue) : AnyShapeStyle(.green) // AnyShapeStyle
    }

    var wrappedGradient: AnyGradient {
        AnyGradient(Gradient(colors: showCircle ? [.blue, .white] : [.green, .white])) // AnyGradient
    }

    var wrappedTransition: AnyTransition {
         showCircle ? AnyTransition.slide : AnyTransition.opacity // AnyTransition
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
                conditionalLayout { // Usage of AnyLayout
                    Text("Item 1")
                    Text("Item 2")
                }
                .border(Color.red)
                Button("Toggle Layout") { useHStack.toggle() }
            }

            VStack {
                 Text("AnyGesture:")
                    .gesture(wrappedGesture) // Usage of AnyGesture
                 Text("(Tap me)")
                    .foregroundStyle(.gray)
            }


            HStack {
                 Text("AnyShapeStyle:")
                 Rectangle()
                    .fill(wrappedStyle) // Usage of AnyShapeStyle
                    .frame(width: 50, height: 50)
                 Button("Toggle Style") { showCircle.toggle() }
            }

             HStack {
                 Text("AnyGradient:")
                 Rectangle()
                    .fill(.linearGradient(wrappedGradient, startPoint: .top, endPoint: .bottom)) // Usage of AnyGradient
                    .frame(width: 100, height: 50)
                 Button("Toggle Gradient") { showCircle.toggle() }
            }

             VStack {
                 Text("AnyTransition:")
                 if showCircle {
                     Text("Transitioning View")
                        .transition(wrappedTransition) // Usage of AnyTransition
                        .matchedGeometryEffect(id: "tView", in: ns)
                 }
                 Button("Toggle Transitioning View") { withAnimation { showCircle.toggle() } }
             }

        }
        .padding()
    }
}

// MARK: - Helper Structs Examples

// Demonstrates EmptyAnimatableData usage
struct NonAnimatingShape: Shape, Animatable {
     // No properties change, so use EmptyAnimatableData
     typealias AnimatableData = EmptyAnimatableData
     var animatableData: EmptyAnimatableData {
         get { EmptyAnimatableData() }
         set { /* No changes */ }
     }

     func path(in rect: CGRect) -> Path {
         Path(rect) // Just draw a rectangle
     }
 }

// Demonstrates EmptyModifier usage
struct DebugBorderModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if DEBUG
        content.border(Color.red)
        #else
        content // Uses EmptyModifier implicitly via 'content'
        #endif
    }
}

// Demonstrates EmptyVisualEffect (conceptual)
// Requires iOS 17+, not easily demoed standalone

// Demonstrates EmptyHoverEffect (conceptual)
// Requires iOS 18+, specific platforms, not easily demoed standalone


struct HelperStructsExamplesView: View {
    @State private var showDebugBorder = false

     // TupleView is created implicitly by ViewBuilder
     var tupleContent: some View {
         Text("Part 1 of Tuple") // This and the next line form a TupleView internally
         return Text("Part 2 of Tuple")
     }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Helper Structs").font(.headline)

            Text("TupleView:")
            VStack {
                tupleContent // Using the TupleView content
            }
            .border(Color.purple)
            Text("VStack implicitly uses TupleView via @ViewBuilder")
                .font(.caption)

            // ModifiedContent is implicit when applying modifiers
            Text("ModifiedContent:")
            Text("Original")
                .modifier(DebugBorderModifier()) // Implicit ModifiedContent
                 .onTapGesture { showDebugBorder.toggle() } // For Debug Border example
            Text("Original text with DebugBorderModifier applied (Tap to toggle)")
                 .font(.caption)


             Text("EmptyModifier:")
             if showDebugBorder {
                 Text("Has conditional Red Border (Debug)")
                     .modifier(DebugBorderModifier())
             } else {
                 Text("No conditional Red Border (Release or Toggled Off)")
                     .modifier(DebugBorderModifier()) // EmptyModifier is used if not DEBUG
             }


            Text("EmptyAnimatableData:")
             NonAnimatingShape() // Shape using EmptyAnimatableData
                 .fill(.cyan)
                 .frame(width: 100, height: 30)
             Text("NonAnimatingShape uses EmptyAnimatableData")
                 .font(.caption)

            // EmptyVisualEffect / EmptyHoverEffect demonstrations are more complex
            // and depend on how visualEffect/hoverEffect modifiers are implemented.
            Text("EmptyVisual/HoverEffect:")
            Text("These act as base types for effect modifiers.")
                .foregroundStyle(.gray)
                 .font(.caption)

        }
        .padding()
    }
}

// MARK: - Helper Shape for LayoutDirectionBehavior demo
struct MirroredShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
    }

    // Explicitly set behavior (optional, default depends on SDK)
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    var layoutDirectionBehavior: LayoutDirectionBehavior {
        .mirrors // or .mirrors(in: .rightToLeft)
    }
}


// MARK: - Main View to Display All Examples
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
        // Fallback on earlier versions
        ContentView()
    }
}
