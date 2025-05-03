//
//  IcosahedronView_2nd_try.swift
//  MyApp
//
//  Created by Cong Le on 5/3/25.
//

//
//  IcosahedronView.swift
//  MyApp
//  (Derived from OctahedronView structure)
//
//  Created by Cong Le on 5/3/25. (Adapted: [Current Date])
//
//  Description:
//  This file defines a SwiftUI view hierarchy that displays a 3D rotating
//  wireframe icosahedron rendered using Apple's Metal framework. It demonstrates:
//  - Embedding a MetalKit view (MTKView) within SwiftUI using UIViewRepresentable.
//  - Setting up a basic Metal rendering pipeline (shaders, buffers, pipeline state).
//  - Defining geometry (vertices, indices) for an icosahedron.
//  - Using SIMD for matrix transformations (Model-View-Projection).
//  - Basic animation through rotation updates per frame.
//  - Depth testing for correct 3D appearance.
//  - Rendering in wireframe mode.
//
import SwiftUI
import MetalKit // Provides MTKView and Metal integration helpers
import simd    // Provides efficient vector and matrix types/operations (like matrix_float4x4)

// MARK: - Metal Shaders (Embedded String)

/// Contains the source code for the Metal vertex and fragment shaders.
/// These shaders run on the GPU to process vertices and determine pixel colors.
let icosahedronMetalShaderSource = """
#include <metal_stdlib> // Import the Metal Standard Library

using namespace metal; // Use the Metal namespace

// Structure defining vertex input data received from the CPU (Swift code).
// The layout *must* match the 'IcosahedronVertex' struct in Swift and the MTLVertexDescriptor.
struct VertexIn {
    // Vertex position in model space. [[attribute(0)]] links to the first attribute in the vertex descriptor.
    float3 position [[attribute(0)]];
    // Vertex color (RGBA). [[attribute(1)]] links to the second attribute.
    float4 color    [[attribute(1)]];
};

// Structure defining data passed from the vertex shader to the fragment shader.
// Metal interpolates these values across the triangle/line surface.
struct VertexOut {
    // Final position in clip space (required output). [[position]] designates this special variable.
    float4 position [[position]];
    // Color to be interpolated for the fragment shader.
    float4 color;
};

// Structure for uniform data (constants for a draw call) passed from the CPU.
// This *must* match the 'Uniforms' struct layout in Swift.
struct Uniforms {
    // Combined Model-View-Projection matrix to transform vertices to clip space.
    float4x4 modelViewProjectionMatrix;
};

// --- Vertex Shader ---
// Function executed for each vertex in the draw call.
vertex VertexOut icosahedron_vertex_shader(
    // Input: Array of vertices passed from the CPU's vertex buffer.
    // [[buffer(0)]] links this to the buffer bound at index 0 by the Render Encoder.
    const device VertexIn *vertices [[buffer(0)]],
    // Input: Uniform data (MVP matrix) from the CPU's uniform buffer.
    // [[buffer(1)]] links this to the buffer bound at index 1.
    const device Uniforms &uniforms [[buffer(1)]],
    // Input: System-generated index of the current vertex being processed.
    unsigned int vid [[vertex_id]]
) {
    // Prepare the output structure
    VertexOut out;

    // Get the current vertex data using the vertex ID
    VertexIn currentVertex = vertices[vid]; // Access the vertex data for this specific vertex index

    // Calculate the vertex's clip space position by multiplying its model position
    // by the Model-View-Projection matrix. Add w=1.0 for perspective division.
    out.position = uniforms.modelViewProjectionMatrix * float4(currentVertex.position, 1.0);

    // Pass the vertex's color directly to the output structure.
    // This color will be interpolated across the primitive (triangle/line).
    out.color = currentVertex.color;

    return out; // Return the processed vertex data
}

// --- Fragment Shader ---
// Function executed for each pixel fragment within the rendered primitives (triangles/lines).
fragment half4 icosahedron_fragment_shader(
    // Input: Interpolated data received from the vertex shader.
    // [[stage_in]] attribute marks this struct as containing interpolated data.
    VertexOut in [[stage_in]]
) {
    // Return the interpolated color as the final color for this pixel.
    // 'half4' is used for potentially better performance on some mobile GPUs (uses 16-bit floats).
    return half4(in.color);
}
"""

// MARK: - Swift Data Structures (Matching Shaders)

/// Swift structure mirroring the layout of the 'Uniforms' struct in the Metal shader code.
/// Used to organize and copy transformation data to the GPU's uniform buffer.
struct Uniforms {
    /// The combined Model-View-Projection matrix. `matrix_float4x4` is a SIMD type alias.
    var modelViewProjectionMatrix: matrix_float4x4
}

/// Structure defining the layout of vertex data in Swift application code.
/// This layout *must* match the `VertexIn` struct in the shader and the `MTLVertexDescriptor` configuration.
struct IcosahedronVertex {
    /// The 3D position (x, y, z) of the vertex in model space.
    var position: SIMD3<Float>
    /// The RGBA color associated with the vertex.
    var color: SIMD4<Float>
}

// MARK: - Renderer Class (Handles Metal Logic)

/// Manages all Metal-specific setup, resource creation, and rendering logic.
/// Conforms to `MTKViewDelegate` to respond to view size changes and draw calls.
class IcosahedronRenderer: NSObject, MTKViewDelegate {

    /// The logical connection to the GPU. Used to create other Metal objects.
    let device: MTLDevice
    /// Queue for sending encoded commands (rendering, compute) to the GPU.
    let commandQueue: MTLCommandQueue
    /// Compiled shader functions and rendering configuration (vertex layout, pixel formats, etc.).
    var pipelineState: MTLRenderPipelineState!
    /// Configures depth testing behavior (essential for correct 3D rendering).
    var depthState: MTLDepthStencilState!

    /// GPU buffer holding the icosahedron's vertex data (`IcosahedronVertex` array).
    var vertexBuffer: MTLBuffer!
    /// GPU buffer holding the indices that define the icosahedron's triangles (`UInt16` array).
    var indexBuffer: MTLBuffer!
    /// GPU buffer holding the transformation matrix (`Uniforms` struct). Updated each frame.
    var uniformBuffer: MTLBuffer!

    /// Current rotation angle for the animation (in radians). Incremented each frame.
    var rotationAngle: Float = 0.0
    /// Aspect ratio of the view (width / height). Updated when the view size changes.
    var aspectRatio: Float = 1.0

    // --- Geometry Data ---

    /// Array defining the 12 vertices of the icosahedron.
    /// Coordinates are based on the golden ratio for regularity.
    let vertices: [IcosahedronVertex] = {
        let phi: Float = (1.0 + sqrt(5.0)) / 2.0 // Golden ratio
        let a: Float = 1.0                       // Scale factor
        let b: Float = 1.0 / phi                 // Derived scale factor

        // Generate positions normalized to roughly radius 1
        var positions: [SIMD3<Float>] = [
            // Vertices on XZ plane (forming two pentagons offset by rotation)
            SIMD3<Float>( 0,  b, -a), // Upper Z-
            SIMD3<Float>( b,  a,  0), // Upper +X
            SIMD3<Float>(-b,  a,  0), // Upper -X

            SIMD3<Float>( 0,  b,  a), // Lower Z+
            SIMD3<Float>( 0, -b,  a), // Lower Z+

            SIMD3<Float>(-a,  0,  b), // Mid -X
            SIMD3<Float>( 0, -b, -a), // Lower Z-

            SIMD3<Float>( a,  0, -b), // Mid +X
            SIMD3<Float>( a,  0,  b), // Mid +X

            SIMD3<Float>(-a,  0, -b), // Mid -X
            SIMD3<Float>( b, -a,  0), // Lower +X
            SIMD3<Float>(-b, -a,  0)  // Lower -X
        ]
        
        // Normalize positions to lie on a sphere
        positions = positions.map { normalize($0) * 1.5 } /* Scale slightly for better view */

        // Assign distinct colors for visualization
        let colors: [SIMD4<Float>] = [
            SIMD4<Float>(1, 0, 0, 1), // Red
            SIMD4<Float>(0, 1, 0, 1), // Green
            SIMD4<Float>(0, 0, 1, 1), // Blue
            SIMD4<Float>(1, 1, 0, 1), // Yellow
            SIMD4<Float>(0, 1, 1, 1), // Cyan
            SIMD4<Float>(1, 0, 1, 1), // Magenta
            SIMD4<Float>(1, 0.5, 0, 1),// Orange
            SIMD4<Float>(0.5, 0, 1, 1),// Purple
            SIMD4<Float>(0, 0.5, 0.5, 1),// Teal
            SIMD4<Float>(0.5, 0.5, 0, 1),// Olive
            SIMD4<Float>(1, 0.8, 0.8, 1),// Pink
            SIMD4<Float>(0.8, 0.8, 1, 1) // Light Blue
        ]

        // Combine positions and colors
        return zip(positions, colors).map { IcosahedronVertex(position: $0.0, color: $0.1) }
    }()

    /// Array of indices defining the 20 triangular faces of the icosahedron.
    /// Each sequence of 3 indices references vertices from the `vertices` array.
    /// Winding order is generally counter-clockwise when viewed from the outside.
     let indices: [UInt16] = [
         0,  1,  2,     // Face 1
         3,  2,  1,     // Face 2
         3,  4,  5,     // Face 3
         3,  5,  6,     // Face 4
         0,  6,  7,     // Face 5
         0,  7,  8,     // Face 6
         9,  8,  7,     // Face 7
         9,  7, 10,     // Face 8
         9, 10, 11,     // Face 9
         4, 11, 10,     // Face 10
         1,  0,  8,     // Face 11
         4,  3,  6,     // Face 12
         2,  3,  1,     // Top Cap Triangle 1 (Example - might need adjustment based on actual vertex def)
         3,  7,  2,     // Top Cap Triangle 2
         7,  6,  2,     // Top Cap Triangle 3
         6,  8,  7,     // Top Cap Triangle 4
         8,  1,  2,     // Top Cap Triangle 5 - Adjusted based on common icosahedron patterns
         // Bottom Cap (adjust indices based on the actual vertex layout)
         11, 5, 4,      // Example Bottom Triangle 1
         10, 5,11,      // Example Bottom Triangle 2
         // Add remaining bottom triangles based on connectivity...
          5,10,  9,      // Example Bottom Triangle 3
          9,  6,  5,     // Example Bottom Triangle 4 - Re-check connectivity
          6, 11, 9      // Example Bottom Triangle 5 - Re-check connectivity
     ]
    // --- End Geometry Data ---

    /// Initializes the renderer with a Metal device.
    /// Sets up essential Metal objects like the command queue and buffers.
    /// Fails if Metal device or command queue creation fails.
    /// - Parameter device: The `MTLDevice` (GPU connection) to use for rendering.
    init?(device: MTLDevice) {
        self.device = device
        guard let queue = device.makeCommandQueue() else {
            print("Could not create command queue")
            return nil
        }
        self.commandQueue = queue
        super.init()

        setupBuffers()
        setupDepthStencil()
    }

    /// Configures the Metal pipeline state.
    /// - Parameter metalKitView: The `MTKView` instance this renderer will draw into.
    func configure(metalKitView: MTKView) {
        setupPipeline(metalKitView: metalKitView)
    }

    // --- Setup Functions ---

    /// Compiles shaders and creates the `MTLRenderPipelineState`.
    /// - Parameter metalKitView: The view providing pixel format information.
    func setupPipeline(metalKitView: MTKView) {
        do {
            let library = try device.makeLibrary(source: icosahedronMetalShaderSource, options: nil)
            guard let vertexFunction = library.makeFunction(name: "icosahedron_vertex_shader"),
                  let fragmentFunction = library.makeFunction(name: "icosahedron_fragment_shader") else {
                fatalError("Could not load shader functions. Check names.")
            }

            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.label = "Wireframe Icosahedron Pipeline"
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
            pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat

            let vertexDescriptor = MTLVertexDescriptor()
            vertexDescriptor.attributes[0].format = .float3
            vertexDescriptor.attributes[0].offset = 0
            vertexDescriptor.attributes[0].bufferIndex = 0
            vertexDescriptor.attributes[1].format = .float4
            vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
            vertexDescriptor.attributes[1].bufferIndex = 0
            vertexDescriptor.layouts[0].stride = MemoryLayout<IcosahedronVertex>.stride
            vertexDescriptor.layouts[0].stepRate = 1
            vertexDescriptor.layouts[0].stepFunction = .perVertex
            pipelineDescriptor.vertexDescriptor = vertexDescriptor

            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        } catch {
            fatalError("Failed to create Metal Render Pipeline State: \(error)")
        }
    }

    /// Creates and populates the GPU buffers for vertices, indices, and uniforms.
    func setupBuffers() {
        // Vertex Buffer
        let vertexDataSize = vertices.count * MemoryLayout<IcosahedronVertex>.stride
        guard let vBuffer = device.makeBuffer(bytes: vertices, length: vertexDataSize, options: []) else {
            fatalError("Could not create vertex buffer")
        }
        vertexBuffer = vBuffer
        vertexBuffer.label = "Icosahedron Vertices"

        // Index Buffer
        let indexDataSize = indices.count * MemoryLayout<UInt16>.stride
        guard let iBuffer = device.makeBuffer(bytes: indices, length: indexDataSize, options: []) else {
            fatalError("Could not create index buffer")
        }
        indexBuffer = iBuffer
        indexBuffer.label = "Icosahedron Indices"

        // Uniform Buffer
        let uniformBufferSize = MemoryLayout<Uniforms>.size
        guard let uBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared) else {
            fatalError("Could not create uniform buffer")
        }
        uniformBuffer = uBuffer
        uniformBuffer.label = "Uniforms Buffer (MVP Matrix)"
    }

    /// Creates the `MTLDepthStencilState` object to configure depth testing.
    func setupDepthStencil() {
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        guard let state = device.makeDepthStencilState(descriptor: depthDescriptor) else {
            fatalError("Failed to create depth stencil state")
        }
        depthState = state
    }

    // --- Update State Per Frame ---

    /// Calculates the Model-View-Projection (MVP) matrix and updates the uniform buffer.
    func updateUniforms() {
        let projectionMatrix = matrix_perspective_left_hand(
            fovyRadians: .pi / 3.0, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100.0
        )
        let viewMatrix = matrix_look_at_left_hand(
            eye: SIMD3<Float>(0, 0.5, -4.5), // Adjusted distance slightly for larger icosahedron
            center: SIMD3<Float>(0, 0, 0),
            up: SIMD3<Float>(0, 1, 0)
        )
        let rotationY = matrix_rotation_y(radians: rotationAngle)
        let rotationX = matrix_rotation_x(radians: rotationAngle * 0.7) // Slightly different rotation speeds
        let modelMatrix = matrix_multiply(rotationY, rotationX)
        let modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix)
        let mvpMatrix = matrix_multiply(projectionMatrix, modelViewMatrix)

        var uniforms = Uniforms(modelViewProjectionMatrix: mvpMatrix)
        let bufferPointer = uniformBuffer.contents()
        memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size)

        rotationAngle += 0.008 // Slightly slower rotation
    }

    // MARK: - MTKViewDelegate Methods

    /// Called when the `MTKView`'s drawable size changes.
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        aspectRatio = Float(size.width / max(1, size.height))
        print("MTKView Resized - New Aspect Ratio: \(aspectRatio)")
    }

    /// Called for each frame to encode rendering commands.
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
             print("Failed to get required Metal objects in draw(in:). Skipping frame.")
            return
        }

        updateUniforms() // Update MVP matrix

        renderEncoder.label = "Icosahedron Render Encoder"
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthState)
        renderEncoder.setTriangleFillMode(.lines) // Render as wireframe

        // Bind buffers
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)

        // *** Draw Call: Use the correct index count for the Icosahedron ***
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: indices.count, // Now uses 60 for icosahedron
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)

        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - SwiftUI UIViewRepresentable

/// Bridges the `MTKView` into the SwiftUI view hierarchy for the Icosahedron.
struct MetalIcosahedronViewRepresentable: UIViewRepresentable {
    typealias UIViewType = MTKView

    func makeCoordinator() -> IcosahedronRenderer {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device.")
        }
        guard let coordinator = IcosahedronRenderer(device: device) else {
            fatalError("IcosahedronRenderer failed to initialize.")
        }
        print("Coordinator (IcosahedronRenderer) created.")
        return coordinator
    }

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = context.coordinator.device
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = false
        mtkView.depthStencilPixelFormat = .depth32Float // Enable depth buffer
        mtkView.clearDepth = 1.0
        mtkView.clearColor = MTLClearColor(red: 0.15, green: 0.1, blue: 0.1, alpha: 1.0) // Slightly different BG
        mtkView.colorPixelFormat = .bgra8Unorm_srgb

        context.coordinator.configure(metalKitView: mtkView) // Configure pipeline *after* view setup
        mtkView.delegate = context.coordinator

        // Trigger initial size update
        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        print("MTKView created and configured for Icosahedron.")
        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        // No updates needed from SwiftUI state in this example.
    }
}

// MARK: - Main SwiftUI View

/// The primary SwiftUI view displaying the Icosahedron.
struct IcosahedronView: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Rotating Wireframe Icosahedron (Metal)")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.15, green: 0.1, blue: 0.1)) // Match new BG
                .foregroundColor(.white)

            MetalIcosahedronViewRepresentable()
                // .ignoresSafeArea(.all) // Optional: Extend into safe areas
        }
        .background(Color(red: 0.15, green: 0.1, blue: 0.1))
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Preview Provider

#Preview {
    // Option 1: Use Placeholder (Recommended for Canvas Stability)
    struct PreviewPlaceholder: View {
        var body: some View {
            VStack {
                Text("Rotating Wireframe Icosahedron (Metal)")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                Spacer()
                Text("Metal View Placeholder\n(Run on Simulator or Device)")
                    .foregroundColor(.gray).italic().multilineTextAlignment(.center).padding()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.15, green: 0.1, blue: 0.1))
            .edgesIgnoringSafeArea(.all)
        }
    }
     return PreviewPlaceholder() // <-- Use Placeholder

    // Option 2: Attempt Live Metal Preview (Uncomment below, comment above)
    // return IcosahedronView()
}

// MARK: - Matrix Math Helper Functions (using SIMD)
// (These are identical to the Octahedron example - No changes needed)

/// Creates a perspective projection matrix (Left-Handed).
func matrix_perspective_left_hand(fovyRadians: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
    let y = 1.0 / tan(fovyRadians * 0.5)
    let x = y / aspectRatio
    let z = farZ / (farZ - nearZ)
    let w = -nearZ * z
    return matrix_float4x4(SIMD4<Float>(x, 0, 0, 0), SIMD4<Float>(0, y, 0, 0), SIMD4<Float>(0, 0, z, 1), SIMD4<Float>(0, 0, w, 0))
}

/// Creates a view matrix (Left-Handed) to position and orient the camera.
func matrix_look_at_left_hand(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> matrix_float4x4 {
    let zAxis = normalize(center - eye)
    let xAxis = normalize(cross(up, zAxis))
    let yAxis = cross(zAxis, xAxis)
    let translateX = -dot(xAxis, eye)
    let translateY = -dot(yAxis, eye)
    let translateZ = -dot(zAxis, eye)
    return matrix_float4x4(SIMD4<Float>(xAxis.x, yAxis.x, zAxis.x, 0), SIMD4<Float>(xAxis.y, yAxis.y, zAxis.y, 0), SIMD4<Float>(xAxis.z, yAxis.z, zAxis.z, 0), SIMD4<Float>(translateX, translateY, translateZ, 1))
}

/// Creates a rotation matrix for rotation around the Y-axis.
func matrix_rotation_y(radians: Float) -> matrix_float4x4 {
    let c = cos(radians); let s = sin(radians)
    return matrix_float4x4(SIMD4<Float>(c, 0, s, 0), SIMD4<Float>(0, 1, 0, 0), SIMD4<Float>(-s, 0, c, 0), SIMD4<Float>(0, 0, 0, 1))
}

/// Creates a rotation matrix for rotation around the X-axis.
func matrix_rotation_x(radians: Float) -> matrix_float4x4 {
    let c = cos(radians); let s = sin(radians)
    return matrix_float4x4(SIMD4<Float>(1, 0, 0, 0), SIMD4<Float>(0, c, s, 0), SIMD4<Float>(0, -s, c, 0), SIMD4<Float>(0, 0, 0, 1))
}

/// Multiplies two 4x4 matrices.
func matrix_multiply(_ matrix1: matrix_float4x4, _ matrix2: matrix_float4x4) -> matrix_float4x4 {
    return matrix1 * matrix2
}
