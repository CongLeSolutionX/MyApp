////
////  RetroGridBackgroundView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//import MetalKit
//import simd // Import for SIMD types like matrix_float4x4
//
//// MARK: - Main SwiftUI View
//struct RetroBackgroundView: View {
//    var body: some View {
//        MetalViewRepresentable()
//            .edgesIgnoringSafeArea(.all) // Make it a background
//            .overlay( // Example overlay content
//                Text("Retro Grid\nby CongLeSolutionX")
//                    .font(.system(size: 40, weight: .bold, design: .monospaced))
//                    .foregroundColor(.white.opacity(0.8))
//                    .shadow(color: .cyan.opacity(0.7), radius: 10, x: 0, y: 0)
//                    .padding(.top, 50), // Position the text
//                alignment: .top
//            )
//    }
//}
//
//#Preview("Retro Background View") {
//    RetroBackgroundView()
//}
//
//// MARK: - SwiftUI <-> UIKit Bridge (No significant changes needed here)
//struct MetalViewRepresentable: UIViewRepresentable {
//    func makeCoordinator() -> Renderer {
//        Renderer()
//    }
//    
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//        mtkView.delegate = context.coordinator
//        mtkView.enableSetNeedsDisplay = true
//        
//        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
//            fatalError("Metal is not supported on this device")
//        }
//        mtkView.device = metalDevice
//        context.coordinator.setup(device: metalDevice, view: mtkView)
//        
//        mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
//        mtkView.colorPixelFormat = .bgra8Unorm
//        mtkView.drawableSize = mtkView.frame.size // Set initial size
//        
//#if targetEnvironment(simulator)
//        print("Warning: Metal performance and features might be limited in the simulator.")
//#endif
//        
//        return mtkView
//    }
//    
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // Ensure drawableSize is updated correctly on rotation or layout changes
//        if uiView.drawableSize != context.coordinator.drawableSize {
//            uiView.drawableSize = uiView.frame.size
//            context.coordinator.updateDrawableSize(uiView.drawableSize)
//        }
//        // Trigger redraw if needed based on state changes (if enableSetNeedsDisplay = false)
//        uiView.setNeedsDisplay()
//    }
//}
//
//// MARK: - Metal Renderer Class
//class Renderer: NSObject, MTKViewDelegate {
//    var device: MTLDevice!
//    var commandQueue: MTLCommandQueue!
//    
//    // Use separate pipelines for clarity, even if shaders are similar
//    var skyPipelineState: MTLRenderPipelineState!
//    var horizonPipelineState: MTLRenderPipelineState!
//    var gridPipelineState: MTLRenderPipelineState!
//    var starPipelineState: MTLRenderPipelineState!
//    
//    // Buffers for vertex data
//    var skyVertexBuffer: MTLBuffer! // Quad (TriangleStrip)
//    var horizonVertexBuffer: MTLBuffer! // Line (LineStrip)
//    var gridVertexBuffer: MTLBuffer! // Lines (LineList)
//    var starVertexBuffer: MTLBuffer! // Points (Point)
//    var starInstanceCount: Int = 0
//    
//    // Uniforms (Data passed to shaders)
//    struct Uniforms {
//        var projectionMatrix: matrix_float4x4 = matrix_identity_float4x4
//        var viewMatrix: matrix_float4x4 = matrix_identity_float4x4
//        var viewportSize: vector_float2 = .zero
//        var currentTime: Float = 0.0
//    }
//    var uniforms = Uniforms()
//    
//    var drawableSize: CGSize = .zero
//    
//    // MARK: - Setup
//    func setup(device: MTLDevice, view: MTKView) {
//        self.device = device
//        self.commandQueue = device.makeCommandQueue()!
//        
//        // Load shaders once
//        guard let library = device.makeDefaultLibrary() else {
//            fatalError("Could not load default Metal library")
//        }
//        let vertexFunction = library.makeFunction(name: "vertexShader")
//        let fragmentFunction = library.makeFunction(name: "fragmentShader")
//        
//        // --- Pipeline States ---
//        skyPipelineState = createPipelineState(device: device, vertexFunc: vertexFunction, fragmentFunc: fragmentFunction, pixelFormat: view.colorPixelFormat, isPointRendering: false)
//        horizonPipelineState = createPipelineState(device: device, vertexFunc: vertexFunction, fragmentFunc: fragmentFunction, pixelFormat: view.colorPixelFormat, isPointRendering: false) // Use line primitive type later
//        gridPipelineState = createPipelineState(device: device, vertexFunc: vertexFunction, fragmentFunc: fragmentFunction, pixelFormat: view.colorPixelFormat, isPointRendering: false)    // Use line primitive type later
//        starPipelineState = createPipelineState(device: device, vertexFunc: vertexFunction, fragmentFunc: fragmentFunction, pixelFormat: view.colorPixelFormat, isPointRendering: true)    // Use point primitive type later
//        
//        // --- Vertex Data Setup ---
//        createSkyVertices()
//        createHorizonVertices()
//        createGridVertices()
//        createStarVertices()
//        
//        // Initial uniform setup
//        updateDrawableSize(view.drawableSize) // Calculate initial matrices
//    }
//    
//    // Helper to create pipeline states
//    func createPipelineState(device: MTLDevice, vertexFunc: MTLFunction?, fragmentFunc: MTLFunction?, pixelFormat: MTLPixelFormat, isPointRendering: Bool) -> MTLRenderPipelineState {
//        let pipelineDescriptor = MTLRenderPipelineDescriptor()
//        pipelineDescriptor.vertexFunction = vertexFunc
//        pipelineDescriptor.fragmentFunction = fragmentFunc
//        pipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
//        
//        // Add blending if needed for glow/transparency
//        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
//        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
//        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
//        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
//        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
//        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
//        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
//        
//        // Define vertex layout (Can be shared if vertex struct is consistent)
//        // Describe the vertex layout for the vertex descriptor
//        let vertexDescriptor = MTLVertexDescriptor()
//        // Attribute 0: Position (float4 or float3 depending on what you pass)
//        vertexDescriptor.attributes[0].format = .float4 // Using float4 for potential UVs / extra data
//        vertexDescriptor.attributes[0].offset = 0
//        vertexDescriptor.attributes[0].bufferIndex = 0 // Buffer index 0 for vertex data
//        
//        // Layout 0: Describes the structure of the data in buffer 0
//        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD4<Float>>.stride // Stride for float4
//        vertexDescriptor.layouts[0].stepRate = 1
//        vertexDescriptor.layouts[0].stepFunction = .perVertex
//        pipelineDescriptor.vertexDescriptor = vertexDescriptor
//        
//        // Enable point size control if drawing points
//        // pipelineDescriptor.isRasterizationEnabled = !isPointRendering // Maybe? Check docs
//        // pipelineDescriptor.maxVertexAmplificationCount // For geometry shaders if needed
//        
//        do {
//            return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//        } catch {
//            fatalError("Failed to create pipeline state: \(error)")
//        }
//    }
//    
//    // MARK: - Vertex Creation
//    func createSkyVertices() {
//        // Quad covering top ~70%, passing UVs in zw
//        let horizonY: Float = -0.4 // Adjust this to match grid perspective visually
//        let vertices: [SIMD4<Float>] = [
//            // X,    Y,      U, V
//            SIMD4<Float>(-1.0,  1.0,    0.0, 0.0), // Top Left
//            SIMD4<Float>( 1.0,  1.0,    1.0, 0.0), // Top Right
//            SIMD4<Float>(-1.0,  horizonY, 0.0, 1.0), // Bottom Left
//            SIMD4<Float>( 1.0,  horizonY, 1.0, 1.0), // Bottom Right
//        ]
//        skyVertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<SIMD4<Float>>.stride, options: .storageModeShared)
//    }
//    
//    func createHorizonVertices() {
//        // A single horizontal line segment where the grid meets the sky
//        let horizonY: Float = -0.4 // Should match sky bottom Y
//        let zPos: Float = 0 // Keep it simple in view space for fragment shader effect
//        let vertices: [SIMD3<Float>] = [
//            SIMD3<Float>(-1.0, horizonY, zPos), // Left
//            SIMD3<Float>( 1.0, horizonY, zPos), // Right
//        ]
//        // Pad to SIMD4 if needed by shader/vertex descriptor, putting 1 in W
//        let paddedVertices = vertices.map { SIMD4<Float>($0.x, $0.y, $0.z, 1.0) }
//        horizonVertexBuffer = device.makeBuffer(bytes: paddedVertices, length: paddedVertices.count * MemoryLayout<SIMD4<Float>>.stride, options: .storageModeShared)
//    }
//    
//    func createGridVertices() {
//        var gridLines: [SIMD3<Float>] = []
//        let gridSize: Float = 20.0 // How far the grid extends in X and Z
//        let lineCount: Int = 40 // Number of lines in each direction
//        
//        // Lines parallel to Z-axis (running away from viewer)
//        for i in 0...lineCount {
//            let x = -gridSize + (2.0 * gridSize * Float(i) / Float(lineCount))
//            gridLines.append(SIMD3<Float>(x, 0.0, 0.0)) // Start point near viewer
//            gridLines.append(SIMD3<Float>(x, 0.0, gridSize * 2.0)) // End point far away
//        }
//        
//        // Lines parallel to X-axis (horizontal lines getting closer)
//        for i in 1...lineCount { // Start from 1 to avoid drawing over horizon
//            let z = (gridSize * 2.0 * Float(i) / Float(lineCount)) * (Float(i) / Float(lineCount)) // Non-linear spacing
//            gridLines.append(SIMD3<Float>(-gridSize, 0.0, z)) // Left point
//            gridLines.append(SIMD3<Float>( gridSize, 0.0, z)) // Right point
//        }
//        
//        // Pad to SIMD4 if needed by shader/vertex descriptor, putting 1 in W
//        let paddedVertices = gridLines.map { SIMD4<Float>($0.x, $0.y, $0.z, 1.0) }
//        gridVertexBuffer = device.makeBuffer(bytes: paddedVertices, length: paddedVertices.count * MemoryLayout<SIMD4<Float>>.stride, options: .storageModeShared)
//    }
//    
//    func createStarVertices() {
//        var starData: [SIMD2<Float>] = [] // X, Y position
//        starInstanceCount = 300 // Number of stars
//        let horizonY: Float = -0.4 // Don't draw stars below horizon
//        
//        for _ in 0..<starInstanceCount {
//            let x = Float.random(in: -1.0...1.0)
//            let y = Float.random(in: horizonY * 0.9...1.0) // Keep stars above the horizon glow
//            starData.append(SIMD2<Float>(x, y))
//        }
//        // Pad to SIMD4 if needed by shader/vertex descriptor
//        let paddedVertices = starData.map { SIMD4<Float>($0.x, $0.y, Float.random(in: 1.0...3.0), 1.0) } // Use Z for Size
//        starVertexBuffer = device.makeBuffer(bytes: paddedVertices, length: paddedVertices.count * MemoryLayout<SIMD4<Float>>.stride, options: .storageModeShared)
//    }
//    
//    // MARK: - Size Update & Matrices
//    func updateDrawableSize(_ size: CGSize) {
//        if size.width <= 0 || size.height <= 0 {
//            print("Warning:Drawable size is zero or negative.")
//            return
//        }
//        self.drawableSize = size
//        uniforms.viewportSize = SIMD2<Float>(Float(size.width), Float(size.height))
//        updateProjectionMatrix(size: size)
//        updateViewMatrix()
//    }
//    
//    func updateProjectionMatrix(size: CGSize) {
//        let aspect = Float(size.width / size.height)
//        let fov = Float.pi / 2.5 // Wider FOV for perspective effect
//        let near: Float = 0.1
//        let far: Float = 100.0 // Increase far plane for distant grid lines
//        
//        let yScale = 1.0 / tan(fov * 0.5)
//        let xScale = yScale / aspect
//        let zRange = far - near
//        let zScale = far / zRange
//        let wzScale = -far * near / zRange
//        
//        uniforms.projectionMatrix = matrix_float4x4(
//            columns:(SIMD4<Float>(xScale, 0, 0, 0),      // Col 0
//                     SIMD4<Float>(0, yScale, 0, 0),      // Col 1
//                     SIMD4<Float>(0, 0, zScale, 1),      // Col 2 - Note the '1' for perspective divide
//                     SIMD4<Float>(0, 0, wzScale, 0))     // Col 3
//        )
//    }
//    
//    func updateViewMatrix() {
//        // Position the camera slightly above the origin, looking forward
//        let cameraPosition = SIMD3<Float>(0, 1.5, -1.5) // Adjust Y up, Z back
//        let target = SIMD3<Float>(0, 0, 0) // Look towards origin
//        let up = SIMD3<Float>(0, 1, 0)
//        
//        uniforms.viewMatrix = lookAt(eye: cameraPosition, center: target, up: up)
//    }
//    
//    // LookAt function helper (common in graphics)
//    func lookAt(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> matrix_float4x4 {
//        let z = normalize(eye - center)
//        let x = normalize(cross(up, z))
//        let y = cross(z, x) // No need to normalize if up and z are orthogonal and normalized
//        
//        let tx = -dot(x, eye)
//        let ty = -dot(y, eye)
//        let tz = -dot(z, eye)
//        
//        return matrix_float4x4(
//            columns:(SIMD4<Float>(x.x, y.x, z.x, 0), // Col 0
//                     SIMD4<Float>(x.y, y.y, z.y, 0), // Col 1
//                     SIMD4<Float>(x.z, y.z, z.z, 0), // Col 2
//                     SIMD4<Float>(tx, ty, tz, 1))   // Col 3
//        )
//    }
//    
//    // MKTViewDelegate method called when the view size changes
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        updateDrawableSize(size)
//    }
//    
//    // MARK: - Drawing
//    func draw(in view: MTKView) {
//        guard let commandBuffer = commandQueue.makeCommandBuffer(),
//              let renderPassDescriptor = view.currentRenderPassDescriptor,
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//            return
//        }
//        //renderEncoder.setLabel("Main Render Pass") // Good practice for debugging
//        
//        // --- Update Uniforms ---
//        uniforms.currentTime += 1.0 / Float(view.preferredFramesPerSecond)
//        
//        // Bind uniforms ONCE - they are needed by both shaders and don't change per draw call inside this pass
//        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1) // Uniforms -> Vertex Buffer 1
//        renderEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 0) // Uniforms -> Fragment Buffer 0
//        
//        // --- Draw Sky ---
//        if let buffer = skyVertexBuffer {
//            renderEncoder.setRenderPipelineState(skyPipelineState)
//            renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0) // Vertex Data -> Buffer 0
//            var drawMode: Int32 = 0 // 0 for Sky
//            // Bind drawMode to BOTH shader stages with their respective indices
//            renderEncoder.setVertexBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 2)
//            renderEncoder.setFragmentBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 1) // Draw Mode -> Fragment Buffer 1
//            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
//        }
//        
//        // --- Draw Horizon Glow ---
//        if let buffer = horizonVertexBuffer {
//            renderEncoder.setRenderPipelineState(horizonPipelineState) // Could be same as grid or sky
//            renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
//            var drawMode: Int32 = 1 // 1 for Horizon
//            // Bind drawMode to BOTH shader stages
//            renderEncoder.setVertexBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 2)
//            renderEncoder.setFragmentBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 1)
//            renderEncoder.setTriangleFillMode(.lines) // Use .lines for line primitives
//            renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: 2) // Use LineStrip
//        }
//        
//        // --- Draw Grid ---
//        if let buffer = gridVertexBuffer {
//            renderEncoder.setRenderPipelineState(gridPipelineState)
//            renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
//            var drawMode: Int32 = 2 // 2 for Grid
//            // Bind drawMode to BOTH shader stages
//            renderEncoder.setVertexBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 2)
//            renderEncoder.setFragmentBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 1)
//            renderEncoder.setTriangleFillMode(.lines) // Use .lines for line primitives
//            renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: buffer.length / MemoryLayout<SIMD4<Float>>.stride) // Draw all lines
//        }
//        
//        // --- Draw Stars ---
//        if let buffer = starVertexBuffer, starInstanceCount > 0 {
//            renderEncoder.setRenderPipelineState(starPipelineState)
//            renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
//            var drawMode: Int32 = 3 // 3 for Stars
//            // Bind drawMode to BOTH shader stages
//            renderEncoder.setVertexBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 2)    // <<< ADD THIS LINE
//            renderEncoder.setFragmentBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 1)
//            renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: starInstanceCount)
//        }
//        
//        // --- End Encoding ---
//        renderEncoder.endEncoding()
//        
//        // --- Present Drawable ---
//        if let drawable = view.currentDrawable {
//            commandBuffer.present(drawable)
//        }
//        
//        // --- Commit Command Buffer ---
//        commandBuffer.commit()
//    }
//}
