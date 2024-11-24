//
//  ComputeShader.swift
//
//  Cong Le on 11/24/24.
//
// Source: https://github.com/andreipitis/FluidDynamicsMetal
// Docs: https://developer.nvidia.com/gpugems/gpugems/part-vi-beyond-triangles/chapter-38-fast-fluid-dynamics-simulation-gpu
// Docs: https://prideout.net/blog/?p=58
import CoreMedia
import Metal

/// A class that encapsulates a compute shader for Metal computations.
class ComputeShader {
    /// The output texture produced by the compute shader.
    var outputTexture: MTLTexture?
    
    /// The input texture to be processed by the compute shader.
    var inputTexture: MTLTexture?
    
    /// The configuration for the pipeline state.
    private var pipelineState: PipelineStateConfiguration
    
    /// The compute pipeline state used to encode compute commands.
    private var computePipelineState: MTLComputePipelineState?
    
    /// Initializes a new `ComputeShader` with the specified compute shader function name.
    /// - Parameter computeShader: The name of the compute shader function to use.
    init(computeShader: String) {
        pipelineState = PipelineStateConfiguration(
            pixelFormat: .bgra8Unorm,
            vertexShader: "",
            fragmentShader: "",
            computeShader: computeShader
        )
        commonInit()
    }
    
    deinit {
        print("Deinit Filter")
    }
    
    /// Calculates the result using the provided command buffer.
    /// - Parameters:
    ///   - buffer: The `MTLCommandBuffer` to encode commands into.
    ///   - configureEncoder: An optional closure to configure the compute command encoder.
    func calculate(withCommandBuffer buffer: MTLCommandBuffer, configureEncoder: ((MTLComputeCommandEncoder) -> Void)?) {
        guard let computePipelineState = computePipelineState,
              let computeCommandEncoder = buffer.makeComputeCommandEncoder() else {
            return
        }
        
        computeCommandEncoder.pushDebugGroup("Base Filter Compute Encoder")
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        
        configureEncoder?(computeCommandEncoder)
        
        computeCommandEncoder.endEncoding()
        computeCommandEncoder.popDebugGroup()
    }
    
    /// Configures the compute pipeline by creating the `MTLComputePipelineState`.
    private func configurePipeline() {
        guard !pipelineState.computeShader.isEmpty else { return }
        guard computePipelineState == nil else { return }
        
        do {
            computePipelineState = try MetalDevice.createComputePipeline(
                computeFunctionName: pipelineState.computeShader
            )
        } catch {
            print("Could not create compute pipeline state: \(error)")
        }
    }
    
    /// Performs common initialization tasks for the compute shader.
    private func commonInit() {
        configurePipeline()
    }
}
