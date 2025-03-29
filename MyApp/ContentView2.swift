//
//  ContentView2.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI
import Combine
import CoreGraphics
import Foundation
import Accessibility

// MARK: - Main Application Structure
@main
struct AnimationTransitionDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Core SwiftUI Concepts Demonstrated

// --- Accessibility Related ---
struct MyChartDescriptorRepresentable: AXChartDescriptorRepresentable {
     @Environment(\.dynamicTypeSize) var dynamicTypeSize
     var dataPoints: [Double] = [10, 20, 15, 30, 25]

     func makeChartDescriptor() -> AXChartDescriptor {
         let minY = dataPoints.min() ?? 0
         let maxY = dataPoints.max() ?? 1
         let yAxis = AXNumericDataAxisDescriptor(
             title: "Value",
             range: minY...maxY,
             gridlinePositions: []) { value in "\(Int(value))" }

         let xAxis = AXCategoricalDataAxisDescriptor(
             title: "Index",
             categoryOrder: dataPoints.indices.map { "Index \($0 + 1)" }
         )

         let series = AXDataSeriesDescriptor(
             name: "Sample Data",
             isContinuous: false,
             dataPoints: dataPoints.enumerated().map { index, value in
                 AXDataPoint(x: ("Index \(index + 1)" as NSString) as String, y: value)
             }
         )

         return AXChartDescriptor(
             title: "Sample Bar Chart",
             summary: "A chart showing sample data values.",
             xAxis: xAxis,
             yAxis: yAxis,
             additionalAxes: [],
             series: [series]
         )
     }

     func updateChartDescriptor(_ descriptor: AXChartDescriptor) {
         let minY = dataPoints.min() ?? 0
         let maxY = dataPoints.max() ?? 1
         if let yAxis = descriptor.yAxis {
              yAxis.range = minY...maxY
         }
         if descriptor.series.indices.contains(0) {
             descriptor.series[0].dataPoints = dataPoints.enumerated().map { index, value in
                 AXDataPoint(x: ("Index \(index + 1)" as NSString) as String, y: value)
             }
         }
         descriptor.title = dynamicTypeSize.isAccessibilitySize ? "Sample Chart (Large Text)" : "Sample Bar Chart"
         print("Chart descriptor updated!")
     }
 }


// --- Alignment Related ---
private struct FirstThirdAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat { context.height / 3 }
}
extension VerticalAlignment { static let firstThird = VerticalAlignment(FirstThirdAlignment.self) }
extension Alignment { static let centerFirstThird = Alignment(horizontal: .center, vertical: .firstThird) }


// --- Layout Related ---
struct BasicVStackLayout: Layout {
     var spacing: CGFloat = 8
     func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
         guard !subviews.isEmpty else { return .zero }
         let totalHeight = subviews.map { $0.sizeThatFits(.unspecified).height }.reduce(0, +)
         let totalSpacing = CGFloat(subviews.count - 1) * spacing
         let finalHeight = totalHeight + totalSpacing
         let maxWidth = subviews.map { $0.sizeThatFits(.unspecified).width }.max() ?? 0
         return CGSize(width: maxWidth, height: finalHeight)
     }
     func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
         guard !subviews.isEmpty else { return }
         var currentY = bounds.minY
         for subview in subviews {
             let subviewSize = subview.sizeThatFits(.unspecified)
             let placementPoint = CGPoint(x: bounds.midX - subviewSize.width / 2, y: currentY)
            subview.place(at: placementPoint, anchor: .topLeading, proposal: .unspecified)
             currentY += subviewSize.height + spacing
         }
     }
    func explicitAlignment(of guide: HorizontalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGFloat? {
        if guide == .center { return bounds.midX }
        return nil
   }
 }


// --- Keyframe Animation Related ---
struct KeyframeDemoValues: Equatable {
    var scale: Double = 1.0
    var rotation: Angle = .zero
    var offset: CGPoint = .zero
}


// --- Custom Animation Related ---
struct BounceAnimation: CustomAnimation {
    let duration: TimeInterval
    let bounceCount: Int = 3

    func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
        guard time >= 0 else { return V.zero }
        guard time < duration else { return value }

        let progress = time / duration
        let cgProgress = CGFloat(progress)
        let amplitude = pow(2.0, -10 * cgProgress)
        let oscillations = sin(cgProgress * .pi * 2.0 * CGFloat(bounceCount))
        let bounceFactor = amplitude * oscillations

        let baseProgress = 1.0 - pow(1.0 - cgProgress, 3)

        var result = V.zero
        var targetContribution = value
        targetContribution.scale(by: Double(baseProgress))
        result += targetContribution

        var bounceDisplacement = value
        bounceDisplacement.scale(by: Double(bounceFactor))
        result += bounceDisplacement

        print("Custom Time: \(time), Bounce Factor: \(bounceFactor), Base Progress: \(baseProgress)")
        return result
    }

    func hash(into hasher: inout Hasher) {
         hasher.combine(duration)
         hasher.combine(bounceCount)
     }
    static func == (lhs: BounceAnimation, rhs: BounceAnimation) -> Bool {
        lhs.duration == rhs.duration && lhs.bounceCount == rhs.bounceCount
     }
}

extension Animation {
    static func bounce(duration: TimeInterval = 0.8) -> Animation {
        Animation(BounceAnimation(duration: duration))
    }
}


// --- Observable Object for State Management ---
class CounterModel: ObservableObject {
    @Published var count: Int = 0
    func increment() { count += 1 }
}


// MARK: - Content View
struct ContentView: View {
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
    @Namespace private var shapeNamespace

    @StateObject private var counterModel = CounterModel()

    @State private var triggerKeyframes: Bool = false

    @State private var showBouncingView = false

    @State private var chartData: [Double] = [5, 12, 8, 15, 10]

     var body: some View {
         List {
             // MARK: Accessibility Section
             Section("Accessibility") {
                 VStack(alignment: .leading) {
                     Text("AXChartDescriptorRepresentable").font(.headline)
                     HStack(alignment: .bottom, spacing: 2) { ForEach(chartData.indices, id: \.self) { index in Rectangle().fill(.blue.opacity(max(0.1, (chartData[index]/(chartData.max() ?? 1))))).frame(width: 20, height: max(1, chartData[index] * 5)) } }
                     .frame(height: 100, alignment: .bottom).accessibilityChartDescriptor(MyChartDescriptorRepresentable(dataPoints: chartData))
                     Button("Change Chart Data") { chartData = chartData.map { _ in Double.random(in: 5...20) } }
                 }.padding(.vertical)
                 VStack(alignment: .leading) { Text("Accessibility Traits & Headings").font(.headline).accessibilityHeading(.h1); Text("This button has accessibility traits.").accessibilityHeading(.h2); Button("Selectable Button") { }.accessibilityAddTraits([.isButton, .isSelected]) }.padding(.vertical)
                 VStack(alignment: .leading) { Text("Text Content Type").font(.headline); Text("let x = 5 // Source Code").font(.system(.body, design: .monospaced)).accessibilityTextContentType(.sourceCode) }.padding(.vertical)
             }

             // MARK: Alignment & Layout Section
             Section("Alignment & Layout") {
                VStack(alignment: .leading) { Text("Alignment & Custom Alignment").font(.headline); HStack(alignment: .firstTextBaseline) { Text("Label:").font(.body); Text("Value").font(.largeTitle) }.padding(.bottom); HStack(alignment: .firstThird, spacing: 1) { Color.red.frame(width: 30, height: 60); Color.green.frame(width: 30, height: 120); Color.blue.frame(width: 30, height: 90) }.frame(height: 130); Text("Custom .firstThird VerticalAlignment").font(.caption) }.padding(.vertical)
                VStack(alignment: .leading) { Text("Custom Layout (BasicVStackLayout)").font(.headline); BasicVStackLayout(spacing: 5) { Text("Line 1"); Text("Longer Line 2").font(.title2); Text("Line 3") }.border(Color.gray) }.padding(.vertical)
               VStack(alignment: .leading) { Text("GeometryReader").font(.headline); GeometryReader { geo in Text("View size: \(Int(geo.size.width)) x \(Int(geo.size.height))").position(x: geo.size.width / 2, y: geo.size.height / 2).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) }.frame(height: 100).border(Color.cyan) }.padding(.vertical)
             }

              // MARK: State Management Basics Section
             Section("State Management Basics") {
                 VStack(alignment: .leading) { Text("State & Binding").font(.headline); Toggle("Enable Feature", isOn: $isEnabled); Text("Feature is \(isEnabled ? "ON" : "OFF")") }.padding(.vertical)
                 VStack(alignment: .leading) { Text("Environment Values").font(.headline); ColorSchemeToggle(colorSchemeOverride: $colorSchemeOverride); Text("Current scheme: \(colorSchemeOverride?.description ?? "System")").environment(\.colorScheme, colorSchemeOverride ?? .light) }.padding(.vertical)
                 VStack(alignment: .leading) { Text("StateObject & EnvironmentObject").font(.headline); CounterView(); Button("Increment Shared Counter") { counterModel.increment() } }.padding(.vertical).environmentObject(counterModel)
             }

             // MARK: Animation & Transition Section
             Section("Animation & Transition") {
                 VStack(alignment: .leading) { Text(".animation() Modifier Example").font(.headline); Circle().fill(.orange).frame(width: 50, height: 50).scaleEffect(sliderValue).animation(.spring(dampingFraction: 0.4), value: sliderValue); Slider(value: $sliderValue, in: 0.5...1.5) }.padding(.vertical)
                 VStack(alignment: .leading) { Text("withAnimation Example").font(.headline); Rectangle().fill(.purple).frame(width: isEnabled ? 100 : 50, height: 50); Button("Toggle Size (withAnimation)") { withAnimation(.easeInOut(duration: 0.5)) { isEnabled.toggle() } } }.padding(.vertical)
                 VStack(alignment: .leading) { Text("Transitions").font(.headline); if isShowingTransitionView { Text("Hello Transition!").padding().background(Color.yellow).transition(.move(edge: .bottom).combined(with: .opacity)) }; Button("Toggle Transition View") { withAnimation(.snappy) { isShowingTransitionView.toggle() } } }.padding(.vertical)
                 VStack(alignment: .leading) { Text("Asymmetric Transition").font(.headline); if isShowingAsymmetricView { Text("Different In/Out").padding().background(Color.mint).transition(.asymmetric(insertion: .scale.animation(.bouncy), removal: .slide.animation(.easeOut))) }; Button("Toggle Asymmetric View") { withAnimation { isShowingAsymmetricView.toggle() } } }.padding(.vertical)
                 VStack(alignment: .leading) { Text("Content Transition").font(.headline); Text(counterTitle).font(.system(size: 30, weight: .bold, design: .rounded)).id("CounterText:\(counterModel.count)").frame(minWidth: 100, alignment: .center).contentTransition(.numericText(countsDown: counterModel.count < Int.random(in: -5...5))); Button("Increment for Content Transition") { withAnimation(.smooth(duration: 0.5)) { counterModel.increment(); counterTitle = "Count: \(counterModel.count)" } } }.padding(.vertical)
                 VStack(alignment: .leading) { Text("Matched Geometry Effect").font(.headline); HStack { if !isShowingAsymmetricView { Circle().fill(.red).matchedGeometryEffect(id: "shape", in: shapeNamespace).frame(width: 50, height: 50) }; Spacer(); if isShowingAsymmetricView { Rectangle().fill(.red).matchedGeometryEffect(id: "shape", in: shapeNamespace).frame(width: 100, height: 50) } }.frame(height: 60) }.padding(.vertical)
                 VStack(alignment: .leading) { Text("Keyframe Animator").font(.headline); KeyframeAnimator(initialValue: KeyframeDemoValues(), trigger: triggerKeyframes) { values in Rectangle().fill(.teal).frame(width: 50, height: 50).scaleEffect(values.scale).rotationEffect(values.rotation).offset(x: values.offset.x, y: values.offset.y) } keyframes: { initialValues in KeyframeTrack(\.offset) { CubicKeyframe(CGPoint(x: 50, y: 0), duration: 0.4); SpringKeyframe(CGPoint(x: 0, y: 50), spring: .bouncy); LinearKeyframe(CGPoint.zero, duration: 0.3) }; KeyframeTrack(\.rotation) { LinearKeyframe(.degrees(0), duration: 0.1); CubicKeyframe(.degrees(45), duration: 0.5); SpringKeyframe(.degrees(0), spring: .smooth) }; KeyframeTrack(\.scale) { CubicKeyframe(1.0, duration: 0.1); CubicKeyframe(1.3, duration: 0.4); SpringKeyframe(1.0, spring: .snappy) } }.frame(height: 70); Button("Run Keyframes") { triggerKeyframes.toggle() } }.padding(.vertical)
                 VStack(alignment: .leading) { Text("Custom Bounce Animation").font(.headline); Circle().fill(showBouncingView ? .green : .gray).frame(width: 50, height: 50).scaleEffect(showBouncingView ? 1.3 : 1.0); Button("Trigger Custom Bounce") { withAnimation(.bounce(duration: 1.0)) { showBouncingView.toggle() } } }.padding(.vertical)
             }

             // MARK: Drawing & Shapes Section
             Section("Drawing & Shapes") {
                 VStack(alignment: .leading) { Text("Shapes (Rectangle, Circle, Capsule, Path)").font(.headline); HStack { Rectangle().fill(.red).frame(width: 40, height: 40); Circle().stroke(.blue, lineWidth: 2).frame(width: 40, height: 40); Capsule().fill(.green).frame(width: 60, height: 30); CustomTriangle().fill(.yellow).frame(width: 40, height: 40) } }.padding(.vertical)
                 VStack(alignment: .leading) { Text("Shape Styles (Color, Gradients, ForegroundStyle)").font(.headline); HStack { Rectangle().fill(.primary); Rectangle().fill(LinearGradient(gradient: Gradient(colors: [.orange, .purple]), startPoint: .top, endPoint: .bottom)); Rectangle().fill(RadialGradient(gradient: Gradient(colors: [.white, .black]), center: .center, startRadius: 5, endRadius: 50)); Rectangle().fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center)); Text("FG").font(.largeTitle).foregroundStyle(.secondary) }.frame(height: 50) }.padding(.vertical)
                 VStack(alignment: .leading) { Text("Canvas & GraphicsContext").font(.headline); Canvas { context, size in let rect = CGRect(origin: .zero, size: size); context.stroke(Path(ellipseIn: rect), with: .color(.green), lineWidth: 4); context.fill(Path(rect.insetBy(dx: 20, dy: 20)), with: .color(.blue.opacity(0.5))); var resolvedText = context.resolve(Text("Canvas Text").font(.caption)); resolvedText.shading = .color(.white); context.draw(resolvedText, at: CGPoint(x: size.width/2, y: size.height/2), anchor: .center) }.frame(height: 100).border(Color.gray) }.padding(.vertical)
             }

             // MARK: Gestures Section
             Section("Gestures") {
                 VStack(alignment: .leading) { Text("TapGesture Example").font(.headline); Text("Tapped \(tapCount) times").padding().background(Color.yellow.opacity(0.3)).onTapGesture(count: 2) { tapCount += 1 } }.padding(.vertical)
                 VStack(alignment: .leading) { Text("DragGesture Example").font(.headline); Circle().fill(isDragging ? Color.green : Color.blue).frame(width: 60, height: 60).offset(dragOffset).gesture(DragGesture().onChanged { value in dragOffset = value.translation; if !isDragging { isDragging = true } }.onEnded { value in withAnimation(.spring()) { dragOffset = .zero; isDragging = false } }); Text("Drag the circle").font(.caption).frame(height: 80) }.padding(.vertical)
                 VStack(alignment: .leading) { Text("GestureState (LongPress scale)").font(.headline); GestureStateScalingButton() }.padding(.vertical)
             }

             // Mark: Miscellaneous
             Section("Miscellaneous") {
                VStack(alignment: .leading) { Text("DynamicTypeSize").font(.headline); DynamicTypeSizeView() }.padding(.vertical)
                VStack(alignment: .leading) { Text("Image Rendering and Display").font(.headline); Image("LandscapePlaceholder").resizable().scaledToFit().frame(height: 100).overlay(Text("Scaled to Fit").font(.caption).foregroundColor(.white).padding(2).background(.black.opacity(0.5)), alignment: .bottom); Image(systemName: "star.fill").renderingMode(.template).foregroundStyle(.yellow).imageScale(.large) }.padding(.vertical)
             }

         } // End List
         .listStyle(.plain)
     }
} // End ContentView


// MARK: - Helper Views for Demos
struct ColorSchemeToggle: View {
    @Environment(\.colorScheme) var currentScheme
    @Binding var colorSchemeOverride: ColorScheme?
    var body: some View { VStack { Text("System Scheme: \(currentScheme == .dark ? "Dark" : "Light")"); Picker("Override Scheme", selection: $colorSchemeOverride) { Text("System").tag(ColorScheme?.none); Text("Light").tag(ColorScheme?.some(.light)); Text("Dark").tag(ColorScheme?.some(.dark)) }.pickerStyle(.segmented) } }
}

struct CounterView: View {
    @EnvironmentObject var model: CounterModel
    var body: some View { Text("Shared Count: \(model.count)").font(.title2).padding(.bottom, 5) }
}

struct CustomTriangle: Shape {
    func path(in rect: CGRect) -> Path { Path { path in path.move(to: CGPoint(x: rect.midX, y: rect.minY)); path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)); path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)); path.closeSubpath() } }
}

struct GestureStateScalingButton: View {
     @GestureState private var isPressing: Bool = false
     var body: some View { Text("Press & Hold Me").padding().background(isPressing ? Color.blue.opacity(0.5) : Color.blue).foregroundColor(.white).cornerRadius(10).scaleEffect(isPressing ? 0.95 : 1.0).animation(.easeInOut(duration: 0.15), value: isPressing).gesture(LongPressGesture(minimumDuration: .infinity).updating($isPressing) { currentState, gestureState, transaction in gestureState = currentState }) }
}

struct DynamicTypeSizeView: View {
     @Environment(\.dynamicTypeSize) var size
     var body: some View { VStack(alignment: .leading) { Text("System Default (\(size.description))"); Text("XLarge Override").dynamicTypeSize(.xLarge); Text("Constrained Range").dynamicTypeSize(.xSmall ... .large) } }
}


// --- Extensions ---
extension DynamicTypeSize: @retroactive CustomStringConvertible {
    public var description: String { String(describing: self) }
}

extension ColorScheme: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        @unknown default: return "Unknown"
        }
    }
}

/// Placeholder image resource if needed for previews/compilation
#if DEBUG
extension Image {
    /// Special initializer for DEBUG mode to handle the placeholder image name.
    init(_ name: StaticString) {
        if toString(name) == "My-meme-original" { // Use your actual placeholder string here
            self.init(systemName: "photo")
        } else {
            self.init(toString(name))
        }
    }

    /// Helper to convert StaticString to String
    private func toString(_ staticString: StaticString) -> String {
        return staticString.withUTF8Buffer { buffer in
            // ** FIX: Correct guard condition **
            // Ensure buffer has a valid base address (is not nil) AND has contents
            guard buffer.baseAddress != nil, buffer.count > 0 else {
                return "" // Return empty string if buffer is invalid/empty
            }
            // Proceed only if guard passes
            return String(decoding: buffer, as: UTF8.self)
        }
    }
}
#endif


// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)

        ContentView()
            .preferredColorScheme(.dark)
    }
}
