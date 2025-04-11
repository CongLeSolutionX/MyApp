////
////  ContentView.swift
////  MyApp
////
////  Created by Cong Le on 8/19/24.
////
////
////import SwiftUI
////
////// Step 2: Use in SwiftUI view
////struct ContentView: View {
////    var body: some View {
////        UIKitViewControllerWrapper()
////            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
////    }
////}
////
////// Before iOS 17, use this syntax for preview UIKit view controller
////struct UIKitViewControllerWrapper_Previews: PreviewProvider {
////    static var previews: some View {
////        UIKitViewControllerWrapper()
////    }
////}
////
////// After iOS 17, we can use this syntax for preview:
////#Preview {
////    ContentView()
////}
//
//import SwiftUI
//
//// MARK: - Enums for Configuration
//
///// Defines the orientation of the color wave animation.
//enum WaveOrientation {
//    case horizontal
//    case vertical
//}
//
///// Defines the shape used for the individual wave segments.
//enum WaveShapeType {
//    case rectangle
//    case circle
//}
//
//// MARK: - ColorWaveView Implementation
//
//struct ColorWaveView: View {
//
//    // MARK: - Configuration Properties
//
//    /// The array of colors to display in the wave.
//    let colors: [Color]
//
//    /// The total duration for one full cycle of the wave animation (in seconds).
//    let animationDuration: Double
//
//    /// The amplitude of the wave (controls how far segments deviate from the center).
//    let amplitude: CGFloat
//
//    /// The orientation of the wave (horizontal or vertical).
//    let orientation: WaveOrientation
//
//    /// The shape used for the wave segments (rectangle or circle).
//    let shapeType: WaveShapeType
//
//    /// The animation curve to use for the wave movement.
//    let animationCurve: Animation
//
//    // MARK: - State Variables
//
//    /// Tracks the current phase of the animation cycle (0 to 2 * pi).
//    @State private var phase: CGFloat = 0
//
//    /// Controls whether the animation is currently active.
//    @State private var isAnimating: Bool
//
//    // MARK: - Initializer
//
//    /// Creates a new ColorWaveView.
//    ///
//    /// - Parameters:
//    ///   - colors: An array of `Color` for the wave segments. Defaults to a rainbow spectrum.
//    ///   - animationDuration: Duration of one full wave cycle in seconds. Defaults to 3.0.
//    ///   - amplitude: Controls the "height" or intensity of the wave. Defaults to 20.0.
//    ///   - orientation: `.horizontal` or `.vertical` wave movement. Defaults to `.horizontal`.
//    ///   - shapeType: `.rectangle` or `.circle` for wave segments. Defaults to `.rectangle`.
//    ///   - animationCurve: The SwiftUI `Animation` to use (e.g., `.linear`, `.easeInOut`). Defaults to `.linear`.
//    ///   - startAnimating: Whether the animation should start immediately on appear. Defaults to `true`.
//    init(
//        colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple],
//        animationDuration: Double = 3.0,
//        amplitude: CGFloat = 20.0,
//        orientation: WaveOrientation = .horizontal,
//        shapeType: WaveShapeType = .rectangle,
//        animationCurve: Animation = .linear,
//        startAnimating: Bool = true
//    ) {
//        // Basic validation
//        guard !colors.isEmpty else {
//            // Use a default if empty array is passed
//            self.colors = [.gray, .blue]
//             print("Warning: ColorWaveView initialized with empty colors array. Using default.")
//       } else {
//            self.colors = colors
//        }
//       guard animationDuration > 0 else {
//            self.animationDuration = 1.0 // Prevent division by zero or non-sensical animation
//            print("Warning: ColorWaveView animationDuration must be positive. Using 1.0.")
//       } else {
//           self.animationDuration = animationDuration
//       }
//
//        self.amplitude = amplitude
//        self.orientation = orientation
//        self.shapeType = shapeType
//        self.animationCurve = animationCurve
//        self._isAnimating = State(initialValue: startAnimating) // Initialize State variable
//    }
//
//    // MARK: - Body
//
//    var body: some View {
//        // Use GeometryReader to get available size for calculations
//        GeometryReader { geometry in
//            // ZStack layers the shapes on top of each other
//            ZStack {
//                // Create a shape for each color
//                ForEach(0..<colors.count, id: \.self) { index in
//                     // Calculate the dynamic offset based on the wave parameters
//                    let offset = calculateOffset(
//                        geometryProxy: geometry,
//                        index: index,
//                        phase: phase,
//                        amplitude: amplitude,
//                        orientation: orientation,
//                        shapeCount: colors.count
//                    )
//
//                    // Create the appropriate shape based on configuration
//                    shape(for: index, geometry: geometry)
//                        .fill(colors[index])
//                         // Apply frame BEFORE offset to ensure correct sizing
//                        .frame(
//                            width: frameSize(for: geometry, orientation: orientation).width,
//                            height: frameSize(for: geometry, orientation: orientation).height
//                        )
//                        // Apply the calculated offset to create the wave motion
//                        .offset(x: offset.dx, y: offset.dy)
//                }
//            }
//            // Ensure the ZStack fills the geometry reader bounds
//           .frame(width: geometry.size.width, height: geometry.size.height)
//           // Clip to bounds to prevent shapes from drawing outside the view
//           .clipped()
//       }
//       // Apply the main animation modifier
//       .animation(isAnimating ? animationCurve.repeatForever(autoreverses: false) : .default, value: phase)
//       .onAppear(perform: setupAnimation)
//       // Add onChange to handle starting/stopping animation externally
//       .onChange(of: isAnimating) { newValue in
//           if newValue {
//               startAnimationLoop()
//           } else {
//               // Stop the animation by setting phase to its current value without animation
//               // The .animation modifier takes care of disabling the loop
//               phase = phase // Keep the current phase when stopped
//           }
//       }
//    }
//
//    // MARK: - Animation Control Methods
//
//    /// Starts or resumes the animation loop.
//    func start() {
//        isAnimating = true
//    }
//
//    /// Stops the animation loop.
//    func stop() {
//        isAnimating = false
//    }
//
//    /// Toggles the animation state (start/stop).
//    func toggle() {
//        isAnimating.toggle()
//    }
//
//    // MARK: - Private Helper Methods
//
//    /// Sets up the initial animation state on view appear.
//    private func setupAnimation() {
//        if isAnimating {
//            startAnimationLoop()
//        }
//    }
//
//    /// Initiates the animation loop by setting the target phase.
//    private func startAnimationLoop() {
//        // Trigger the animation by setting the target value for the `phase` state variable.
//        // The `.animation` modifier will handle the interpolation over the duration.
//        phase = 2 * .pi
//    }
//
//    /// Creates and returns the appropriate shape view based on `shapeType`.
//    @ViewBuilder
//    private func shape(for index: Int, geometry: GeometryProxy) -> some View {
//        switch shapeType {
//        case .rectangle:
//            Rectangle()
//        case .circle:
//             // Make circle diameter fit the smaller dimension of the segment
//            let segmentSize = frameSize(for: geometry, orientation: orientation)
//            let diameter = min(segmentSize.width, segmentSize.height)
//             // We still return a Circle(), the frame modifier will size it correctly.
//            // NOTE: If circles are used in horizontal orientation, they might appear cut off
//            //       unless the amplitude is small or view height is large enough.
//            Circle()
//         }
//    }
//
//    /// Calculates the frame size for each shape segment based on orientation.
//    private func frameSize(for geometry: GeometryProxy, orientation: WaveOrientation) -> CGSize {
//        let count = CGFloat(colors.count)
//        guard count > 0 else { return .zero}
//
//        switch orientation {
//        case .horizontal:
//            // Segments are vertical strips
//            return CGSize(width: geometry.size.width / count, height: geometry.size.height)
//        case .vertical:
//            // Segments are horizontal strips
//            return CGSize(width: geometry.size.width, height: geometry.size.height / count)
//        }
//    }
//
//    /// Calculates the required offset (dx, dy) for a shape segment to create the wave effect.
//    private func calculateOffset(
//        geometryProxy geometry: GeometryProxy,
//        index: Int,
//        phase: CGFloat,
//        amplitude: CGFloat,
//        orientation: WaveOrientation,
//        shapeCount: Int
//    ) -> CGSize {
//        guard shapeCount > 0 else { return .zero }
//        let count = CGFloat(shapeCount)
//        let size = geometry.size
//
//        // Calculate the angular offset for this segment within a full 2π cycle
//        let angleOffset = CGFloat(index) * 2 * .pi / count
//
//        // Calculate the dynamic sine wave component
//        let dynamicOffset = amplitude * sin(phase + angleOffset)
//
//        switch orientation {
//        case .horizontal:
//            // Calculate the basic horizontal position (centers the segment)
//            let segmentWidth = size.width / count
//            // Position is calculated from the center of the view, offset by segment index
//            let staticX = (CGFloat(index) * segmentWidth) + (segmentWidth / 2) - (size.width / 2)
//             // Total offset is static position + dynamic wave offset
//            return CGSize(width: staticX + dynamicOffset, height: 0)
//
//        case .vertical:
//            // Calculate the basic vertical position (centers the segment)
//            let segmentHeight = size.height / count
//            // Position is calculated from the center of the view, offset by segment index
//            let staticY = (CGFloat(index) * segmentHeight) + (segmentHeight / 2) - (size.height / 2)
//            // Total offset is static position + dynamic wave offset
//            return CGSize(width: 0, height: staticY + dynamicOffset)
//        }
//    }
//}
//
//// MARK: - Example Usage ContentView
//
//struct ContentView: View {
//    @State private var wave1IsAnimating = true
//    @State private var waveAmplitude: CGFloat = 25.0
//    @State private var waveDuration: Double = 4.0
//    
//    // State for the controllable wave view
//    @State private var controllableWave: ColorWaveView?
//    @State private var controllableIsAnimating: Bool = false
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 30) {
//
//                // --- Use Case 1: Default Horizontal Wave ---
//                VStack {
//                    Text("Default Horizontal Wave").font(.headline)
//                    ColorWaveView() // Uses all default parameters
//                        .frame(height: 100)
//                        .cornerRadius(10)
//                        .shadow(radius: 5)
//                }
//
//                // --- Use Case 2: Customized Horizontal Wave (Circles, Faster, Higher Amp) ---
//                 VStack {
//                     Text("Custom Horizontal (Circles, Fast, High Amp)").font(.headline)
//                     ColorWaveView(
//                         colors: [.cyan, .mint, .teal, .blue, .indigo],
//                         animationDuration: 1.5,
//                         amplitude: 40,
//                         shapeType: .circle,
//                         animationCurve: .easeInOut
//                     )
//                     .frame(height: 150)
//                     .cornerRadius(10)
//                 }
//
//                // --- Use Case 3: Vertical Wave ---
//                VStack {
//                    Text("Vertical Wave").font(.headline)
//                    ColorWaveView(
//                        colors: [.pink, .purple, .red, .orange],
//                        orientation: .vertical
//                    )
//                    .frame(height: 200) // Give it more height to be noticeable
//                    .cornerRadius(10)
//                }
//
//                // --- Use Case 4: Wave as a Background ---
//                 VStack {
//                     Text("Wave as Background").font(.headline)
//                     ZStack {
//                         ColorWaveView(
//                            colors: [.black, .gray.opacity(0.7), .white.opacity(0.5), .gray.opacity(0.7)],
//                            animationDuration: 6,
//                             amplitude: 15,
//                            animationCurve: .easeInOut
//                         )
//                         .blur(radius: 5) // Optional blur for softer background
//
//                         Text("Content on Top")
//                             .font(.title)
//                             .padding()
//                             .background(.ultraThinMaterial) // Make text readable
//                             .cornerRadius(8)
//                     }
//                     .frame(height: 120)
//                     .cornerRadius(10)
//                 }
//
//                // --- Use Case 5: Controllable Wave ---
//                VStack {
//                    Text("Controllable Wave").font(.headline)
//
//                    // Use optional state to dynamically create/hold the view instance
//                    // This allows changing parameters via sliders/pickers if needed by recreating it
//                    if let wave = controllableWave {
//                         wave // Display the wave
//                            .frame(height: 100)
//                            .cornerRadius(10)
//                    } else {
//                        // Placeholder or initial state view
//                         RoundedRectangle(cornerRadius: 10)
//                            .fill(.gray.opacity(0.2))
//                            .frame(height: 100)
//                            .overlay(Text("Wave Placeholder"))
//                    }
//
//                    HStack {
//                        Button(controllableIsAnimating ? "Stop" : "Start") {
//                            controllableIsAnimating.toggle()
//                            // Update the state passed to the ColorWaveView's toggle
//                            if controllableIsAnimating {
//                                controllableWave?.start()
//                            } else {
//                                controllableWave?.stop()
//                            }
//                        }
//                        .buttonStyle(.borderedProminent)
//
//                         Button("Reset Phase (Stop)") {
//                             controllableIsAnimating = false
//                             // Recreate the view instance to reset its internal state including phase
//                             controllableWave = createControllableWave()
//                         }
//                         .buttonStyle(.bordered)
//                    }
//                    .padding(.top, 5)
//                }
//               // Initialize the controllable wave when the view appears
//               .onAppear {
//                   controllableWave = createControllableWave()
//               }
//               // Update the internal animation state when the external state changes
//                .onChange(of: controllableIsAnimating) { newValue in
//                    if newValue {
//                        controllableWave?.start()
//                    } else {
//                        controllableWave?.stop()
//                    }
//                }
//
//                Spacer() // Push content to top
//            }
//            .padding()
//        }
//    }
//    
//    // Helper function to create the controllable wave instance
//    private func createControllableWave() -> ColorWaveView {
//        return ColorWaveView(
//            colors: [.green, .yellow, .orange],
//            animationDuration: 3.0,
//            amplitude: 30,
//            startAnimating: controllableIsAnimating // Initialize internal state correctly
//        )
//    }
//}
//
//// MARK: - App Entry Point
//
//@main
//struct ColorWaveApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
