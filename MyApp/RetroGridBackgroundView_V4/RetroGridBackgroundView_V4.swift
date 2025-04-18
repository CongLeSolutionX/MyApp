//
//  RetroGridBackgroundView_V4.swift
//  MyApp
//
//  Created by Cong Le on 4/17/25.
//

import SwiftUI
import MetalKit
import simd // Import for SIMD types like matrix_float4x4

// MARK: - Main SwiftUI View
struct RetroBackgroundView: View {
    var body: some View {
        MetalViewRepresentable()
            .edgesIgnoringSafeArea(.all) // Make it a background
            .overlay( // Example overlay content
                Text("Retro Grid\nby CongLeSolutionX")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(color: .cyan.opacity(0.7), radius: 10, x: 0, y: 0)
                    .padding(.top, 50), // Position the text
                alignment: .top
            )
    }
}

#Preview("Retro Background View") {
    RetroBackgroundView()
}

// MARK: - SwiftUI <-> UIKit Bridge
struct MetalViewRepresentable: UIViewRepresentable {
    // Coordinator remains the Renderer
    func makeCoordinator() -> Renderer {
        // Initialize the Renderer; device setup happens in makeUIView
        Renderer()
    }

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        // Don't set delegate immediately, wait until device is confirmed

        // Safely get the Metal device
        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
            print("❌ Metal is not supported on this device. Returning a basic view.")
            // Return a simple view, perhaps styled to indicate failure
            // Or just return the mtkView which won't render anything Metal
            mtkView.backgroundColor = UIColor(red: 0.01, green: 0.0, blue: 0.05, alpha: 1.0) // Match fallback
            return mtkView // Return the non-functional MTKView
        }
        
        // Assign device only if successful
        mtkView.device = metalDevice
        
        // Now set the delegate and perform setup
        mtkView.delegate = context.coordinator
        // Pass the confirmed device to the setup method
        context.coordinator.setup(device: metalDevice, view: mtkView)

        mtkView.enableSetNeedsDisplay = true // Better for on-demand rendering
        mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Black clear, shaders create color
        mtkView.colorPixelFormat = .bgra8Unorm // Common format
        mtkView.drawableSize = mtkView.frame.size // Set initial size explicitly

        #if targetEnvironment(simulator)
        print("⚠️ Warning: Metal performance and features might be limited in the simulator.")
//        #else
//        if metalDevice.isLowPower {
//             print("⚠️ Warning: Running on a low-power Metal device. Performance may vary.")
//        }
        #endif

        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
         // Ensure drawableSize is updated correctly on rotation or layout changes
        // Use coordinator's size as the source of truth after initial setup
        if uiView.drawableSize != context.coordinator.drawableSize && context.coordinator.isSetupComplete {
            // Only update if the coordinator thinks it should change
            // Check against uiView.frame.size to avoid loop if coordinator update failed
            if uiView.frame.size != .zero && uiView.frame.size != uiView.drawableSize {
                 uiView.drawableSize = uiView.frame.size
                 context.coordinator.updateDrawableSize(uiView.drawableSize)
             }
        }
        // Trigger redraw if needed based on state changes
        uiView.setNeedsDisplay()
    }
}

// MARK: - Metal Renderer Class
class Renderer: NSObject, MTKViewDelegate {
    // Make properties optional where initialization might fail
    var device: MTLDevice? // Keep track of the device
    var commandQueue: MTLCommandQueue?
    
    // Make pipeline states optional
    var skyPipelineState: MTLRenderPipelineState?
    var horizonPipelineState: MTLRenderPipelineState?
    var gridPipelineState: MTLRenderPipelineState?
    var starPipelineState: MTLRenderPipelineState?
    
    // Buffers can be optional too, or default to zero-length buffers if needed
    var skyVertexBuffer: MTLBuffer?
    var horizonVertexBuffer: MTLBuffer?
    var gridVertexBuffer: MTLBuffer?
    var starVertexBuffer: MTLBuffer?
    var starInstanceCount: Int = 0
    
    var uniforms = Uniforms() // Structs are value types, okay to initialize directly
    
    var drawableSize: CGSize = .zero
    private(set) var isSetupComplete: Bool = false // Flag to indicate successful setup

    // MARK: - Setup
    func setup(device: MTLDevice, view: MTKView) {
        self.device = device // Device is confirmed non-nil here
        
        // Safely create the command queue
        guard let queue = device.makeCommandQueue() else {
            print("❌ Failed to create command queue.")
            isSetupComplete = false
            return // Cannot proceed without a command queue
        }
        self.commandQueue = queue
        
        // Load shaders once
        guard let library = device.makeDefaultLibrary() else {
            print("❌ Could not load default Metal library. Check build phases or target membership.")
            isSetupComplete = false
            return // Cannot proceed without shaders
        }
        
        // Use optional binding for function creation (less likely to fail, but good practice)
        guard let vertexFunction = library.makeFunction(name: "vertexShader"),
              let fragmentFunction = library.makeFunction(name: "fragmentShader") else {
            print("❌ Failed to find shader functions. Check names in .metal file.")
            isSetupComplete = false
            return
        }
        
        // --- Create Pipeline States ---
        skyPipelineState = createPipelineState(device: device, vertexFunc: vertexFunction, fragmentFunc: fragmentFunction, pixelFormat: view.colorPixelFormat, isPointRendering: false)
        horizonPipelineState = createPipelineState(device: device, vertexFunc: vertexFunction, fragmentFunc: fragmentFunction, pixelFormat: view.colorPixelFormat, isPointRendering: false)
        gridPipelineState = createPipelineState(device: device, vertexFunc: vertexFunction, fragmentFunc: fragmentFunction, pixelFormat: view.colorPixelFormat, isPointRendering: false)
        starPipelineState = createPipelineState(device: device, vertexFunc: vertexFunction, fragmentFunc: fragmentFunction, pixelFormat: view.colorPixelFormat, isPointRendering: true)
        
        // Check if ALL essential pipelines were created (optional, depends on requirements)
        guard skyPipelineState != nil, gridPipelineState != nil else {
             print("❌ Failed to create essential pipeline states (sky or grid).")
             // Decide if rendering can partially continue or should stop
             // isSetupComplete = false // Or allow partial rendering
             // return
        }

        // --- Vertex Data Setup ---
        // Device is non-nil here, so buffer creation should be safe unless out of memory
        createSkyVertices(device: device)
        createHorizonVertices(device: device)
        createGridVertices(device: device)
        createStarVertices(device: device)
        
        // --- Initial Uniform Setup ---
        updateDrawableSize(view.drawableSize) // Calculate initial matrices based on view's current size

        print("✅ Renderer setup complete.")
        isSetupComplete = true // Mark setup as successful
    }
    
    // Helper to create pipeline states, returns optional
    func createPipelineState(device: MTLDevice, vertexFunc: MTLFunction?, fragmentFunc: MTLFunction?, pixelFormat: MTLPixelFormat, isPointRendering: Bool) -> MTLRenderPipelineState? {
        // Ensure functions are non-nil before proceeding
        guard let vertexFunc = vertexFunc, let fragmentFunc = fragmentFunc else {
             print("❌ Cannot create pipeline state with nil shader function.")
             return nil
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "Pipeline_\(isPointRendering ? "Points" : "LinesTriangles")" // Add labels
        pipelineDescriptor.vertexFunction = vertexFunc
        pipelineDescriptor.fragmentFunction = fragmentFunc
        pipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        
        // Blending for glow/transparency
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        // Vertex Descriptor
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD4<Float>>.stride
        // vertexDescriptor.layouts[0].stepRate = 1 (default)
        // vertexDescriptor.layouts[0].stepFunction = .perVertex (default)
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        // Use try? to safely attempt creation, returns nil on failure
        do {
            return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("❌ Failed to create pipeline state: \(error)")
            return nil
        }
    }
    
    // MARK: - Vertex Creation (Pass device safely)
    func createSkyVertices(device: MTLDevice) {
        let horizonY: Float = -0.4
        let vertices: [SIMD4<Float>] = [
            SIMD4<Float>(-1.0,  1.0,    0.0, 0.0), SIMD4<Float>( 1.0,  1.0,    1.0, 0.0),
            SIMD4<Float>(-1.0,  horizonY, 0.0, 1.0), SIMD4<Float>( 1.0,  horizonY, 1.0, 1.0),
        ]
        skyVertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<SIMD4<Float>>.stride, options: .storageModeShared)
    }
    
    func createHorizonVertices(device: MTLDevice) {
        let horizonY: Float = -0.4
        let zPos: Float = 0
        let vertices: [SIMD3<Float>] = [ SIMD3<Float>(-1.0, horizonY, zPos), SIMD3<Float>( 1.0, horizonY, zPos) ]
        let paddedVertices = vertices.map { SIMD4<Float>($0.x, $0.y, $0.z, 1.0) }
        horizonVertexBuffer = device.makeBuffer(bytes: paddedVertices, length: paddedVertices.count * MemoryLayout<SIMD4<Float>>.stride, options: .storageModeShared)
    }
    
    func createGridVertices(device: MTLDevice) {
        var gridLines: [SIMD3<Float>] = []
        let gridSize: Float = 20.0
        let lineCount: Int = 40
        
        for i in 0...lineCount {
            let x = -gridSize + (2.0 * gridSize * Float(i) / Float(lineCount))
            gridLines.append(SIMD3<Float>(x, 0.0, 0.0))
            gridLines.append(SIMD3<Float>(x, 0.0, gridSize * 2.0))
        }
        for i in 1...lineCount {
            let z = (gridSize * 2.0 * Float(i) / Float(lineCount)) * (Float(i) / Float(lineCount))
            gridLines.append(SIMD3<Float>(-gridSize, 0.0, z))
            gridLines.append(SIMD3<Float>( gridSize, 0.0, z))
        }
        let paddedVertices = gridLines.map { SIMD4<Float>($0.x, $0.y, $0.z, 1.0) }
        gridVertexBuffer = device.makeBuffer(bytes: paddedVertices, length: paddedVertices.count * MemoryLayout<SIMD4<Float>>.stride, options: .storageModeShared)
    }
    
    func createStarVertices(device: MTLDevice) {
        var starData: [SIMD2<Float>] = []
        starInstanceCount = 300
        let horizonY: Float = -0.4
        
        for _ in 0..<starInstanceCount {
            let x = Float.random(in: -1.0...1.0)
            let y = Float.random(in: horizonY * 0.9...1.0)
            starData.append(SIMD2<Float>(x, y))
        }
        let paddedVertices = starData.map { SIMD4<Float>($0.x, $0.y, Float.random(in: 1.0...3.0), 1.0) }
        starVertexBuffer = device.makeBuffer(bytes: paddedVertices, length: paddedVertices.count * MemoryLayout<SIMD4<Float>>.stride, options: .storageModeShared)
    }
    
    // MARK: - Size Update & Matrices
    func updateDrawableSize(_ size: CGSize) {
         guard size.width > 0 && size.height > 0 else {
             print("⚠️ Attempted to update drawable size with zero or negative dimensions: \(size). Skipping.")
             // Potentially invalidate projection matrix or set a default?
             return
         }
        self.drawableSize = size
        uniforms.viewportSize = SIMD2<Float>(Float(size.width), Float(size.height))
        updateProjectionMatrix(size: size)
        updateViewMatrix()
    }
    
    // updateProjectionMatrix and updateViewMatrix methods remain largely the same
    // but ensure they don't rely on device-specific info if device could be nil initially.
    // (In this flow, updateDrawableSize is called after device is confirmed)
    func updateProjectionMatrix(size: CGSize) {
        let aspect = Float(size.width / size.height)
        let fov = Float.pi / 2.5
        let near: Float = 0.1
        let far: Float = 100.0
        
        let yScale = 1.0 / tan(fov * 0.5)
        let xScale = yScale / aspect
        let zRange = far - near
        let zScale = far / zRange // Using reverse Z might be better for precision
        let wzScale = -far * near / zRange
        
        uniforms.projectionMatrix = matrix_float4x4(
            columns:(SIMD4<Float>(xScale, 0, 0, 0),
                     SIMD4<Float>(0, yScale, 0, 0),
                     SIMD4<Float>(0, 0, zScale, 1), // Reverse Z: (0, 0, -near / zRange, 1)
                     SIMD4<Float>(0, 0, wzScale, 0)) // Reverse Z: (0, 0, near * (far - near) / zRange, 0) ? Check maths
        )
    }
    
     func updateViewMatrix() {
        let cameraPosition = SIMD3<Float>(0, 1.5, -1.5)
        let target = SIMD3<Float>(0, 0, 0)
        let up = SIMD3<Float>(0, 1, 0)
        uniforms.viewMatrix = lookAt(eye: cameraPosition, center: target, up: up)
    }

    // lookAt helper remains the same
    func lookAt(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> matrix_float4x4 {
        let z = normalize(eye - center)
        let x = normalize(cross(up, z))
        let y = cross(z, x)
        let tx = -dot(x, eye); let ty = -dot(y, eye); let tz = -dot(z, eye)
        return matrix_float4x4(
            columns:(SIMD4<Float>(x.x, y.x, z.x, 0), SIMD4<Float>(x.y, y.y, z.y, 0),
                     SIMD4<Float>(x.z, y.z, z.z, 0), SIMD4<Float>(tx, ty, tz, 1))
        )
    }

    // MARK: - MKTViewDelegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateDrawableSize(size)
    }
    
    // MARK: - Drawing
    func draw(in view: MTKView) {
        // Ensure setup is complete and essential components exist
        guard isSetupComplete,
              let queue = commandQueue, // Safely unwrap queue
              let commandBuffer = queue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor, // Already optional
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
              // Print a message only once or periodically if setup failed
              if !isSetupComplete { /* print("Setup not complete, skipping draw.") */ }
              // If setup IS complete but command buffer/drawable failed, maybe log that.
            return
        }
        
        renderEncoder.label = "Main Render Pass" // For debugging
        
        // --- Update Uniforms ---
        uniforms.currentTime += 1.0 / Float(max(1, view.preferredFramesPerSecond)) // Avoid division by zero
        
        // Bind uniforms - device is confirmed non-nil if setup succeeded
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        renderEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 0)
        
        // --- Draw Sky ---
        // Use optional chaining and guard let for pipelines and buffers
        if let pipeline = skyPipelineState, let buffer = skyVertexBuffer {
            renderEncoder.setRenderPipelineState(pipeline)
            renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
            var drawMode: Int32 = 0
            renderEncoder.setVertexBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 2)
            renderEncoder.setFragmentBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 1)
            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        } // else { print("Skipping sky draw (pipeline or buffer missing)") } // Optional debug

         // --- Draw Horizon Glow ---
        if let pipeline = horizonPipelineState, let buffer = horizonVertexBuffer { // Use the correct optional pipeline state
            renderEncoder.setRenderPipelineState(pipeline)
            renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
            var drawMode: Int32 = 1
            renderEncoder.setVertexBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 2)
            renderEncoder.setFragmentBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 1)
            // Set fill mode AFTER pipeline state if needed (though line primitive type is better)
            // renderEncoder.setTriangleFillMode(.lines) // Might not be needed if using line topology
            renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: 2) // Use LineStrip
        }

        // --- Draw Grid ---
        if let pipeline = gridPipelineState, let buffer = gridVertexBuffer {
            let vertexCount = buffer.length / MemoryLayout<SIMD4<Float>>.stride // Calculate safely
            if vertexCount > 0 {
                renderEncoder.setRenderPipelineState(pipeline)
                renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
                var drawMode: Int32 = 2
                renderEncoder.setVertexBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 2)
                renderEncoder.setFragmentBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 1)
                // renderEncoder.setTriangleFillMode(.lines) // Might not be needed if using line topology
                renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: vertexCount) // Use Line topology
            }
        }

        // --- Draw Stars ---
        if let pipeline = starPipelineState, let buffer = starVertexBuffer, starInstanceCount > 0 {
            renderEncoder.setRenderPipelineState(pipeline)
            renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
            var drawMode: Int32 = 3
            renderEncoder.setVertexBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 2)
            renderEncoder.setFragmentBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 1)
            renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: starInstanceCount)
        }
        
        // --- End Encoding ---
        renderEncoder.endEncoding()
        
        // --- Present Drawable ---
        if let drawable = view.currentDrawable { // Already optional
            commandBuffer.present(drawable)
        }
        
        // --- Commit Command Buffer ---
        commandBuffer.commit()
        // commandBuffer.waitUntilCompleted() // Avoid for production code, use for debugging ONLY
    }
}
