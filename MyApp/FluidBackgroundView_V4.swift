//
//  FluidBackgroundView_V4.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//
import SwiftUI
import MetalKit
import simd // Required for SIMD vector types matching Metal's float2, float4, etc.

// MARK: - Shared Structures (CPU <-> GPU)

/// Swift struct equivalent of the Metal InteractionUniforms struct.
/// MUST match the layout and types defined in the `fluidShaderSource`.
struct InteractionUniforms {
    var interactionPoint: SIMD2<Float>      // Corresponds to float2
    var interactionVelocity: SIMD2<Float>   // Corresponds to float2
    var interactionColor: SIMD4<Float>      // Corresponds to float4
    var interactionRadius: Float            // Corresponds to float
    var timestep: Float                     // Corresponds to float
    var viscosity: Float                    // Corresponds to float
    var addDensity: Bool                    // Corresponds to bool (Metal bool is usually 1 byte)
    var addVelocity: Bool                   // Corresponds to bool
}

// MARK: - Metal Shaders (Compute & Render)

// MARK: - Swift Code: Fluid Simulation Renderer

class FluidRenderer: NSObject, MTKViewDelegate {
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    
    // Textures for simulation state (using ping-pong for some)
    var velocityTextureA: MTLTexture!
    var velocityTextureB: MTLTexture!
    var densityTextureA: MTLTexture!
    var densityTextureB: MTLTexture!
    var pressureTextureA: MTLTexture! // Use ping-pong for Jacobi
    var pressureTextureB: MTLTexture!
    var divergenceTexture: MTLTexture!
    
    // Pipeline states
    var advectPSO: MTLComputePipelineState!
    var addSourcePSO: MTLComputePipelineState!
    var jacobiDiffusePSO: MTLComputePipelineState!
    var divergencePSO: MTLComputePipelineState!
    var jacobiPressurePSO: MTLComputePipelineState!
    var subtractGradientPSO: MTLComputePipelineState!
    var visualizeRenderPSO: MTLRenderPipelineState!
    var clearTexturePSO: MTLComputePipelineState! // Added PSO for clearing
    
    // Buffers for uniforms
    var interactionUniforms: InteractionUniforms // The Swift struct
    var interactionUniformsBuffer: MTLBuffer!
    var dtBuffer: MTLBuffer! // Buffer for simple float dt
    var diffusionParamsBuffer: MTLBuffer! // Holds alpha, beta_recip
    var gradParamsBuffer: MTLBuffer!      // Holds halfTexelSize
    
    // Texture dimensions
    let textureWidth = 256
    let textureHeight = 256
    
    // Simulation parameters
    let jacobiIterations = 20 // Iterations for pressure solve
    let diffusionIterations = 8 // Iterations for viscosity/diffusion
    let simulationTimeStep: Float = 0.8
    let fluidViscosity: Float = 0.000005 // Lower viscosity
    let interactionRadiusScreenFraction: Float = 0.06 // Radius as fraction of min screen dim
    
    // Private state tracking
    private var lastInteractionPoint: CGPoint? = nil
    private var currentDrawableSize: CGSize = .zero
    
    init?(mtkView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            print("Error: Metal is not supported on this device")
            return nil // Fail initialization if Metal is not available
        }
        self.device = device
        self.commandQueue = commandQueue
        
        // Configure the MTKView
        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm // Standard display format
        mtkView.framebufferOnly = false      // Keep true unless reading from drawable
        mtkView.clearColor = MTLClearColorMake(0.01, 0.01, 0.02, 1.0) // Set clear color
        
        // Initialize interaction uniforms (using the Swift struct)
        interactionUniforms = InteractionUniforms(
            interactionPoint: .zero,
            interactionVelocity: .zero,
            interactionColor: .zero,
            interactionRadius: 0.0, // Will be set based on size later
            timestep: simulationTimeStep,
            viscosity: fluidViscosity,
            addDensity: false,
            addVelocity: false
        )
        
        super.init()
        
        // Perform Metal setup - can potentially fail, ideally handle errors
        setupTextures()
        setupBuffers()
        setupPipelines() // This can fail if shaders don't compile
        
        // Initialize texture contents
        clearTexture(texture: velocityTextureA)
        clearTexture(texture: velocityTextureB)
        clearTexture(texture: densityTextureA)
        clearTexture(texture: densityTextureB)
        clearTexture(texture: pressureTextureA)
        clearTexture(texture: pressureTextureB)
        clearTexture(texture: divergenceTexture)
    }
    
    // --- Setup Helper Methods ---
    
    func setupTextures() {
        let descriptor = MTLTextureDescriptor()
        descriptor.textureType = .type2D
        descriptor.width = textureWidth
        descriptor.height = textureHeight
        descriptor.usage = [.shaderRead, .shaderWrite] // Allow read/write by compute kernels
        descriptor.storageMode = .private             // Optimize for GPU-only access
        
        // Velocity (RG channels, 16-bit float for precision)
        descriptor.pixelFormat = .rg16Float
        velocityTextureA = device.makeTexture(descriptor: descriptor)
        velocityTextureB = device.makeTexture(descriptor: descriptor)
        velocityTextureA.label = "Velocity A"
        velocityTextureB.label = "Velocity B"
        
        // Density (RGBA, 8-bit normalized)
        descriptor.pixelFormat = .rgba8Unorm
        densityTextureA = device.makeTexture(descriptor: descriptor)
        densityTextureB = device.makeTexture(descriptor: descriptor)
        densityTextureA.label = "Density A"
        densityTextureB.label = "Density B"
        
        // Pressure (Single channel, 16-bit float)
        descriptor.pixelFormat = .r16Float
        pressureTextureA = device.makeTexture(descriptor: descriptor)
        pressureTextureB = device.makeTexture(descriptor: descriptor) // For ping-ponging Jacobi
        divergenceTexture = device.makeTexture(descriptor: descriptor) // Also single channel float
        pressureTextureA.label = "Pressure A"
        pressureTextureB.label = "Pressure B"
        divergenceTexture.label = "Divergence"
        
        // Check if textures were created successfully (optional but good practice)
        if velocityTextureA == nil || densityTextureA == nil || pressureTextureA == nil {
            print("Error: Failed to create one or more simulation textures.")
            // Handle error appropriately - perhaps throw or fatalError
        }
    }
    
    func setupBuffers() {
        // Buffer for the main InteractionUniforms struct
        guard let iUniformsBuff = device.makeBuffer(length: MemoryLayout<InteractionUniforms>.stride, options: .storageModeShared) else {
            fatalError("Failed to create InteractionUniforms buffer")
        }
        interactionUniformsBuffer = iUniformsBuff
        interactionUniformsBuffer.label = "Interaction Uniforms Buffer"
        
        // Simple buffer for timestep (dt) used in advection
        guard let dtBuff = device.makeBuffer(length: MemoryLayout<Float>.stride, options: .storageModeShared) else {
            fatalError("Failed to create dt buffer")
        }
        dtBuffer = dtBuff
        dtBuffer.label = "Timestep (dt) Buffer"
        // Initial upload of dt value
        dtBuffer.contents().storeBytes(of: simulationTimeStep, as: Float.self)
        
        // Buffer for diffusion parameters [alpha, 1.0/beta]
        guard let diffBuff = device.makeBuffer(length: MemoryLayout<Float>.stride * 2, options: .storageModeShared) else {
            fatalError("Failed to create diffusion params buffer")
        }
        diffusionParamsBuffer = diffBuff
        diffusionParamsBuffer.label = "Diffusion Params Buffer"
        // Calculate and upload initial diffusion params (assuming grid spacing dx=1)
        updateDiffusionParams()
        
        // Buffer for gradient parameters [0.5/texWidth, 0.5/texHeight]
        guard let gradBuff = device.makeBuffer(length: MemoryLayout<SIMD2<Float>>.stride, options: .storageModeShared) else {
            fatalError("Failed to create gradient params buffer")
        }
        gradParamsBuffer = gradBuff
        gradParamsBuffer.label = "Gradient Params Buffer"
        // Calculate and upload initial gradient params
        updateGradientParams()
        
    }
    
    func updateDiffusionParams() {
        guard diffusionParamsBuffer != nil else { return }
        // Assuming dx=1 for simplicity in alpha/beta calculation
        let dx_sq: Float = 1.0 * 1.0
        let alpha = dx_sq / (fluidViscosity * simulationTimeStep) // Ensure viscosity and dt are non-zero if possible
        let beta_recip = 1.0 / (4.0 + alpha)
        let params: [Float] = [alpha, beta_recip]
        diffusionParamsBuffer.contents().copyMemory(from: params, byteCount: MemoryLayout<Float>.stride * 2)
    }
    
    func updateGradientParams() {
        guard gradParamsBuffer != nil, textureWidth > 0, textureHeight > 0 else { return }
        let halfTexelSize = SIMD2<Float>(0.5 / Float(textureWidth), 0.5 / Float(textureHeight))
        gradParamsBuffer.contents().storeBytes(of: halfTexelSize, as: SIMD2<Float>.self)
    }
    
    func setupPipelines() {
        do {
            //            guard let library = try? device.makeLibrary(source: fluidShaderSource, options: nil) else {
            //                fatalError("Failed to create Metal library from source.")
            //            }
            
            // Get the default library compiled by Xcode from .metal files
            guard let library = device.makeDefaultLibrary() else {
                fatalError("Failed to get default Metal library. Ensure FluidShaders.metal is in target.")
            }
            
            
            
            // --- Compute Pipelines ---
            advectPSO = try makeComputePSO(library: library, functionName: "advect")
            addSourcePSO = try makeComputePSO(library: library, functionName: "add_source")
            jacobiDiffusePSO = try makeComputePSO(library: library, functionName: "diffuse_jacobi")
            divergencePSO = try makeComputePSO(library: library, functionName: "calculate_divergence")
            jacobiPressurePSO = try makeComputePSO(library: library, functionName: "pressure_jacobi")
            subtractGradientPSO = try makeComputePSO(library: library, functionName: "subtract_gradient")
            clearTexturePSO = try makeComputePSO(library: library, functionName: "clear_texture_kernel") // Initialize clear PSO
            
            // --- Render Pipeline (for visualization) ---
            let renderDesc = MTLRenderPipelineDescriptor()
            renderDesc.label = "Fluid Visualization Pipeline"
            renderDesc.vertexFunction = library.makeFunction(name: "fluid_vertex")
            renderDesc.fragmentFunction = library.makeFunction(name: "fluid_fragment")
            renderDesc.colorAttachments[0].pixelFormat = .bgra8Unorm // Match MTKView's format
            
            visualizeRenderPSO = try device.makeRenderPipelineState(descriptor: renderDesc)
            
        } catch {
            fatalError("Failed to create Metal pipeline state: \(error)")
        }
    }
    
    // Helper to create compute PSOs
    func makeComputePSO(library: MTLLibrary, functionName: String) throws -> MTLComputePipelineState {
        guard let function = library.makeFunction(name: functionName) else {
            // Use a specific error type or just fatalError for essential functions
            fatalError("Failed to find Metal function named: \(functionName)")
        }
        return try device.makeComputePipelineState(function: function)
    }
    
    /// Clears the given texture to zero using a compute shader.
    func clearTexture(texture: MTLTexture) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("Error: Failed to create command buffer for clearing texture \(texture.label ?? "unlabeled").")
            return
        }
        commandBuffer.label = "Clear Texture (\(texture.label ?? "unlabeled")) CB"
        
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            print("Error: Failed to create compute encoder for clearing texture \(texture.label ?? "unlabeled").")
            return
        }
        computeEncoder.label = "Clear Texture (\(texture.label ?? "unlabeled")) CE"
        
        // Ensure the clear PSO is valid
        guard let validClearPSO = clearTexturePSO else {
            print("Error: Clear Texture PSO is not initialized. Cannot clear texture \(texture.label ?? "unlabeled").")
            computeEncoder.endEncoding()
            return
        }
        
        computeEncoder.setComputePipelineState(validClearPSO)
        computeEncoder.setTexture(texture, index: 0) // Target texture at index 0
        
        // Dispatch threads covering the entire texture
        let threadsPerGrid = MTLSize(width: texture.width, height: texture.height, depth: 1)
        let threadsPerThreadgroup = calculateThreadGroupSize(for: validClearPSO)
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        computeEncoder.endEncoding()
        commandBuffer.commit()
        // Don't wait unless absolutely necessary for synchronization
    }
    
    // Helper to calculate optimal thread group size
    func calculateThreadGroupSize(for pso: MTLComputePipelineState) -> MTLSize {
        let w = pso.threadExecutionWidth
        let h = pso.maxTotalThreadsPerThreadgroup / w
        let validHeight = max(1, h) // Ensure height is at least 1
        return MTLSize(width: w, height: validHeight, depth: 1)
    }
    
    // --- MTKViewDelegate Methods ---
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        currentDrawableSize = size
        // Update interaction radius based on the new MIN dimension and texture size
        let minDim = Float(min(size.width, size.height))
        // Normalize radius relative to texture dimensions
        interactionUniforms.interactionRadius = interactionRadiusScreenFraction * minDim / Float(min(textureWidth, textureHeight))
        // Recalculate gradient params which depend on texture size (shouldn't change here, but good if texture size could change)
        updateGradientParams()
        print("Drawable size changed: \(size), Interaction Radius (Norm Texture Space): \(interactionUniforms.interactionRadius)")
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let currentDrawable = view.currentDrawable // Get drawable early
        else {
            print("Warning: Could not get command buffer or drawable for frame.")
            return
        }
        commandBuffer.label = "Fluid Frame Command Buffer"
        
        updateInteractionUniforms() // Copy latest interaction data to buffer
        
        // --- Encode Simulation Compute Passes ---
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            print("Error: Failed to create compute encoder for simulation.")
            return // Don't proceed if encoder fails
        }
        computeEncoder.label = "Fluid Simulation Compute Pass"
        
        let threadsPerGrid = MTLSize(width: textureWidth, height: textureHeight, depth: 1)
        // Calculate threadgroup size once, assuming it's okay for most kernels
        // Or calculate individually if kernels have different requirements
        let threadsPerThreadgroup = calculateThreadGroupSize(for: advectPSO)
        
        // 1. Advect Velocity (Velocity A -> Velocity B)
        computeEncoder.setComputePipelineState(advectPSO)
        computeEncoder.setTexture(velocityTextureA, index: 0) // Velocity field (read)
        computeEncoder.setTexture(velocityTextureA, index: 1) // Quantity to advect (velocity, sample)
        computeEncoder.setTexture(velocityTextureB, index: 2) // Output (write)
        computeEncoder.setBuffer(dtBuffer, offset: 0, index: 0) // Pass dt
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        swapVelocityTextures() // Result in A
        
        // 2. Advect Density (Density A -> Density B)
        // Re-use advectPSO
        computeEncoder.setTexture(velocityTextureA, index: 0) // Current velocity field (read)
        computeEncoder.setTexture(densityTextureA, index: 1)  // Quantity to advect (density, sample)
        computeEncoder.setTexture(densityTextureB, index: 2)  // Output (write)
        // dt buffer still bound at index 0
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        swapDensityTextures() // Result in A
        
        // 3. Apply Diffusion (Viscosity) to Velocity (Iteratively A <-> B)
        if fluidViscosity > 0 && diffusionIterations > 0 {
            computeEncoder.setComputePipelineState(jacobiDiffusePSO)
            // Set precomputed diffusion params once
            computeEncoder.setBuffer(diffusionParamsBuffer, offset: 0, index: 0) // alpha
            computeEncoder.setBuffer(diffusionParamsBuffer, offset: MemoryLayout<Float>.stride, index: 1) // beta_recip
            
            // Variable 'vel_b' was never mutated; changed to 'let' constant
            let vel_b = velocityTextureA! // Input 'b' term (velocity before diffusion)
            var vel_x_k = velocityTextureA! // Previous iteration x_k (starts same as b)
            var vel_x_k1 = velocityTextureB! // Next iteration x_{k+1}
            
            for _ in 0..<diffusionIterations {
                computeEncoder.setTexture(vel_b, index: 0)     // quantity_b (constant for all iterations)
                computeEncoder.setTexture(vel_x_k, index: 1)   // quantity_x_prev (result from last iter)
                computeEncoder.setTexture(vel_x_k1, index: 2)  // quantity_x_next (output of this iter)
                computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
                // Swap textures: output becomes input for next iteration
                swap(&vel_x_k, &vel_x_k1)
            }
            // Final diffused velocity is now in vel_x_k (which points to A or B depending on iterations)
            // Ensure velocityTextureA holds the final result
            if vel_x_k !== velocityTextureA {
                blitTexture(commandBuffer: commandBuffer, source: vel_x_k, destination: velocityTextureA)
            }
        }
        
        // 4. Add Sources (Forces/Density to A textures)
        computeEncoder.setComputePipelineState(addSourcePSO)
        computeEncoder.setBuffer(interactionUniformsBuffer, offset: 0, index: 0)
        // Add density (if flag is set internally in uniforms)
        computeEncoder.setTexture(densityTextureA, index: 0)
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        // Add velocity (if flag is set internally in uniforms)
        computeEncoder.setTexture(velocityTextureA, index: 0)
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        // Flags are reset in updateInteraction / endInteraction, managed by CPU side
        
        // 5. Projection Step (Make fluid incompressible)
        // 5a. Calculate Divergence (Velocity A -> Divergence Texture)
        computeEncoder.setComputePipelineState(divergencePSO)
        computeEncoder.setTexture(velocityTextureA, index: 0)   // Input velocity
        computeEncoder.setTexture(divergenceTexture, index: 1) // Output divergence
        computeEncoder.setBuffer(gradParamsBuffer, offset: 0, index: 0) // Pass halfTexelSize
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        // 5b. Solve Pressure (Iteratively A <-> B using Divergence) -> Final pressure in A or B
        // Clear initial pressure guess (optional, helps stability)
        // Clearing pressure textures if needed
        if jacobiIterations > 0 { // Only clear if we're about to solve pressure
            clearTexture(texture: pressureTextureA) // Use compute clear
            clearTexture(texture: pressureTextureB) // Use compute clear
        }
        
        computeEncoder.setComputePipelineState(jacobiPressurePSO)
        computeEncoder.setTexture(divergenceTexture, index: 0) // Input divergence (RHS, fixed)
        
        var pressure_k = pressureTextureA! // Previous pressure
        var pressure_k1 = pressureTextureB! // Next pressure
        
        for _ in 0..<jacobiIterations {
            computeEncoder.setTexture(pressure_k, index: 1)     // pressurePrevIter
            computeEncoder.setTexture(pressure_k1, index: 2)    // pressureOut
            computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            // Prepare for next iteration
            swap(&pressure_k, &pressure_k1)
        }
        // Final pressure is in pressure_k (which points to pressureTextureA or B)
        
        // 5c. Subtract Gradient (Updates Velocity A using final pressure_k)
        computeEncoder.setComputePipelineState(subtractGradientPSO)
        computeEncoder.setTexture(velocityTextureA, index: 0) // Velocity field to modify (read/write)
        computeEncoder.setTexture(pressure_k, index: 1)       // Final pressure field (sample)
        computeEncoder.setBuffer(gradParamsBuffer, offset: 0, index: 0) // Pass halfTexelSize
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        // velocityTextureA now holds the divergence-free velocity field
        
        computeEncoder.endEncoding() // Finish all compute dispatches
        
        // Add explicit barrier if clearing pressure textures caused issues (unlikely but possible)
        // Note: Command buffer submission ensures kernels complete before render pass starts,
        // but clearing in a separate command buffer adds complexity. Clearing inline like this is better.
        // commandBuffer.commit() // Avoid this mid-frame if possible
        // commandBuffer = commandQueue.makeCommandBuffer()! // Need a new one
        
        // --- Render Pass (Visualize Density A to Screen) ---
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            print("Warning: Could not get render pass descriptor.")
            commandBuffer.commit()
            return
        }
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            print("Error: Failed to create render command encoder.")
            commandBuffer.commit()
            return
        }
        renderEncoder.label = "Fluid Visualization Render Pass"
        
        renderEncoder.setRenderPipelineState(visualizeRenderPSO)
        renderEncoder.setFragmentTexture(densityTextureA, index: 0) // Visualize Density A
        
        // Draw a full-screen quad (6 vertices specified in vertex shader)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        
        renderEncoder.endEncoding()
        
        // --- Present Drawable ---
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
    // --- Utility Methods ---
    
    func swapDensityTextures() { swap(&densityTextureA, &densityTextureB) }
    func swapVelocityTextures() { swap(&velocityTextureA, &velocityTextureB) }
    func swapPressureTextures() { swap(&pressureTextureA, &pressureTextureB) }
    
    // Utility to copy textures using a Blit encoder (useful for ensuring final state)
    // Added command buffer parameter and guard let for encoder
    func blitTexture(commandBuffer: MTLCommandBuffer, source: MTLTexture, destination: MTLTexture) {
        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
            print("Error: Failed to create blit command encoder for texture copy.")
            return
        }
        blitEncoder.label = "Blit Texture (\(source.label ?? "src") -> \(destination.label ?? "dst"))"
        
        let origin = MTLOrigin(x: 0, y: 0, z: 0)
        let size = MTLSize(width: source.width, height: source.height, depth: source.depth) // Use source depth
        blitEncoder.copy(from: source, sourceSlice: 0, sourceLevel: 0, sourceOrigin: origin, sourceSize: size,
                         to: destination, destinationSlice: 0, destinationLevel: 0, destinationOrigin: origin)
        
        blitEncoder.endEncoding()
    }
    
    // --- Interaction Handling ---
    
    /// Updates the interaction state based on user input.
    func updateInteraction(point: CGPoint, viewSize: CGSize, isDragging: Bool) {
        guard viewSize.width > 0, viewSize.height > 0,
              currentDrawableSize.width > 0, currentDrawableSize.height > 0 else { return }
        
        // Normalize point to [0, 1] range using the view's bounds size
        let normalizedPoint = SIMD2<Float>(
            Float(point.x / viewSize.width),
            Float(point.y / viewSize.height) // UIKit coords (0,0 is top-left) match Metal texture coords
        )
        // Clamp to avoid edge issues if dragging slightly outside bounds
        interactionUniforms.interactionPoint = simd_clamp(normalizedPoint, .zero, SIMD2<Float>(1.0, 1.0))
        
        // Calculate velocity based on drag delta (in view points)
        if let lastPoint = lastInteractionPoint, isDragging {
            let deltaX = Float(point.x - lastPoint.x)
            let deltaY = Float(point.y - lastPoint.y)
            // Normalize velocity roughly to texture space? Needs careful scaling.
            // This scaling factor (0.05) is arbitrary, adjust for desired effect.
            let scaleFactor: Float = 0.05 / Float(min(textureWidth, textureHeight)) // Scale based on texture size
            interactionUniforms.interactionVelocity = SIMD2<Float>(deltaX, deltaY) * scaleFactor
            interactionUniforms.addVelocity = true
        } else {
            interactionUniforms.interactionVelocity = .zero
            interactionUniforms.addVelocity = false
        }
        
        // Set density color (e.g., random color on tap/drag start)
        if lastInteractionPoint == nil { // Start of interaction (tap or drag start)
            interactionUniforms.interactionColor = SIMD4<Float>(Float.random(in: 0.5...1.0), Float.random(in: 0.2...0.8), Float.random(in: 0.1...0.5), 1.0) // Random bright-ish color
        }
        interactionUniforms.addDensity = true // Add density whenever interacting
        
        // Update last point for velocity calculation next frame
        lastInteractionPoint = isDragging ? point : nil
    }
    
    /// Called when user interaction ends (e.g., finger lifted).
    func endInteraction() {
        lastInteractionPoint = nil
        // Stop adding sources - the draw loop will pick up these false flags
        interactionUniforms.addDensity = false
        interactionUniforms.addVelocity = false
        interactionUniforms.interactionVelocity = .zero // Ensure velocity stops being added
    }
    
    /// Copies the current Swift `interactionUniforms` struct data to the Metal buffer.
    func updateInteractionUniforms() {
        guard interactionUniformsBuffer != nil else { return }
        let pointer = interactionUniformsBuffer.contents().bindMemory(to: InteractionUniforms.self, capacity: 1)
        pointer[0] = interactionUniforms
    }
}

// MARK: - SwiftUI View Structure

struct FluidBackgroundView: UIViewRepresentable {
    typealias UIViewType = MTKView
    
    func makeCoordinator() -> Coordinator {
        guard let device = MTLCreateSystemDefaultDevice(),
              let renderer = FluidRenderer(mtkView: MTKView(frame: .zero, device: device)) else {
            fatalError("Fluid Renderer could not be initialized. Metal might not be supported or setup failed.")
        }
        return Coordinator(self, renderer: renderer)
    }
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.device = context.coordinator.renderer.device // Use renderer's device
        mtkView.enableSetNeedsDisplay = false // Rely on the draw loop
        mtkView.isPaused = false             // Run continuously
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        mtkView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mtkView.addGestureRecognizer(tapGesture)
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        // Usually empty for continuous Metal effects driven by the delegate/renderer
    }
    
    // MARK: Coordinator Class
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: FluidBackgroundView
        var renderer: FluidRenderer // Hold a strong reference to the renderer
        
        init(_ parent: FluidBackgroundView, renderer: FluidRenderer) {
            self.parent = parent
            self.renderer = renderer
            super.init()
        }
        
        // --- MTKViewDelegate ---
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            renderer.mtkView(view, drawableSizeWillChange: size)
        }
        
        func draw(in view: MTKView) {
            renderer.draw(in: view)
        }
        
        // --- Gesture Handling ---
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let view = gesture.view else { return }
            let location = gesture.location(in: view)
            let viewSize = view.bounds.size // Use view bounds size for gesture location context
            
            switch gesture.state {
            case .began, .changed:
                renderer.updateInteraction(point: location, viewSize: viewSize, isDragging: true)
            case .ended, .cancelled, .failed:
                renderer.endInteraction()
            default:
                break // Ignore other states like .possible
            }
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard gesture.state == .ended, let view = gesture.view else { return } // Handle tap on state .ended
            let location = gesture.location(in: view)
            let viewSize = view.bounds.size
            renderer.updateInteraction(point: location, viewSize: viewSize, isDragging: false)
        }
    }
}

// MARK: - Main SwiftUI Content View

struct ContentView: View {
    var body: some View {
        ZStack {
            FluidBackgroundView()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Interactive Fluid")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    .padding(.top, 60)
                
                Text("Drag or Tap")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.75))
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                    .padding(.top, 8)
                
                Spacer()
            }
        }
    }
}

// MARK: - Preview Provider

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

#Preview("ContentView") {
    ContentView()
}
