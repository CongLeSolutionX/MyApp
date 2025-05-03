//
//  TheFlowerOfLifeComprehensiveView_V4_Over_the_Top.swift
//  MyApp
//
//  Created by Cong Le on 5/3/25.

//  Description:
//  This file defines a SwiftUI view that displays an animated construction
//  of the Flower of Life pattern using Apple's Metal framework. It demonstrates:
//  - Embedding an MTKView within SwiftUI using UIViewRepresentable.
//  - Basic Metal pipeline for 2D drawing using line strips.
//  - Defining geometry for a base circle.
//  - Using Instanced Drawing to render multiple circles efficiently from the base geometry.
//  - Passing instance-specific data (position offset, scale, alpha) to the GPU via a dedicated buffer.
//  - Passing uniform data (projection matrix, time, base color) common to all instances.
//  - Animating the sequential appearance and fade-in of circles forming the Seed and Flower of Life patterns.
//
import SwiftUI
import MetalKit
import simd // For SIMD types like float2, float4x4

// MARK: - Metal Shaders (Flower of Life)

/// Metal Shading Language (MSL) source code for the Flower of Life rendering pipeline.
/// Contains vertex and fragment shaders.
let flowerOfLifeMetalShaderSource = """
#include <metal_stdlib>

using namespace metal;

// --- Data Structures ---

// Structure for vertex data of the BASE CIRCLE
struct VertexIn {
    // Attribute 0: 2D position for each vertex of the base circle line strip.
    float2 position [[attribute(0)]];
};

// Structure for PER-INSTANCE data (one set of data for each circle instance drawn)
// Passed in a separate buffer bound at index 2.
struct InstanceData {
    float2 offset [[attribute(1)]];  // Attribute 1: Center position offset for this instance.
    float scale   [[attribute(2)]];  // Attribute 2: Scale factor for this instance.
    float alpha   [[attribute(3)]];  // Attribute 3: Alpha (opacity) for this instance.
};

// Structure for uniform data (constant across all instances for a single draw call)
// Passed in a buffer bound at index 1.
struct Uniforms {
    float4x4 projectionMatrix; // Orthographic projection matrix to map to clip space.
    float time;                // Current animation time, driving the animation.
    float4 baseColor;          // Base color for the circle lines before alpha modulation.
};

// Data passed from the vertex shader to the fragment shader.
// Metal interpolates these values across the primitive (line segment).
struct VertexOut {
    float4 position [[position]]; // Mandatory: Final projected position in clip space.
    float4 color;                 // Color (including alpha) to be passed to the fragment shader.
};

// --- Vertex Shader ---
/// Processes each vertex of the base circle geometry for each instance being drawn.
/// Applies instance-specific transformations (scale, offset) and the uniform projection.
/// Calculates the vertex color incorporating instance alpha.
vertex VertexOut flower_vertex_shader(
    const device VertexIn *vertices      [[buffer(0)]], // Buffer 0: Array of base circle vertices.
    const device Uniforms &uniforms      [[buffer(1)]], // Buffer 1: Uniform data structure.
    const device InstanceData *instanceData [[buffer(2)]], // Buffer 2: Array of per-instance data structures.
    unsigned int vid          [[vertex_id]],   // System-generated: Index of the current vertex in the base geometry.
    unsigned int instance_id  [[instance_id]] // System-generated: Index of the current instance being processed.
) {
    VertexOut out;
    VertexIn currentVertex = vertices[vid];               // Get the specific vertex from the base circle buffer.
    InstanceData currentInstance = instanceData[instance_id]; // Get the data for the specific circle instance being drawn.

    // 1. Apply Instance Transformation: Scale the base vertex position and add the instance's offset.
    float2 transformedPos = (currentVertex.position * currentInstance.scale) + currentInstance.offset;

    // 2. Apply Projection: Transform the 2D position into 4D clip space using the projection matrix.
    //    (z=0, w=1 for standard 2D orthographic projection).
    out.position = uniforms.projectionMatrix * float4(transformedPos, 0.0, 1.0);

    // 3. Set Color: Use the base color from uniforms but modulate its alpha with the instance's specific alpha.
    out.color = float4(uniforms.baseColor.rgb, currentInstance.alpha);

    return out;
}

// --- Fragment Shader ---
/// Processes each fragment (potential pixel) along the rasterized line segments.
/// Receives interpolated data (VertexOut) from the vertex shader.
/// Outputs the final color for the fragment.
fragment float4 flower_fragment_shader(VertexOut in [[stage_in]]) { // stage_in indicates data comes from the vertex stage.
    // Return the interpolated color, applying premultiplied alpha.
    // Premultiplying (RGB * Alpha) is often preferred for correct blending results.
    return float4(in.color.rgb * in.color.a, in.color.a);
}
"""

// MARK: - Swift Data Structures Matching Shaders

/// Swift structure mirroring the `Uniforms` struct in the Metal shader.
/// Used to send data that is constant for all instances in a draw call.
struct FlowerUniforms {
    /// Orthographic projection matrix to transform coordinates into Metal's Normalized Device Coordinates (NDC).
    var projectionMatrix: matrix_float4x4
    /// Current animation time, used to control the appearance of circles.
    var time: Float
    /// Base color for the circle lines (RGBA). Alpha component might be overridden by instance alpha.
    var baseColor: SIMD4<Float> // Using SIMD4 for color, common practice with Metal.
}

/// Swift structure mirroring the `VertexIn` struct in the Metal shader.
/// Represents a single vertex of the base circle geometry.
struct CircleVertex {
    /// 2D position of the vertex.
    var position: SIMD2<Float> // Using SIMD2 for 2D positions.
}

/// Swift structure mirroring the `InstanceData` struct in the Metal shader.
/// Represents the unique properties for a single circle instance.
struct InstanceData {
    /// The center offset (translation) for this circle instance from the origin.
    var offset: SIMD2<Float>
    /// The scaling factor applied to the base circle radius for this instance.
    var scale: Float
    /// The alpha (opacity) value for this circle instance (0.0 = transparent, 1.0 = opaque).
    var alpha: Float
}

// MARK: - Metal Renderer Class

/// Handles all Metal setup, drawing logic, and delegation for the MTKView.
class FlowerOfLifeRenderer: NSObject, MTKViewDelegate {
    
    /// The Metal device (GPU) used for rendering.
    let device: MTLDevice
    /// Queue for sending commands (like rendering) to the GPU.
    let commandQueue: MTLCommandQueue
    /// The compiled rendering pipeline state object containing shaders and configuration.
    var pipelineState: MTLRenderPipelineState!
    // Note: No depth state needed for this 2D, alpha-blended visualization.
    
    // --- Metal Buffers ---
    /// Buffer storing the vertices of the base circle (line strip). Bound to buffer index 0 in vertex shader.
    var circleVertexBuffer: MTLBuffer!
    /// Buffer storing the indices defining the order to draw base circle vertices as a line strip.
    var circleIndexBuffer: MTLBuffer!
    /// Buffer storing the `FlowerUniforms` data. Bound to buffer index 1 in vertex shader.
    var uniformBuffer: MTLBuffer!
    /// Buffer storing the array of `InstanceData`. Bound to buffer index 2 in vertex shader.
    var instanceDataBuffer: MTLBuffer!
    
    // --- Animation State ---
    /// Timestamp captured when rendering begins, used to calculate animation time.
    var startTime: Date = Date()
    /// Aspect ratio of the view, used for correct projection scaling.
    var aspectRatio: Float = 1.0
    /// Stores the count of instances calculated in `updateState` to be drawn in the `draw` method. Avoids recalculation.
    var lastCalculatedInstanceCount = 0
    
    // --- Geometry Configuration ---
    /// Number of line segments used to approximate the base circle. Higher values mean smoother circles.
    let circleSegments = 60 // Increased for smoother circle
    /// Array holding the `CircleVertex` data for the base circle.
    var circleVertices: [CircleVertex] = []
    /// Array holding the `UInt16` indices for drawing the base circle vertices as a line strip.
    var circleIndices: [UInt16] = []
    /// Maximum number of circle instances needed for the standard 19-circle Flower of Life pattern.
    let maxInstances = 19
    
    // --- Flower of Life Pattern Data ---
    /// Array storing the calculated center `SIMD2<Float>` positions for each of the 19 circles.
    var circleCenters: [SIMD2<Float>] = []
    /// The base radius used for the circles before instance-specific scaling.
    let baseRadius: Float = 0.5
    
    /// Initializes the renderer. Fails if a Metal device or command queue cannot be created.
    /// - Parameter device: The `MTLDevice` to use for rendering.
    init?(device: MTLDevice) {
        self.device = device
        guard let queue = device.makeCommandQueue() else {
            print("Error: Could not create Metal command queue.")
            return nil
        }
        self.commandQueue = queue
        super.init()
        
        // Perform initial setup tasks
        generateCircleGeometry()         // Create vertices/indices for the base circle
        calculateFlowerOfLifeCenters()   // Determine the positions for each circle instance
        setupBuffers()                   // Create and populate Metal buffers (except InstanceData)
        
        // Note: The pipeline state depends on the MTKView's pixel format,
        // so its setup is deferred to the `configure(metalKitView:)` method,
        // called after the MTKView is available.
    }
    
    /// Configures the renderer after the `MTKView` has been created and its properties (like pixel format) are known.
    /// Primarily sets up the Metal render pipeline state.
    /// - Parameter metalKitView: The `MTKView` being used for rendering.
    func configure(metalKitView: MTKView) {
        setupPipeline(metalKitView: metalKitView)
        print("Renderer configured with MTKView.")
    }
    
    // MARK: - Geometry Generation
    
    /// Generates the vertex positions and index list for a single base circle, drawn as a connected line strip.
    /// The circle is initially centered at (0,0) with a radius of 1.0; scaling is applied via instance data later.
    func generateCircleGeometry() {
        circleVertices.removeAll()
        circleIndices.removeAll()
        
        // Calculate the angle increment between vertices.
        let angleStep = (2.0 * Float.pi) / Float(circleSegments)
        
        // Generate vertices around the unit circle.
        for i in 0...circleSegments { // Use 0...N for N+1 vertices to define N segments.
            let angle = angleStep * Float(i)
            // Calculate position on a unit circle (radius = 1.0).
            let x = cos(angle)
            let y = sin(angle)
            circleVertices.append(CircleVertex(position: SIMD2<Float>(x, y)))
            // Indices simply go in order: 0, 1, 2, ..., N for a line strip.
            circleIndices.append(UInt16(i))
        }
        
        print("Generated \(circleVertices.count) vertices and \(circleIndices.count) indices for base circle.")
    }
    
    /// Calculates and stores the center positions for the 19 circles that form the complete Flower of Life pattern.
    /// Positions are based on the `baseRadius`.
    func calculateFlowerOfLifeCenters() {
        circleCenters.removeAll()
        let r = baseRadius // Alias for readability
        // Calculate the vertical distance between centers in the hexagonal grid (apothem * 2, or height of equilateral triangle).
        let h = r * sqrt(3.0) / 2.0
        
        // Layer 0: Center circle (Instance 0)
        circleCenters.append(SIMD2<Float>(0, 0))
        
        // Layer 1: Seed of Life - 6 surrounding circles (Instances 1-6)
        let layer1AngleStep = Float.pi / 3.0 // 60 degrees
        for i in 0..<6 {
            let angle = layer1AngleStep * Float(i)
            circleCenters.append(SIMD2<Float>(r * cos(angle), r * sin(angle)))
        }
        
        // Layer 2: Outer Flower - 12 additional circles (Instances 7-18)
        // Positions derived from the hexagonal grid geometry.
        circleCenters.append(SIMD2<Float>(2*r, 0))      // Far Right (7)
        circleCenters.append(SIMD2<Float>(r, 2*h))      // Top-Right Outer (8) -> Corrected position
        circleCenters.append(SIMD2<Float>(0, 2*h))      // Top Outer (9)
        circleCenters.append(SIMD2<Float>(-r, 2*h))     // Top-Left Outer (10) -> Corrected position
        circleCenters.append(SIMD2<Float>(-2*r, 0))     // Far Left (11)
        circleCenters.append(SIMD2<Float>(-r, -2*h))    // Bottom-Left Outer (12) -> Corrected position
        circleCenters.append(SIMD2<Float>(0, -2*h))     // Bottom Outer (13)
        circleCenters.append(SIMD2<Float>(r, -2*h))     // Bottom-Right Outer (14) -> Corrected position
        
        circleCenters.append(SIMD2<Float>(r * 1.5, h))  // Outer Mid-Top-Right (15)
        circleCenters.append(SIMD2<Float>(-r * 1.5, h)) // Outer Mid-Top-Left (16)
        circleCenters.append(SIMD2<Float>(-r * 1.5, -h))// Outer Mid-Bottom-Left (17)
        circleCenters.append(SIMD2<Float>(r * 1.5, -h)) // Outer Mid-Bottom-Right (18)
        
        guard circleCenters.count == maxInstances else {
            print("Warning: Calculated \(circleCenters.count) centers, expected \(maxInstances). Check calculation logic.")
            // Pad if necessary, though logic implies exactly 19
            while circleCenters.count < maxInstances { circleCenters.append(.zero) }
            return
        }
        
        print("Calculated \(circleCenters.count) circle center positions.")
    }
    
    // MARK: - Setup Functions
    
    /// Compiles shaders and sets up the `MTLRenderPipelineState` object.
    /// Configures vertex descriptors, blending, and other pipeline settings based on the `MTKView`.
    /// - Parameter metalKitView: The target `MTKView` providing the pixel format.
    func setupPipeline(metalKitView: MTKView) {
        do {
            // 1. Create Metal Library from shader source
            let library = try device.makeLibrary(source: flowerOfLifeMetalShaderSource, options: nil)
            guard let vertexFunction = library.makeFunction(name: "flower_vertex_shader"),
                  let fragmentFunction = library.makeFunction(name: "flower_fragment_shader") else {
                fatalError("Could not load shader functions from Metal library.")
            }
            
            // 2. Create Pipeline Descriptor
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.label = "Flower of Life Rendering Pipeline"
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            // Set the pixel format for the color attachment to match the MTKView's format.
            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
            
            // 3. Configure Blending for Alpha Transparency
            // Enable blending on the first color attachment.
            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
            // Blend operation: FinalColor = SourceColor * SourceBlendFactor + DestinationColor * DestBlendFactor
            pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
            pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
            // Source factors: Use the source fragment's alpha (premultiplied in shader).
            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            // Destination factors: Use (1 - source alpha) to blend with existing framebuffer color.
            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
            // 4. Configure Vertex Descriptors (Crucial for Instancing)
            // This tells Metal how vertex data (base circle) and instance data are laid out in buffers.
            let vertexDescriptor = MTLVertexDescriptor()
            
            // -- Base Circle Vertex Layout (Buffer 0) --
            // Attribute 0: `position` (float2) in `VertexIn`.
             guard let basePositionOffset = MemoryLayout<CircleVertex>.offset(of: \.position) else {
                 fatalError("Could not determine memory offset for CircleVertex.position.")
             }
            vertexDescriptor.attributes[0].format = .float2    // Data type is float2.
            vertexDescriptor.attributes[0].offset = basePositionOffset         // Starts at the beginning of the CircleVertex struct.
            vertexDescriptor.attributes[0].bufferIndex = 0    // Data comes from the buffer bound at index 0 (circleVertexBuffer).
            
            // Layout for Buffer 0: Describes how to step through the `circleVertexBuffer`.
            vertexDescriptor.layouts[0].stride = MemoryLayout<CircleVertex>.stride // Size of one CircleVertex element.
            // Step function: Advance for each vertex processed.
            vertexDescriptor.layouts[0].stepFunction = .perVertex
            // stepRate is 1 (default for perVertex).
            
            // -- Instance Data Layout (Buffer 2) --
            
            // Attribute 1: `offset` (float2) in `InstanceData`.
            // Use guard let for safety
            guard let offsetOffset = MemoryLayout<InstanceData>.offset(of: \.offset) else {
               fatalError("Could not determine memory offset for InstanceData.offset.")
            }
            vertexDescriptor.attributes[1].format = .float2
            vertexDescriptor.attributes[1].offset = offsetOffset
            vertexDescriptor.attributes[1].bufferIndex = 2
            
            // Attribute 2: `scale` (float) in `InstanceData`.
             // Use guard let for safety
            guard let scaleOffset = MemoryLayout<InstanceData>.offset(of: \.scale) else {
                fatalError("Could not determine memory offset for InstanceData.scale.")
            }
            vertexDescriptor.attributes[2].format = .float
            vertexDescriptor.attributes[2].offset = scaleOffset
            vertexDescriptor.attributes[2].bufferIndex = 2
            
            // Attribute 3: `alpha` (float) in `InstanceData`.
            // **FIXED:** Use guard let for safety
            guard let alphaOffset = MemoryLayout<InstanceData>.offset(of: \.alpha) else {
                fatalError("Could not determine memory offset for InstanceData.alpha.")
            }
            vertexDescriptor.attributes[3].format = .float
            vertexDescriptor.attributes[3].offset = alphaOffset // Use the safely unwrapped value
            vertexDescriptor.attributes[3].bufferIndex = 2
            
            // Layout for Buffer 2: Describes how to step through the `instanceDataBuffer`.
            vertexDescriptor.layouts[2].stride = MemoryLayout<InstanceData>.stride // Size of one InstanceData element.
            // **** Key for Instancing ****
            // Step function: Advance only ONCE per instance drawn, not per vertex.
            vertexDescriptor.layouts[2].stepFunction = .perInstance
            // Use the same instance data for all vertices of that one instance.
            vertexDescriptor.layouts[2].stepRate = 1
            
            // Assign the configured vertex descriptor to the pipeline descriptor.
            pipelineDescriptor.vertexDescriptor = vertexDescriptor
            
            // 5. Create the Render Pipeline State
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            print("Metal Render Pipeline State created successfully.")
            
        } catch {
            fatalError("Failed to create Metal Render Pipeline State: \(error)")
        }
    }
    
    /// Creates and initializes Metal buffers for vertex, index, uniform, and instance data.
    func setupBuffers() {
        // 1. Circle Vertex Buffer (Buffer 0)
        guard !circleVertices.isEmpty else { fatalError("Cannot create buffer: Circle vertices not generated.") }
        let vertexDataSize = circleVertices.count * MemoryLayout<CircleVertex>.stride
        // Create buffer and copy vertex data into it. Default storage mode is shared on unified memory architectures (iOS/macOS).
        circleVertexBuffer = device.makeBuffer(bytes: circleVertices, length: vertexDataSize, options: [])
        circleVertexBuffer.label = "Circle Base Vertices"
        
        // 2. Circle Index Buffer (Used by drawIndexedPrimitives)
        guard !circleIndices.isEmpty else { fatalError("Cannot create buffer: Circle indices not generated.") }
        let indexDataSize = circleIndices.count * MemoryLayout<UInt16>.stride
        circleIndexBuffer = device.makeBuffer(bytes: circleIndices, length: indexDataSize, options: [])
        circleIndexBuffer.label = "Circle Base Indices"
        
        // 3. Uniform Buffer (Buffer 1)
        let uniformBufferSize = MemoryLayout<FlowerUniforms>.stride // Use stride for safety
        // Create an empty buffer, contents will be updated each frame.
        uniformBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared) // Shared recommended for CPU updates
        uniformBuffer.label = "Uniforms Buffer"
        
        // 4. Instance Data Buffer (Buffer 2)
        let instanceDataSize = maxInstances * MemoryLayout<InstanceData>.stride
        // Create an empty buffer large enough for all potential instances. Contents updated each frame.
        instanceDataBuffer = device.makeBuffer(length: instanceDataSize, options: .storageModeShared)
        instanceDataBuffer.label = "Instance Data Buffer"
        
        print("Metal buffers created.")
    }
    
    // MARK: - Update State Per Frame
    
    /// Called before `draw`, this method updates data buffers based on the current time.
    /// Calculates and updates the `uniformBuffer` (projection matrix, time).
    /// Calculates and updates the `instanceDataBuffer` (offset, scale, alpha for each visible circle).
    /// Determines `lastCalculatedInstanceCount` for the `draw` call.
    func updateState() {
        // Calculate elapsed time since the animation started.
        let currentTime = Float(Date().timeIntervalSince(startTime))
        
        // 1. Update Uniform Buffer (Buffer 1)
        let projMatrix = matrix_orthographic_projection(aspectRatio: aspectRatio)
        let uniforms = FlowerUniforms(
            projectionMatrix: projMatrix,
            time: currentTime,
            baseColor: SIMD4<Float>(0.8, 0.8, 1.0, 1.0) // Light blueish color
        )
        // Copy the updated uniform data into the Metal buffer.
        // Ensure buffer is not nil before accessing contents
        guard let uniformBuffer = uniformBuffer else {
            print("Error: Uniform buffer is nil in updateState.")
            return
        }
        uniformBuffer.contents().copyMemory(from: [uniforms], byteCount: MemoryLayout<FlowerUniforms>.stride)
        
        // 2. Update Instance Data Buffer (Buffer 2) based on Time
        
        // Ensure instance buffer is not nil before accessing contents
        guard let instanceDataBuffer = instanceDataBuffer else {
             print("Error: Instance data buffer is nil in updateState.")
             return
         }
        
        // Get a typed pointer to the buffer's memory to write InstanceData structs directly.
        let instanceDataPtr = instanceDataBuffer.contents().bindMemory(to: InstanceData.self, capacity: maxInstances)
        
        var currentInstanceCount = 0 // Track how many instances are actually active/visible this frame.
        
        // --- Define Animation Timings ---
        // These control when different parts of the pattern appear and fade in.
        let timeSeedStart: Float = 0.5         // Time the first 7 circles (Seed of Life) start appearing.
        let timeSeedDuration: Float = 2.0      // Duration over which the Seed of Life circles fade in sequentially.
        let timeFlowerStart: Float = timeSeedStart + timeSeedDuration + 0.5 // Time the remaining 12 circles start.
        let timeFlowerDuration: Float = 3.0    // Duration over which the remaining 12 circles fade in sequentially.
        
        // Loop through all potential instance positions.
        for i in 0..<maxInstances {
            // Safety check in case calculation logic yielded fewer centers than maxInstances.
            guard i < circleCenters.count else { continue }
            
            var alpha: Float = 0.0          // Initialize alpha to transparent.
            let scale: Float = baseRadius   // Use the base radius for scale initially.
            
            // Determine the target alpha based on the current time and which animation phase this circle belongs to.
            if i == 0 { // Center circle (Instance 0)
                // Fade in the center circle at the very beginning of the Seed phase.
                alpha = smoothstep(0.0, timeSeedStart, currentTime)
            } else if i < 7 { // Seed of Life circles (Instances 1 to 6)
                // Calculate a staggered start time for each Seed circle.
                let startTimeForThis = timeSeedStart + Float(i-1) * (timeSeedDuration / 6.0) * 0.5 // Staggered start
                // Fade in this Seed circle over a fraction of the total Seed duration.
                alpha = smoothstep(startTimeForThis, startTimeForThis + timeSeedDuration * 0.8, currentTime) // Fade-in duration
            } else { // Flower of Life outer circles (Instances 7 to 18)
                // Calculate a staggered start time for each outer Flower circle.
                let startTimeForThis = timeFlowerStart + Float(i-7) * (timeFlowerDuration / 12.0) * 0.5 // Staggered start
                // Fade in this Flower circle over a fraction of the total Flower duration.
                alpha = smoothstep(startTimeForThis, startTimeForThis + timeFlowerDuration * 0.8, currentTime) // Fade-in duration
            }
            
            // Optimization: If a circle's alpha is effectively zero, don't add it to the instance buffer
            // and potentially stop processing further instances if they haven't started yet.
            if alpha > 0.001 { // Use a small threshold to avoid floating point issues.
                // If visible, populate the instance data for this circle at the current active index.
                instanceDataPtr[currentInstanceCount] = InstanceData(
                    offset: circleCenters[i],
                    scale: scale * alpha, // Fade in scale along with alpha for a smoother appearance
                    alpha: alpha
                )
                currentInstanceCount += 1 // Increment the count of active instances.
            }
            
            // Further Optimization Checks: Break early if no more circles could possibly be visible yet.
            if alpha <= 0.001 && i >= 6 && currentTime < timeFlowerStart {
                // If we are past the Seed circles (i>=6), current alpha is near zero, and the Flower phase hasn't started,
                // then no subsequent circles will be visible yet.
                break
            }
            if alpha <= 0.001 && i > 0 && currentTime < timeSeedStart {
                // If we are past the center circle (i>0), current alpha is near zero, and the Seed phase hasn't started,
                // then no subsequent circles will be visible yet.
                break
            }
        }
        
        // Store the final count of active instances for the draw call.
        self.lastCalculatedInstanceCount = currentInstanceCount
    }
    
    // MARK: - MTKViewDelegate Methods
    
    /// Called whenever the `MTKView`'s drawable size (resolution) changes (e.g., orientation change, window resize).
    /// Updates the `aspectRatio` needed for the projection matrix.
    /// - Parameters:
    ///   - view: The `MTKView` whose size changed.
    ///   - size: The new drawable size in pixels.
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Avoid division by zero if height is 0 during setup.
        aspectRatio = Float(size.width / max(1.0, size.height))
        print("MTKView size changed, updated aspect ratio to: \(aspectRatio)")
    }
    
    /// Called for every frame that needs to be rendered.
    /// This is the main drawing loop where commands are encoded and sent to the GPU.
    /// - Parameter view: The `MTKView` requesting the drawing.
    func draw(in view: MTKView) {
        // 1. Preliminary checks: Ensure essential components are available before proceeding.
        // Check if pipeline state has been created (depends on MTKView configuration).
         guard let pipelineState = pipelineState,
               // Check if buffers have been created.
               let circleVertexBuffer = circleVertexBuffer,
               let circleIndexBuffer = circleIndexBuffer,
               let uniformBuffer = uniformBuffer,
               let instanceDataBuffer = instanceDataBuffer else {
             print("Error: Renderer not fully initialized (pipeline or buffers missing). Skipping draw.")
             return // Skip drawing if essential components are not ready.
         }

        // 2. Obtain necessary objects for rendering for this frame.
        guard let drawable = view.currentDrawable, // Represents the texture to draw into.
              let renderPassDescriptor = view.currentRenderPassDescriptor, // Describes attachments (color, depth, stencil).
              let commandBuffer = commandQueue.makeCommandBuffer(), // Container for encoded commands.
              // Use the render pass descriptor to create an encoder.
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            print("Error: Failed to get resources for drawing.")
            return
        }
        
        // Configure the clear color for the background when the render pass begins.
        // Matches the SwiftUI background for seamless look.
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
        // Load action: Clear the texture at the start of the render pass.
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        // Store action: Store the rendered result in the texture.
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        // 3. Update dynamic data (Uniforms and Instance Data)
        updateState() // This calculates uniforms, instance data, and `lastCalculatedInstanceCount`.
        
        // Use the instance count calculated and stored during `updateState`.
        let visibleInstanceCount = self.lastCalculatedInstanceCount
        
        // 4. Encode Rendering Commands (only if there are visible instances)
        if visibleInstanceCount > 0 {
            renderEncoder.label = "Flower of Life Render Encoder" // For debugging in Metal frame capture.
            
            // Set the active render pipeline state.
            renderEncoder.setRenderPipelineState(pipelineState)
            
            // Bind the necessary data buffers to the correct indices expected by the vertex shader.
            renderEncoder.setVertexBuffer(circleVertexBuffer, offset: 0, index: 0) // Base circle vertices -> buffer(0)
            renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)      // Uniforms -> buffer(1)
            renderEncoder.setVertexBuffer(instanceDataBuffer, offset: 0, index: 2) // Instance data array -> buffer(2)
            
            // **** Issue the Instanced Draw Call ****
            // Draw the geometry defined by the index buffer.
            renderEncoder.drawIndexedPrimitives(type: .lineStrip, // Draw as connected lines.
                                                // Number of indices from the index buffer to use (all of them for the full circle).
                                                indexCount: circleIndices.count,
                                                // Data type of the indices.
                                                indexType: .uint16,
                                                // The buffer containing the indices.
                                                indexBuffer: circleIndexBuffer,
                                                // Offset within the index buffer to start reading from.
                                                indexBufferOffset: 0,
                                                // **** Key for Instancing ****
                                                // Number of instances to draw using the base geometry.
                                                instanceCount: visibleInstanceCount)
        } else {
            // If no instances are visible (e.g., before animation starts), we don't need to issue a draw call.
            // The clear color will still be applied due to the load action.
        }
        
        // 5. Finalize Encoding and Command Buffer
        renderEncoder.endEncoding() // Signal that command encoding is finished for this pass.
        
        // Schedule the drawable to be presented onscreen after the command buffer completes execution.
        commandBuffer.present(drawable)
        
        // Commit the command buffer to the command queue to be sent to the GPU for execution.
        commandBuffer.commit()
        // commandBuffer.waitUntilCompleted() // Optional: For debugging or strict synchronization, but generally avoid in production.
    }
}

// MARK: - SwiftUI UIViewRepresentable Wrapper

/// A SwiftUI `UIViewRepresentable` that wraps the `MTKView` and manages the `FlowerOfLifeRenderer`.
/// This acts as the bridge between the Metal rendering world and the SwiftUI view hierarchy.
struct MetalFlowerViewRepresentable: UIViewRepresentable {
    /// The type of UIKit view being represented (`MTKView`).
    typealias UIViewType = MTKView
    
    /// Creates the custom coordinator object.
    /// The coordinator is responsible for handling the Metal rendering logic (`FlowerOfLifeRenderer`)
    /// and acting as the delegate for the `MTKView`.
    /// - Parameter context: The context provided by SwiftUI.
    /// - Returns: An initialized `FlowerOfLifeRenderer` instance.
    func makeCoordinator() -> FlowerOfLifeRenderer {
        // Attempt to get the default Metal device.
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device.")
        }
        // Attempt to initialize the custom renderer.
        guard let coordinator = FlowerOfLifeRenderer(device: device) else {
            fatalError("Failed to initialize FlowerOfLifeRenderer.")
        }
        print("Coordinator (FlowerOfLifeRenderer) created.")
        return coordinator
    }
    
    /// Creates and configures the underlying UIKit view (`MTKView`).
    /// This method is called only once when the view is first added to the SwiftUI hierarchy.
    /// - Parameter context: The context containing the coordinator and environment information.
    /// - Returns: A configured `MTKView` instance.
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        // Assign the Metal device from the coordinator to the view.
        mtkView.device = context.coordinator.device
        // Set the desired frame rate.
        mtkView.preferredFramesPerSecond = 60
        // Allow the view to manage its own display loop via the delegate (`draw(in:)`).
        mtkView.enableSetNeedsDisplay = false
        // Ensure delegate drawing is enabled for the coordinator to receive callbacks.
        mtkView.isPaused = false // Ensure view is not paused
        
        // Set the view's pixel format (ensure consistency with pipeline state setup).
        // sRGB is commonly used for color UI elements.
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        // We don't need a depth buffer for this simple 2D drawing.
        mtkView.depthStencilPixelFormat = .invalid
        
        // Assign the coordinator as the delegate to handle drawing and size changes.
        mtkView.delegate = context.coordinator
        
        // **Crucially, configure the renderer's pipeline AFTER the view is set up**,
        // as the pipeline needs the view's pixel format.
        context.coordinator.configure(metalKitView: mtkView)
        
        // Perform an initial size update using the view's current drawable size.
        // Check if drawableSize is valid before calling the delegate method
        if mtkView.drawableSize.width > 0 && mtkView.drawableSize.height > 0 {
            context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        } else {
             print("Warning: MTKView initial drawableSize is zero or invalid.")
             // Consider setting a default aspectRatio or delaying the first update if safe.
             // context.coordinator.aspectRatio = 1.0 // Example default
         }
        
        print("MTKView created and configured for Flower of Life.")
        return mtkView
    }
    
    /// Updates the state of the `MTKView` when relevant SwiftUI state changes.
    /// For this specific view, the animation is driven internally by time within the renderer,
    /// so no external state changes from SwiftUI need to be passed down.
    /// - Parameters:
    ///   - uiView: The `MTKView` instance.
    ///   - context: The context containing the coordinator and environment information.
    func updateUIView(_ uiView: MTKView, context: Context) {
        // No external state updates required for this self-animating view.
        // If SwiftUI state needed to influence the Metal rendering (e.g., change color, speed),
        // you would pass that information to the coordinator here.
        // Example: context.coordinator.updateColor(newColor)
    }
}

// MARK: - Main SwiftUI View

/// The main SwiftUI `View` that incorporates the Metal rendering.
struct FlowerOfLifeView: View {
    var body: some View {
        // Use a VStack to potentially add other UI elements above/below the Metal view.
        VStack(spacing: 0) { // No spacing between title and Metal view
            // Simple title bar
            Text("Flower of Life Animation (Metal)")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity) // Take full width
                .background(Color(red: 0.05, green: 0.05, blue: 0.1)) // Match Metal clear color
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 1.0)) // Match Metal line color
            
            // Embed the Metal view using the representable wrapper.
            MetalFlowerViewRepresentable()
                // The representable will automatically size to fit the available space.
        }
        // Set the background for the entire VStack area
        .background(Color(red: 0.05, green: 0.05, blue: 0.1))
        // Ignore safe area for keyboard to prevent layout shifts if one appears.
        .ignoresSafeArea(.keyboard)
        // Allow the view content (especially the Metal part) to extend to the bottom edge.
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Preview Provider

/// Provides previews for the `FlowerOfLifeView` in Xcode.
#Preview {
    // NOTE: Metal previews can sometimes be unreliable or slow in Xcode.
    // Running on a real device or simulator is often more stable.
    
    // Option 1: Placeholder View (Safer for complex Metal views)
    //    struct PreviewPlaceholder: View {
    //        var body: some View {
    //            VStack(spacing: 0) {
    // A title matching the actual view's title
    //                Text("Flower of Life Animation (Metal)")
    //                    .font(.headline)
    //                    .padding()
    //                    .frame(maxWidth: .infinity)
    //                    .background(Color(red: 0.05, green: 0.05, blue: 0.1))
    //                    .foregroundColor(Color(red: 0.8, green: 0.8, blue: 1.0))
    //
    //                Spacer() // Use Spacer to push placeholder text to center
    //                Text("Metal View Placeholder\n(Flower of Life Animation)")
    //                    .foregroundColor(.gray)
    //                    .multilineTextAlignment(.center)
    //                    .padding()
    //                Spacer()
    //            }
    //            .frame(maxWidth: .infinity, maxHeight: .infinity) // Take full space
    //            .background(Color(red: 0.05, green: 0.05, blue: 0.1)) // Match background
    //            .edgesIgnoringSafeArea(.all) // Ignore safe areas like the placeholder
    //        }
    //    }
    // Uncomment the line below to use the placeholder
    // return PreviewPlaceholder()
    
    // Option 2: Attempt to preview the actual Metal view
    // This might work but can be resource-intensive or fail in some Xcode versions/configurations.
    return FlowerOfLifeView()
}

// MARK: - Matrix Math Helper Functions (using SIMD)

/// Creates an orthographic projection matrix (Left-Handed convention often used with Metal).
/// Maps view-space coordinates directly to Metal's Normalized Device Coordinates (NDC) [-1, 1] range for X and Y,
/// and typically [0, 1] for Z, without perspective distortion. Adjusts scale based on aspect ratio to prevent stretching.
///
/// - Parameters:
///   - aspectRatio: The width-to-height ratio (`width / height`) of the viewport.
///   - nearZ: The near clipping plane (defaults to -1). Objects closer than this are clipped.
///   - farZ: The far clipping plane (defaults to 1). Objects farther than this are clipped.
/// - Returns: A `matrix_float4x4` representing the orthographic projection transformation.
func matrix_orthographic_projection(aspectRatio: Float, nearZ: Float = -1.0, farZ: Float = 1.0) -> matrix_float4x4 {
    // Determine the scaling needed to map world units [-scale, scale] to NDC [-1, 1].
    // The `overallScale` controls the "zoom" level. Larger values zoom out, smaller values zoom in.
    // Using 1/2.5 means world y-coordinates from -2.5 to 2.5 will fit within the [-1, 1] NDC range.
    let overallScale: Float = 1.0 / 2.5

    // Calculate base scaling factors based on the overall zoom.
    var scaleX = overallScale
    var scaleY = overallScale

    // Adjust scaling based on aspect ratio to prevent distortion.
    if aspectRatio > 0 { // Ensure aspectRatio is valid before using it
        if aspectRatio > 1.0 {
            // View is wider than tall: Reduce horizontal scale (squeeze horizontally)
            scaleX /= aspectRatio
        } else {
            // View is taller than wide (or square): Reduce vertical scale (squeeze vertically)
            scaleY *= aspectRatio
        }
    } else {
         print("Warning: Invalid aspect ratio (\(aspectRatio)) in projection matrix calculation.")
         // Handle invalid aspect ratio, e.g., assume square (1.0) or keep unscaled
         // scaleX = overallScale
         // scaleY = overallScale
     }

    // Calculate Z-axis scaling and translation to map [nearZ, farZ] -> [0, 1] (Metal's usual NDC Z range).
    let scaleZ = 1.0 / (farZ - nearZ)
    let translateZ = -nearZ * scaleZ

    // Construct the column-major orthographic projection matrix.
    // Remember `simd` matrices are column-major!
    return matrix_float4x4(
        // Column 0: X-scaling and aspect ratio correction
        SIMD4<Float>(scaleX, 0, 0, 0),
        // Column 1: Y-scaling and aspect ratio correction
        SIMD4<Float>(0, scaleY, 0, 0),
        // Column 2: Z-scaling for depth remapping
        SIMD4<Float>(0, 0, scaleZ, 0),
        // Column 3: Z-translation for depth remapping and the W component
        SIMD4<Float>(0, 0, translateZ, 1)
    )
}

/// Smoothly interpolates between 0.0 and 1.0 as `x` moves between `edge0` and `edge1`.
/// Creates an ease-in/ease-out effect, useful for smooth animation transitions.
/// - Parameters:
///   - edge0: The value of `x` where the transition begins (output starts smoothly increasing from 0.0).
///   - edge1: The value of `x` where the transition ends (output smoothly reaches 1.0).
///   - x: The current input value to check against the edges.
/// - Returns: A Float between 0.0 and 1.0, representing the smoothed interpolation factor.
func smoothstep(_ edge0: Float, _ edge1: Float, _ x: Float) -> Float {
    // Avoid division by zero if edges are equal.
    let denominator = edge1 - edge0
    // Add a small epsilon or check for zero to prevent NaN issues.
    guard abs(denominator) > .ulpOfOne else { return x < edge0 ? 0.0 : 1.0 }

    // Clamp x to the range [edge0, edge1] and normalize to [0, 1]
    let t = clamp((x - edge0) / denominator, 0.0, 1.0)

    // Apply the smoothstep formula: 3t^2 - 2t^3 (or t*t*(3-2t))
    return t * t * (3.0 - 2.0 * t)
}

/// Clamps a value `x` to be within the range [`lower`, `upper`].
/// - Parameters:
///   - x: The value to clamp.
///   - lower: The minimum allowed value.
///   - upper: The maximum allowed value.
/// - Returns: The clamped value, guaranteed to be between `lower` and `upper` (inclusive).
func clamp(_ x: Float, _ lower: Float, _ upper: Float) -> Float {
    return min(upper, max(lower, x))
}
