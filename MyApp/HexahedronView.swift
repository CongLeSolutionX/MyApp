//
//  HexahedronView.swift
//  MyApp
//
//  Created by Cong Le on 5/3/25.
//
//  Description:
//  This file defines a SwiftUI view hierarchy that displays a 3D rotating
//  wireframe Hexahedron (Cube) rendered using Apple's Metal framework. It demonstrates:
//  - Embedding a MetalKit view (MTKView) within SwiftUI using UIViewRepresentable.
//  - Setting up a basic Metal rendering pipeline (shaders, buffers, pipeline state).
//  - Defining geometry (vertices, indices) for a Hexahedron (Cube).
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
let hexahedronMetalShaderSource = """
#include <metal_stdlib> // Import the Metal Standard Library

using namespace metal; // Use the Metal namespace

// Structure defining vertex input data received from the CPU (Swift code).
// The layout *must* match the 'HexahedronVertex' struct in Swift and the MTLVertexDescriptor.
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
vertex VertexOut hexahedron_vertex_shader( // Renamed function
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
fragment half4 hexahedron_fragment_shader( // Renamed function
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
/// *Note*: Renamed from OctahedronVertex for clarity, but structure is identical.
struct HexahedronVertex {
    /// The 3D position (x, y, z) of the vertex in model space.
    var position: SIMD3<Float>
    /// The RGBA color associated with the vertex.
    var color: SIMD4<Float>
}

// MARK: - Renderer Class (Handles Metal Logic)

/// Manages all Metal-specific setup, resource creation, and rendering logic for the Hexahedron.
/// Conforms to `MTKViewDelegate` to respond to view size changes and draw calls.
class HexahedronRenderer: NSObject, MTKViewDelegate {

    /// The logical connection to the GPU. Used to create other Metal objects.
    let device: MTLDevice
    /// Queue for sending encoded commands (rendering, compute) to the GPU.
    let commandQueue: MTLCommandQueue
    /// Compiled shader functions and rendering configuration (vertex layout, pixel formats, etc.).
    var pipelineState: MTLRenderPipelineState!
    /// Configures depth testing behavior (essential for correct 3D rendering).
    var depthState: MTLDepthStencilState!

    /// GPU buffer holding the hexahedron's vertex data (`HexahedronVertex` array).
    var vertexBuffer: MTLBuffer!
    /// GPU buffer holding the indices that define the hexahedron's triangles (`UInt16` array).
    var indexBuffer: MTLBuffer!
    /// GPU buffer holding the transformation matrix (`Uniforms` struct). Updated each frame.
    var uniformBuffer: MTLBuffer!

    /// Current rotation angle for the animation (in radians). Incremented each frame.
    var rotationAngle: Float = 0.0
    /// Aspect ratio of the view (width / height). Updated when the view size changes.
    var aspectRatio: Float = 1.0

    // --- Geometry Data ---

    /// Array defining the 8 vertices of the Hexahedron (Cube), centered at the origin, side length 2.
    let hexahedronVertices: [HexahedronVertex] = [
        // Vertex Format: HexahedronVertex(position: SIMD3<Float>(x, y, z), color: SIMD4<Float>(r, g, b, a))
        // Using standard cube coords from -1 to +1

        // Front Face vertices (Z = -1)
        HexahedronVertex(position: SIMD3<Float>(-1, -1, -1), color: SIMD4<Float>(1, 0, 0, 1)), // 0: Front Bottom Left (Red)
        HexahedronVertex(position: SIMD3<Float>( 1, -1, -1), color: SIMD4<Float>(0, 1, 0, 1)), // 1: Front Bottom Right (Green)
        HexahedronVertex(position: SIMD3<Float>( 1,  1, -1), color: SIMD4<Float>(0, 0, 1, 1)), // 2: Front Top Right (Blue)
        HexahedronVertex(position: SIMD3<Float>(-1,  1, -1), color: SIMD4<Float>(1, 1, 0, 1)), // 3: Front Top Left (Yellow)

        // Back Face vertices (Z = 1)
        HexahedronVertex(position: SIMD3<Float>(-1, -1,  1), color: SIMD4<Float>(0, 1, 1, 1)), // 4: Back Bottom Left (Cyan)
        HexahedronVertex(position: SIMD3<Float>( 1, -1,  1), color: SIMD4<Float>(1, 0, 1, 1)), // 5: Back Bottom Right (Magenta)
        HexahedronVertex(position: SIMD3<Float>( 1,  1,  1), color: SIMD4<Float>(1, 1, 1, 1)), // 6: Back Top Right (White)
        HexahedronVertex(position: SIMD3<Float>(-1,  1,  1), color: SIMD4<Float>(0.5, 0.5, 0.5, 1)) // 7: Back Top Left (Gray)
    ]

    /// Array of indices defining the 12 triangles (6 faces) of the Hexahedron (Cube).
    /// Each sequence of 3 indices references vertices from the `hexahedronVertices` array to form a triangle.
    /// Using Counter-Clockwise (CCW) winding order for front faces.
    let hexahedronIndices: [UInt16] = [
        // Front Face (Z = -1) - vertices 0, 1, 2, 3
        0, 1, 2, // Triangle 1: BottomLeft -> BottomRight -> TopRight
        2, 3, 0, // Triangle 2: TopRight -> TopLeft -> BottomLeft

        // Back Face (Z = 1) - vertices 4, 5, 6, 7
        // (winding order reversed relative to front face when viewed from origin)
        4, 7, 6, // Triangle 3: BBLeft -> BTLeft -> BT chiropracteur chiropracteur ight
        6, 5, 4, // Triangle 4: BT chiropracteur chiropracteur ight -> BB chiropracteur chiropracteur ight -> BBLeft

        // Left Face (X = -1) - vertices 0, 3, 7, 4
        4, 0, 3, // Triangle 5
        3, 7, 4, // Triangle 6

        // Right Face (X = 1) - vertices 1, 5, 6, 2
        1, 5, 6, // Triangle 7
        6, 2, 1, // Triangle 8

        // Top Face (Y = 1) - vertices 3, 2, 6, 7
        3, 2, 6, // Triangle 9
        6, 7, 3, // Triangle 10

        // Bottom Face (Y = -1) - vertices 0, 4, 5, 1
        0, 4, 5, // Triangle 11
        5, 1, 0  // Triangle 12
    ]
    // Indices count: 12 triangles * 3 indices/triangle = 36 indices
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

        setupBuffers()        // Create vertex, index, and uniform buffers
        setupDepthStencil()   // Configure depth testing state
    }

    /// Configures the Metal pipeline state. This is called *after* the `MTKView` is created,
    /// as the pipeline needs to know the view's pixel formats.
    /// - Parameter metalKitView: The `MTKView` instance this renderer will draw into.
    func configure(metalKitView: MTKView) {
        setupPipeline(metalKitView: metalKitView)
    }

    // --- Setup Functions ---

    /// Compiles shaders and creates the `MTLRenderPipelineState`.
    /// - Parameter metalKitView: The view providing the necessary pixel format information.
    func setupPipeline(metalKitView: MTKView) {
        do {
            let library = try device.makeLibrary(source: hexahedronMetalShaderSource, options: nil)

            // Use the *renamed* shader function names
            guard let vertexFunction = library.makeFunction(name: "hexahedron_vertex_shader"),
                  let fragmentFunction = library.makeFunction(name: "hexahedron_fragment_shader") else {
                fatalError("Could not load shader functions from library. Check function names.")
            }

            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.label = "Wireframe Hexahedron Pipeline" // Updated label
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction

            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
            pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat

            // Vertex Descriptor - Matches HexahedronVertex layout (same as OctahedronVertex)
            let vertexDescriptor = MTLVertexDescriptor()
            // Attribute 0: Position
            vertexDescriptor.attributes[0].format = .float3
            vertexDescriptor.attributes[0].offset = 0
            vertexDescriptor.attributes[0].bufferIndex = 0
            // Attribute 1: Color
            vertexDescriptor.attributes[1].format = .float4
            vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
            vertexDescriptor.attributes[1].bufferIndex = 0
            // Layout 0: Overall stride
            vertexDescriptor.layouts[0].stride = MemoryLayout<HexahedronVertex>.stride
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
        // Vertex Buffer (uses hexahedronVertices)
        let vertexDataSize = hexahedronVertices.count * MemoryLayout<HexahedronVertex>.stride
        guard let vBuffer = device.makeBuffer(bytes: hexahedronVertices, length: vertexDataSize, options: []) else {
            fatalError("Could not create vertex buffer")
        }
        vertexBuffer = vBuffer
        vertexBuffer.label = "Hexahedron Vertices" // Updated label

        // Index Buffer (uses hexahedronIndices)
        let indexDataSize = hexahedronIndices.count * MemoryLayout<UInt16>.stride
        guard let iBuffer = device.makeBuffer(bytes: hexahedronIndices, length: indexDataSize, options: []) else {
            fatalError("Could not create index buffer")
        }
        indexBuffer = iBuffer
        indexBuffer.label = "Hexahedron Indices" // Updated label

        // Uniform Buffer (structure is the same)
        let uniformBufferSize = MemoryLayout<Uniforms>.stride // size works here too
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
    /// (This logic is generic and reused from the Octahedron example).
    func updateUniforms() {
        let projectionMatrix = matrix_perspective_left_hand(
            fovyRadians: Float.pi / 3.0,
            aspectRatio: aspectRatio,
            nearZ: 0.1,
            farZ: 100.0
        )

        let viewMatrix = matrix_look_at_left_hand(
            eye: SIMD3<Float>(0, 0.5, -4),
            center: SIMD3<Float>(0, 0, 0),
            up: SIMD3<Float>(0, 1, 0)
        )

        let rotationY = matrix_rotation_y(radians: rotationAngle)
        let rotationX = matrix_rotation_x(radians: rotationAngle * 0.5)
        let modelMatrix = matrix_multiply(rotationY, rotationX)

        let modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix)
        let mvpMatrix = matrix_multiply(projectionMatrix, modelViewMatrix)

        var uniforms = Uniforms(modelViewProjectionMatrix: mvpMatrix)
        let bufferPointer = uniformBuffer.contents()
        memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size)

        rotationAngle += 0.01 // Adjust for desired rotation speed
    }

    // MARK: - MTKViewDelegate Methods

    /// Called automatically whenever the `MTKView`'s drawable size changes.
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        aspectRatio = Float(size.width / max(1, size.height))
        // print("MTKView Resized - New Aspect Ratio: \(aspectRatio)")
    }

    /// Called automatically for each frame, responsible for encoding rendering commands.
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            print("Failed to get required Metal objects in draw(in:). Skipping frame.")
            return
        }

        updateUniforms() // Update MVP matrix

        renderEncoder.label = "Hexahedron Render Encoder" // Updated label
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthState)
        renderEncoder.setTriangleFillMode(.lines) // Keep wireframe

        // Bind Buffers
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)

        // Issue Draw Call (Crucially, use the hexahedronIndices.count)
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: hexahedronIndices.count, // Use the correct count
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)

        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - SwiftUI UIViewRepresentable

/// Bridges the `MTKView` for rendering the Hexahedron into the SwiftUI view hierarchy.
struct MetalHexahedronViewRepresentable: UIViewRepresentable { // Renamed
    typealias UIViewType = MTKView

    func makeCoordinator() -> HexahedronRenderer { // Return correct type
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device.")
        }
        guard let coordinator = HexahedronRenderer(device: device) else { // Instantiate correct type
            fatalError("HexahedronRenderer failed to initialize.")
        }
        print("Coordinator (HexahedronRenderer) created.")
        return coordinator
    }

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = context.coordinator.device
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = false
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.clearDepth = 1.0
        mtkView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        mtkView.colorPixelFormat = .bgra8Unorm_srgb

        // Configure renderer *after* view formats are set
        context.coordinator.configure(metalKitView: mtkView)
        mtkView.delegate = context.coordinator

        // Initial size update
        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        print("MTKView created and configured for Hexahedron.")
        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        // No external state updates handled here.
    }
}

// MARK: - Main SwiftUI View

/// The primary SwiftUI view displaying the Hexahedron (Cube).
struct HexahedronView: View { // Renamed
    var body: some View {
        VStack(spacing: 0) {
            Text("Rotating Wireframe Hexahedron (Metal)") // Updated Title
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.1, green: 0.1, blue: 0.15))
                .foregroundColor(.white)

            MetalHexahedronViewRepresentable() // Use the renamed representable
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Preview Provider

#Preview {
    // Option 1: Use a Placeholder View (Safer for Previews)
    struct PreviewPlaceholder: View {
        var body: some View {
            VStack {
                Text("Rotating Wireframe Hexahedron (Metal)") // Updated Title
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                Spacer()
                Text("Metal View Placeholder\n(Run on Simulator or Device)")
                    .foregroundColor(.gray)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.1, green: 0.1, blue: 0.15))
            .edgesIgnoringSafeArea(.all)
        }
    }
     //return PreviewPlaceholder() // Using placeholder by default

    // Option 2: Attempt to Render the Actual Metal View (May Fail in Canvas)
     return HexahedronView() // Use the renamed view
}

// MARK: - Matrix Math Helper Functions (using SIMD)
// (These functions are generic and identical to the Octahedron example)

/// Creates a perspective projection matrix (Left-Handed).
func matrix_perspective_left_hand(fovyRadians: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
    let y = 1.0 / tan(fovyRadians * 0.5)
    let x = y / aspectRatio
    let z = farZ / (farZ - nearZ)
    let w = -nearZ * z
    return matrix_float4x4(
        SIMD4<Float>(x, 0, 0, 0), SIMD4<Float>(0, y, 0, 0), SIMD4<Float>(0, 0, z, 1), SIMD4<Float>(0, 0, w, 0)
    )
}

/// Creates a view matrix (Left-Handed) to position and orient the camera.
func matrix_look_at_left_hand(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> matrix_float4x4 {
    let zAxis = normalize(center - eye)
    let xAxis = normalize(cross(up, zAxis))
    let yAxis = cross(zAxis, xAxis)
    let translateX = -dot(xAxis, eye)
    let translateY = -dot(yAxis, eye)
    let translateZ = -dot(zAxis, eye)
    return matrix_float4x4(
        SIMD4<Float>( xAxis.x,  yAxis.x,  zAxis.x, 0),
        SIMD4<Float>( xAxis.y,  yAxis.y,  zAxis.y, 0),
        SIMD4<Float>( xAxis.z,  yAxis.z,  zAxis.z, 0),
        SIMD4<Float>(translateX, translateY, translateZ, 1)
    )
}

/// Creates a rotation matrix for rotation around the Y-axis.
func matrix_rotation_y(radians: Float) -> matrix_float4x4 {
    let c = cos(radians)
    let s = sin(radians)
    return matrix_float4x4(
        SIMD4<Float>( c, 0, s, 0), SIMD4<Float>( 0, 1, 0, 0), SIMD4<Float>(-s, 0, c, 0), SIMD4<Float>( 0, 0, 0, 1)
    )
}

/// Creates a rotation matrix for rotation around the X-axis.
func matrix_rotation_x(radians: Float) -> matrix_float4x4 {
    let c = cos(radians)
    let s = sin(radians)
    return matrix_float4x4(
        SIMD4<Float>(1,  0, 0, 0), SIMD4<Float>(0,  c, s, 0), SIMD4<Float>(0, -s, c, 0), SIMD4<Float>(0,  0, 0, 1)
    )
}

/// Multiplies two 4x4 matrices.
func matrix_multiply(_ matrix1: matrix_float4x4, _ matrix2: matrix_float4x4) -> matrix_float4x4 {
    return matrix1 * matrix2
}
