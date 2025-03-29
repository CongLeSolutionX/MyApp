//
//  ContentView2.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI



// MARK: - Core SwiftUI Concepts Demonstrated

// --- Accessibility Related ---

/// Represents the data needed to make a chart accessible.
/// Conforming types provide methods to create and update an AXChartDescriptor.
/// Example: Used with `.accessibilityChartDescriptor()`.
struct MyChartDescriptorRepresentable: AXChartDescriptorRepresentable {
     // Example state that might influence the chart
     @Environment(\.dynamicTypeSize) var dynamicTypeSize
     var dataPoints: [Double] = [10, 20, 15, 30, 25]

     // Creates the initial descriptor
     func makeChartDescriptor() -> AXChartDescriptor {
         // Create an AXNumericDataAxisDescriptor for the Y-axis (values)
         let yAxis = AXNumericDataAxisDescriptor(
             title: "Value",
             range: dataPoints.min()!...dataPoints.max()!, // Dynamically calculate range
             gridlinePositions: []) { value in "\(value)" }

         // Create an AXCategoricalDataAxisDescriptor for the X-axis (indices/categories)
         let xAxis = AXCategoricalDataAxisDescriptor(
             title: "Index",
             categoryOrder: dataPoints.indices.map { "Index \($0 + 1)" }
         )

         // Create a series representing the data
         let series = AXDataSeriesDescriptor(
             name: "Sample Data",
             isContinuous: false, // Bars are typically discrete
             dataPoints: dataPoints.enumerated().map { index, value in
                 AXDataPoint(x: "Index \(index + 1)", y: value)
             }
         )

         // Assemble the chart descriptor
         return AXChartDescriptor(
             title: "Sample Bar Chart",
             summary: "A chart showing sample data values.",
             xAxis: xAxis,
             yAxis: yAxis,
             additionalAxes: [],
             series: [series]
         )
     }

     // Updates the descriptor if the environment or view state changes
     func updateChartDescriptor(_ descriptor: AXChartDescriptor) {
         // Example: Update axis range if data changes or title based on type size
         descriptor.yAxis?.range = dataPoints.min()!...dataPoints.max()!
        descriptor.series[0].dataPoints = dataPoints.enumerated().map { index, value in
             AXDataPoint(x: "Index \(index + 1)", y: value)
        }

         if dynamicTypeSize.isAccessibilitySize {
             descriptor.title = "Sample Chart (Large Text)"
         } else {
             descriptor.title = "Sample Bar Chart"
         }

         print("Chart descriptor updated!")
     }
 }

// --- Alignment Related ---

/// A custom AlignmentID for aligning views at one-third of their height.
private struct FirstThirdAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        // Calculate one-third of the view's height from the top edge (origin)
        context.height / 3
    }
}

/// Extension to provide easy access to the custom alignment.
extension VerticalAlignment {
    static let firstThird = VerticalAlignment(FirstThirdAlignment.self)
}

/// Extension to create a composite Alignment using the custom vertical guide.
extension Alignment {
     static let centerFirstThird = Alignment(horizontal: .center, vertical: .firstThird)
}


// --- Layout Related ---

/// A basic custom vertical stack layout conforming to the Layout protocol.
/// Demonstrates sizeThatFits and placeSubviews.
struct BasicVStackLayout: Layout {
     var spacing: CGFloat = 8 // Allow customizable spacing

     // Calculate the total size needed by the stack.
     func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
         guard !subviews.isEmpty else { return .zero }

         // Calculate total height including spacing
         let totalHeight = subviews.map { $0.sizeThatFits(.unspecified).height }.reduce(0, +)
         let totalSpacing = CGFloat(subviews.count - 1) * spacing
         let finalHeight = totalHeight + totalSpacing

         // Find the maximum width among subviews
         let maxWidth = subviews.map { $0.sizeThatFits(.unspecified).width }.max() ?? 0

         return CGSize(width: maxWidth, height: finalHeight)
     }

     // Place each subview vertically.
     func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
         guard !subviews.isEmpty else { return }

         var currentY = bounds.minY // Start placing from the top boundary

         for subview in subviews {
             // Ask the subview for its ideal size
             let subviewSize = subview.sizeThatFits(.unspecified)

             // Calculate the placement point (top-leading corner in this case)
             // We use bounds.midX and subtract half the subview width for centering horizontally.
             // In a real VStack, you'd use the HorizontalAlignment.
             let placementPoint = CGPoint(x: bounds.midX - subviewSize.width / 2, y: currentY)

             // Place the subview
            subview.place(at: placementPoint, anchor: .topLeading, proposal: .unspecified)

             // Update Y position for the next subview, adding spacing
             currentY += subviewSize.height + spacing
         }
     }

    // Optional LayoutProperties example (could define stackOrientation)
//   static var layoutProperties: LayoutProperties {
//       var properties = LayoutProperties()
//       properties.stackOrientation = .vertical
//       return properties
//   }

    // Example of explicit alignment (optional)
    func explicitAlignment(of guide: HorizontalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGFloat? {
        // Example: Default to center alignment if not specified otherwise within subviews
        if guide == .center {
           return bounds.midX
        }
        // Let subviews define other alignments implicitly
        return nil
   }
 }


// --- Keyframe Animation Related ---

/// Holds values that can be animated with keyframes.
struct KeyframeDemoValues: Equatable { // Equatable often needed for trigger
    var scale: Double = 1.0
    var rotation: Angle = .zero
    var offset: CGPoint = .zero
}


// --- Custom Animation Related ---

/// A simple custom animation simulating a bounce effect.
struct BounceAnimation: CustomAnimation {
    let duration: TimeInterval
    let bounceCount: Int = 3 // How many bounces

    func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
        guard time < duration else { return nil } // Animation finished

        let progress = time / duration
        // Create a bounce effect using a scaled sine wave that dampens over time
        let bounceFactor = CGFloat(pow(2, -10 * progress) * abs(sin(progress * .pi * CGFloat(bounceCount))))

        // Interpolate from zero (start) towards the target (value)
        var result = V.zero
        result.scale(by: 1 - bounceFactor) // Scale down the starting point (zero)
        var targetContribution = value
        targetContribution.scale(by: bounceFactor) // Scale up the target point
        result += targetContribution

        return result
    }
    
    // Required for Hashable conformance if struct isn't just basic types
    func hash(into hasher: inout Hasher) {
         hasher.combine(duration)
         hasher.combine(bounceCount)
     }

    static func == (lhs: BounceAnimation, rhs: BounceAnimation) -> Bool {
        lhs.duration == rhs.duration && lhs.bounceCount == rhs.bounceCount
     }
}

/// Extension to make the custom animation easily accessible.
extension Animation {
    static func bounce(duration: TimeInterval = 0.8) -> Animation {
        Animation(BounceAnimation(duration: duration))
    }
}


// --- Observable Object for State Management ---

/// Simple ObservableObject for demonstration.
class CounterModel: ObservableObject {
    @Published var count: Int = 0

    func increment() {
        count += 1
    }
}


// MARK: - Content View
struct ContentView: View {
    // State for various demos
    @State private var isEnabled: Bool = true
    @State private var alignmentChoice: HorizontalAlignment = .center
    @State private var isShowingTransitionView: Bool = false
    @State private var isShowingAsymmetricView: Bool = false
    @State private var counterTitle: String = "Count: 0"
    @State private var tapCount: Int = 0
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var colorSchemeOverride: ColorScheme? = nil
    @State private var sliderValue: Double = 0.5
    @Namespace private var shapeNamespace // For MatchedGeometryEffect

    // Observable Object Demos
    @StateObject private var counterModel = CounterModel() // Create the source of truth

    // Keyframe Animator State
    @State private var triggerKeyframes: Bool = false
    @State private var keyframeValues = KeyframeDemoValues() // Keep track of current values

    // Custom Animation State
    @State private var showBouncingView = false

    // Accessibility Chart Data
    @State private var chartData: [Double] = [5, 12, 8, 15, 10]

    var body: some View {
        List { // Using List to easily structure many examples

            // MARK: Accessibility Section
            Section("Accessibility") {
                VStack(alignment: .leading) {
                    Text("AXChartDescriptorRepresentable")
                        .font(.headline)
                    // Basic visual representation - ACCESSIBILITY is key here
                    HStack {
                        ForEach(chartData.indices, id: \.self) { index in
                           Rectangle()
                                .fill(.blue.opacity(chartData[index]/chartData.max()!))
                                .frame(width: 20, height: chartData[index] * 5)
                         }
                    }
                    .frame(height: 100)
                    // Apply the accessibility descriptor
                    .accessibilityChartDescriptor(MyChartDescriptorRepresentable(dataPoints: chartData))

                    Button("Change Chart Data") {
                         chartData = chartData.map { _ in Double.random(in: 5...20) }
                    }
                }
                .padding(.vertical)

                VStack(alignment: .leading) {
                   Text("Accessibility Traits & Headings")
                       .font(.headline)
                       .accessibilityHeading(.h1) // Set heading level
                   Text("This button has accessibility traits.")
                        .accessibilityHeading(.h2)
                   Button("Selectable Button") { }
                       .accessibilityAddTraits([.isButton, .isSelected]) // Add traits
                }
                .padding(.vertical)

                VStack(alignment: .leading) {
                     Text("Text Content Type")
                       .font(.headline)
                      Text("let x = 5 // Source Code")
                        .font(.system(.body, design: .monospaced))
                        .accessibilityTextContentType(.sourceCode) // Specify content type
                 }
                .padding(.vertical)
            }

            // MARK: Alignment & Layout Section
            Section("Alignment & Layout") {
                 VStack(alignment: .leading) {
                    Text("Alignment & Custom Alignment")
                         .font(.headline)

                     // Using standard Alignment
                     HStack(alignment: .firstTextBaseline) {
                         Text("Label:").font(.body)
                         Text("Value").font(.largeTitle)
                     }
                     .padding(.bottom)

                     // Using custom Alignment
                     HStack(alignment: .firstThird, spacing: 1) {
                         Color.red.frame(width: 30, height: 60)
                         Color.green.frame(width: 30, height: 120)
                         Color.blue.frame(width: 30, height: 90)
                     }
                     .frame(height: 130) // Ensure frame is tall enough
                     Text("Custom .firstThird VerticalAlignment")
                         .font(.caption)
                 }
                 .padding(.vertical)

                 VStack(alignment: .leading) {
                    Text("Custom Layout (BasicVStackLayout)")
                         .font(.headline)
                     // Using the custom Layout protocol implementaiton
                    BasicVStackLayout(spacing: 5) {
                        Text("Line 1")
                        Text("Longer Line 2").font(.title2)
                        Text("Line 3")
                    }
                    .border(Color.gray)
                 }
                 .padding(.vertical)

                VStack(alignment: .leading) {
                    Text("GeometryReader")
                        .font(.headline)
                    GeometryReader { geo in
                         Text("View size: \(Int(geo.size.width)) x \(Int(geo.size.height))")
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity) // Allow positioning
                     }
                     .frame(height: 100)
                     .border(Color.cyan)
                }
                .padding(.vertical)

            }

             // MARK: State Management Basics Section
            Section("State Management Basics") {
                VStack(alignment: .leading) {
                   Text("State & Binding")
                         .font(.headline)
                     Toggle("Enable Feature", isOn: $isEnabled)
                     Text("Feature is \(isEnabled ? "ON" : "OFF")")
                 }
                .padding(.vertical)

                 VStack(alignment: .leading) {
                    Text("Environment Values")
                         .font(.headline)
                         ColorSchemeToggle(colorSchemeOverride: $colorSchemeOverride)
                     Text("Current scheme: \(colorSchemeOverride?.description ?? "System")")
                         .environment(\.colorScheme, colorSchemeOverride ?? .light) // Example override
                 }
                .padding(.vertical)

                 VStack(alignment: .leading) {
                     Text("StateObject & EnvironmentObject")
                         .font(.headline)
                    // CounterView gets the model via @EnvironmentObject
                     CounterView()
                    Button("Increment Shared Counter") {
                        counterModel.increment() // Can increment from parent
                     }
                 }
                 .padding(.vertical)
                 .environmentObject(counterModel) // Provide the model to the hierarchy
            }


            // MARK: Animation & Transition Section
            Section("Animation & Transition") {
                // --- Implicit Animation with .animation() ---
                VStack(alignment: .leading) {
                    Text(".animation() Modifier Example")
                         .font(.headline)
                    Circle()
                        .fill(.orange)
                        .frame(width: 50, height: 50)
                        .scaleEffect(sliderValue)
                        .animation(.spring(dampingFraction: 0.4), value: sliderValue) // Animate when sliderValue changes
                    Slider(value: $sliderValue, in: 0.5...1.5)
                 }
                 .padding(.vertical)

                // --- Explicit Animation with withAnimation ---
                 VStack(alignment: .leading) {
                    Text("withAnimation Example")
                         .font(.headline)
                    Rectangle()
                         .fill(.purple)
                         .frame(width: isEnabled ? 100 : 50, height: 50)
                    Button("Toggle Size (withAnimation)") {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isEnabled.toggle()
                        }
                     }
                 }
                 .padding(.vertical)


                // --- View Transitions ---
                VStack(alignment: .leading) {
                   Text("Transitions")
                        .font(.headline)
                    if isShowingTransitionView {
                         Text("Hello Transition!")
                            .padding()
                            .background(Color.yellow)
                            .transition(.move(edge: .bottom).combined(with: .opacity)) // Combine effects
                     }
                     Button("Toggle Transition View") {
                         withAnimation(.snappy) {
                             isShowingTransitionView.toggle()
                         }
                     }
                }
                .padding(.vertical)

                 // --- Asymmetric Transitions ---
                VStack(alignment: .leading) {
                    Text("Asymmetric Transition")
                        .font(.headline)
                    if isShowingAsymmetricView {
                         Text("Different In/Out")
                             .padding()
                             .background(Color.mint)
                             .transition(.asymmetric(insertion: .scale.animation(.bouncy), removal: .slide))
                    }
                    Button("Toggle Asymmetric View") {
                         withAnimation { isShowingAsymmetricView.toggle() }
                    }
                 }
                .padding(.vertical)


                // --- Content Transition ---
                 VStack(alignment: .leading) {
                    Text("Content Transition")
                         .font(.headline)
                    Text(counterTitle)
                        .font(.title)
                        .contentTransition(.numericText(countsDown: counterModel.count < Int.random(in: -5...5))) // Dynamic countdown direction
                    Button("Increment for Content Transition") {
                        withAnimation(.smooth) {
                             counterModel.increment()
                             counterTitle = "Count: \(counterModel.count)"
                        }
                     }
                 }
                 .padding(.vertical)

                // --- Matched Geometry Effect ---
                 VStack(alignment: .leading) {
                    Text("Matched Geometry Effect")
                         .font(.headline)
                    HStack {
                         if !isShowingAsymmetricView { // Reuse state for simplicity
                            Circle().fill(.red)
                                .matchedGeometryEffect(id: "shape", in: shapeNamespace)
                                .frame(width: 50, height: 50)
                         }
                         Spacer()
                         if isShowingAsymmetricView {
                             Rectangle().fill(.red)
                                 .matchedGeometryEffect(id: "shape", in: shapeNamespace)
                                 .frame(width: 100, height: 50)
                         }
                    }
                    .frame(height: 60)
                    // Button already exists to toggle isShowingAsymmetricView
                 }
                 .padding(.vertical)

                // --- Keyframe Animator ---
                 VStack(alignment: .leading) {
                    Text("Keyframe Animator")
                         .font(.headline)
                     KeyframeAnimator(initialValue: KeyframeDemoValues(), trigger: triggerKeyframes) { values in
                         Rectangle()
                             .fill(.teal)
                             .frame(width: 50, height: 50)
                             .scaleEffect(values.scale)
                             .rotationEffect(values.rotation)
                             .offset(x: values.offset.x, y: values.offset.y)
                     } keyframes: { _ in // Start value captured implicitly if needed
                        KeyframeTrack(\.offset) {
                            CubicKeyframe(CGPoint(x: 50, y: 0), duration: 0.4)
                            SpringKeyframe(CGPoint(x: 0, y: 50), spring: .bouncy)
                            LinearKeyframe(CGPoint.zero, duration: 0.3)
                        }
                        KeyframeTrack(\.rotation) {
                            LinearKeyframe(.degrees(0), duration: 0.1) // Start rotation
                            CubicKeyframe(.degrees(45), duration: 0.5)
                            SpringKeyframe(.degrees(0), spring: .smooth)
                         }
                        KeyframeTrack(\.scale) {
                            CubicKeyframe(1.0, duration: 0.1)
                            CubicKeyframe(1.3, duration: 0.4)
                            SpringKeyframe(1.0, spring: .snappy)
                        }
                    }
                    .frame(height: 70) // Ensure space for animation

                     Button("Run Keyframes") {
                        triggerKeyframes.toggle()
                     }
                 }
                 .padding(.vertical)

                // --- Custom Animation ---
                 VStack(alignment: .leading) {
                     Text("Custom Bounce Animation")
                        .font(.headline)
                     Circle()
                        .fill(showBouncingView ? .green : .gray)
                        .frame(width: 50, height: 50)
                        .scaleEffect(showBouncingView ? 1.3 : 1.0)

                     Button("Trigger Custom Bounce") {
                         withAnimation(.bounce(duration: 1.2)) { // Use custom animation
                             showBouncingView.toggle()
                         }
                     }
                 }
                 .padding(.vertical)
            }

            // MARK: Drawing & Shapes Section
            Section("Drawing & Shapes") {
                 VStack(alignment: .leading) {
                    Text("Shapes (Rectangle, Circle, Capsule, Path)")
                         .font(.headline)
                     HStack {
                        Rectangle().fill(.red).frame(width: 40, height: 40)
                        Circle().stroke(.blue, lineWidth: 2).frame(width: 40, height: 40)
                        Capsule().fill(.green).frame(width: 60, height: 30)
                        CustomTriangle().fill(.yellow).frame(width: 40, height: 40)
                     }
                 }
                 .padding(.vertical)

                VStack(alignment: .leading) {
                     Text("Shape Styles (Color, Gradients, ForegroundStyle)")
                         .font(.headline)
                    HStack {
                        Rectangle().fill(.primary) // Contextual color
                        Rectangle().fill(LinearGradient(gradient: Gradient(colors: [.orange, .purple]), startPoint: .top, endPoint: .bottom))
                        Rectangle().fill(RadialGradient(gradient: Gradient(colors: [.white, .black]), center: .center, startRadius: 5, endRadius: 50))
                        Rectangle().fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                        // ForegroundStyle demo
                        Text("FG").font(.largeTitle).foregroundStyle(.secondary)
                    }
                    .frame(height: 50)
                }
                 .padding(.vertical)

                 VStack(alignment: .leading) {
                     Text("Canvas & GraphicsContext")
                         .font(.headline)
                    Canvas { context, size in
                         // Draw using GraphicsContext
                        let rect = CGRect(origin: .zero, size: size)
                        context.stroke(Path(ellipseIn: rect), with: .color(.green), lineWidth: 4)
                        context.fill(Path(rect.insetBy(dx: 20, dy: 20)), with: .color(.blue.opacity(0.5)))

                        // Draw resolved text
                        var resolvedText = context.resolve(Text("Canvas Text").font(.caption))
                        resolvedText.shading = .color(.white)
                        context.draw(resolvedText, at: CGPoint(x: size.width/2, y: size.height/2), anchor: .center)
                        
                        // Draw resolved image (if needed)
                        // var resolvedImage = context.resolve(Image(systemName:"star"))
                        // context.draw(resolvedImage, at: ...)

                     }
                     .frame(height: 100)
                     .border(Color.gray)
                 }
                 .padding(.vertical)
            }

            // MARK: Gestures Section
            Section("Gestures") {
                VStack(alignment: .leading) {
                    Text("TapGesture Example")
                         .font(.headline)
                         Text("Tapped \(tapCount) times")
                        .padding()
                        .background(Color.yellow.opacity(0.3))
                         .onTapGesture(count: 2) { // Detect double tap
                            tapCount += 1
                        }
                }
                 .padding(.vertical)

                VStack(alignment: .leading) {
                   Text("DragGesture Example")
                        .font(.headline)
                    Circle()
                         .fill(isDragging ? Color.green : Color.blue)
                         .frame(width: 60, height: 60)
                        .offset(dragOffset)
                         .gesture(
                             DragGesture()
                                .onChanged { value in
                                     // No animation needed during drag for direct feedback
                                     dragOffset = value.translation
                                     if !isDragging { isDragging = true }
                                 }
                                .onEnded { value in
                                    withAnimation(.spring()) { // Animate snapping back
                                         dragOffset = .zero
                                         isDragging = false
                                     }
                                 }
                         )
                     Text("Drag the circle")
                        .font(.caption)
                        .frame(height: 80) // Provide space for dragging

                 }
                 .padding(.vertical)

                // --- Simultaneous/Exclusive Gestures are more complex ---
                // --- Usually involve combining simple gestures ---
                // --- Example: LongPress then Drag ---

                // --- GestureState Example ---
                 VStack(alignment: .leading) {
                    Text("GestureState (LongPress scale)")
                         .font(.headline)
                     GestureStateScalingButton()
                 }
                 .padding(.vertical)

            }

            // Mark: Miscellaneous
            Section("Miscellaneous") {
               VStack(alignment: .leading) {
                    Text("DynamicTypeSize")
                        .font(.headline)
                    DynamicTypeSizeView()
                }
                .padding(.vertical)
                
                VStack(alignment: .leading) {
                    Text("Image Rendering and Display")
                        .font(.headline)
                    Image("LandscapePlaceholder") // Assumes an image named 'LandscapePlaceholder' exists in assets
                         .resizable()
                         .scaledToFit()
                         .frame(height: 100)
                         .overlay(Text("Scaled to Fit").font(.caption).foregroundColor(.white).padding(2).background(.black.opacity(0.5)), alignment: .bottom)
                    Image(systemName: "star.fill")
                         .renderingMode(.template) // Default for symbols
                         .foregroundStyle(.yellow)
                         .imageScale(.large) // Scale relative to font size
                }
                .padding(.vertical)
            }


        } // End List
        .listStyle(.plain)
    }
}

// MARK: - Helper Views for Demos

/// View demonstrating reading environment values related to color scheme.
struct ColorSchemeToggle: View {
    @Environment(\.colorScheme) var currentScheme
    @Binding var colorSchemeOverride: ColorScheme?

    var body: some View {
        VStack {
            Text("System Scheme: \(currentScheme == .dark ? "Dark" : "Light")")
            Picker("Override Scheme", selection: $colorSchemeOverride) {
                 Text("System").tag(ColorScheme?.none) // Use Optional<ColorScheme> tag for nil
                 Text("Light").tag(ColorScheme?.some(.light))
                 Text("Dark").tag(ColorScheme?.some(.dark))
             }
             .pickerStyle(.segmented)
        }
    }
}


/// View demonstrating reading an EnvironmentObject.
struct CounterView: View {
    @EnvironmentObject var model: CounterModel // Read the object from the environment

    var body: some View {
        Text("Shared Count: \(model.count)")
            .font(.title2)
            .padding(.bottom, 5)
    }
}


/// Basic Triangle Shape for demonstration.
struct CustomTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

/// View demonstrating GestureState for interactive feedback.
struct GestureStateScalingButton: View {
     @GestureState private var isPressing: Bool = false // Temporary state during gesture

     var body: some View {
         Text("Press & Hold Me")
            .padding()
             .background(isPressing ? Color.blue.opacity(0.5) : Color.blue) // Feedback during press
             .foregroundColor(.white)
             .cornerRadius(10)
             .scaleEffect(isPressing ? 0.95 : 1.0) // Scale during press
             .animation(.easeInOut(duration: 0.15), value: isPressing) // Animate the scale/bg change
             .gesture(
                 LongPressGesture(minimumDuration: .infinity) // Press and hold
                     .updating($isPressing) { currentState, gestureState, transaction in
                         gestureState = currentState // Update temporary state while gesture active
                         // transaction.animation = ... // Can customize animation here too
                     }
             )
     }
}

/// View showing different Dynamic Type sizes for comparison.
struct DynamicTypeSizeView: View {
     @Environment(\.dynamicTypeSize) var size

     var body: some View {
         VStack(alignment: .leading) {
             Text("System Default (\(size.description))")
             Text("XLarge Override")
                 .dynamicTypeSize(.xLarge) // Override
            Text("Constrained Range")
                 .dynamicTypeSize(.xSmall ... .large) // Apply range limit
         }
     }
}

/// Simple extension for ColorScheme description
extension ColorScheme: CustomStringConvertible {
    public var description: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        @unknown default: return "Unknown"
        }
    }
}

/// Simple extension for DynamicTypeSize description
extension DynamicTypeSize: CustomStringConvertible {
    public var description: String { String(describing: self) } // Basic description
}

// Placeholder image resource if needed for previews/compilation
// You should replace "LandscapePlaceholder" with an actual image in your assets
#if DEBUG
extension Image {
    init(_ name: String) where name == "LandscapePlaceholder" { // Hack to allow compilation without the asset
        self.init(systemName: "photo") // Use SF Symbol as placeholder
    }
}
#endif

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light) // Preview in light mode

        ContentView()
            .preferredColorScheme(.dark) // Preview in dark mode
    }
}
