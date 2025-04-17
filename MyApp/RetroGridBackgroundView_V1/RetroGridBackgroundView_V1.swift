//
//  RetroGridBackgroundView_V1.swift
//  MyApp
//
//  Created by Cong Le on 4/17/25.
//

import SwiftUI
import MetalKit

// MARK: - Main SwiftUI View
struct RetroBackgroundView: View {
    var body: some View {
        MetalViewRepresentable()
            .edgesIgnoringSafeArea(.all) // Make it a background
        // Add overlay content on top of this background if needed
        // .overlay(
        //     Text("Your Content Here")
        //         .foregroundColor(.white)
        // )
    }
}
#Preview("Retro Background View") {
    RetroBackgroundView()
}

// MARK: - SwiftUI <-> UIKit Bridge
struct MetalViewRepresentable: UIViewRepresentable {
    func makeCoordinator() -> Renderer {
        Renderer() // Create the renderer instance
    }
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator // Set the Renderer as the delegate
        mtkView.enableSetNeedsDisplay = true // Important for on-demand rendering
        
        // Configure the Metal view
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
            context.coordinator.setup(device: metalDevice, view: mtkView)
        } else {
            print("Metal is not supported on this device")
            // Provide a fallback view or behavior
        }
        
        mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Base background
        mtkView.colorPixelFormat = .bgra8Unorm // Standard pixel format
        mtkView.drawableSize = mtkView.frame.size // Initial size
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        // Update view properties if needed, e.g., based on state changes
        uiView.drawableSize = uiView.frame.size // Ensure size is updated on layout changes
        context.coordinator.drawableSize = uiView.drawableSize // Inform the renderer
    }
}

// MARK: - Metal Renderer Class
class Renderer: NSObject, MTKViewDelegate {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState! // Could have multiple for different objects
    
    // Buffers for vertex data
    var skyVertexBuffer: MTLBuffer!
    var gridVertexBuffer: MTLBuffer!
    var starVertexBuffer: MTLBuffer! // Optional buffer for stars
    
    // Uniforms (Data passed to shaders)
    var perspectiveMatrix: matrix_float4x4 = matrix_identity_float4x4
    var viewportSize: vector_float2 = vector_float2(0, 0)
    var currentTime: Float = 0.0 // For potential animations
    
    var drawableSize : CGSize = .zero
    
    func setup(device: MTLDevice, view: MTKView) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        
        // --- Shader Setup ---
        // Load .metal file or create library from string
        let library = device.makeDefaultLibrary()! // Assumes shaders are in default.metal
        let vertexFunction = library.makeFunction(name: "vertexShader")
        let fragmentFunction = library.makeFunction(name: "fragmentShader")
        
        // --- Pipeline Setup ---
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        // --- BEGIN FIX: Add Vertex Descriptor ---
        let vertexDescriptor = MTLVertexDescriptor()
        
        // Describe Attribute 0 (position in VertexIn struct)
        vertexDescriptor.attributes[0].format = .float4 // Our data structure has 4 Floats (X,Y,U,V) matching float4
        vertexDescriptor.attributes[0].offset = 0      // The data starts at the beginning of each vertex structure
        vertexDescriptor.attributes[0].bufferIndex = 0 // Matches the `setVertexBuffer(..., index: 0)` call
        
        // Describe the layout of the buffer at index 0
        // The stride is the size of one complete vertex element (4 Floats)
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.stride * 4
        vertexDescriptor.layouts[0].stepRate = 1 // Advance per vertex
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        
        // Assign the configured descriptor to the pipeline descriptor
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        // --- END FIX ---
        
        // Add vertex descriptors if needed // <-- We just did this!
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor) // Line 97
        } catch {
            // Line 99 (where the error was reported)
            fatalError("Failed to create pipeline state: \(error)")
        }
        
        // --- Vertex Data Setup ---
        createSkyVertices()
        createGridVertices()
        createStarVertices() // Optional
    }
    
    // --- Vertex Creation Functions ---
    func createSkyVertices() {
        // A simple quad covering the top ~2/3rds of the screen
        let vertices: [Float] = [
            // X,    Y,   U, V  (Position, Texture Coords for gradient)
            -1.0,  1.0, 0.0, 0.0, // Top Left
             1.0,  1.0, 1.0, 0.0, // Top Right
             -1.0, -0.3, 0.0, 1.0, // Bottom Left (Adjust Y for horizon position)
             1.0, -0.3, 1.0, 1.0, // Bottom Right
        ]
        skyVertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.stride, options: .storageModeShared)
    }
    
    func createGridVertices() {
        // Requires more complex calculation for perspective lines
        // Define lines in a 3D space (X, 0, Z) and project them
        let lines: [Float] = [
            // Example single line segment (Needs many more!)
            // X1, Y1, Z1,   X2, Y2, Z2 (Y is typically 0 for floor)
            -10.0, 0.0, 0.0,  10.0, 0.0, 0.0, // Horizon line (Simplified)
             -10.0, 0.0, 1.0,  10.0, 0.0, 1.0, // Parallel line 1
             // ... more parallel lines ...
             0.0, 0.0, 0.0,   0.0, 0.0, 20.0, // Perpendicular line (Center)
             1.0, 0.0, 0.0,   1.0, 0.0, 20.0, // Perpendicular line 1
             // ... more perpendicular lines ...
        ]
        // Store as pairs of (X, Y=0, Z) points
        gridVertexBuffer = device.makeBuffer(bytes: lines, length: lines.count * MemoryLayout<Float>.stride, options: .storageModeShared)
    }
    
    func createStarVertices() {
        // Create random star positions (X, Y in clip space [-1, 1]) and sizes
        // Store as vector_float3 (x, y, size) or similar
        // Example:
        var starData: [vector_float3] = []
        for _ in 0..<200 { // Number of stars
            let x = Float.random(in: -1.0...1.0)
            // Ensure stars are mostly in the upper part/sky
            let y = Float.random(in: -0.2...1.0)
            let size = Float.random(in: 1.0...3.0) // Pixel size
            starData.append(vector_float3(x, y, size))
        }
        starVertexBuffer = device.makeBuffer(bytes: starData, length: starData.count * MemoryLayout<vector_float3>.stride, options: .storageModeShared)
    }
    
    // Called whenever the view size changes
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.drawableSize = size
        self.viewportSize = vector_float2(Float(size.width), Float(size.height))
        updatePerspectiveMatrix(size: size) // Recalculate perspective
    }
    
    // The main drawing loop
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        // --- Update Time for Animations ---
        currentTime += 1.0 / Float(view.preferredFramesPerSecond) // Simple time increment
        
        // --- Set Pipeline State ---
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // --- Set Viewport (optional, often handled by descriptor) ---
        let viewport = MTLViewport(originX: 0.0, originY: 0.0, width: Double(drawableSize.width), height: Double(drawableSize.height), znear: 0.0, zfar: 1.0)
        renderEncoder.setViewport(viewport)
        
        // --- Pass Uniforms to Shaders ---
        renderEncoder.setVertexBytes(&perspectiveMatrix, length: MemoryLayout<matrix_float4x4>.stride, index: 1) // Vertex Shader Buffer Index 1
        renderEncoder.setVertexBytes(&viewportSize, length: MemoryLayout<vector_float2>.stride, index: 2)       // Vertex Shader Buffer Index 2
        renderEncoder.setFragmentBytes(&viewportSize, length: MemoryLayout<vector_float2>.stride, index: 0)     // Fragment Shader Buffer Index 0
        renderEncoder.setFragmentBytes(&currentTime, length: MemoryLayout<Float>.stride, index: 1)            // Fragment Shader Buffer Index 1
        
        // --- Draw Sky ---
        if let skyVertexBuffer = skyVertexBuffer {
            renderEncoder.setVertexBuffer(skyVertexBuffer, offset: 0, index: 0) // Vertex Shader Buffer Index 0
            // Tell shader we are drawing the sky (e.g., using a uniform or a different pipeline)
            var drawMode: Int32 = 0 // 0 for Sky
            renderEncoder.setFragmentBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 2)
            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        }
        
        // --- Draw Grid ---
        if let gridVertexBuffer = gridVertexBuffer {
            renderEncoder.setVertexBuffer(gridVertexBuffer, offset: 0, index: 0)
            // Tell shader we are drawing the grid
            var drawMode: Int32 = 1 // 1 for Grid
            renderEncoder.setFragmentBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 2)
            // renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: /* Number of grid vertices */)
            // NOTE: Drawing the grid correctly requires a different vertex structure and shader logic for perspective projection.
            // The example `createGridVertices` is simplified. Typically, you'd process 3D grid points in the vertex shader.
            // For simplicity here, we are skipping the actual grid draw command. A real implementation needs proper perspective calculation.
        }
        
        // --- Draw Stars (optional, assuming point primitive support or small quads) ---
        if let starVertexBuffer = starVertexBuffer {
            renderEncoder.setVertexBuffer(starVertexBuffer, offset: 0, index: 0)
            // Tell shader we are drawing stars
            var drawMode: Int32 = 2 // 2 for Stars
            renderEncoder.setFragmentBytes(&drawMode, length: MemoryLayout<Int32>.stride, index: 2)
            renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: 200 /* Number of Stars */)
            // Note: Drawing points might require specific pipeline state configuration.
        }
        
        // --- End Encoding ---
        renderEncoder.endEncoding()
        
        // --- Present Drawable ---
        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
        
        // --- Commit Command Buffer ---
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted() // Or manage asynchronously for better performance
    }
    
    // --- Helper for Perspective ---
    func updatePerspectiveMatrix(size: CGSize) {
        let aspect = Float(size.width / size.height)
        let fov = Float.pi / 3.0 // Field of view (adjust as needed)
        let near: Float = 0.1
        let far: Float = 100.0
        
        let f = 1.0 / tan(fov / 2.0)
        
        perspectiveMatrix = matrix_float4x4(
            columns:(vector_float4( f / aspect,  0,  0,  0),
                     vector_float4( 0,           f,  0,  0),
                     vector_float4( 0,           0, far / (far - near),  1), // Adjusted for Metal coord system? Check W.
                     vector_float4( 0,           0, (-far * near) / (far - near), 0))
        )
        // This matrix needs to be applied correctly in the vertex shader for the grid lines
    }
}
