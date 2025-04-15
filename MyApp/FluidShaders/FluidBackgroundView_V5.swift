////
////  V5.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//import SwiftUI
//import MetalKit
//import simd // Required for SIMD vector types matching Metal's float2, float4, etc.
//
//// MARK: - Shared Structures (CPU <-> GPU)
//
///// Swift struct equivalent of the Metal InteractionUniforms struct.
///// MUST match the layout and types defined in the `.metal` file.
//struct InteractionUniforms {
//    var interactionPoint: SIMD2<Float>      // Corresponds to float2
//    var interactionVelocity: SIMD2<Float>   // Corresponds to float2
//    var interactionColor: SIMD4<Float>      // Corresponds to float4
//    var interactionRadius: Float            // Corresponds to float
//    var timestep: Float                     // Corresponds to float
//    var viscosity: Float                    // Corresponds to float
//    var addDensity: Bool                    // Corresponds to bool (Metal bool is usually 1 byte)
//    var addVelocity: Bool                   // Corresponds to bool
//}
//
//// MARK: - Swift Code: Fluid Simulation Renderer
//
//class FluidRenderer: NSObject, MTKViewDelegate {
//
//    // --- Metal Core Objects (Non-Optional after successful init) ---
//    let device: MTLDevice
//    let commandQueue: MTLCommandQueue
//
//    // --- Textures (Non-Optional after successful init) ---
//    // Using implicit unwrapping knowing init? guarantees creation or fails.
//    var velocityTextureA: MTLTexture!
//    var velocityTextureB: MTLTexture!
//    var densityTextureA: MTLTexture!
//    var densityTextureB: MTLTexture!
//    var pressureTextureA: MTLTexture!
//    var pressureTextureB: MTLTexture!
//    var divergenceTexture: MTLTexture!
//
//    // --- Pipeline states (Non-Optional after successful init) ---
//    var advectPSO: MTLComputePipelineState!
//    var addDensitySourcePSO: MTLComputePipelineState! // New PSO for density
//    var addVelocitySourcePSO: MTLComputePipelineState! // New PSO for velocity
//    var jacobiDiffusePSO: MTLComputePipelineState!
//    var divergencePSO: MTLComputePipelineState!
//    var jacobiPressurePSO: MTLComputePipelineState!
//    var subtractGradientPSO: MTLComputePipelineState!
//    var visualizeRenderPSO: MTLRenderPipelineState!
//    var clearTexturePSO: MTLComputePipelineState!
//
//    // --- Buffers (Non-Optional after successful init) ---
//    var interactionUniforms: InteractionUniforms // The Swift struct controlling simulation
//    var interactionUniformsBuffer: MTLBuffer!
//    var dtBuffer: MTLBuffer!
//    var diffusionParamsBuffer: MTLBuffer!
//    var gradParamsBuffer: MTLBuffer!
//
//    // --- Configuration ---
//    let textureWidth = 256
//    let textureHeight = 256
//    let jacobiIterations = 20 // Iterations for pressure solve
//    let diffusionIterations = 8 // Iterations for viscosity/diffusion
//    let simulationTimeStep: Float = 0.8
//    let fluidViscosity: Float = 0.000005 // Lower viscosity
//    let interactionRadiusScreenFraction: Float = 0.06 // Radius as fraction of min screen dim
//
//    // --- Private State ---
//    private var lastInteractionPoint: CGPoint? = nil
//    private var currentDrawableSize: CGSize = .zero // Track drawable size for calculations
//
//    // --- Failable Initializer ---
//    init?(mtkView: MTKView) {
//        // 1. Get Metal Device and Command Queue
//        guard let device = MTLCreateSystemDefaultDevice(),
//              let commandQueue = device.makeCommandQueue() else {
//            print("Error: Metal is not supported on this device or failed to create command queue.")
//            return nil // Initialization fails if Metal core components aren't available
//        }
//        self.device = device
//        self.commandQueue = commandQueue
//
//        // Initial interaction state
//        self.interactionUniforms = InteractionUniforms(
//            interactionPoint: .zero,
//            interactionVelocity: .zero,
//            interactionColor: .zero,
//            interactionRadius: 0.0, // Calculated later based on size
//            timestep: simulationTimeStep,
//            viscosity: fluidViscosity,
//            addDensity: false,
//            addVelocity: false
//        )
//
//        super.init() // Call super.init() after initializing properties
//
//        // 2. Configure MTKView
//        mtkView.device = device
//        mtkView.colorPixelFormat = .bgra8Unorm
//        mtkView.framebufferOnly = false // Typically true, false if reading from drawable needed
//        mtkView.clearColor = MTLClearColor(red: 0.01, green: 0.01, blue: 0.02, alpha: 1.0)
//        mtkView.delegate = self // Set delegate after super.init()
//
//        // 3. Perform Essential Metal Setup (Textures, Buffers, Pipelines)
//        // If any of these fail, the init? will cascade the `nil` return.
//        guard setupTextures(),
//              setupBuffers(),
//              setupPipelines() else {
//            print("Error: Failed during critical Metal setup (Textures, Buffers, or Pipelines).")
//            return nil
//        }
//
//        // 4. Initialize Textures (Clear them)
//        // Use a command buffer to ensure clearing happens before first draw
//        guard let initialClearBuffer = commandQueue.makeCommandBuffer() else {
//             print("Error: Could not create command buffer for initial texture clear.")
//             return nil // Crucial setup step failed
//        }
//        initialClearBuffer.label = "Initial Texture Clear CB"
//        clearTexture(commandBuffer: initialClearBuffer, texture: velocityTextureA)
//        clearTexture(commandBuffer: initialClearBuffer, texture: velocityTextureB)
//        clearTexture(commandBuffer: initialClearBuffer, texture: densityTextureA)
//        clearTexture(commandBuffer: initialClearBuffer, texture: densityTextureB)
//        clearTexture(commandBuffer: initialClearBuffer, texture: pressureTextureA)
//        clearTexture(commandBuffer: initialClearBuffer, texture: pressureTextureB)
//        clearTexture(commandBuffer: initialClearBuffer, texture: divergenceTexture)
//        initialClearBuffer.commit() // Commit the clearing commands
//        // Consider initialClearBuffer.waitUntilCompleted() if strict sync is needed before first frame,
//        // but usually not necessary as subsequent frames will queue after this one.
//
//        print("FluidRenderer initialized successfully.")
//    }
//
//    // --- Setup Helper Methods (Return Bool indicating success/failure) ---
//
//    func setupTextures() -> Bool {
//        let descriptor = MTLTextureDescriptor()
//        descriptor.textureType = .type2D
//        descriptor.width = textureWidth
//        descriptor.height = textureHeight
//        descriptor.usage = [.shaderRead, .shaderWrite]
//        descriptor.storageMode = .private // GPU optimal
//
//        // Velocity (RG channels, 16-bit float)
//        descriptor.pixelFormat = .rg16Float
//        guard let velA = device.makeTexture(descriptor: descriptor),
//              let velB = device.makeTexture(descriptor: descriptor) else { return false }
//        velocityTextureA = velA; velocityTextureA.label = "Velocity A"
//        velocityTextureB = velB; velocityTextureB.label = "Velocity B"
//
//        // Density (RGBA, 8-bit normalized)
//        descriptor.pixelFormat = .rgba8Unorm
//        guard let denA = device.makeTexture(descriptor: descriptor),
//              let denB = device.makeTexture(descriptor: descriptor) else { return false }
//        densityTextureA = denA; densityTextureA.label = "Density A"
//        densityTextureB = denB; densityTextureB.label = "Density B"
//
//        // Pressure/Divergence (Single channel, 16-bit float -> Use R16Float)
//        descriptor.pixelFormat = .r16Float
//        guard let presA = device.makeTexture(descriptor: descriptor),
//              let presB = device.makeTexture(descriptor: descriptor),
//              let div = device.makeTexture(descriptor: descriptor) else { return false }
//        pressureTextureA = presA; pressureTextureA.label = "Pressure A"
//        pressureTextureB = presB; pressureTextureB.label = "Pressure B"
//        divergenceTexture = div; divergenceTexture.label = "Divergence"
//
//        return true
//    }
//
//    func setupBuffers() -> Bool {
//        // Interaction Uniforms Buffer
//        guard let iUniformsBuff = device.makeBuffer(length: MemoryLayout<InteractionUniforms>.stride, options: .storageModeShared) else {
//             print("Error: Failed to create InteractionUniforms buffer.")
//             return false
//        }
//        interactionUniformsBuffer = iUniformsBuff
//        interactionUniformsBuffer.label = "Interaction Uniforms Buffer"
//
//        // Simple Timestep (dt) Buffer
//        guard let dtBuff = device.makeBuffer(length: MemoryLayout<Float>.stride, options: .storageModeShared) else {
//            print("Error: Failed to create dt buffer.")
//            return false
//        }
//        dtBuffer = dtBuff
//        dtBuffer.label = "Timestep (dt) Buffer"
//        // Upload initial dt value (safe to access contents after successful makeBuffer)
//        dtBuffer.contents().storeBytes(of: simulationTimeStep, as: Float.self)
//
//        // Diffusion Parameters Buffer [alpha, 1.0/beta]
//        guard let diffBuff = device.makeBuffer(length: MemoryLayout<Float>.stride * 2, options: .storageModeShared) else {
//            print("Error: Failed to create diffusion params buffer.")
//            return false
//        }
//        diffusionParamsBuffer = diffBuff
//        diffusionParamsBuffer.label = "Diffusion Params Buffer"
//        updateDiffusionParams() // Calculate and upload initial values
//
//        // Gradient Parameters Buffer [0.5/texWidth, 0.5/texHeight]
//        guard let gradBuff = device.makeBuffer(length: MemoryLayout<SIMD2<Float>>.stride, options: .storageModeShared) else {
//             print("Error: Failed to create gradient params buffer.")
//             return false
//         }
//         gradParamsBuffer = gradBuff
//         gradParamsBuffer.label = "Gradient Params Buffer"
//         updateGradientParams() // Calculate and upload initial values
//
//        return true
//    }
//
//    func setupPipelines() -> Bool {
//        // Load the default library (compiled from .metal files by Xcode)
//        guard let library = device.makeDefaultLibrary() else {
//            print("Error: Failed to get default Metal library. Is FluidShaders.metal included in the target?")
//            return false
//        }
//
//        do {
//            // --- Compute Pipelines ---
//            advectPSO = try makeComputePSO(library: library, functionName: "advect")
//            addDensitySourcePSO = try makeComputePSO(library: library, functionName: "add_density_source")
//            addVelocitySourcePSO = try makeComputePSO(library: library, functionName: "add_velocity_source")
//            jacobiDiffusePSO = try makeComputePSO(library: library, functionName: "diffuse_jacobi")
//            divergencePSO = try makeComputePSO(library: library, functionName: "calculate_divergence")
//            jacobiPressurePSO = try makeComputePSO(library: library, functionName: "pressure_jacobi")
//            subtractGradientPSO = try makeComputePSO(library: library, functionName: "subtract_gradient")
//            clearTexturePSO = try makeComputePSO(library: library, functionName: "clear_texture_kernel")
//
//            // --- Render Pipeline (for visualization) ---
//            let renderDesc = MTLRenderPipelineDescriptor()
//            renderDesc.label = "Fluid Visualization Pipeline"
//            guard let vertFunc = library.makeFunction(name: "fluid_vertex"),
//                  let fragFunc = library.makeFunction(name: "fluid_fragment") else {
//                print("Error: Could not find vertex or fragment function for render pipeline.")
//                return false
//            }
//            renderDesc.vertexFunction = vertFunc
//            renderDesc.fragmentFunction = fragFunc
//            renderDesc.colorAttachments[0].pixelFormat = .bgra8Unorm // Match MTKView's format
//            visualizeRenderPSO = try device.makeRenderPipelineState(descriptor: renderDesc)
//
//        } catch {
//            print("Error: Failed to create one or more pipeline states: \(error)")
//            return false // Indicate pipeline setup failure
//        }
//        return true // All pipelines created successfully
//    }
//
//    // Helper to create compute PSOs safely (throws error on failure)
//    func makeComputePSO(library: MTLLibrary, functionName: String) throws -> MTLComputePipelineState {
//        guard let function = library.makeFunction(name: functionName) else {
//            // Throwing an error is better than fatalError inside a helper
//             enum PipelineError: Error { case functionNotFound(String) }
//             throw PipelineError.functionNotFound("Metal function named '\(functionName)' not found in library.")
//        }
//        return try device.makeComputePipelineState(function: function)
//    }
//
//    // Helper to calculate optimal thread group size
//    func calculateThreadGroupSize(for pso: MTLComputePipelineState) -> MTLSize {
//         let w = pso.threadExecutionWidth
//         // Calculate height ensuring it doesn't exceed maxTotalThreadsPerThreadgroup and is at least 1
//         let h = max(1, pso.maxTotalThreadsPerThreadgroup / w)
//         return MTLSize(width: w, height: h, depth: 1)
//     }
//
//    // --- MTKViewDelegate Methods ---
//
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        currentDrawableSize = size
//        if size.width > 0 && size.height > 0 && textureWidth > 0 && textureHeight > 0 {
//            // Update interaction radius based on the new MIN dimension normalized to texture space
//            let minScreenDim = Float(min(size.width, size.height))
//            let minTextureDim = Float(min(textureWidth, textureHeight))
//            interactionUniforms.interactionRadius = interactionRadiusScreenFraction * minScreenDim / minTextureDim
//
//            // Recalculate gradient params (dependent on texture size, though it doesn't change here)
//            updateGradientParams()
//            print("Drawable size changed: \(size), Interaction Radius (Norm Texture Space): \(interactionUniforms.interactionRadius)")
//        } else {
//            print("Warning: drawableSizeWillChange called with zero dimension.")
//        }
//    }
//
//    func draw(in view: MTKView) {
//        // 1. Get Command Buffer and Drawable (Safely)
//        guard let commandBuffer = commandQueue.makeCommandBuffer(),
//              let currentDrawable = view.currentDrawable // Get drawable for presentation
//        else {
//            print("Warning: Could not get command buffer or drawable for this frame.")
//            return // Skip drawing this frame
//        }
//        commandBuffer.label = "Fluid Frame CB"
//
//        // 2. Update Uniforms Buffer
//        updateInteractionUniforms() // Copy latest interaction data
//
//        // 3. Encode Compute Passes (Safely)
//        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
//            print("Error: Failed to create compute encoder for simulation.")
//            commandBuffer.commit() // Commit buffer even if encoder fails? Or just return? Let's just return.
//            return
//        }
//        computeEncoder.label = "Fluid Simulation CE"
//
//        // Prepare grid and group sizes (assuming most kernels are compatible)
//        let threadsPerGrid = MTLSize(width: textureWidth, height: textureHeight, depth: 1)
//        let threadsPerThreadgroup = calculateThreadGroupSize(for: advectPSO) // Use one PSO as reference
//
//        // --- Simulation Steps ---
//
//        // 1. Advect Velocity (A -> B, then swap so result is in A)
//        computeEncoder.setComputePipelineState(advectPSO)
//        computeEncoder.setTexture(velocityTextureA, index: 0) // Velocity field (read)
//        computeEncoder.setTexture(velocityTextureA, index: 1) // Quantity to advect (velocity, sample)
//        computeEncoder.setTexture(velocityTextureB, index: 2) // Output (write)
//        computeEncoder.setBuffer(dtBuffer, offset: 0, index: 0) // Pass dt
//        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
//        swapVelocityTextures() // Result now in A
//
//        // 2. Advect Density (A -> B, then swap so result is in A)
//        // Re-use advectPSO state (already set)
//        computeEncoder.setTexture(velocityTextureA, index: 0) // Current velocity field (read)
//        computeEncoder.setTexture(densityTextureA, index: 1)  // Quantity to advect (density, sample)
//        computeEncoder.setTexture(densityTextureB, index: 2)  // Output (write)
//        // dt buffer still bound at index 0
//        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
//        swapDensityTextures() // Result now in A
//
//        // 3. Apply Diffusion (Viscosity) to Velocity (Iteratively A <-> B)
//        if fluidViscosity > 0 && diffusionIterations > 0 {
//            computeEncoder.setComputePipelineState(jacobiDiffusePSO)
//            // Set diffusion params once per frame
//            computeEncoder.setBuffer(diffusionParamsBuffer, offset: 0, index: 0) // alpha
//            computeEncoder.setBuffer(diffusionParamsBuffer, offset: MemoryLayout<Float>.stride, index: 1) // beta_recip
//
//            // No force unwrap needed: init? guarantees textures exist
//            let vel_b = velocityTextureA // Input 'b' term (velocity A before diffusion)
//            var vel_x_k = velocityTextureA // Previous iteration x_k (starts as A)
//            var vel_x_k1 = velocityTextureB // Next iteration x_{k+1} (starts as B)
//
//            for _ in 0..<diffusionIterations {
//                computeEncoder.setTexture(vel_b, index: 0)     // quantity_b (constant A)
//                computeEncoder.setTexture(vel_x_k, index: 1)   // quantity_x_prev (result from last iter)
//                computeEncoder.setTexture(vel_x_k1, index: 2)  // quantity_x_next (output of this iter)
//                computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
//                // Swap textures: output becomes input for next iteration
//                swap(&vel_x_k, &vel_x_k1) // Swap the references vel_x_k and vel_x_k1 point to
//            }
//            // Final diffused velocity is now in vel_x_k (which points to A or B)
//            // Ensure velocityTextureA holds the final result if iterations were even
//            if vel_x_k !== velocityTextureA {
//                 // Need a blit encoder *within* the current command buffer
//                 computeEncoder.endEncoding() // End compute before starting blit
//                blitTexture(commandBuffer: commandBuffer, source: vel_x_k!, destination: velocityTextureA)
//                 // Start a new compute encoder if more compute needed (not needed here)
//                 // Re-create encoder if needed after blit:
//                 // guard let nextEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
//                 // computeEncoder = nextEncoder // Requires computeEncoder to be var
//                 // Or structure code differently to avoid mid-compute blits if possible.
//            }
//        }
//         // Ensure compute encoder is valid before proceeding if blit happened.
//         // If the above blit path *wasn't* taken, 'computeEncoder' is still valid.
//         // If it *was* taken, we need a new one if more compute follows.
//         // Let's assume the encoder is valid for now, or restructure if issues arise.
//        // FIXME: Potential issue if blit occurs - encoder needs recreation or blit moved.
//
//        // 4. Add Sources (Dispatch distinct kernels based on CPU flags)
//        computeEncoder.setBuffer(interactionUniformsBuffer, offset: 0, index: 0) // Set uniforms for both subsequent dispatches
//
//        if interactionUniforms.addDensity {
//            computeEncoder.setComputePipelineState(addDensitySourcePSO)
//            computeEncoder.setTexture(densityTextureA, index: 0)
//            computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
//        }
//
//        if interactionUniforms.addVelocity {
//            computeEncoder.setComputePipelineState(addVelocitySourcePSO)
//            computeEncoder.setTexture(velocityTextureA, index: 0)
//            computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
//        }
//
//        // Flags are reset in updateInteraction / endInteraction on the CPU side
//               // 5. Projection Step (Make fluid incompressible)
//               // 5a. Calculate Divergence (Velocity A -> Divergence Texture)
//               computeEncoder.setComputePipelineState(divergencePSO)
//               computeEncoder.setTexture(velocityTextureA, index: 0)   // Input velocity
//               computeEncoder.setTexture(divergenceTexture, index: 1) // Output divergence
//               computeEncoder.setBuffer(gradParamsBuffer, offset: 0, index: 0) // Pass halfTexelSize
//               computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
//       
//               // 5b. Solve Pressure (Iteratively A <-> B using Divergence) -> Final pressure in A or B
//               // Clear initial pressure guess (optional, helps stability)
//               // Clearing pressure textures if needed
//               if jacobiIterations > 0 { // Only clear if we're about to solve pressure
//                   clearTexture(commandBuffer: any MTLCommandBuffer, texture: pressureTextureA) // Use compute clear
//                   clearTexture(commandBuffer: any MTLCommandBuffer, texture: pressureTextureB) // Use compute clear
//               }
//       
//               computeEncoder.setComputePipelineState(jacobiPressurePSO)
//               computeEncoder.setTexture(divergenceTexture, index: 0) // Input divergence (RHS, fixed)
//       
//               var pressure_k = pressureTextureA! // Previous pressure
//               var pressure_k1 = pressureTextureB! // Next pressure
//       
//               for _ in 0..<jacobiIterations {
//                   computeEncoder.setTexture(pressure_k, index: 1)     // pressurePrevIter
//                   computeEncoder.setTexture(pressure_k1, index: 2)    // pressureOut
//                   computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
//                   // Prepare for next iteration
//                   swap(&pressure_k, &pressure_k1)
//               }
//               // Final pressure is in pressure_k (which points to pressureTextureA or B)
//       
//               // 5c. Subtract Gradient (Updates Velocity A using final pressure_k)
//               computeEncoder.setComputePipelineState(subtractGradientPSO)
//               computeEncoder.setTexture(velocityTextureA, index: 0) // Velocity field to modify (read/write)
//               computeEncoder.setTexture(pressure_k, index: 1)       // Final pressure field (sample)
//               computeEncoder.setBuffer(gradParamsBuffer, offset: 0, index: 0) // Pass halfTexelSize
//               computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
//               // velocityTextureA now holds the divergence-free velocity field
//       
//               computeEncoder.endEncoding() // Finish all compute dispatches
//       
//               // Add explicit barrier if clearing pressure textures caused issues (unlikely but possible)
//               // Note: Command buffer submission ensures kernels complete before render pass starts,
//               // but clearing in a separate command buffer adds complexity. Clearing inline like this is better.
//               // commandBuffer.commit() // Avoid this mid-frame if possible
//               // commandBuffer = commandQueue.makeCommandBuffer()! // Need a new one
//       
//               // --- Render Pass (Visualize Density A to Screen) ---
//               guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
//                   print("Warning: Could not get render pass descriptor.")
//                   commandBuffer.commit()
//                   return
//               }
//       
//               guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//                   print("Error: Failed to create render command encoder.")
//                   commandBuffer.commit()
//                   return
//               }
//               renderEncoder.label = "Fluid Visualization Render Pass"
//       
//               renderEncoder.setRenderPipelineState(visualizeRenderPSO)
//               renderEncoder.setFragmentTexture(densityTextureA, index: 0) // Visualize Density A
//       
//               // Draw a full-screen quad (6 vertices specified in vertex shader)
//               renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
//       
//               renderEncoder.endEncoding()
//       
//               // --- Present Drawable ---
//               commandBuffer.present(currentDrawable)
//               commandBuffer.commit()
//
//        // 6. Render Pass (Visualize Density A to Screen - Safely)
//        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
//             print("Warning: Could not get render pass descriptor for this frame.")
//             commandBuffer.commit() // Still commit previous work
//             return
//        }
//
//        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//            print("Error: Failed to create render command encoder.")
//            commandBuffer.commit()
//            return
//        }
//        renderEncoder.label = "Fluid Visualization Render Pass"
//
//        renderEncoder.setRenderPipelineState(visualizeRenderPSO)
//        renderEncoder.setFragmentTexture(densityTextureA, index: 0) // Visualize Density A
//
//        // Draw a full-screen quad (6 vertices generated in vertex shader)
//        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
//
//        renderEncoder.endEncoding()
//
//        // 7. Present Drawable
//        commandBuffer.present(currentDrawable)
//        commandBuffer.commit() // Commit all encoded work
//    }
//
//    // --- Utility Methods ---
//
//    func swapDensityTextures() { swap(&densityTextureA, &densityTextureB) }
//    func swapVelocityTextures() { swap(&velocityTextureA, &velocityTextureB) }
//    func swapPressureTextures() { swap(&pressureTextureA, &pressureTextureB) }
//
//    /// Utility to copy textures using a Blit encoder on the provided command buffer.
//    func blitTexture(commandBuffer: MTLCommandBuffer, source: MTLTexture, destination: MTLTexture) {
//         guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
//             print("Error: Failed to create blit command encoder for texture copy.")
//             // Decide how to handle - maybe just return and accept potential visual glitch?
//             return
//         }
//         blitEncoder.label = "Blit Texture (\(source.label ?? "src") -> \(destination.label ?? "dst"))"
//         let origin = MTLOrigin(x: 0, y: 0, z: 0)
//         let size = MTLSize(width: source.width, height: source.height, depth: source.depth)
//         blitEncoder.copy(from: source, sourceSlice: 0, sourceLevel: 0, sourceOrigin: origin, sourceSize: size,
//                          to: destination, destinationSlice: 0, destinationLevel: 0, destinationOrigin: origin)
//         blitEncoder.endEncoding()
//    }
//
//     /// Enqueues a compute kernel to clear the given texture to zero *within an existing compute pass*.
//     /// Assumes the compute encoder is valid and the clearTexturePSO is set up.
//     func clearTextureCompute(computeEncoder: MTLComputeCommandEncoder, texture: MTLTexture) {
//         guard let validClearPSO = clearTexturePSO else {
//              print("Error: Clear Texture PSO is not initialized. Cannot clear \(texture.label ?? "unnamed") in compute pass.")
//              return // Skip clearing if PSO is missing
//         }
//
//         // Temporarily set the clear PSO
//         computeEncoder.pushDebugGroup("Clear \(texture.label ?? "unnamed")")
//         computeEncoder.setComputePipelineState(validClearPSO)
//         computeEncoder.setTexture(texture, index: 0) // Target texture at index 0
//
//         let threadsPerGrid = MTLSize(width: texture.width, height: texture.height, depth: 1)
//         let threadsPerThreadgroup = calculateThreadGroupSize(for: validClearPSO)
//         computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
//         computeEncoder.popDebugGroup()
//
//         // Note: Caller must restore the previous compute pipeline state if needed after this call.
//     }
//
//    /// Clears the given texture to zero using a dedicated command buffer and compute pass.
//     /// This is less efficient than clearing within an existing pass but useful for initialization.
//     func clearTexture(commandBuffer: MTLCommandBuffer, texture: MTLTexture) {
//        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
//            print("Error: Failed to create compute encoder for clearing texture \(texture.label ?? "unlabeled").")
//            return
//        }
//        computeEncoder.label = "Clear Texture (\(texture.label ?? "unlabeled")) CE"
//
//        guard let validClearPSO = clearTexturePSO else {
//             print("Error: Clear Texture PSO is not initialized. Cannot clear texture \(texture.label ?? "unlabeled").")
//             computeEncoder.endEncoding() // Still need to end encoding even on error
//             return
//        }
//
//        computeEncoder.setComputePipelineState(validClearPSO)
//        computeEncoder.setTexture(texture, index: 0) // Target texture at index 0
//
//        // Dispatch threads covering the entire texture
//        let threadsPerGrid = MTLSize(width: texture.width, height: texture.height, depth: 1)
//        let threadsPerThreadgroup = calculateThreadGroupSize(for: validClearPSO)
//        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
//
//        computeEncoder.endEncoding()
//        // Do not commit here; the caller (e.g., init) is responsible for committing the buffer.
//    }
//
//    // --- Buffer Update Methods ---
//
//    /// Updates the diffusion parameters buffer based on current viscosity and timestep.
//    func updateDiffusionParams() {
//         guard let buffer = diffusionParamsBuffer, fluidViscosity > 0, simulationTimeStep > 0 else {
//             print("Warning: Cannot update diffusion params - buffer nil or invalid parameters.")
//             return
//         }
//         let dx_sq: Float = 1.0 * 1.0 // Assume grid spacing dx=1
//         let alpha = dx_sq / (fluidViscosity * simulationTimeStep)
//         let beta_recip = 1.0 / (4.0 + alpha)
//         let params: [Float] = [alpha, beta_recip]
//         // Safely copy data to the buffer's memory
//         buffer.contents().copyMemory(from: params, byteCount: MemoryLayout<Float>.stride * 2)
//     }
//
//     /// Updates the gradient parameters buffer based on texture dimensions.
//     func updateGradientParams() {
//          guard let buffer = gradParamsBuffer, textureWidth > 0, textureHeight > 0 else {
//               print("Warning: Cannot update gradient params - buffer nil or invalid texture dimensions.")
//               return
//          }
//          let halfTexelSize = SIMD2<Float>(0.5 / Float(textureWidth), 0.5 / Float(textureHeight))
//          // Safely store data in the buffer's memory
//         buffer.contents().storeBytes(of: halfTexelSize, as: SIMD2<Float>.self)
//      }
//
//    /// Copies the current Swift `interactionUniforms` struct data to the Metal GPU buffer.
//    func updateInteractionUniforms() {
//        guard let buffer = interactionUniformsBuffer else {
//            print("Warning: Interaction uniforms buffer is nil. Cannot update.")
//            return
//        }
//        // Safely get a typed pointer and update the buffer contents
//        let pointer = buffer.contents().bindMemory(to: InteractionUniforms.self, capacity: 1)
//        pointer[0] = interactionUniforms
//    }
//
//    // --- Interaction Handling ---
//
//    /// Updates the interaction state based on user input (tap or drag).
//    func updateInteraction(point: CGPoint, viewSize: CGSize, isDragging: Bool) {
//        guard viewSize.width > 0, viewSize.height > 0,
//              currentDrawableSize.width > 0, currentDrawableSize.height > 0 else {
//             print("Warning: Skipping interaction update due to zero view/drawable size.")
//             return
//        }
//
//        // 1. Normalize interaction point from View coordinates to Texture coordinates [0, 1]
//        let normalizedPoint = SIMD2<Float>(
//            Float(point.x / viewSize.width),
//            Float(point.y / viewSize.height) // UIKit/AppKit coords (0,0 top-left) match Metal tex coords
//        )
//        // Clamp to avoid issues if interaction goes slightly outside bounds
//        interactionUniforms.interactionPoint = simd_clamp(normalizedPoint, .zero, SIMD2<Float>(1.0, 1.0))
//
//        // 2. Calculate interaction velocity (if dragging)
//        if let last = lastInteractionPoint, isDragging {
//            let deltaX = Float(point.x - last.x)
//            let deltaY = Float(point.y - last.y) // Y increases downwards in view coords
//
//            // Scale velocity based on drag distance and texture size for a consistent effect
//            // This scaling factor needs tuning based on desired visual strength.
//            let scaleFactor: Float = 0.05 / Float(min(textureWidth, textureHeight))
//            interactionUniforms.interactionVelocity = SIMD2<Float>(deltaX, deltaY) * scaleFactor
//            interactionUniforms.addVelocity = true
//        } else {
//            interactionUniforms.interactionVelocity = .zero // No velocity if not dragging
//            interactionUniforms.addVelocity = false
//        }
//
//        // 3. Set density color (e.g., random color on interaction start)
//        if lastInteractionPoint == nil { // First point of interaction (tap or drag start)
//             interactionUniforms.interactionColor = SIMD4<Float>(
//                 Float.random(in: 0.5...1.0), // R
//                 Float.random(in: 0.2...0.8), // G
//                 Float.random(in: 0.1...0.5), // B
//                 1.0)                         // A
//        }
//        interactionUniforms.addDensity = true // Always add density when interacting
//
//        // 4. Update last point for next frame's velocity calculation
//        lastInteractionPoint = isDragging ? point : nil // Only store if currently dragging
//    }
//
//    /// Called when user interaction ends (e.g., finger lifted).
//    func endInteraction() {
//        lastInteractionPoint = nil
//        // Signal to stop adding sources in the next frame
//        interactionUniforms.addDensity = false
//        interactionUniforms.addVelocity = false
//        interactionUniforms.interactionVelocity = .zero // Explicitly zero out velocity
//    }
//}
//
//// MARK: - SwiftUI View Structure
//
//struct FluidBackgroundView: UIViewRepresentable {
//    // Use UIView or NSView based on target platform
//    #if os(iOS) || os(tvOS)
//    typealias UIViewType = MTKView
//    #elseif os(macOS)
//    typealias NSViewType = MTKView
//    #endif
//
//    // Coordinator handles delegate methods and gestures
//    func makeCoordinator() -> Coordinator {
//        // Try to create the renderer; fatalError if it fails, as the view cannot function.
//        guard let renderer = FluidRenderer(mtkView: MTKView(frame: .zero)) else {
//             fatalError("Fluid Renderer could not be initialized. Metal support or setup failed.")
//         }
//        return Coordinator(self, renderer: renderer)
//    }
//
//    // Create the underlying MTKView
//    #if os(iOS) || os(tvOS)
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//        setupMTKView(mtkView, context: context)
//
//        // --- iOS/tvOS Gestures ---
//        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
//        mtkView.addGestureRecognizer(panGesture)
//
//        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
//        mtkView.addGestureRecognizer(tapGesture)
//        // --- ---
//
//        return mtkView
//    }
//    #elseif os(macOS)
//    func makeNSView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//        setupMTKView(mtkView, context: context)
//
//        // --- macOS Gestures ---
//        // Note: macOS gesture handling is slightly different (mouse events)
//         let panGesture = NSPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
//         mtkView.addGestureRecognizer(panGesture)
//
//         let clickGesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleClick(_:)))
//         mtkView.addGestureRecognizer(clickGesture)
//        // --- ---
//
//        return mtkView
//    }
//    #endif
//
//    // Common setup for MTKView on both platforms
//    func setupMTKView(_ mtkView: MTKView, context: Context) {
//        mtkView.delegate = context.coordinator   // Coordinator handles drawing
//        mtkView.device = context.coordinator.renderer.device // Use renderer's device
//        mtkView.enableSetNeedsDisplay = false    // Renderer drives display via draw loop
//        mtkView.isPaused = false                 // Start drawing immediately
//        #if os(macOS)
//        mtkView.layer?.isOpaque = true          // Performance hint for macOS layer
//        #endif
//    }
//
//    // Update view (usually not needed for continuous Metal rendering)
//    #if os(iOS) || os(tvOS)
//    func updateUIView(_ uiView: MTKView, context: Context) { }
//    #elseif os(macOS)
//    func updateNSView(_ nsView: MTKView, context: Context) { }
//    #endif
//
//    // MARK: Coordinator Class
//    class Coordinator: NSObject, MTKViewDelegate {
//        var parent: FluidBackgroundView
//        var renderer: FluidRenderer // Hold the renderer
//
//        init(_ parent: FluidBackgroundView, renderer: FluidRenderer) {
//            self.parent = parent
//            self.renderer = renderer
//            super.init()
//        }
//
//        // --- MTKViewDelegate Conformance ---
//        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//            renderer.mtkView(view, drawableSizeWillChange: size)
//        }
//
//        func draw(in view: MTKView) {
//            renderer.draw(in: view)
//        }
//
//        // --- Gesture Handling ---
//
//        #if os(iOS) || os(tvOS)
//        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
//            guard let view = gesture.view else { return }
//            let location = gesture.location(in: view)
//            let viewSize = view.bounds.size
//
//            switch gesture.state {
//            case .began, .changed:
//                 renderer.updateInteraction(point: location, viewSize: viewSize, isDragging: true)
//            case .ended, .cancelled, .failed:
//                 renderer.endInteraction()
//            default:
//                 break
//            }
//        }
//
//        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
//            guard gesture.state == .ended, let view = gesture.view else { return }
//            let location = gesture.location(in: view)
//            let viewSize = view.bounds.size
//             // Treat tap as a non-dragging interaction at the final point
//            renderer.updateInteraction(point: location, viewSize: viewSize, isDragging: false)
//            // Consider automatically calling endInteraction shortly after for a 'splash' effect
//            // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in self?.renderer.endInteraction() }
//        }
//        #elseif os(macOS)
//        @objc func handlePan(_ gesture: NSPanGestureRecognizer) {
//             guard let view = gesture.view else { return }
//             let location = gesture.location(in: view)
//             let viewSize = view.bounds.size
//
//             switch gesture.state {
//             case .began, .changed:
//                 // Convert location from view's flipped coordinate system if necessary
//                 // let flippedLocation = CGPoint(x: location.x, y: viewSize.height - location.y)
//                 renderer.updateInteraction(point: location, viewSize: viewSize, isDragging: true)
//             case .ended, .cancelled, .failed:
//                 renderer.endInteraction()
//             default:
//                 break
//             }
//         }
//
//         @objc func handleClick(_ gesture: NSClickGestureRecognizer) {
//             guard gesture.state == .ended, let view = gesture.view else { return }
//             let location = gesture.location(in: view)
//             let viewSize = view.bounds.size
//             // let flippedLocation = CGPoint(x: location.x, y: viewSize.height - location.y)
//             renderer.updateInteraction(point: location, viewSize: viewSize, isDragging: false)
//             // Optional: End interaction quickly for a splash effect
//             // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in self?.renderer.endInteraction() }
//         }
//        #endif
//    }
//}
//
//// MARK: - Main SwiftUI Content View
//
//struct ContentView: View {
//    var body: some View {
//        ZStack {
//            FluidBackgroundView()
//                .edgesIgnoringSafeArea(.all) // Make it cover the whole screen
//
//            VStack {
//                Text("Interactive Fluid")
//                    .font(.system(size: 34, weight: .bold, design: .rounded))
//                    .foregroundColor(.white.opacity(0.85))
//                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
//                    .padding(.top, 60) // Adjust padding as needed
//
//                Text("Drag or Tap/Click")
//                     .font(.title3)
//                     .foregroundColor(.white.opacity(0.75))
//                     .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
//                     .padding(.top, 8)
//
//                Spacer() // Pushes text towards the top
//            }
//        }
//         // Consider `.persistentSystemOverlays(.hidden)` for a more immersive feel on supporting OS versions
//         // .persistentSystemOverlays(.hidden) // Hides home indicator etc.
//    }
//}
//
//// MARK: - Preview Provider
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//             // Explicitly set a preview device if needed
//             // .previewDevice("iPhone 14 Pro")
//    }
//}
