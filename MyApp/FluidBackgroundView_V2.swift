//
//  FluidBackgroundView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//


import SwiftUI
import MetalKit
import simd // For SIMD types used in shaders

// MARK: - Metal Shaders (Compute & Render)

let fluidShaderSource = """
#include <metal_stdlib>
using namespace metal;

// MARK: Structures --------------

// Data passed from CPU about interaction
struct InteractionUniforms {
    float2 interactionPoint; // Normalized position [0, 1]
    float2 interactionVelocity; // Force vector
    float4 interactionColor; // Color (density) to add
    float interactionRadius; // Radius of influence
    float timestep;         // dt
    float viscosity;        // Diffusion rate
    bool addDensity;       // Flag: add density this frame?
    bool addVelocity;      // Flag: add velocity this frame?
};

// Simple Vertex output (position + texcoord) for screen quad
struct RasterizerData {
    float4 position [[position]];
    float2 texCoord;
};

// MARK: Vertex Shader (Screen Quad) --------------

vertex RasterizerData fluid_vertex(uint vid [[vertex_id]]) {
    RasterizerData out;
    // Simple vertices for a full-screen triangle pair (quad)
    float4 positions[6] = {
        float4(-1, -1, 0, 1), float4( 1, -1, 0, 1), float4(-1,  1, 0, 1),
        float4(-1,  1, 0, 1), float4( 1, -1, 0, 1), float4( 1,  1, 0, 1)
    };
    // Corresponding texture coordinates
    float2 texCoords[6] = {
        float2(0, 1), float2(1, 1), float2(0, 0),
        float2(0, 0), float2(1, 1), float2(1, 0)
    };

    out.position = positions[vid];
    out.texCoord = texCoords[vid];
    return out;
}

// MARK: Fragment Shader (Visualize Density) --------------

fragment float4 fluid_fragment(RasterizerData in [[stage_in]],
                                texture2d<float, access::sample> densityTexture [[texture(0)]]) {
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    float4 densityColor = densityTexture.sample(s, in.texCoord);
    // Simple visualization: use density directly as color (assuming RGBA density)
    // Could also just use density.r for grayscale, or map it through a color gradient.
    return densityColor;
    // Example: Grayscale from density.r
    // return float4(densityColor.rrr, 1.0);
}

// MARK: Compute Shaders: Fluid Simulation Steps --------------

// --- Helper: Bilinear Interpolation ---
float4 sample_bilinear(texture2d<float, access::sample> tex, float2 uv, float texelSizeX, float texelSizeY) {
    constexpr sampler s(coord::pixel, address::clamp_to_edge, filter::linear);
    // Sample using pixel coordinates for potentially higher precision with linear filter
    return tex.sample(s, uv * float2(texelSizeX, texelSizeY));
}

// --- 1. Advection ---
// Moves quantity (velocity or density) along the velocity field
// Uses a backward trace (semi-Lagrangian method)
kernel void advect(texture2d<float, access::read> velocityIn [[texture(0)]],    // Velocity field to advect along
                    texture2d<float, access::sample> quantityIn [[texture(1)]], // Quantity to advect (can be velocity or density)
                    texture2d<float, access::write> quantityOut [[texture(2)]], // Resulting advected quantity
                    constant float &dt [[buffer(0)]],                          // Timestep
                    uint2 gid [[thread_position_in_grid]])
{
    float texelSizeX = 1.0 / velocityIn.get_width();
    float texelSizeY = 1.0 / velocityIn.get_height();
    float2 uv = float2(gid) * float2(texelSizeX, texelSizeY); // Normalized pos

    // Read velocity at current grid point (convert uint2 gid to float2 for lookup)
    float2 vel = velocityIn.read(gid).xy; // Assuming velocity is stored in xy

    // Trace backward in time
    float2 prevUV = uv - vel * dt;

    // Sample the quantity at the previous position using bilinear interpolation
    float4 advectedQuantity = sample_bilinear(quantityIn, prevUV, quantityIn.get_width(), quantityIn.get_height());

    quantityOut.write(advectedQuantity, gid);
}

// --- 2. Add External Forces/Density ---
kernel void add_source(texture2d<float, access::read_write> field [[texture(0)]], // Field to modify (velocity or density)
                       constant InteractionUniforms &uniforms [[buffer(0)]],
                       uint2 gid [[thread_position_in_grid]])
{
    // Only add if flags are set
    if (!uniforms.addDensity && !uniforms.addVelocity) return;

    float texelSizeX = 1.0 / field.get_width();
    float texelSizeY = 1.0 / field.get_height();
    float2 uv = float2(gid) * float2(texelSizeX, texelSizeY); // Normalized pos

    float dx = uv.x - uniforms.interactionPoint.x;
    float dy = uv.y - uniforms.interactionPoint.y;
    float distSq = dx * dx + dy * dy;
    float radiusSq = uniforms.interactionRadius * uniforms.interactionRadius;

    // Add force/density within the interaction radius using a smooth falloff
    if (distSq < radiusSq) {
        float falloff = 1.0 - smoothstep(0.0, radiusSq, distSq);
        float4 valueToAdd;
        if (uniforms.addDensity) {
             valueToAdd = uniforms.interactionColor * falloff * uniforms.timestep;
        } else { // addVelocity
             valueToAdd = float4(uniforms.interactionVelocity, 0.0, 0.0) * falloff * uniforms.timestep;
        }

        float4 currentValue = field.read(gid);
        field.write(currentValue + valueToAdd, gid);
    }
}

// --- 3. Diffusion (Implicit method using Jacobi iterations for stability) ---
// Solves (I - viscosity * dt * Laplacian) * quantity_new = quantity_old
kernel void diffuse_jacobi(texture2d<float, access::sample> quantityIn [[texture(0)]], // Input quantity (from previous step or advection)
                           texture2d<float, access::sample> quantityPrevIter [[texture(1)]], // Quantity from previous Jacobi iteration
                           texture2d<float, access::write> quantityOut [[texture(2)]],  // Output for this iteration
                           constant InteractionUniforms &uniforms [[buffer(0)]], // Need dt, viscosity
                           uint2 gid [[thread_position_in_grid]])
{
    float4 x_in = quantityIn.read(gid);          // b in Ax=b
    float4 x_prev = quantityPrevIter.read(gid);  // x from previous iteration

    // Sample neighbors (using read for direct texel access)
    int width = quantityPrevIter.get_width();
    int height = quantityPrevIter.get_height();
    int x = gid.x;
    int y = gid.y;

    float4 left   = quantityPrevIter.read(uint2(max(0, x - 1), y));
    float4 right  = quantityPrevIter.read(uint2(min(width - 1, x + 1), y));
    float4 bottom = quantityPrevIter.read(uint2(x, max(0, y - 1))); // Metal texture origin is top-left
    float4 top    = quantityPrevIter.read(uint2(x, min(height - 1, y + 1)));

    // Jacobi iteration for the diffusion equation
    float alpha = 1.0 / (uniforms.viscosity * uniforms.timestep); // dx^2/ (nu*dt) -- assuming dx=1 here
    float beta = 4.0 + alpha;

    float4 result = (x_in * alpha + left + right + bottom + top) / beta;

    quantityOut.write(result, gid);
}

// --- 4. Divergence Calculation ---
// Computes the divergence of the velocity field (how much fluid flows out of a point)
kernel void calculate_divergence(texture2d<float, access::sample> velocityField [[texture(0)]],
                                 texture2d<float, access::write> divergenceField [[texture(1)]],
                                 uint2 gid [[thread_position_in_grid]])
{
    // Sample neighboring velocities (halve distance for central differencing)
    int width = velocityField.get_width();
    int height = velocityField.get_height();
    int x = gid.x;
    int y = gid.y;

    float velL = velocityField.read(uint2(max(0, x - 1), y)).x;
    float velR = velocityField.read(uint2(min(width - 1, x + 1), y)).x;
    float velB = velocityField.read(uint2(x, max(0, y - 1))).y; // Metal y is down
    float velT = velocityField.read(uint2(x, min(height - 1, y + 1))).y;

    // Central difference for divergence: dVx/dx + dVy/dy
    // Assuming grid spacing dx=dy=1 for simplicity here
    float divergence = 0.5 * (velR - velL + velT - velB);

    divergenceField.write(float4(divergence, 0, 0, 0), gid);
}

// --- 5. Pressure Solve (Jacobi iterations for Poisson equation: Laplacian(pressure) = divergence) ---
kernel void pressure_jacobi(texture2d<float, access::sample> divergenceField [[texture(0)]], // Right hand side (b)
                            texture2d<float, access::sample> pressurePrevIter [[texture(1)]], // Pressure from previous Jacobi iteration
                            texture2d<float, access::write> pressureOut [[texture(2)]],   // Output pressure for this iteration
                            uint2 gid [[thread_position_in_grid]])
{
    float divergence = divergenceField.read(gid).x; // b in Ax=b (Laplacian(p) = div)

    // Sample neighboring pressures
    int width = pressurePrevIter.get_width();
    int height = pressurePrevIter.get_height();
    int x = gid.x;
    int y = gid.y;

    float pressureL = pressurePrevIter.read(uint2(max(0, x - 1), y)).x;
    float pressureR = pressurePrevIter.read(uint2(min(width - 1, x + 1), y)).x;
    float pressureB = pressurePrevIter.read(uint2(x, max(0, y - 1))).x;
    float pressureT = pressurePrevIter.read(uint2(x, min(height - 1, y + 1))).x;

    // Jacobi iteration for Poisson equation: (pressureL + pressureR + pressureB + pressureT - divergence) / 4
    // Note: Sign of divergence depends on formulation; here assuming Laplacian(p) = divergence
    // The alpha = -dx^2 part is implicitly 1 here
    float beta = 4.0;

    float result = (pressureL + pressureR + pressureB + pressureT - divergence) / beta;

    pressureOut.write(float4(result, 0, 0, 0), gid);
}

// --- 6. Subtract Pressure Gradient ---
// Adjusts the velocity field to make it divergence-free using the calculated pressure
kernel void subtract_gradient(texture2d<float, access::read_write> velocityField [[texture(0)]],
                              texture2d<float, access::sample> pressureField [[texture(1)]],
                              uint2 gid [[thread_position_in_grid]])
{
    // Sample neighboring pressures for gradient calculation
    int width = pressureField.get_width();
    int height = pressureField.get_height();
    int x = gid.x;
    int y = gid.y;

    float pressureL = pressureField.read(uint2(max(0, x - 1), y)).x;
    float pressureR = pressureField.read(uint2(min(width - 1, x + 1), y)).x;
    float pressureB = pressureField.read(uint2(x, max(0, y - 1))).x;
    float pressureT = pressureField.read(uint2(x, min(height - 1, y + 1))).x;

    // Calculate pressure gradient (central difference)
    float gradX = 0.5 * (pressureR - pressureL);
    float gradY = 0.5 * (pressureT - pressureB);

    // Read current velocity and subtract the gradient
    float2 currentVel = velocityField.read(gid).xy;
    float2 newVel = currentVel - float2(gradX, gradY);

    velocityField.write(float4(newVel, 0, 0), gid); // Write back divergence-free velocity
}

"""

// MARK: - Swift Code: Fluid Simulation Renderer

class FluidRenderer: NSObject, MTKViewDelegate {

    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    // Textures for simulation state (using ping-pong for some)
    var velocityTextureA: MTLTexture!
    var velocityTextureB: MTLTexture!
    var densityTextureA: MTLTexture!
    var densityTextureB: MTLTexture!
    var pressureTexture: MTLTexture!
    var divergenceTexture: MTLTexture!

    // Pipeline states
    var advectPSO: MTLComputePipelineState!
    var addSourcePSO: MTLComputePipelineState!
    var jacobiDiffusePSO: MTLComputePipelineState! // For diffusion
    var divergencePSO: MTLComputePipelineState!
    var jacobiPressurePSO: MTLComputePipelineState! // For pressure solve
    var subtractGradientPSO: MTLComputePipelineState!
    var visualizeRenderPSO: MTLRenderPipelineState! // Renders density to screen

    // Interaction state
    var interactionUniforms: InteractionUniforms
    var interactionUniformsBuffer: MTLBuffer!

    // Texture dimensions
    let textureWidth = 256
    let textureHeight = 256

    // Simulation parameters
    let jacobiIterations = 20 // Pressure solve iterations
    let diffusionIterations = 5 // Diffusion iterations
    let simulationTimeStep: Float = 0.8
    let fluidViscosity: Float = 0.00001 // Low viscosity
    let interactionRadiusScreenFraction: Float = 0.05 // Radius as fraction of min screen dimension

    // Private state tracking
    private var lastInteractionPoint: CGPoint? = nil
    private var currentSize: CGSize = .zero

    init?(mtkView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("Metal is not supported on this device")
        }
        self.device = device
        self.commandQueue = commandQueue
        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm // Standard display format
        mtkView.framebufferOnly = false // Needed to read from the drawable texture if we wanted to

        // Initialize interaction uniforms
        interactionUniforms = InteractionUniforms(
            interactionPoint: .zero,
            interactionVelocity: .zero,
            interactionColor: .zero,
            interactionRadius: 0.0, // Will be set based on size
            timestep: simulationTimeStep,
            viscosity: fluidViscosity,
            addDensity: false,
            addVelocity: false
        )

        super.init()

        setupTextures()
        setupBuffers()
        setupPipelines()
    }

    // --- Setup Helper Methods ---

    func setupTextures() {
        let descriptor = MTLTextureDescriptor()
        descriptor.textureType = .type2D
        descriptor.width = textureWidth
        descriptor.height = textureHeight
        descriptor.pixelFormat = .rg16Float // Store velocity (x, y) - higher precision often better
        descriptor.usage = [.shaderRead, .shaderWrite] // Read/write for compute
        descriptor.storageMode = .private // Best performance on GPU

        velocityTextureA = device.makeTexture(descriptor: descriptor)
        velocityTextureB = device.makeTexture(descriptor: descriptor)

        // Density can often use lower precision
        descriptor.pixelFormat = .rgba8Unorm // Store color (RGBA)
        densityTextureA = device.makeTexture(descriptor: descriptor)
        densityTextureB = device.makeTexture(descriptor: descriptor)

        // Pressure and Divergence can be single channel float
        descriptor.pixelFormat = .r16Float
        pressureTexture = device.makeTexture(descriptor: descriptor)
        divergenceTexture = device.makeTexture(descriptor: descriptor)

        clearTexture(texture: velocityTextureA)
        clearTexture(texture: velocityTextureB)
        clearTexture(texture: densityTextureA)
        clearTexture(texture: densityTextureB)
    }

    func clearTexture(texture: MTLTexture) {
        // Helper to zero out textures initially
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let blitEncoder = commandBuffer.makeBlitCommandEncoder() else { return }
        blitEncoder.fill(buffer: device.makeBuffer(length: 1, options: .storageModeShared)!, // Dummy buffer
                         range: 0..<1,
                         value: 0) // Fill with zero byte pattern (works for float formats too)

         // This is a simplified clear - might need a compute shader clear for precision
        blitEncoder.copy(from: device.makeBuffer(length: 1)!, sourceOffset: 0, sourceBytesPerRow: 0, sourceBytesPerImage: 0, sourceSize: MTLSize(width: 0, height: 0, depth: 0), to: texture, destinationSlice: 0, destinationLevel: 0, destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))

        blitEncoder.endEncoding()
        commandBuffer.commit()
    }

    func setupBuffers() {
        interactionUniformsBuffer = device.makeBuffer(length: MemoryLayout<InteractionUniforms>.stride, options: .storageModeShared)
    }

    func setupPipelines() {
        guard let library = try? device.makeLibrary(source: fluidShaderSource, options: nil) else {
            fatalError("Failed to create Metal library")
        }

        // Compute Pipelines
        advectPSO = makeComputePSO(library: library, functionName: "advect")
        addSourcePSO = makeComputePSO(library: library, functionName: "add_source")
        jacobiDiffusePSO = makeComputePSO(library: library, functionName: "diffuse_jacobi")
        divergencePSO = makeComputePSO(library: library, functionName: "calculate_divergence")
        jacobiPressurePSO = makeComputePSO(library: library, functionName: "pressure_jacobi")
        subtractGradientPSO = makeComputePSO(library: library, functionName: "subtract_gradient")

        // Render Pipeline (for visualization)
        let renderDesc = MTLRenderPipelineDescriptor()
        renderDesc.vertexFunction = library.makeFunction(name: "fluid_vertex")
        renderDesc.fragmentFunction = library.makeFunction(name: "fluid_fragment")
        renderDesc.colorAttachments[0].pixelFormat = .bgra8Unorm // Match MTKView

        do {
            visualizeRenderPSO = try device.makeRenderPipelineState(descriptor: renderDesc)
        } catch {
            fatalError("Failed to create render pipeline state: \(error)")
        }
    }

    func makeComputePSO(library: MTLLibrary, functionName: String) -> MTLComputePipelineState {
        guard let function = library.makeFunction(name: functionName) else {
            fatalError("Failed to find compute function: \(functionName)")
        }
        do {
            return try device.makeComputePipelineState(function: function)
        } catch {
            fatalError("Failed to create compute pipeline state for \(functionName): \(error)")
        }
    }

    // --- MTKViewDelegate Methods ---

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle view size changes if necessary (e.g., update aspect ratio)
        currentSize = size
        // Recalculate interaction radius based on the smaller dimension
        interactionUniforms.interactionRadius = interactionRadiusScreenFraction * Float(min(size.width, size.height)) / Float(textureWidth) // Normalized to texture space
        print("Drawable size changed: \(size), Interaction Radius (Norm): \(interactionUniforms.interactionRadius)")
    }

    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        commandBuffer.label = "Fluid Simulation Frame"

        updateInteractionUniforms() // Update buffer with latest interaction state

        // --- Simulation Compute Passes ---
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        computeEncoder.label = "Fluid Simulation Steps"

        let threadsPerGrid = MTLSize(width: textureWidth, height: textureHeight, depth: 1)
        let maxTotalThreadsPerThreadgroup = advectPSO.maxTotalThreadsPerThreadgroup // Use one PSO as example
        let threadgroupWidth = 8
        let threadgroupHeight = maxTotalThreadsPerThreadgroup / threadgroupWidth
        let threadsPerThreadgroup = MTLSize(width: threadgroupWidth, height: threadgroupHeight, depth: 1)

        // 1. Advect Velocity
        computeEncoder.setComputePipelineState(advectPSO)
        computeEncoder.setTexture(velocityTextureA, index: 0) // Velocity In
        computeEncoder.setTexture(velocityTextureA, index: 1) // Quantity In (velocity itself)
        computeEncoder.setTexture(velocityTextureB, index: 2) // Quantity Out (advected velocity)
        computeEncoder.setBuffer(interactionUniformsBuffer, offset: 0, index: 0)
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        swapVelocityTextures() // velocityB now has result

        // 2. Advect Density
        computeEncoder.setTexture(velocityTextureA, index: 0) // Velocity In (result from previous step)
        computeEncoder.setTexture(densityTextureA, index: 1) // Quantity In (density)
        computeEncoder.setTexture(densityTextureB, index: 2) // Quantity Out (advected density)
        // Buffer 0 (uniforms) remains set
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        swapDensityTextures() // densityB now has result

        // 3. Apply Diffusion (Viscosity) to Velocity - Optional but recommended
        if fluidViscosity > 0 {
            computeEncoder.setComputePipelineState(jacobiDiffusePSO)
            computeEncoder.setBuffer(interactionUniformsBuffer, offset: 0, index: 0)
            var velInDiffusion = velocityTextureA! // Starting input for iterations
            var velOutDiffusion = velocityTextureB! // Starting output for iterations
            for _ in 0..<diffusionIterations {
                computeEncoder.setTexture(velInDiffusion, index: 0) // Input from fixed source B term
                computeEncoder.setTexture(velInDiffusion, index: 1) // Input from previous Jacobi step
                computeEncoder.setTexture(velOutDiffusion, index: 2) // Output of Jacobi step
                computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
                // Swap textures for next iteration
                swap(&velInDiffusion, &velOutDiffusion)
            }
            // Final result is now in velInDiffusion (after the last swap)
            // Copy this back to the main velocity texture A if needed, or just use velIn for next steps
            if velInDiffusion !== velocityTextureA { // Make sure velocityTextureA holds the final diffused result
                blitTexture(encoder:commandBuffer.makeBlitCommandEncoder()!, source: velInDiffusion, destination: velocityTextureA)
            }
       }

        // 4. Add Sources (Forces/Density)
        computeEncoder.setComputePipelineState(addSourcePSO)
        computeEncoder.setBuffer(interactionUniformsBuffer, offset: 0, index: 0)
        // Add density to densityTextureA
        computeEncoder.setTexture(densityTextureA, index: 0)
        interactionUniforms.addDensity = true; interactionUniforms.addVelocity = false; uploadInteractionUniforms() // Set flags
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        // Add velocity to velocityTextureA
        computeEncoder.setTexture(velocityTextureA, index: 0)
        interactionUniforms.addDensity = false; interactionUniforms.addVelocity = true; uploadInteractionUniforms() // Set flags
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        interactionUniforms.addDensity = false; interactionUniforms.addVelocity = false; // Reset flags after use

        // 5. Projection Step (Make fluid incompressible)
        // 5a. Calculate Divergence
        computeEncoder.setComputePipelineState(divergencePSO)
        computeEncoder.setTexture(velocityTextureA, index: 0) // Current velocity field
        computeEncoder.setTexture(divergenceTexture, index: 1) // Output divergence
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)

        // 5b. Solve Pressure (Jacobi iterations)
        computeEncoder.setComputePipelineState(jacobiPressurePSO)
        computeEncoder.setTexture(divergenceTexture, index: 0) // Input divergence (RHS)
        // Clear pressure texture initially (optional, depends on solver stability)
        blitTexture(encoder:commandBuffer.makeBlitCommandEncoder()!, source: pressureTexture, destination: pressureTexture, clear: true)
        var pressureIn = pressureTexture! // Use same texture for read/write across iterations conceptually
        var pressureOut = divergenceTexture! // Use divergence as temporary swap (REPURPOSED!)

        for _ in 0..<jacobiIterations {
             computeEncoder.setTexture(divergenceTexture, index: 0) // RHS divergence (fixed)
             computeEncoder.setTexture(pressureIn, index: 1)     // Previous iteration's pressure estimate
             computeEncoder.setTexture(pressureOut, index: 2)    // Output pressure for this iteration
             computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
             // Swap textures for next iteration
             swap(&pressureIn, &pressureOut) // pressureIn now holds the result of the last calculation
        }
         // Ensure pressureTexture holds the final result
        if pressureIn !== pressureTexture {
             blitTexture(encoder:commandBuffer.makeBlitCommandEncoder()!, source: pressureIn, destination: pressureTexture)
        }

        // 5c. Subtract Gradient
        computeEncoder.setComputePipelineState(subtractGradientPSO)
        computeEncoder.setTexture(velocityTextureA, index: 0) // Velocity field to modify
        computeEncoder.setTexture(pressureTexture, index: 1) // Final pressure field
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        // velocityTextureA now holds the divergence-free velocity field

        computeEncoder.endEncoding() // Finish compute passes

        // --- Render Pass (Visualize Density) ---
        guard let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                  commandBuffer.commit() // Commit compute work even if render fails
                  return
              }
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.01, 0.01, 0.02, 1.0) // Dark blue background
        renderEncoder.label = "Visualize Fluid Density"

        renderEncoder.setRenderPipelineState(visualizeRenderPSO)
        renderEncoder.setFragmentTexture(densityTextureA, index: 0) // Use final density texture

        // Draw a full-screen quad (using 6 vertices) specified in the vertex shader
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)

        renderEncoder.endEncoding()

        // Present
        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
        commandBuffer.commit()

         // Reset one-shot interaction flags for next frame
        interactionUniforms.addDensity = false
        interactionUniforms.addVelocity = false
    }

    // --- Texture Swapping ---
    func swapDensityTextures() {
        swap(&densityTextureA, &densityTextureB)
    }
    func swapVelocityTextures() {
        swap(&velocityTextureA, &velocityTextureB)
    }

    // Quick utility to copy textures using a Blit encoder
    func blitTexture(encoder: MTLBlitCommandEncoder, source: MTLTexture, destination: MTLTexture, clear: Bool = false) {
         if clear {
                 // Simple clear - might not work perfectly for all formats / needs specific clear color
                // Ideally use a compute shader for a precise clear if needed.
                encoder.fill(buffer: device.makeBuffer(length: 1)!, range: 0..<1, value: 0) // Fill with zero
                 encoder.copy(from: device.makeBuffer(length: 1)!, sourceOffset: 0, sourceBytesPerRow: 0, sourceBytesPerImage: 0, sourceSize: MTLSize(width: 0, height: 0, depth: 0), to: destination, destinationSlice: 0, destinationLevel: 0, destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
         } else {
            let origin = MTLOrigin(x: 0, y: 0, z: 0)
            let size = MTLSize(width: source.width, height: source.height, depth: 1)
            encoder.copy(from: source, sourceSlice: 0, sourceLevel: 0, sourceOrigin: origin, sourceSize: size,
                         to: destination, destinationSlice: 0, destinationLevel: 0, destinationOrigin: origin)
         }
         encoder.endEncoding() // Assume encoder is single-use here or managed externally
    }

    // --- Interaction Handling ---
    func updateInteraction(point: CGPoint, viewSize: CGSize, isDragging: Bool) {
        guard viewSize.width > 0, viewSize.height > 0 else { return }

        // Normalize point to [0, 1] range (texture coords)
        let normalizedPoint = SIMD2<Float>(
            Float(point.x / viewSize.width),
            Float(point.y / viewSize.height) // Metal texture V is often downwards from top-left
        )
        interactionUniforms.interactionPoint = normalizedPoint

        // Calculate velocity based on drag distance
        if let lastPoint = lastInteractionPoint, isDragging {
            let deltaX = Float(point.x - lastPoint.x)
            let deltaY = Float(point.y - lastPoint.y)
            // Scale velocity - adjust multiplier as needed
            interactionUniforms.interactionVelocity = SIMD2<Float>(deltaX, deltaY) * 0.5
            interactionUniforms.addVelocity = true
        } else {
            interactionUniforms.interactionVelocity = .zero
            interactionUniforms.addVelocity = false
        }

        // Add density (e.g., a random-ish color on drag start or continuously)
        if interactionUniforms.interactionColor == .zero || !isDragging { // New color on drag start
              interactionUniforms.interactionColor = SIMD4<Float>(Float.random(in: 0.5...1.0), Float.random(in: 0.2...0.8), Float.random(in: 0.1...0.5), 1.0)
        }
         interactionUniforms.addDensity = true // Always add density when interacting

        // Update last point
        lastInteractionPoint = isDragging ? point : nil

        // No need to call uploadInteractionUniforms here, draw loop does it.
        print("Interaction: \(normalizedPoint), Vel: \(interactionUniforms.interactionVelocity), AddDensity: \(interactionUniforms.addDensity), AddVel: \(interactionUniforms.addVelocity)")
    }

    func endInteraction() {
        lastInteractionPoint = nil
        interactionUniforms.addDensity = false
        interactionUniforms.addVelocity = false
         // Don't reset point/color immediately, let the draw loop pick up the flags are false
         print("Interaction Ended")
    }

    func updateInteractionUniforms() {
        // Copy Swift struct data to the MTLBuffer
        let pointer = interactionUniformsBuffer.contents().bindMemory(to: InteractionUniforms.self, capacity: 1)
        pointer[0] = interactionUniforms
    }
      func uploadInteractionUniforms() {
        // If needing to upload mid-frame (like setting flags)
        let pointer = interactionUniformsBuffer.contents().bindMemory(to: InteractionUniforms.self, capacity: 1)
        pointer[0] = interactionUniforms
    }
}

// MARK: - SwiftUI View Structure

struct FluidBackgroundView: UIViewRepresentable {
    typealias UIViewType = MTKView

    func makeCoordinator() -> Coordinator {
        print("Making Coordinator")
        // Create renderer first, coordinator holds reference
         guard let device = MTLCreateSystemDefaultDevice(),
               let renderer = FluidRenderer(mtkView: MTKView(frame: .zero, device: device)) else {
                    fatalError("Renderer cannot be initialized")
                }
        return Coordinator(self, renderer: renderer)
    }

    func makeUIView(context: Context) -> MTKView {
        print("Making MTKView")
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.enableSetNeedsDisplay = false // Use draw loop
        mtkView.isPaused = false // Run continuously

        // Assign the renderer's device to the view
        guard let renderer = context.coordinator.renderer else {
             fatalError("Renderer not set up in coordinator")
        }
        mtkView.device = renderer.device

        // Add gesture recognizer
        let dragGesture = DragGesture(minimumDistance: 0)
            .onChanged { value in
                context.coordinator.handleDrag(location: value.location, viewSize: mtkView.drawableSize, isDragging: true)
            }
            .onEnded { _ in
                context.coordinator.handleDragEnd()
            }
        mtkView.addGestureRecognizer(UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:))))

        // Add tap gesture too for single impulse (optional)
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mtkView.addGestureRecognizer(tapGesture)

        print("MTKView Made with Delegate and Gestures")
        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
         // Typically interaction state is passed/updated via Coordinator actions
         // so updateUIView might be empty for this kind of continuous effect.
         print("Updating MTKView Representable (frame: \(uiView.frame))")
    }

    // Coordinator Class
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: FluidBackgroundView
        var renderer: FluidRenderer? // Store the renderer

        init(_ parent: FluidBackgroundView, renderer: FluidRenderer) {
             print("Coordinator Init")
            self.parent = parent
            self.renderer = renderer
            super.init()
        }

        // MTKViewDelegate methods
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
             print("Coordinator: Size Will Change \(size)")
            renderer?.mtkView(view, drawableSizeWillChange: size)
        }

        func draw(in view: MTKView) {
            renderer?.draw(in: view)
        }

        // Gesture Handling
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let view = gesture.view else { return }
            let location = gesture.location(in: view)
            let viewSize = view.bounds.size // Use bounds size which aligns with UIKit coords

             print("Pan State: \(gesture.state.rawValue), Location: \(location)")

            switch gesture.state {
            case .began, .changed:
                renderer?.updateInteraction(point: location, viewSize: viewSize, isDragging: true)
            case .ended, .cancelled, .failed:
                renderer?.endInteraction()
            default:
                break
            }
        }

         @objc func handleTap(_ gesture: UITapGestureRecognizer) {
             guard let view = gesture.view else { return }
             let location = gesture.location(in: view)
             let viewSize = view.bounds.size
             print("Tap Location: \(location)")
             // Treat tap as a brief drag start/end or a single impulse
             renderer?.updateInteraction(point: location, viewSize: viewSize, isDragging: false) // Add density/maybe small vel impulse
             // No endInteraction needed right after tap if interaction flags reset per frame
         }

        func handleDrag(location: CGPoint, viewSize: CGSize, isDragging: Bool) {
             renderer?.updateInteraction(point: location, viewSize: viewSize, isDragging: isDragging)
        }
         func handleDragEnd() {
            renderer?.endInteraction()
         }
    }
}

// MARK: - Main SwiftUI Content View

struct ContentView: View {
    var body: some View {
        ZStack {
            // FluidBackgroundView takes up the whole screen
            FluidBackgroundView()
                .edgesIgnoringSafeArea(.all) // Make it extend edge-to-edge

            // Overlay some text or other UI elements on top
            VStack {
                Text("Interactive Fluid Background")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 50) // Add padding from the top edge

                Text("Drag on the screen")
                     .foregroundColor(.white.opacity(0.7))
                     .padding(.top, 10)

                Spacer() // Pushes text to the top
            }
        }
    }
}

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/*
// MARK: - App Entry Point (Optional)
@main
struct FluidBackgroundApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
