//
//  MetalContentView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//


import SwiftUI
import MetalKit
import Combine // Needed for Color conversion helper

// MARK: - Metal Shaders (Unchanged from previous example)

let metalShaderSource = """
using namespace metal;

// Structure to define vertex data (position and color)
struct Vertex {
    float4 position [[position]]; // Output position for rasterizer
    float4 color;             // Color associated with the vertex
};

// Structure defining the data pass from vertex to fragment shader
struct VertexOut {
    float4 position [[position]]; // Output position (required)
    float4 color;             // Interpolated color for the fragment
};

// ---- Vertex Shader ----
// Takes vertex data and a uniform time variable as input
// Outputs transformed position and vertex color
vertex VertexOut vertex_main(
                             uint vertexID [[vertex_id]], // Built-in vertex identifier
                             constant float3 *vertices [[buffer(0)]], // Input vertex positions
                             constant float4 *colors [[buffer(1)]], // Input vertex colors
                             constant float &time [[buffer(2)]] // Input uniform time
                            )
{
    VertexOut out;

    // Basic animation: Rotate the triangle based on time
    // Rotation speed is now controlled externally via the time uniform's update rate
    float angle = time; // Time itself directly represents accumulated angle
    float cosA = cos(angle);
    float sinA = sin(angle);

    // Simple 2D rotation matrix applied in Z=0 plane
    // Apply rotation to vertex position
    float3 initialPos = vertices[vertexID];
    float4 pos = float4(0.0, 0.0, 0.0, 1.0); // Initialize position

    pos.x = initialPos.x * cosA - initialPos.y * sinA;
    pos.y = initialPos.x * sinA + initialPos.y * cosA; // Use original coords for accuracy
    pos.z = initialPos.z; // Keep z the same

    out.position = pos;
    out.color = colors[vertexID]; // Pass the original color through
    return out;
}

// ---- Fragment Shader ----
// Takes the interpolated data from the vertex shader (VertexOut)
// Outputs the final color for the pixel/fragment
fragment float4 fragment_main(VertexOut in [[stage_in]]) // Input is interpolated data
{
    // Output the interpolated color directly
    return in.color;
}
"""

// MARK: - Color Conversion Helper

// Helper extension to convert SwiftUI Color to MTLClearColor
// Note: This is a simplified conversion and might not handle all Color types (e.g., gradients, materials) accurately.
// It primarily works for solid RGB colors.
extension Color {
    func toMTLClearColor() -> MTLClearColor {
        #if os(macOS)
        // On macOS, NSColor conversion works well
        let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor.clear
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return MTLClearColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
        #else
        // On iOS/visionOS etc., UIColor conversion is needed
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return MTLClearColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
        #endif
    }
}

// MARK: - Metal Renderer Class (Modified)

class MetalRenderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState
    var vertexBuffer: MTLBuffer
    var colorBuffer: MTLBuffer
    var timeBuffer: MTLBuffer

    // Control Parameters - settable from outside
    var rotationSpeed: Float = 0.5 // Default speed
    private var time: Float = 0.0 // Internal accumulated time (angle)

    // Initializer (mostly unchanged, sets default speed)
    init?(mtkView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        self.device = device
        mtkView.device = device

        guard let commandQueue = device.makeCommandQueue() else { return nil }
        self.commandQueue = commandQueue

        let vertices: [SIMD3<Float>] = [
             SIMD3<Float>( 0.0,  0.5, 0.0), SIMD3<Float>(-0.5, -0.5, 0.0), SIMD3<Float>( 0.5, -0.5, 0.0)
        ]
        let colors: [SIMD4<Float>] = [
             SIMD4<Float>(1.0, 0.0, 0.0, 1.0), SIMD4<Float>(0.0, 1.0, 0.0, 1.0), SIMD4<Float>(0.0, 0.0, 1.0, 1.0)
        ]

        guard let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<SIMD3<Float>>.stride, options: []) else { return nil }
        self.vertexBuffer = vertexBuffer
        guard let colorBuffer = device.makeBuffer(bytes: colors, length: colors.count * MemoryLayout<SIMD4<Float>>.stride, options: []) else { return nil }
        self.colorBuffer = colorBuffer
        guard let timeBuffer = device.makeBuffer(length: MemoryLayout<Float>.stride, options: .storageModeShared) else { return nil }
        self.timeBuffer = timeBuffer

        do {
            let library = try device.makeLibrary(source: metalShaderSource, options: nil)
            guard let vertexFunction = library.makeFunction(name: "vertex_main"),
                  let fragmentFunction = library.makeFunction(name: "fragment_main") else { return nil }

            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Error creating Metal pipeline state: \(error)")
            return nil
        }
        super.init()
    }

    // Draw function (Modified time update)
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor, // Clear color is now set externally
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else { return }

        // --- Update Time (Angle) based on external speed ---
        // The time interval between frames can fluctuate. A more robust approach
        // would involve using view.preferredFramesPerSecond or CADisplayLink.
        // Using a fixed delta time for simplicity here.
        let deltaTime: Float = 1.0 / 60.0 // Approximate time per frame at 60 FPS
        time += deltaTime * rotationSpeed * 2.0 * Float.pi // Update angle based on speed (radians per second * delta)
        // Wrap time angle if desired (e.g., time.formTruncatingRemainder(dividingBy: 2.0 * Float.pi))

        // Update the time buffer on the GPU
        let timePtr = timeBuffer.contents().bindMemory(to: Float.self, capacity: 1)
        timePtr[0] = time // Pass the accumulated angle

        // --- Configure Render Encoder ---
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBuffer(timeBuffer, offset: 0, index: 2)

        // --- Issue Draw Call ---
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

        // --- Finalize ---
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        // commandBuffer.waitUntilCompleted() // Generally avoid blocking the main thread in real apps
    }
}

// MARK: - Coordinator (Unchanged Logic, but holds the renderer)

class Coordinator: NSObject, MTKViewDelegate {
    var parent: MetalViewRepresentable
    var renderer: MetalRenderer // Coordinator holds the renderer

    init(_ parent: MetalViewRepresentable, renderer: MetalRenderer) {
        self.parent = parent
        self.renderer = renderer
        super.init()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Resize logic (if needed)
    }

    func draw(in view: MTKView) {
        // Delegate drawing to the renderer
        renderer.draw(in: view)
    }
}

// MARK: - UIViewRepresentable (Modified with updateUIView)

struct MetalViewRepresentable: UIViewRepresentable {
    // Input properties from SwiftUI
    @Binding var rotationSpeed: Float // Use Binding to receive updates
    @Binding var backgroundColor: Color

    // Create the underlying MTKView and its associated Metal resources
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()

        // Renderer initialization
        guard let renderer = MetalRenderer(mtkView: mtkView) else {
            fatalError("MetalRenderer could not be initialized")
        }
        // Assign initial values from bindings
        renderer.rotationSpeed = rotationSpeed
        mtkView.clearColor = backgroundColor.toMTLClearColor() // Set initial clear color

        // Store renderer in coordinator and set delegate
        context.coordinator.renderer = renderer
        mtkView.delegate = context.coordinator

        // MTKView configuration
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false

        return mtkView
    }

    // **This is the key method for reacting to SwiftUI state changes**
    func updateUIView(_ uiView: MTKView, context: Context) {
        // This method is called whenever `rotationSpeed` or `backgroundColor` changes in the parent SwiftUI view.
        print("Updating Metal View: Speed=\(rotationSpeed), Color=\(backgroundColor)")

        // Update the renderer's speed property
        context.coordinator.renderer.rotationSpeed = rotationSpeed

        // Update the MTKView's clear color directly
        uiView.clearColor = backgroundColor.toMTLClearColor()
    }

    // Creates the Coordinator instance (same as before)
    func makeCoordinator() -> Coordinator {
        // Create placeholder renderer for coordinator initialization safety
        guard let placeholderDevice = MTLCreateSystemDefaultDevice(),
            let placeholderRenderer = MetalRenderer(mtkView: MTKView(frame: .zero, device: placeholderDevice)) else {
            fatalError("Could not create placeholder renderer for coordinator")
        }
        // The actual renderer with the correct MTKView is assigned in makeUIView
       return Coordinator(self, renderer: placeholderRenderer)
   }
}

// MARK: - SwiftUI Content View (Modified with Sliders)

struct ContentView: View {
    // State variables to control Metal rendering
    @State private var speed: Float = 0.5 // Rotation speed (in full rotations per second conceptually)
    @State private var bgColor: Color = Color(red: 0.1, green: 0.1, blue: 0.15) // Initial background color

    var body: some View {
        VStack(spacing: 0) { // Remove spacing for seamless integration
            // Metal View occupies the top portion
            MetalViewRepresentable(rotationSpeed: $speed, backgroundColor: $bgColor)
                // Use .identity modifier if you need to specifically tell SwiftUI
                // that the view's identity doesn't change often, though usually not required here.
                // .id(UUID()) // Force recreation if absolutely necessary (usually avoid)

            // Controls Area
            VStack {
                Text("Controls").font(.headline).padding(.top)

                // Rotation Speed Slider
                HStack {
                    Text("Speed:")
                    Slider(value: $speed, in: 0.0...2.0) // Control speed from 0 to 2
                }
                .padding(.horizontal)

                // Background Color Sliders
                 ColorPicker("Background Color", selection: $bgColor)
                     .padding(.horizontal)

                Spacer() // Pushes controls down if needed, or use fixed height
            }
            .padding(.bottom) // Add padding at the bottom of controls
            .background(Color(.systemGray6)) // Background for control area
            .frame(height: 150) // Fixed height for the controls section

        }
         // Apply background and ignore safe area *after* the main VStack
        .background(Color(.systemGray6)) // Match control area background or use global
        .edgesIgnoringSafeArea(.all) // Ignore all safe areas if desired

    }
}

// MARK: - Preview Provider
#Preview("ContentView") {
    ContentView()
}
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

// MARK: - App Entry Point (If this is the main file)
/*
@main
struct MetalSwiftUIControlApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
