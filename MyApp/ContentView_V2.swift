//
//  V2.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//

import SwiftUI

// MARK: - Enums for Configuration

/// Defines the orientation of the color wave animation.
enum WaveOrientation {
    case horizontal
    case vertical
}

/// Defines the shape used for the individual wave segments.
enum WaveShapeType {
    case rectangle
    case circle
}

// MARK: - ColorWaveView Implementation

struct ColorWaveView: View {

    // MARK: - Configuration Properties

    /// The array of colors to display in the wave.
    let colors: [Color]

    /// The total duration for one full cycle of the wave animation (in seconds).
    let animationDuration: Double

    /// The amplitude of the wave (controls how far segments deviate from the center).
    let amplitude: CGFloat

    /// The orientation of the wave (horizontal or vertical).
    let orientation: WaveOrientation

    /// The shape used for the wave segments (rectangle or circle).
    let shapeType: WaveShapeType

    /// The animation curve to use for the wave movement.
    let animationCurve: Animation

    // MARK: - State Variables

    /// Tracks the current phase of the animation cycle (0 to 2 * pi).
    @State private var phase: CGFloat = 0

    /// Controls whether the animation is currently active.
    @State private var isAnimating: Bool

    // MARK: - Initializer

    /// Creates a new ColorWaveView.
    ///
    /// - Parameters:
    ///   - colors: An array of `Color` for the wave segments. Defaults to a rainbow spectrum.
    ///   - animationDuration: Duration of one full wave cycle in seconds. Defaults to 3.0.
    ///   - amplitude: Controls the "height" or intensity of the wave. Defaults to 20.0.
    ///   - orientation: `.horizontal` or `.vertical` wave movement. Defaults to `.horizontal`.
    ///   - shapeType: `.rectangle` or `.circle` for wave segments. Defaults to `.rectangle`.
    ///   - animationCurve: The SwiftUI `Animation` to use (e.g., `.linear`, `.easeInOut`). Defaults to `.linear`.
    ///   - startAnimating: Whether the animation should start immediately on appear. Defaults to `true`.
    init(
        colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple],
        animationDuration: Double = 3.0,
        amplitude: CGFloat = 20.0,
        orientation: WaveOrientation = .horizontal,
        shapeType: WaveShapeType = .rectangle,
        animationCurve: Animation = .linear,
        startAnimating: Bool = true
    ) {
        // Basic validation
        guard !colors.isEmpty else {
            // Use a default if empty array is passed
            self.colors = [.gray, .blue]
            print("Warning: ColorWaveView initialized with empty colors array. Using default.")
        } // <-- Closing brace
        // CORRECTED: else moved to new line
        else {
            self.colors = colors
        }

        guard animationDuration > 0 else {
            self.animationDuration = 1.0 // Prevent division by zero or non-sensical animation
            print("Warning: ColorWaveView animationDuration must be positive. Using 1.0.")
        } // <-- Closing brace
        // CORRECTED: else moved to new line
        else {
            self.animationDuration = animationDuration
        }

        self.amplitude = amplitude
        self.orientation = orientation
        self.shapeType = shapeType
        self.animationCurve = animationCurve
        self._isAnimating = State(initialValue: startAnimating) // Initialize State variable
    }

    // MARK: - Body

    var body: some View {
        // Use GeometryReader to get available size for calculations
        GeometryReader { geometry in
            // ZStack layers the shapes on top of each other
            ZStack {
                // Create a shape for each color
                // CORRECTED: Removed `id: \.self` to help compiler inference
                ForEach(0..<colors.count) { index in
                     // Calculate the dynamic offset based on the wave parameters
                    let offset = calculateOffset(
                        geometryProxy: geometry,
                        index: index, // index is now correctly inferred as Int
                        phase: phase,
                        amplitude: amplitude,
                        orientation: orientation,
                        shapeCount: colors.count
                    )

                    // Create the appropriate shape based on configuration
                    shape(for: index, geometry: geometry)
                        .fill(colors[index])
                         // Apply frame BEFORE offset to ensure correct sizing
                        .frame(
                            width: frameSize(for: geometry, orientation: orientation).width,
                            height: frameSize(for: geometry, orientation: orientation).height
                        )
                        // Apply the calculated offset to create the wave motion
                        .offset(x: offset.dx, y: offset.dy)
                }
            }
            // Ensure the ZStack fills the geometry reader bounds
           .frame(width: geometry.size.width, height: geometry.size.height)
           // Clip to bounds to prevent shapes from drawing outside the view
           .clipped()
       }
       // Apply the main animation modifier
       .animation(isAnimating ? animationCurve.repeatForever(autoreverses: false) : .default, value: phase)
       .onAppear(perform: setupAnimation)
       // Add onChange to handle starting/stopping animation externally
       .onChange(of: isAnimating) { newValue in
           if newValue {
               startAnimationLoop()
           } else {
               // Stop the animation by setting phase to its current value without animation
               // The .animation modifier takes care of disabling the loop
               phase = phase // Keep the current phase when stopped
           }
       }
    }

    // MARK: - Animation Control Methods

    /// Starts or resumes the animation loop.
    func start() {
        isAnimating = true
    }

    /// Stops the animation loop.
    func stop() {
        isAnimating = false
    }

    /// Toggles the animation state (start/stop).
    func toggle() {
        isAnimating.toggle()
    }

    // MARK: - Private Helper Methods

    /// Sets up the initial animation state on view appear.
    private func setupAnimation() {
        if isAnimating {
            startAnimationLoop()
        }
    }

    /// Initiates the animation loop by setting the target phase.
    private func startAnimationLoop() {
        // Trigger the animation by setting the target value for the `phase` state variable.
        // The `.animation` modifier will handle the interpolation over the duration.
        // Ensure we restart from current phase if stopped mid-way, or 0 if starting fresh/reset
        // A simple 2 * .pi target is sufficient as the animation modifier handles looping.
        phase = phase + 2 * .pi // Increment phase; .repeatForever handles the wrap-around
    }

    /// Creates and returns the appropriate shape view based on `shapeType`.
    @ViewBuilder
    private func shape(for index: Int, geometry: GeometryProxy) -> some View {
        switch shapeType {
        case .rectangle:
            Rectangle()
        case .circle:
             // Make circle diameter fit the smaller dimension of the segment
            let segmentSize = frameSize(for: geometry, orientation: orientation)
            let diameter = min(segmentSize.width, segmentSize.height)
             // We still return a Circle(), the frame modifier will size it correctly.
            // NOTE: If circles are used in horizontal orientation, they might appear cut off
            //       unless the amplitude is small or view height is large enough.
             // Corrected: Use Circle() directly, frame handles size
             Circle()
        }
    }

    /// Calculates the frame size for each shape segment based on orientation.
    private func frameSize(for geometry: GeometryProxy, orientation: WaveOrientation) -> CGSize {
        let count = CGFloat(colors.count)
        guard count > 0 else { return .zero}

        switch orientation {
        case .horizontal:
            // Segments are vertical strips
            return CGSize(width: geometry.size.width / count, height: geometry.size.height)
        case .vertical:
            // Segments are horizontal strips
            return CGSize(width: geometry.size.width, height: geometry.size.height / count)
        }
    }

    /// Calculates the required offset (dx, dy) for a shape segment to create the wave effect.
    private func calculateOffset(
        geometryProxy geometry: GeometryProxy,
        index: Int,
        phase: CGFloat,
        amplitude: CGFloat,
        orientation: WaveOrientation,
        shapeCount: Int
    ) -> CGSize {
        guard shapeCount > 0 else { return .zero }
        let count = CGFloat(shapeCount)
        let size = geometry.size

        // Calculate the angular offset for this segment within a full 2π cycle
        let angleOffset = CGFloat(index) * 2 * .pi / count

        // Calculate the dynamic sine wave component
        let dynamicOffset = amplitude * sin(phase + angleOffset)

        switch orientation {
        case .horizontal:
            // Calculate the basic horizontal position (centers the segment)
            let segmentWidth = size.width / count
            // Position is calculated from the center of the view, offset by segment index
            // Need to account for the segment's own width to place its center correctly.
            let staticX = CGFloat(index) * segmentWidth // Left edge of segment
                                // removed + (segmentWidth / 2) - (size.width / 2) // simplified below

            // Calculate the offset relative to the segment's natural position
            // The .offset modifier moves ORIGIN, so we calculate displacement from that.
             // The ZStack places origins at the center by default.
             // Let's rethink the offset calculation for ZStack placement.
             // ZStack centers content. Each segment's default origin is the center.
             // We need to move it left/right first, then apply the dynamic offset.

            let alignmentOffset = (CGFloat(index) - (count - 1) / 2.0) * segmentWidth
             return CGSize(width: alignmentOffset + dynamicOffset, height: 0)

        case .vertical:
            // Calculate the basic vertical position (centers the segment)
            let segmentHeight = size.height / count
            // Position is calculated similarly to horizontal, based on index and total count.
            // Need to align vertically relative to the center.
            let alignmentOffset = (CGFloat(index) - (count - 1) / 2.0) * segmentHeight
            // Total offset is static position + dynamic wave offset
            return CGSize(width: 0, height: alignmentOffset + dynamicOffset)
        }
    }
}

// MARK: - Example Usage ContentView

struct ContentView: View {
    @State private var wave1IsAnimating = true
    @State private var waveAmplitude: CGFloat = 25.0
    @State private var waveDuration: Double = 4.0

    // State for the controllable wave view
    // Keep track of the config to recreate if needed
    @State private var controllableWaveConfig = ColorWaveConfig()
    @State private var controllableIsAnimating: Bool = false

    struct ColorWaveConfig {
        var colors: [Color] = [.green, .yellow, .orange]
        var duration: Double = 3.0
        var amplitude: CGFloat = 30
        // Add other parameters if you want to control them too
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {

                // --- Use Case 1: Default Horizontal Wave ---
                VStack {
                    Text("Default Horizontal Wave").font(.headline)
                    ColorWaveView() // Uses all default parameters
                        .frame(height: 100)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }

                // --- Use Case 2: Customized Horizontal Wave (Circles, Faster, Higher Amp) ---
                 VStack {
                     Text("Custom Horizontal (Circles, Fast, High Amp)").font(.headline)
                     ColorWaveView(
                         colors: [.cyan, .mint, .teal, .blue, .indigo],
                         animationDuration: 1.5,
                         amplitude: 40,
                         shapeType: .circle,
                         animationCurve: .easeInOut
                     )
                     .frame(height: 150)
                     .cornerRadius(10)
                 }

                // --- Use Case 3: Vertical Wave ---
                VStack {
                    Text("Vertical Wave").font(.headline)
                    ColorWaveView(
                        colors: [.pink, .purple, .red, .orange],
                        orientation: .vertical
                    )
                    .frame(height: 200) // Give it more height to be noticeable
                    .cornerRadius(10)
                }

                // --- Use Case 4: Wave as a Background ---
                 VStack {
                     Text("Wave as Background").font(.headline)
                     ZStack {
                         ColorWaveView(
                            colors: [.black, .gray.opacity(0.7), .white.opacity(0.5), .gray.opacity(0.7)],
                            animationDuration: 6,
                             amplitude: 15,
                            animationCurve: .easeInOut
                         )
                         .blur(radius: 5) // Optional blur for softer background

                         Text("Content on Top")
                             .font(.title)
                             .padding()
                             .background(.ultraThinMaterial) // Make text readable
                             .cornerRadius(8)
                     }
                     .frame(height: 120)
                     .cornerRadius(10)
                 }

                // --- Use Case 5: Controllable Wave ---
                 VStack {
                     Text("Controllable Wave").font(.headline)

                     // Create the view based on the current config and animation state
                     // Recreated whenever config changes, automatically uses `controllableIsAnimating`
                     ColorWaveView(
                         colors: controllableWaveConfig.colors,
                         animationDuration: controllableWaveConfig.duration,
                         amplitude: controllableWaveConfig.amplitude,
                         startAnimating: controllableIsAnimating // Pass current state
                     )
                     .frame(height: 100)
                     .cornerRadius(10)
                     // Add ID to force recreation if needed, but init parameter should suffice
                     // .id(UUID()) // Uncomment if view doesn't update reliably on state change

                     HStack {
                         Button(controllableIsAnimating ? "Stop" : "Start") {
                             controllableIsAnimating.toggle()
                             // The view will react via its init/onAppear/onChange
                         }
                         .buttonStyle(.borderedProminent)

                         Button("Reset Phase (Stop)") {
                            controllableIsAnimating = false
                            // Recreate the view by slightly changing config (if needed)
                            // or rely on startAnimating: false in init
                            // For a true phase reset, you might need internal view logic
                            // or force view recreation, e.g., changing an ID
                            // Toggling state is enough to stop it based on current code
                         }
                         .buttonStyle(.bordered)

                         // Example: Add slider to control Amplitude
                         Slider(value: $controllableWaveConfig.amplitude, in: 5...50) {
                             Text("Amplitude")
                         }

                     }
                     .padding(.top, 5)
                 }

                Spacer() // Push content to top
            }
            .padding()
        }
    }
}

// MARK: - App Entry Point

@main
struct ColorWaveApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#Preview("ContentView") {
    ContentView()
}
