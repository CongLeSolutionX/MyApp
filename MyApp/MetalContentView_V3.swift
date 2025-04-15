//
//  MetalContentView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import SwiftUI
import MetalKit
import Combine // For Color conversion

// MARK: - Metal Shaders (Modified for Instancing)

let metalShaderSourceInstanced = """
using namespace metal;

// ---- Data Structures ----

// Per-Vertex data (position within the base triangle model)
struct Vertex {
    float3 position [[attribute(0)]]; // Using attribute for clarity
};

// Per-Instance data (unique properties for each triangle drawn)
struct InstanceData {
    float4 position [[attribute(1)]];   // x, y position offset; z unused; w=scale (optional)
    float4 color [[attribute(2)]];     // RGBA color for this instance
    float rotationOffset [[attribute(3)]]; // Initial rotation phase for variation
};

// Data passed from Vertex Shader to Fragment Shader
struct VertexOut {
    float4 position [[position]]; // Final clip-space position
    float4 color;             // Color for this fragment (from instance)
};

// Uniforms (global values affecting all instances)
struct Uniforms {
    float time; // Global animation time/angle
};

// ---- Vertex Shader ----
// Processes one vertex for a specific instance.
vertex VertexOut vertex_main(
                             Vertex in [[stage_in]],              // Input vertex data (from vertex buffer)
                             constant InstanceData *instanceData [[buffer(1)]], // Array of instance data
                             constant Uniforms &uniforms [[buffer(2)]],         // Global uniforms
                             uint instanceID [[instance_id]]      // Built-in ID of the current instance being drawn
                            )
{
    VertexOut out;

    // Get data for the current instance
    InstanceData currentInstance = instanceData[instanceID];

    // Calculate rotation angle: global time + instance-specific offset
    float angle = uniforms.time + currentInstance.rotationOffset;
    float cosA = cos(angle);
    float sinA = sin(angle);

    // Start with the base vertex position
    float3 basePos = in.position;

    // Apply rotation (simple 2D rotation around Z-axis)
    float rotatedX = basePos.x * cosA - basePos.y * sinA;
    float rotatedY = basePos.x * sinA + basePos.y * cosA;

    // Apply instance position offset (after rotation) and potential scale
    float scale = currentInstance.position.w > 0.0 ? currentInstance.position.w : 0.15; // Use w for scale, default 0.15
    float finalX = rotatedX * scale + currentInstance.position.x;
    float finalY = rotatedY * scale + currentInstance.position.y;

    // Final position for the rasterizer
    out.position = float4(finalX, finalY, 0.0, 1.0); // Assuming Z=0

    // Pass the instance's color to the fragment shader
    out.color = currentInstance.color;

    return out;
}

// ---- Fragment Shader ----
// Calculates the final color for a pixel on the screen.
fragment float4 fragment_main(VertexOut in [[stage_in]]) // Input interpolated from Vertex Shader
{
    // Simply output the interpolated color received from the vertex shader.
    return in.color;
}

"""

// MARK: - Data Structures (Swift side)

// Matches the InstanceData struct in the shader
struct InstanceDataSwift {
    var position: SIMD4<Float>   // x, y offset, z unused, w scale
    var color: SIMD4<Float>      // RGBA
    var rotationOffset: Float
}

// Matches the Uniforms struct in the shader
struct UniformsSwift {
    var time: Float
}

// MARK: - Color Conversion Helper (Unchanged)
extension Color {
    func toMTLClearColor() -> MTLClearColor {
        #if os(macOS)
        let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor.clear
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return MTLClearColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
        #else
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return MTLClearColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
        #endif
    }
}

// MARK: - Metal Renderer Class (Modified for Instancing)

class MetalRenderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState
    var vertexBuffer: MTLBuffer // Buffer for the single triangle model
    var instanceBuffer: MTLBuffer? // Buffer for per-instance data (optional initially)
    var uniformBuffer: MTLBuffer // Buffer for global uniforms (time)

    // Internal State
    private var uniforms = UniformsSwift(time: 0.0)
    private var instances: [InstanceDataSwift] = []
    var instanceCount: Int = 1 { // Default to 1 instance
        didSet {
            if instanceCount != oldValue {
                // Regenerate instance data when count changes
                updateInstanceData(count: instanceCount)
            }
        }
    }
    var isAnimating: Bool = true // Control animation state

    // Maximum number of instances allowed (adjust based on performance needs)
    let maxInstances = 1000

    // Initializer
    init?(mtkView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        self.device = device
        mtkView.device = device

        guard let commandQueue = device.makeCommandQueue() else { return nil }
        self.commandQueue = commandQueue

        // Define vertices for the base triangle model (smaller size)
        let scale: Float = 0.5 // Make the base triangle smaller
        let vertices: [SIMD3<Float>] = [
            SIMD3<Float>( 0.0 * scale,  0.5 * scale, 0.0),
            SIMD3<Float>(-0.5 * scale, -0.5 * scale, 0.0),
            SIMD3<Float>( 0.5 * scale, -0.5 * scale, 0.0)
        ]

        // Create Vertex Buffer for the single triangle model
        guard let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<SIMD3<Float>>.stride, options: []) else { return nil }
        self.vertexBuffer = vertexBuffer

        // Create Uniform Buffer
        guard let uniformBuffer = device.makeBuffer(length: MemoryLayout<UniformsSwift>.stride, options: .storageModeShared) else { return nil }
        self.uniformBuffer = uniformBuffer

        // --- Pipeline State Setup ---
        do {
            let library = try device.makeLibrary(source: metalShaderSourceInstanced, options: nil)
            guard let vertexFunction = library.makeFunction(name: "vertex_main"),
                  let fragmentFunction = library.makeFunction(name: "fragment_main") else { return nil }

            // Define Vertex Descriptor for instancing layout
            let vertexDescriptor = MTLVertexDescriptor()
            // Per-Vertex attributes (from vertexBuffer)
            vertexDescriptor.attributes[0].format = .float3 // position
            vertexDescriptor.attributes[0].offset = 0
            vertexDescriptor.attributes[0].bufferIndex = 0 // Buffer index for vertex data
            vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride
            vertexDescriptor.layouts[0].stepFunction = .perVertex // Data advances per vertex

            // Per-Instance attributes (from instanceBuffer) - Buffer index 1
            // Position (attribute 1, buffer 1)
            vertexDescriptor.attributes[1].format = .float4 // Instance position+scale
            vertexDescriptor.attributes[1].offset = MemoryLayout<InstanceDataSwift>.offset(of: \.position)!
            vertexDescriptor.attributes[1].bufferIndex = 1
            // Color (attribute 2, buffer 1)
            vertexDescriptor.attributes[2].format = .float4 // Instance color
            vertexDescriptor.attributes[2].offset = MemoryLayout<InstanceDataSwift>.offset(of: \.color)!
            vertexDescriptor.attributes[2].bufferIndex = 1
            // Rotation Offset (attribute 3, buffer 1)
            vertexDescriptor.attributes[3].format = .float // Rotation offset
            vertexDescriptor.attributes[3].offset = MemoryLayout<InstanceDataSwift>.offset(of: \.rotationOffset)!
            vertexDescriptor.attributes[3].bufferIndex = 1

            // Define the layout for the instance buffer (Buffer 1)
            vertexDescriptor.layouts[1].stride = MemoryLayout<InstanceDataSwift>.stride
            vertexDescriptor.layouts[1].stepFunction = .perInstance // Data advances per instance

            // Create pipeline descriptor
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.vertexDescriptor = vertexDescriptor // Apply the vertex descriptor
            pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat

            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        } catch {
            print("Error creating Metal pipeline state: \(error)")
            return nil
        }

        super.init()

        // Generate initial instance data
        updateInstanceData(count: self.instanceCount)
    }

    // Regenerates instance positions, colors, etc., and updates the GPU buffer
    func updateInstanceData(count: Int) {
        let clampedCount = min(count, maxInstances) // Ensure we don't exceed max
        self.instanceCount = clampedCount // Update internal count
        instances.removeAll(keepingCapacity: true)

        // Simple grid layout for demonstration
        let gridDim = Int(ceil(sqrt(Double(clampedCount))))
        let spacing: Float = 1.8 / Float(gridDim) // Spacing in normalized coordinates [-1, 1]
        let startOffset: Float = -0.9 // Starting position

        for i in 0..<clampedCount {
            // Calculate grid position
            let gridX = i % gridDim
            let gridY = i / gridDim
            let xPos = startOffset + Float(gridX) * spacing + Float.random(in: -spacing/4...spacing/4)
            let yPos = startOffset + Float(gridY) * spacing + Float.random(in: -spacing/4...spacing/4)

            // Random scale
            let scale = Float.random(in: 0.05...0.25) // Random size for variation

            // Random color variation (around blues/greens)
            let r = Float.random(in: 0.0...0.3)
            let g = Float.random(in: 0.3...0.8)
            let b = Float.random(in: 0.5...1.0)
            let color = SIMD4<Float>(r, g, b, 1.0)

            // Random initial rotation
            let rotationOffset = Float.random(in: 0...(2.0 * .pi))

            let instance = InstanceDataSwift(position: SIMD4<Float>(xPos, yPos, 0, scale),
                                           color: color,
                                           rotationOffset: rotationOffset)
            instances.append(instance)
        }

        // Update the GPU buffer
        if instances.isEmpty {
            instanceBuffer = nil // No instances, clear buffer
        } else {
            let dataSize = instances.count * MemoryLayout<InstanceDataSwift>.stride
            if let buffer = instanceBuffer, buffer.length >= dataSize {
                // Reuse existing buffer if large enough
                buffer.contents().copyMemory(from: instances, byteCount: dataSize)
            } else {
                // Create new buffer if needed or size increased
                instanceBuffer = device.makeBuffer(bytes: instances, length: dataSize, options: [])
                 if instanceBuffer == nil {
                     print("Failed to create/update instance buffer")
                 }
            }
        }
         print("Updated instance buffer for \(instances.count) instances.")
    }

    // Draw function
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
              let currentInstanceBuffer = instanceBuffer, // Ensure buffer exists
              !instances.isEmpty // Don't draw if no instances
        else {
            // If no instances, still clear the screen
             if let drawable = view.currentDrawable,
                let renderPassDescriptor = view.currentRenderPassDescriptor,
                let commandBuffer = commandQueue.makeCommandBuffer(),
                let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
             {
                 renderEncoder.endEncoding()
                 commandBuffer.present(drawable)
                 commandBuffer.commit()
             }
            return
        }

        // --- Update Uniforms ---
        if isAnimating {
            let deltaTime: Float = 1.0 / 60.0 // Approximate frame time
            uniforms.time += deltaTime * 0.5 * Float.pi // Slower base rotation speed
        }
        let uniformPtr = uniformBuffer.contents().bindMemory(to: UniformsSwift.self, capacity: 1)
        uniformPtr[0] = uniforms

        // --- Configure Render Encoder ---
        renderEncoder.setRenderPipelineState(pipelineState)

        // Bind Buffers
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0) // Base triangle vertices
        renderEncoder.setVertexBuffer(currentInstanceBuffer, offset: 0, index: 1) // Per-instance data
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2) // Global uniforms

        // --- Issue Instanced Draw Call ---
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,          // Start at first vertex of the model
                                     vertexCount: 3,          // Draw 3 vertices (one triangle)
                                     instanceCount: instances.count) // Draw this many instances

        // --- Finalize ---
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - Coordinator (Unchanged Role)

class Coordinator: NSObject, MTKViewDelegate {
    var parent: MetalViewRepresentable
    var renderer: MetalRenderer

    init(_ parent: MetalViewRepresentable, renderer: MetalRenderer) {
        self.parent = parent
        self.renderer = renderer
        super.init()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        renderer.draw(in: view)
    }
}

// MARK: - UIViewRepresentable (Modified Bindings and updateUIView)

struct MetalViewRepresentable: UIViewRepresentable {
    // Input properties from SwiftUI
    @Binding var instanceCount: Int
    @Binding var isAnimating: Bool
    @Binding var backgroundColor: Color

    // Create the MTKView and Renderer
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        guard let renderer = MetalRenderer(mtkView: mtkView) else {
            fatalError("MetalRenderer could not be initialized")
        }

        // Set initial values from bindings
        renderer.instanceCount = instanceCount // Trigger initial data generation
        renderer.isAnimating = isAnimating
        mtkView.clearColor = backgroundColor.toMTLClearColor()

        context.coordinator.renderer = renderer
        mtkView.delegate = context.coordinator
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false // We control animation via isAnimating flag in renderer

        return mtkView
    }

    // Update Metal state based on SwiftUI changes
    func updateUIView(_ uiView: MTKView, context: Context) {
        print("Updating Metal View: Count=\(instanceCount), Animating=\(isAnimating), Color=\(backgroundColor)")

        // Update instance count (renderer has logic to check if changed)
        context.coordinator.renderer.instanceCount = instanceCount

        // Update animation state
        context.coordinator.renderer.isAnimating = isAnimating

        // Update background color
        uiView.clearColor = backgroundColor.toMTLClearColor()
    }

    // Creates the Coordinator instance
    func makeCoordinator() -> Coordinator {
        guard let placeholderDevice = MTLCreateSystemDefaultDevice(),
              let placeholderRenderer = MetalRenderer(mtkView: MTKView(frame: .zero, device: placeholderDevice)) else {
            fatalError("Could not create placeholder renderer for coordinator")
        }
       return Coordinator(self, renderer: placeholderRenderer)
   }
}

// MARK: - SwiftUI Content View (Modified with Stepper and Toggle)

struct ContentView: View {
    @State private var count: Int = 10 // Start with 10 triangles
    @State private var animate: Bool = true
    @State private var bgColor: Color = Color(red: 0.1, green: 0.1, blue: 0.15)

    // Define the range for the stepper based on renderer's max instances
    // Note: We access a static/constant value here, or pass maxInstances up if needed.
    // For simplicity, using a constant here. Must match renderer's maxInstances.
    let maxInstances = 1000
    var countRange: ClosedRange<Int> { 0...maxInstances }

    var body: some View {
        VStack(spacing: 0) {
            // Metal View
            MetalViewRepresentable(instanceCount: $count,
                                   isAnimating: $animate,
                                   backgroundColor: $bgColor)

            // Controls Area
            VStack {
                Text("Controls").font(.headline).padding(.top)

                // Instance Count Stepper
                Stepper("Instances: \(count)", value: $count, in: countRange)
                    .padding(.horizontal)

                // Animation Toggle
                Toggle("Animate", isOn: $animate)
                    .padding(.horizontal)

                // Background Color Picker
                 ColorPicker("Background Color", selection: $bgColor)
                     .padding(.horizontal)

                Spacer()
            }
            .padding(.bottom)
            .background(Color(.systemGray6))
            .frame(height: 180) // Slightly taller control area
        }
        .background(Color(.systemGray6))
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - App Entry Point
/*
@main
struct MetalInstancingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
