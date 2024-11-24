//
//  MetalDevice.swift
//
//
//  Cong Le on 11/24/24.

import Foundation
import Metal

/// An error type representing possible failures when working with `MetalDevice`.
enum MetalDeviceError: Error {
    /// Indicates that a Metal function could not be created.
    case failedToCreateFunction(name: String)
}

/// A singleton class that manages Metal device resources and provides helper methods for pipeline and texture creation.
class MetalDevice {

    /// The shared singleton instance of `MetalDevice`.
    static let sharedInstance = MetalDevice()

    /// The underlying Metal device.
    let device: MTLDevice

    /// The command queue associated with the Metal device.
    private let commandQueue: MTLCommandQueue

    /// The active command buffer used for encoding commands.
    var activeCommandBuffer: MTLCommandBuffer

    /// The default Metal shader library.
    let defaultLibrary: MTLLibrary

    /// A cache for storing compiled pipeline states to improve performance.
    private let pipelineCache = NSCache<NSString, AnyObject>()

    /// A global background dispatch queue for asynchronous tasks.
    let queue = DispatchQueue.global(qos: .background)

    /// The input texture used in operations.
    var inputTexture: MTLTexture?

    /// The output texture resulting from operations.
    var outputTexture: MTLTexture?

    /// Private initializer to enforce singleton pattern.
    private init() {
        guard let defaultDevice = MTLCreateSystemDefaultDevice(),
              let queue = defaultDevice.makeCommandQueue(),
              let buffer = queue.makeCommandBuffer(),
              let library = defaultDevice.makeDefaultLibrary() else {
            fatalError("Unable to initialize MetalDevice")
        }

        self.device = defaultDevice
        self.commandQueue = queue
        self.activeCommandBuffer = buffer
        self.defaultLibrary = library
    }

    // MARK: - Convenience Methods

    /// Creates a render pipeline state with the specified vertex and fragment function names and pixel format.
    ///
    /// - Parameters:
    ///   - vertexFunctionName: The name of the vertex function. Default is `"basicVertexFunction"`.
    ///   - fragmentFunctionName: The name of the fragment function.
    ///   - pixelFormat: The pixel format for the render pipeline.
    /// - Returns: A configured `MTLRenderPipelineState` object.
    /// - Throws: `MetalDeviceError` if functions cannot be created or pipeline state creation fails.
    class func createRenderPipeline(vertexFunctionName: String = "basicVertexFunction",
                                    fragmentFunctionName: String,
                                    pixelFormat: MTLPixelFormat) throws -> MTLRenderPipelineState {
        return try sharedInstance.createRenderPipeline(vertexFunctionName: vertexFunctionName,
                                                       fragmentFunctionName: fragmentFunctionName,
                                                       pixelFormat: pixelFormat)
    }

    /// Creates a compute pipeline state with the specified compute function name.
    ///
    /// - Parameter computeFunctionName: The name of the compute function.
    /// - Returns: A configured `MTLComputePipelineState` object.
    /// - Throws: `MetalDeviceError` if the function cannot be created or pipeline state creation fails.
    class func createComputePipeline(computeFunctionName: String) throws -> MTLComputePipelineState {
        return try sharedInstance.createComputePipeline(computeFunctionName: computeFunctionName)
    }

    /// Creates a texture with the specified descriptor.
    ///
    /// - Parameter descriptor: The texture descriptor.
    /// - Returns: A new `MTLTexture` object.
    class func createTexture(descriptor: MTLTextureDescriptor) -> MTLTexture {
        guard let texture = sharedInstance.device.makeTexture(descriptor: descriptor) else {
            fatalError("Failed to create texture")
        }
        return texture
    }

    /// Swaps the input and output textures.
    func swapBuffers() {
        swap(&inputTexture, &outputTexture)
    }

    /// Creates a buffer containing the provided array.
    ///
    /// - Parameters:
    ///   - array: The array of elements to store in the buffer.
    ///   - options: The resource options for the buffer. Default is `[]`.
    /// - Returns: A new `MTLBuffer` containing the array data.
    func makeBuffer<T>(from array: [T], options: MTLResourceOptions = []) -> MTLBuffer {
        let length = array.count * MemoryLayout<T>.stride
        return array.withUnsafeBufferPointer { bufferPointer in
            device.makeBuffer(bytes: bufferPointer.baseAddress!, length: length, options: options)!
        }
    }

    /// Creates a new command buffer.
    ///
    /// - Returns: A new `MTLCommandBuffer` object.
    func newCommandBuffer() -> MTLCommandBuffer {
        return commandQueue.makeCommandBuffer()!
    }

    /// Creates a render pipeline state with the specified vertex and fragment function names and pixel format.
    ///
    /// - Parameters:
    ///   - vertexFunctionName: The name of the vertex function.
    ///   - fragmentFunctionName: The name of the fragment function.
    ///   - pixelFormat: The pixel format for the render pipeline.
    /// - Returns: A configured `MTLRenderPipelineState` object.
    /// - Throws: `MetalDeviceError` if functions cannot be created or pipeline state creation fails.
    func createRenderPipeline(vertexFunctionName: String = "basicVertexFunction",
                              fragmentFunctionName: String,
                              pixelFormat: MTLPixelFormat) throws -> MTLRenderPipelineState {
        let cacheKey = "\(vertexFunctionName)|\(fragmentFunctionName)" as NSString

        if let cachedPipelineState = pipelineCache.object(forKey: cacheKey) as? MTLRenderPipelineState {
            return cachedPipelineState
        }

        guard let vertexFunction = defaultLibrary.makeFunction(name: vertexFunctionName),
              let fragmentFunction = defaultLibrary.makeFunction(name: fragmentFunctionName) else {
            throw MetalDeviceError.failedToCreateFunction(name: "\(vertexFunctionName) or \(fragmentFunctionName)")
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        pipelineDescriptor.label = "\(vertexFunctionName)|\(fragmentFunctionName)"

        let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        pipelineCache.setObject(pipelineState, forKey: cacheKey)

        return pipelineState
    }

    /// Creates a compute pipeline state with the specified compute function name.
    ///
    /// - Parameter computeFunctionName: The name of the compute function.
    /// - Returns: A configured `MTLComputePipelineState` object.
    /// - Throws: `MetalDeviceError` if the function cannot be created or pipeline state creation fails.
    func createComputePipeline(computeFunctionName: String) throws -> MTLComputePipelineState {
        let cacheKey = computeFunctionName as NSString

        if let cachedPipelineState = pipelineCache.object(forKey: cacheKey) as? MTLComputePipelineState {
            return cachedPipelineState
        }

        guard let computeFunction = defaultLibrary.makeFunction(name: computeFunctionName) else {
            throw MetalDeviceError.failedToCreateFunction(name: computeFunctionName)
        }

        let pipelineState = try device.makeComputePipelineState(function: computeFunction)
        pipelineCache.setObject(pipelineState, forKey: cacheKey)

        return pipelineState
    }
}
