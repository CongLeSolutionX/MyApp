////
////  TheSeedOfLifeView.swift
////  MyApp
////
////  Created by Cong Le on 5/3/25.
////
//
////  Description:
////  Renders the "Seed of Life" sacred geometry pattern using Metal within a SwiftUI view.
////  This implementation draws a full-screen quad and uses the fragment shader
////  to calculate whether each pixel falls inside one of the 7 overlapping circles.
////
////  Demonstrates:
////  - Embedding MTKView in SwiftUI via UIViewRepresentable.
////  - Minimal vertex shader for a full-screen quad.
////  - Fragment shader performing geometric calculations (distance checks).
////  - Passing uniform data (viewport size, geometry parameters) to shaders.
////  - Dynamic calculation of circle positions based on view size.
////
//import SwiftUI
//import MetalKit
//import simd
//
//// MARK: - Metal Shaders (Seed of Life)
//
///// Metal shader source code for rendering the Seed of Life pattern.
//let seedOfLifeMetalShaderSource = """
//#include <metal_stdlib>
//
//using namespace metal;
//
//// Simple vertex structure for the full-screen quad.
//// Only position is needed as geometry is calculated in the fragment shader.
//struct QuadVertex {
//    float4 position [[position]]; // Clip space position (-1 to 1)
//};
//
//// Uniform data passed from CPU to the fragment shader.
//struct SeedOfLifeUniforms {
//    float2 viewportSize; // Dimensions of the view in pixels (width, height)
//    float radius;        // Radius of each circle in pixels
//    // Array holding the center positions of the 7 circles in pixel coordinates.
//    // Note: Metal arrays in buffers often require careful alignment. Using float2x4 might be safer
//    // if alignment issues arise, but float2[7] *might* work directly depending on shader compiler.
//    // Using packed_float2 avoids padding issues. Or pass centers individually if array fails.
//    packed_float2 centers[7]; // Center coordinates (x, y) for the 7 circles
//    float4 fillColor;    // Color to draw the circles (RGBA)
//    float edgeSoftness;  // Controls the anti-aliasing width (in pixels)
//};
//
//// --- Vertex Shader (Pass-through for Quad) ---
//// Takes hardcoded quad vertices and passes them directly to rasterization.
//vertex QuadVertex seed_of_life_vertex_shader(
//    unsigned int vid [[vertex_id]] // System-generated index of the current vertex
//) {
//    // Define the 4 vertices of a full-screen quad in clip space coordinates.
//    // These form two triangles covering the entire screen.
//    float4 positions[6] = {
//        float4(-1.0, -1.0, 0.0, 1.0), // Triangle 1: V0 (Bottom Left)
//        float4( 1.0, -1.0, 0.0, 1.0), // Triangle 1: V1 (Bottom Right)
//        float4(-1.0,  1.0, 0.0, 1.0), // Triangle 1: V2 (Top Left)
//
//        float4( 1.0, -1.0, 0.0, 1.0), // Triangle 2: V3 (Bottom Right)
//        float4( 1.0,  1.0, 0.0, 1.0), // Triangle 2: V4 (Top Right)
//        float4(-1.0,  1.0, 0.0, 1.0)  // Triangle 2: V5 (Top Left)
//    };
//
//    QuadVertex out;
//    out.position = positions[vid]; // Select the vertex based on vertex ID
//    return out;
//}
//
//// --- Fragment Shader (Seed of Life Geometry) ---
//// Calculates if the current fragment (pixel) is inside any of the 7 circles.
//fragment half4 seed_of_life_fragment_shader(
//    // Input: Built-in fragment position in pixel coordinates (origin likely top-left or bottom-left).
//    float4 fragCoord [[position]],
//    // Input: Uniform data containing geometry parameters.
//    // [[buffer(0)]] binds to the buffer set at index 0 in the encoder.
//    constant SeedOfLifeUniforms &uniforms [[buffer(0)]]
//) {
//    // Get the 2D pixel coordinates of the current fragment.
//    float2 pixelPos = fragCoord.xy;
//
//    // Calculate the minimum signed distance from the pixel to the edge of *any* circle.
//    // A negative distance means inside, positive means outside.
//    float minSignedDistance = 1e9; // Initialize with a large positive value
//
//    for (int i = 0; i < 7; ++i) {
//        // Calculate distance from current pixel to the center of circle 'i'.
//        float dist = distance(pixelPos, float2(uniforms.centers[i]));
//        // Signed distance: distance - radius. Negative if inside.
//        float signedDist = dist - uniforms.radius;
//        // Keep track of the minimum signed distance (closest the pixel is to being inside any circle edge).
//        minSignedDistance = min(minSignedDistance, signedDist);
//    }
//
//    // --- Anti-aliasing (Smooth Edge) ---
//    // Calculate alpha based on the minimum signed distance.
//    // smoothstep(edge0, edge1, x): Returns 0 if x <= edge0, 1 if x >= edge1, smooth interpolation between.
//    // We want alpha=1 deep inside (large negative distance) and alpha=0 far outside (large positive distance).
//    // The transition occurs over a range defined by 'edgeSoftness'.
//    half alpha = half(1.0 - smoothstep(0.0, uniforms.edgeSoftness, minSignedDistance));
//
//    // --- Determine Final Color ---
//    // If alpha is near zero, discard the fragment to avoid unnecessary blending.
//    if (alpha < 0.01h) {
//        discard_fragment();
//    }
//
//    // Otherwise, return the fill color modulated by the calculated alpha for smooth edges.
//    return half4(uniforms.fillColor.rgb, uniforms.fillColor.a * alpha);
//}
//"""
//
//// MARK: - Swift Data Structures (Matching Shaders)
//
///// Swift structure mirroring the `SeedOfLifeUniforms` struct in the Metal shader.
///// Needs careful consideration of memory layout/packing if issues arise.
//struct SeedOfLifeUniforms {
//    /// Viewport dimensions in pixels (width, height).
//    var viewportSize: SIMD2<Float> = .zero
//    /// Radius of each circle in pixels.
//    var radius: Float = 0.0
//    /// Array storing the 7 circle center positions (x, y) in pixel coordinates.
//    /// Using `SIMD2<Float>` which should align well. Size needs to match shader array size (7).
//    var centers: (SIMD2<Float>, SIMD2<Float>, SIMD2<Float>, SIMD2<Float>, SIMD2<Float>, SIMD2<Float>, SIMD2<Float>) = (.zero, .zero, .zero, .zero, .zero, .zero, .zero)
//    /// RGBA color for the circles.
//    var fillColor: SIMD4<Float> = SIMD4<Float>(1.0, 0.84, 0.0, 1.0) // Default: Gold
//    /// Width of the anti-aliased edge in pixels.
//    var edgeSoftness: Float = 1.5 // Smooth edge over ~1.5 pixels
//    
//    // Helper to get the centers as a standard array for buffer copying if needed,
//    // though direct struct copy should work if layout matches shader expectation.
//    func getCentersArray() -> [SIMD2<Float>] {
//        return [centers.0, centers.1, centers.2, centers.3, centers.4, centers.5, centers.6]
//    }
//}
//
///// Simple structure for the quad vertices (only position needed).
///// Matches the passthrough vertex shader input, though the shader itself hardcodes positions.
///// We still create a small dummy buffer for formality if needed by pipeline setup.
//struct QuadVertex {
//    var position: SIMD4<Float> // Not strictly used if shader hardcodes, but defines layout
//}
//
//// MARK: - Renderer Class (Handles Metal Logic for Seed of Life)
//
//class SeedOfLifeRenderer: NSObject, MTKViewDelegate {
//    let device: MTLDevice
//    let commandQueue: MTLCommandQueue
//    var pipelineState: MTLRenderPipelineState!
//    // No depth state needed for this 2D fragment-based drawing unless layering complex scenes
//    // var depthState: MTLDepthStencilState! // Removed for simplicity
//
//    // No vertex/index buffer needed for complex geometry
//    // We might need a tiny dummy buffer if the pipeline requires *some* vertex buffer bound.
//    var dummyVertexBuffer: MTLBuffer! // Optional, potentially unused buffer
//    
//    /// GPU buffer holding the uniform data (viewport, radius, centers, color).
//    var uniformBuffer: MTLBuffer!
//
//    /// Structure holding the current uniform values to be copied to the GPU buffer.
//    var uniforms = SeedOfLifeUniforms()
//
//    /// Size of the drawable area in pixels. Used to calculate circle positions.
//    var viewportSize: CGSize = .zero
//
//    /// Initializes the renderer with a Metal device.
//    init?(device: MTLDevice) {
//        self.device = device
//        guard let queue = device.makeCommandQueue() else { return nil }
//        self.commandQueue = queue
//        super.init()
//
//        setupBuffers()
//        // setupDepthStencil() // Not needed for this basic 2D render
//    }
//
//    /// Configures the Metal pipeline state after the MTKView is ready.
//    func configure(metalKitView: MTKView) {
//        setupPipeline(metalKitView: metalKitView)
//    }
//
//    // --- Setup Functions ---
//
//    func setupPipeline(metalKitView: MTKView) {
//        do {
//            let library = try device.makeLibrary(source: seedOfLifeMetalShaderSource, options: nil)
//            guard let vertexFunction = library.makeFunction(name: "seed_of_life_vertex_shader"),
//                  let fragmentFunction = library.makeFunction(name: "seed_of_life_fragment_shader") else {
//                fatalError("Could not load shader functions.")
//            }
//
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Seed of Life Pipeline"
//            pipelineDescriptor.vertexFunction = vertexFunction
//            pipelineDescriptor.fragmentFunction = fragmentFunction
//            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
//             // Set up blending for smooth edges (alpha blending)
//            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
//            pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
//            pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
//            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
//            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
//            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
//            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
//
//            // No depth buffer needed for this render
//            // pipelineDescriptor.depthAttachmentPixelFormat = .invalid
//             
//            // No complex vertex descriptor needed as shader hardcodes quad positions
//            // let vertexDescriptor = MTLVertexDescriptor() ...
//            // pipelineDescriptor.vertexDescriptor = vertexDescriptor
//
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//        } catch {
//            fatalError("Failed to create Seed of Life Render Pipeline State: \(error)")
//        }
//    }
//
//    func setupBuffers() {
//        // Uniform Buffer - Size must accommodate the SeedOfLifeUniforms struct
//        // Calculate size based on the Swift struct definition.
//        // Alignment rules might make `MemoryLayout<SeedOfLifeUniforms>.stride` safer than `.size`.
//         let uniformBufferSize = MemoryLayout<SeedOfLifeUniforms>.stride
//        guard let uBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared) else {
//            fatalError("Could not create uniform buffer")
//        }
//        uniformBuffer = uBuffer
//        uniformBuffer.label = "Seed of Life Uniforms"
//
//        // Dummy Vertex Buffer (Optional - might not be strictly needed if shader hardcodes)
//        // Create a tiny buffer just in case the pipeline validation requires *a* vertex buffer bound.
//        let dummyVertexData: [Float] = [0.0] // Minimal data
//         if let vBuffer = device.makeBuffer(bytes: dummyVertexData, length: MemoryLayout<Float>.size, options: []) {
//             dummyVertexBuffer = vBuffer
//             dummyVertexBuffer.label = "Dummy Vertex Buffer"
//        } else {
//             print("Warning: Could not create dummy vertex buffer.")
//        }
//    }
//
//    /* // Depth buffer setup removed - not needed for this 2D render
//    func setupDepthStencil() {
//        let depthDescriptor = MTLDepthStencilDescriptor()
//        depthDescriptor.depthCompareFunction = .less
//        depthDescriptor.isDepthWriteEnabled = true
//        guard let state = device.makeDepthStencilState(descriptor: depthDescriptor) else {
//            fatalError("Failed to create depth stencil state")
//        }
//        depthState = state
//    }
//    */
//
//    // --- Update State Per Frame ---
//
//    /// Calculates the geometry parameters (radius, centers) based on the current view size
//    /// and updates the uniform buffer.
//    func updateUniforms() {
//        guard viewportSize.width > 0 && viewportSize.height > 0 else { return }
//
//        uniforms.viewportSize = SIMD2<Float>(Float(viewportSize.width), Float(viewportSize.height))
//
//        // --- Calculate Seed of Life Geometry ---
//        // Determine the overall scale based on the smaller dimension of clamped viewport
//        let clampedWidth = max(1.0, viewportSize.width)
//        let clampedHeight = max(1.0, viewportSize.height)
//        let minDimension = min(clampedWidth, clampedHeight)
//        
//        // The Seed of Life fits within a bounding circle. Let the radius of one circle
//        // be a fraction of the minimum dimension. The whole pattern spans roughly 4 radii vertically/horizontally
//        // if centered correctly (center-to-center distance = Radius).
//        // Let's make the pattern occupy about 80% of the minimum dimension.
//        // Total span approx 4 * Radius, so make 4 * Radius = 0.8 * minDimension
//        let calculatedRadius = Float(0.8 * minDimension / 4.0)
//        uniforms.radius = calculatedRadius
//
//        // Center the pattern in the viewport
//        let centerX = Float(clampedWidth / 2.0)
//        let centerY = Float(clampedHeight / 2.0)
//        let centerPoint = SIMD2<Float>(centerX, centerY)
//
//        // Calculate the 7 center positions relative to the viewport center
//        // using the calculated radius as the distance between centers.
//        let r = calculatedRadius
//        let angleStep = Float.pi * 2.0 / 6.0 // 60 degrees
//        
//        uniforms.centers.0 = centerPoint // Central circle
//
//        for i in 0..<6 {
//            let angle = angleStep * Float(i) // Angle for this outer circle
//            let offsetX = r * cos(angle)
//            let offsetY = r * sin(angle) // Use sin for Y (standard polar to Cartesian)
//            let outerCenter = centerPoint + SIMD2<Float>(offsetX, offsetY)
//
//            // Assign to the correct tuple element (1-based index for outer circles)
//            switch i {
//                case 0: uniforms.centers.1 = outerCenter
//                case 1: uniforms.centers.2 = outerCenter
//                case 2: uniforms.centers.3 = outerCenter
//                case 3: uniforms.centers.4 = outerCenter
//                case 4: uniforms.centers.5 = outerCenter
//                case 5: uniforms.centers.6 = outerCenter
//                default: break // Should not happen
//            }
//        }
//        
//        uniforms.fillColor = SIMD4<Float>(1.0, 0.843, 0.0, 1.0) // Gold color (Red=1.0, Green=~0.84, Blue=0.0)
//        uniforms.edgeSoftness = 1.5 // Keep edge softness reasonable
//
//        // --- Copy to GPU Buffer ---
//        let bufferPointer = uniformBuffer.contents()
//        // Use stride for safety with potential struct padding
//        memcpy(bufferPointer, &uniforms, MemoryLayout<SeedOfLifeUniforms>.stride)
//
//    }
//
//    // MARK: - MTKViewDelegate Methods
//
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        // Store the new size to recalculate geometry in updateUniforms
//        viewportSize = size
//        print("SeedOfLife MTKView Resized - New Size: \(size)")
//    }
//
//    func draw(in view: MTKView) {
//        guard let drawable = view.currentDrawable,
//              // Use clear color defined on the view itself
//              let renderPassDescriptor = view.currentRenderPassDescriptor,
//              let commandBuffer = commandQueue.makeCommandBuffer(),
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//            print("Failed to get required Metal objects in draw(in:).")
//            return
//        }
//
//        // --- Update ---
//        updateUniforms() // Calculate geometry based on current size and update buffer
//
//        // --- Encode ---
//        renderEncoder.label = "Seed of Life Render Encoder"
//        renderEncoder.setRenderPipelineState(pipelineState)
//        // renderEncoder.setDepthStencilState(depthState) // Removed
//
//         // Bind the uniform buffer to the *fragment* shader stage at index 0
//        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
//        
//        // Bind the dummy vertex buffer if needed by pipeline state validation
//        // If rendering works without this, it can be removed.
//        // if let dummyVertexBuffer = dummyVertexBuffer {
//        //     renderEncoder.setVertexBuffer(dummyVertexBuffer, offset: 0, index: 0)
//        // }
//
//        // --- Draw Call ---
//        // Draw the full-screen quad (2 triangles = 6 vertices).
//        // The vertex shader will use [[vertex_id]] to generate the correct clip space positions.
//        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
//
//        // --- Finalize ---
//        renderEncoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//}
//
//// MARK: - SwiftUI UIViewRepresentable Bridge
//
//struct MetalSeedOfLifeViewRepresentable: UIViewRepresentable {
//    typealias UIViewType = MTKView
//
//    func makeCoordinator() -> SeedOfLifeRenderer {
//        guard let device = MTLCreateSystemDefaultDevice() else {
//            fatalError("Metal is not supported on this device.")
//        }
//        guard let coordinator = SeedOfLifeRenderer(device: device) else {
//            fatalError("SeedOfLifeRenderer failed to initialize.")
//        }
//        print("SeedOfLife Coordinator created.")
//        return coordinator
//    }
//
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//        mtkView.device = context.coordinator.device
//        mtkView.preferredFramesPerSecond = 60 // Keep interactive frame rate
//        mtkView.enableSetNeedsDisplay = false // Use delegate's draw method
//
//        // Configure pixel formats - NO depth buffer needed here
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb // Standard color format
//        mtkView.depthStencilPixelFormat = .invalid // Explicitly disable depth/stencil
//
//        // Set clear color (background)
//        mtkView.clearColor = MTLClearColor(red: 0.05, green: 0.0, blue: 0.1, alpha: 1.0) // Dark blue/purple
//
//        // Configure pipeline *after* view's formats are set
//        context.coordinator.configure(metalKitView: mtkView)
//        mtkView.delegate = context.coordinator
//
//        // Trigger initial size update
//        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
//
//        print("SeedOfLife MTKView created and configured.")
//        return mtkView
//    }
//
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // No external state updates needed in this version.
//    }
//}
//
//// MARK: - Main SwiftUI View
//
//struct SeedOfLifeView: View {
//    var body: some View {
//        VStack(spacing: 0) {
//            Text("Seed of Life (Metal)")
//                .font(.headline)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color(red: 0.05, green: 0.0, blue: 0.1)) // Match Metal clear color
//                .foregroundColor(.white)
//
//            MetalSeedOfLifeViewRepresentable()
//                // Use .aspectRatio to maintain shape if desired, or let it fill.
//                 .aspectRatio(1.0, contentMode: .fit) // Make it square if space allows
//                 .background(Color(red: 0.05, green: 0.0, blue: 0.1)) // Ensure background consistency
//
//        }
//        .background(Color(red: 0.05, green: 0.0, blue: 0.1)) // Background for the VStack container
//        .ignoresSafeArea(.keyboard)
//    }
//}
//
//// MARK: - Preview Provider
//
//#Preview {
//    // Use a placeholder for safety in previews, as Metal often fails.
//    struct PreviewPlaceholder: View {
//        var body: some View {
//            VStack {
//                 Text("Seed of Life (Metal)")
//                    .font(.headline)
//                    .padding()
//                    .foregroundColor(.white)
//                 Spacer()
//                 Text("Metal View Placeholder\n(Run on Simulator or Device)")
//                    .foregroundColor(.gray).italic().multilineTextAlignment(.center).padding()
//                 Spacer()
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color(red: 0.05, green: 0.0, blue: 0.1))
//            .edgesIgnoringSafeArea(.all)
//        }
//    }
//     return PreviewPlaceholder() // <-- Recommended for stability
//
//     //return SeedOfLifeView() // <-- Uncomment to attempt rendering the actual view
//}
//
//// Note: Matrix math helper functions removed as they are not needed for this 2D implementation.
