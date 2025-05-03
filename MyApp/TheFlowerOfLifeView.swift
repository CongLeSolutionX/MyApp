//
//  TheFlowerOfLifeView.swift
//  MyApp
//
//  Created by Cong Le on 5/3/25.
//

//
//  FlowerOfLifeView.swift
//  MyApp
//  (New Filename)
//
//  Created by Cong Le on 5/4/25. (Adaptation Date)
//
//  Description:
//  This file defines a SwiftUI view that displays the Flower of Life pattern
//  using Apple's Metal framework. It adapts the Octahedron example to:
//  - Generate 2D geometry (approximated circles using triangle fans) for the pattern.
//  - Render multiple instances (circles) with potentially varying colors.
//  - Use a simple orthographic or perspective projection suitable for a 2D pattern.
//  - Demonstrate basic Metal setup within SwiftUI for custom 2D geometry.
//
import SwiftUI
import MetalKit
import simd

// MARK: - Metal Shaders (Flower of Life)

// Simpler shaders for 2D colored shapes
let flowerOfLifeMetalShaderSource = """
#include <metal_stdlib>

using namespace metal;

// Vertex data from CPU
struct VertexIn {
    float3 position [[attribute(0)]]; // xy position, z can be 0 or used for layering
    float4 color    [[attribute(1)]]; // Color for this vertex/circle
};

// Data passed from vertex to fragment shader
struct VertexOut {
    float4 position [[position]]; // Clip space position
    float4 color;              // Interpolated color
};

// Uniforms (optional, could use simpler projection if static)
struct Uniforms {
    float4x4 projectionMatrix; // Matrix to map view space to clip space
    // Could add ModelView matrix if rotation/scaling is desired later
};

// --- Vertex Shader ---
vertex VertexOut flower_vertex_shader(
    const device VertexIn *vertices [[buffer(0)]],
    const device Uniforms &uniforms [[buffer(1)]], // Using index 1 for Uniforms
    unsigned int vid [[vertex_id]]
) {
    VertexOut out;
    VertexIn currentVertex = vertices[vid];

    // Apply only projection (or ModelViewProjection if model/view were added)
    // Assume input 'position' is already in a conceptual "view" or "world" space for this 2D pattern
    out.position = uniforms.projectionMatrix * float4(currentVertex.position, 1.0);
    out.color = currentVertex.color; // Pass color through

    return out;
}

// --- Fragment Shader ---
fragment half4 flower_fragment_shader(VertexOut in [[stage_in]]) {
    // Output interpolated color
    return half4(in.color);
}
"""

// MARK: - Swift Data Structures

// Uniforms struct (Simplified for potentially 2D ortho projection)
struct FlowerUniforms {
    var projectionMatrix: matrix_float4x4
}

// Vertex structure
struct FlowerVertex {
    var position: SIMD3<Float> // x, y, z (z usually 0 for 2D)
    var color: SIMD4<Float>
}

// MARK: - Renderer Class (Flower of Life)

class FlowerOfLifeRenderer: NSObject, MTKViewDelegate {

    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState!
    // Depth state might not be needed for simple 2D overlapping circles,
    // but can be useful if layering (using Z) is intended. Let's omit for now.
    // var depthState: MTLDepthStencilState!

    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    var uniformBuffer: MTLBuffer! // Still need projection

    var aspectRatio: Float = 1.0

    // Geometry Data - Will be generated
    var vertices: [FlowerVertex] = []
    var indices: [UInt16] = []

    // Flower of Life Parameters
    let numCircles = 19 // Standard pattern
    let circleRadius: Float = 0.5
    let circleSegments = 36 // Number of triangles to approximate a circle

    init?(device: MTLDevice) {
        self.device = device
        guard let queue = device.makeCommandQueue() else {
            print("Could not create command queue")
            return nil
        }
        self.commandQueue = queue
        super.init()

        generateFlowerOfLifeGeometry() // Generate the vertices/indices
        setupBuffers()
        // setupDepthStencil() // Omitted for basic 2D overlap
        setupUniformBuffer() // Separate setup for uniform buffer
    }

    func configure(metalKitView: MTKView) {
        setupPipeline(metalKitView: metalKitView)
    }

    // --- Geometry Generation ---

    /// Generates the vertex and index data for the Flower of Life pattern.
    func generateFlowerOfLifeGeometry() {
        vertices.removeAll()
        indices.removeAll()

        var currentBaseIndex: UInt16 = 0

        // Function to add a single circle's geometry
        func addCircle(center: SIMD2<Float>, color: SIMD4<Float>) {
            // 1. Add Center Vertex
            vertices.append(FlowerVertex(position: SIMD3<Float>(center.x, center.y, 0.0), color: color))
            let centerVertexIndex = currentBaseIndex

            // 2. Add Circumference Vertices
            for i in 0..<circleSegments {
                let angle = (Float(i) / Float(circleSegments)) * 2.0 * .pi
                let x = center.x + circleRadius * cos(angle)
                let y = center.y + circleRadius * sin(angle)
                vertices.append(FlowerVertex(position: SIMD3<Float>(x, y, 0.0), color: color))
            }

            // 3. Add Indices for Triangle Fan
            let firstCircumferenceIndex = centerVertexIndex + 1
            for i in 0..<circleSegments {
                indices.append(centerVertexIndex) // Center vertex
                indices.append(firstCircumferenceIndex + UInt16(i)) // Current circumference vertex
                // Next circumference vertex (wrapping around for the last triangle)
                indices.append(firstCircumferenceIndex + UInt16((i + 1) % circleSegments))
            }

            // Update base index for the next circle
            currentBaseIndex += UInt16(circleSegments + 1) // Center + Circumference Verts
        }

        // --- Calculate Circle Centers ---
        // Based on hexagonal grid, distance between centers = radius

        // Layer 0: Center
        addCircle(center: SIMD2<Float>(0, 0), color: SIMD4<Float>(1.0, 0.9, 0.8, 1.0)) // Center White/Cream

        // Layer 1: 6 circles around center
        let angleStep = Float.pi / 3.0 // 60 degrees
        let layer1Dist = circleRadius
        for i in 0..<6 {
            let angle = angleStep * Float(i)
            let centerX = layer1Dist * cos(angle)
            let centerY = layer1Dist * sin(angle)
             // Simple color variation based on angle
            let hue = Float(i) / 6.0
            let color = hsvToRgb(h: hue, s: 0.6, v: 0.9)
            addCircle(center: SIMD2<Float>(centerX, centerY), color: color)
        }

        // Layer 2: 12 circles forming the outer ring
        let layer2Dist = circleRadius * 2.0 // Distance from origin for inner points of layer 2 circles
        let layer2DistOuter = circleRadius * sqrt(3.0) * 2.0 * 0.5 // Simpler: radius * sqrt(3) for center-to-center
        
        // More complex calculation needed for precise layer 2 placement based on intersections
        // Let's use the simpler hexagonal grid distance approach: distance between centers = radius
        // There are 12 centers in layer 2. 6 are at distance 2*R, 6 are at distance sqrt(3)*R ? No.
        // Consider vectors: 6 centers at radius*<vec>, 6 centers at other radius*<vec>
        // Easy way: Centers are at R distance from Layer 1 centers.

        let r = circleRadius
        let hexCenters: [SIMD2<Float>] = [
            // Layer 1 centers again for reference
             SIMD2<Float>(r * cos(0*angleStep), r * sin(0*angleStep)), // 0 deg
             SIMD2<Float>(r * cos(1*angleStep), r * sin(1*angleStep)), // 60 deg
             SIMD2<Float>(r * cos(2*angleStep), r * sin(2*angleStep)), // 120 deg
             SIMD2<Float>(r * cos(3*angleStep), r * sin(3*angleStep)), // 180 deg
             SIMD2<Float>(r * cos(4*angleStep), r * sin(4*angleStep)), // 240 deg
             SIMD2<Float>(r * cos(5*angleStep), r * sin(5*angleStep)), // 300 deg
             // Layer 2 centers (relative to origin, or via L1 centers)
             SIMD2<Float>(2*r, 0), // Out from index 0
             SIMD2<Float>(r * cos(0*angleStep) + r * cos(1*angleStep), r * sin(0*angleStep) + r * sin(1*angleStep)), // Between 0 and 1 -> simplifies to r*cos(30), r*sin(30)*sqrt(3)? NO. vector sum. (1+0.5, 0+sqrt(3)/2) * r -> (1.5, sqrt(3)/2)*r
             // Corrected Layer 2 centers placement (12 total) relative to origin (0,0)
             // 6 centers further out along the axes:
             SIMD2<Float>(2*r * cos(0*angleStep), 2*r * sin(0*angleStep)),
             SIMD2<Float>(2*r * cos(1*angleStep), 2*r * sin(1*angleStep)),
             SIMD2<Float>(2*r * cos(2*angleStep), 2*r * sin(2*angleStep)),
             SIMD2<Float>(2*r * cos(3*angleStep), 2*r * sin(3*angleStep)),
             SIMD2<Float>(2*r * cos(4*angleStep), 2*r * sin(4*angleStep)),
             SIMD2<Float>(2*r * cos(5*angleStep), 2*r * sin(5*angleStep)),
             // 6 centers falling between the axes at distance sqrt(3)*r
             SIMD2<Float>(sqrt(3)*r * cos(angleStep/2 + 0*angleStep), sqrt(3)*r * sin(angleStep/2 + 0*angleStep)), // 30 deg
             SIMD2<Float>(sqrt(3)*r * cos(angleStep/2 + 1*angleStep), sqrt(3)*r * sin(angleStep/2 + 1*angleStep)), // 90 deg
             SIMD2<Float>(sqrt(3)*r * cos(angleStep/2 + 2*angleStep), sqrt(3)*r * sin(angleStep/2 + 2*angleStep)), // 150 deg
             SIMD2<Float>(sqrt(3)*r * cos(angleStep/2 + 3*angleStep), sqrt(3)*r * sin(angleStep/2 + 3*angleStep)), // 210 deg
             SIMD2<Float>(sqrt(3)*r * cos(angleStep/2 + 4*angleStep), sqrt(3)*r * sin(angleStep/2 + 4*angleStep)), // 270 deg
             SIMD2<Float>(sqrt(3)*r * cos(angleStep/2 + 5*angleStep), sqrt(3)*r * sin(angleStep/2 + 5*angleStep)), // 330 deg
        ]
         // Add layer 2 circles using these calculated hex centers
        for i in 0..<12 {
             let center = hexCenters[i + 6] // Use the layer 2 centers calculated above
             let hue = Float(i) / 12.0 // Different color variation for layer 2
             let color = hsvToRgb(h: hue, s: 0.7, v: 0.8)
             addCircle(center: center, color: color)
        }

        print("Generated \(vertices.count) vertices and \(indices.count) indices for Flower of Life.")
    }

    // --- Setup Functions ---

    func setupPipeline(metalKitView: MTKView) {
        do {
            let library = try device.makeLibrary(source: flowerOfLifeMetalShaderSource, options: nil)
            guard let vertexFunction = library.makeFunction(name: "flower_vertex_shader"),
                  let fragmentFunction = library.makeFunction(name: "flower_fragment_shader") else {
                fatalError("Could not load shader functions.")
            }

            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.label = "Flower of Life Pipeline"
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
            // Disable depth testing for simple 2D overlap
            pipelineDescriptor.depthAttachmentPixelFormat = .invalid // No depth buffer needed

            // Configure vertex descriptor for FlowerVertex
            let vertexDescriptor = MTLVertexDescriptor()
            // Position (float3)
            vertexDescriptor.attributes[0].format = .float3
            vertexDescriptor.attributes[0].offset = 0
            vertexDescriptor.attributes[0].bufferIndex = 0 // Buffer 0: Vertex Data
            // Color (float4)
            vertexDescriptor.attributes[1].format = .float4
            vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
            vertexDescriptor.attributes[1].bufferIndex = 0 // Buffer 0: Vertex Data

            vertexDescriptor.layouts[0].stride = MemoryLayout<FlowerVertex>.stride
            vertexDescriptor.layouts[0].stepRate = 1
            vertexDescriptor.layouts[0].stepFunction = .perVertex

            pipelineDescriptor.vertexDescriptor = vertexDescriptor

            // Blending might be needed if using alpha < 1.0, but not for opaque circles.
            // pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
            // pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
            // ... setup blend factors ...

            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        } catch {
            fatalError("Failed to create Metal Render Pipeline State: \(error)")
        }
    }

    func setupBuffers() {
        guard !vertices.isEmpty, !indices.isEmpty else {
             fatalError("Geometry not generated before setupBuffers call")
        }

        let vertexDataSize = vertices.count * MemoryLayout<FlowerVertex>.stride
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertexDataSize, options: [])
        vertexBuffer.label = "Flower Vertices"

        let indexDataSize = indices.count * MemoryLayout<UInt16>.stride
        indexBuffer = device.makeBuffer(bytes: indices, length: indexDataSize, options: [])
        indexBuffer.label = "Flower Indices"
    }

    // Separate setup for uniform buffer as it might be updated differently
    func setupUniformBuffer() {
         let uniformBufferSize = MemoryLayout<FlowerUniforms>.size // Use FlowerUniforms size
        guard let uBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared) else {
            fatalError("Could not create uniform buffer")
        }
        uniformBuffer = uBuffer
        uniformBuffer.label = "Flower Uniforms Buffer"
    }

    // --- Update State Per Frame ---

    // Simplified update, only calculates projection matrix based on aspect ratio
    func updateUniforms() {
        // Use an Orthographic projection for 2D patterns usually
        // Define the visible area in view coordinates
        let viewHeight: Float = 3.0 * circleRadius // Make sure pattern fits vertically
        let viewWidth = viewHeight * aspectRatio

        // Create Orthographic Matrix (Left-Handed)
        // Maps the rectangle defined by left/right/bottom/top directly to clip space (-1 to 1)
         let projectionMatrix = matrix_ortho_left_hand(
            left: -viewWidth / 2.0,
            right: viewWidth / 2.0,
            bottom: -viewHeight / 2.0,
            top: viewHeight / 2.0,
            nearZ: -1.0, // Can be negative for ortho
            farZ: 1.0
        )
        /* // --- OR use perspective if you prefer ---
        let projectionMatrix = matrix_perspective_left_hand(
            fovyRadians: .pi / 4.0, // Adjust FOV as needed
            aspectRatio: aspectRatio,
            nearZ: 0.1,
            farZ: 100.0
        )
        // If using perspective, also need a view matrix to position camera
         let viewMatrix = matrix_look_at_left_hand(
            eye: SIMD3<Float>(0, 0, -3.0 * circleRadius * 2.0), // Pull camera back to see pattern
             center: SIMD3<Float>(0, 0, 0),
             up: SIMD3<Float>(0, 1, 0)
         )
         let finalProjection = viewMatrix * projectionMatrix // Combine if needed
         // Update buffer with finalProjection
        */

        // Copy matrix to the buffer
        var uniforms = FlowerUniforms(projectionMatrix: projectionMatrix)
        uniformBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<FlowerUniforms>.size)
    }

    // MARK: - MTKViewDelegate Methods

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        aspectRatio = Float(size.width / max(1, size.height))
        print("Flower MTKView Resized - New Aspect Ratio: \(aspectRatio)")
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
             print("Failed to get required Metal objects in Flower draw(in:). Skipping frame.")
            return
        }

        updateUniforms() // Update projection matrix based on current aspect ratio

        renderEncoder.label = "Flower of Life Render Encoder"
        renderEncoder.setRenderPipelineState(pipelineState)
        // renderEncoder.setDepthStencilState(depthState) // Omitted

        // No wireframe mode needed for filled circles
        // renderEncoder.setTriangleFillMode(.lines)

        // Bind buffers
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0) // Vertex data
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1) // Projection Uniform data

        // Draw Call
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: indices.count,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)

        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - SwiftUI UIViewRepresentable (Flower of Life)

struct MetalFlowerOfLifeViewRepresentable: UIViewRepresentable {
    typealias UIViewType = MTKView

    func makeCoordinator() -> FlowerOfLifeRenderer {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported.")
        }
        guard let coordinator = FlowerOfLifeRenderer(device: device) else {
            fatalError("FlowerOfLifeRenderer failed to initialize.")
        }
        print("FlowerOfLife Coordinator created.")
        return coordinator
    }

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = context.coordinator.device

        mtkView.preferredFramesPerSecond = 60 // Can be lower if static
        mtkView.enableSetNeedsDisplay = false // Use delegate draw loop

        // No depth buffer needed for this basic 2D setup
        mtkView.depthStencilPixelFormat = .invalid
        mtkView.clearDepth = 1.0 // Still good practice to set

        mtkView.clearColor = MTLClearColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0) // Light background
        mtkView.colorPixelFormat = .bgra8Unorm_srgb

        // Allow the renderer to configure its pipeline
        context.coordinator.configure(metalKitView: mtkView)

        mtkView.delegate = context.coordinator

        // Trigger initial size update
        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        print("Flower MTKView created and configured.")
        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        // No updates from SwiftUI state in this example
    }
}

// MARK: - Main SwiftUI View (Flower of Life)

struct FlowerOfLifeView: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Flower of Life Pattern (Metal)")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.95, green: 0.95, blue: 1.0)) // Match clear color
                .foregroundColor(.black)

            MetalFlowerOfLifeViewRepresentable()
                // Ensure it takes available space
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        }
        .background(Color(red: 0.95, green: 0.95, blue: 1.0))
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Preview Provider

#Preview {
    // Placeholder is safer for Metal previews
    struct PreviewPlaceholder: View {
         var body: some View {
            VStack {
                 Text("Flower of Life Pattern (Metal)")
                    .font(.headline)
                    .padding()
                 Spacer()
                 Text("Metal View Placeholder")
                     .foregroundColor(.gray)
                     .italic()
                 Spacer()
             }
             .frame(maxWidth: .infinity, maxHeight: .infinity)
             .background(Color(red: 0.95, green: 0.95, blue: 1.0))
         }
    }
    // return PreviewPlaceholder() // Use this generally

     // Try rendering actual view (may fail in preview)
     return FlowerOfLifeView()
}

// MARK: - Helper Functions (Color and Math)

/// Converts HSV color values to RGB.
/// - Parameters:
///   - h: Hue (0.0 to 1.0)
///   - s: Saturation (0.0 to 1.0)
///   - v: Value (Brightness) (0.0 to 1.0)
/// - Returns: SIMD4<Float> representing RGBA color. Alpha is always 1.0.
func hsvToRgb(h: Float, s: Float, v: Float) -> SIMD4<Float> {
    if s == 0 { return SIMD4<Float>(v, v, v, 1.0) } // achromatic (grey)

    let i = floor(h * 6.0)
    let f = (h * 6.0) - i
    let p = v * (1.0 - s)
    let q = v * (1.0 - s * f)
    let t = v * (1.0 - s * (1.0 - f))

    var r: Float = 0, g: Float = 0, b: Float = 0
    switch(i) {
    case 0: r = v; g = t; b = p; break
    case 1: r = q; g = v; b = p; break
    case 2: r = p; g = v; b = t; break
    case 3: r = p; g = q; b = v; break
    case 4: r = t; g = p; b = v; break
    default: r = v; g = p; b = q; break // case 5
    }
    return SIMD4<Float>(r, g, b, 1.0)
}

/// Creates an orthographic projection matrix (Left-Handed).
/// Maps a 3D box directly to clip space بدون perspective distortion.
func matrix_ortho_left_hand(left: Float, right: Float, bottom: Float, top: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
    let lr = 1.0 / (right - left)
    let bt = 1.0 / (top - bottom)
    let nf = 1.0 / (farZ - nearZ)

    let col0 = SIMD4<Float>(2.0 * lr, 0, 0, 0)
    let col1 = SIMD4<Float>(0, 2.0 * bt, 0, 0)
    let col2 = SIMD4<Float>(0, 0, nf, 0) // Note: Z mapping for ortho
    let col3 = SIMD4<Float>(-(left + right) * lr, -(top + bottom) * bt, -nearZ * nf, 1)

    return matrix_float4x4(columns: (col0, col1, col2, col3))
}

// Include previous matrix math functions if perspective is used:
// matrix_perspective_left_hand, matrix_look_at_left_hand, matrix_rotation_y/x, matrix_multiply
