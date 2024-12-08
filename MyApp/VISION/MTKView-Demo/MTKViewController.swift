//
//  MTKViewController.swift
//  MyApp
//
//  Created by Cong Le on 12/7/24.
//
import UIKit
import MetalKit
import AVFoundation

class MTKViewController: UIViewController {
    
    // MARK: - Metal Properties
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    
    // Vertex and Fragment Functions
    var vertexFunction: MTLFunction!
    var fragmentFunction: MTLFunction!
    
    // MARK: - AVFoundation Properties
    let captureSession = AVCaptureSession()
    var videoOutput: AVCaptureVideoDataOutput!
    var videoQueue = DispatchQueue(label: "videoQueue")
    
    // MARK: - Texture Caching
    var textureCache: CVMetalTextureCache?
    
    // Current camera texture
    var currentCameraTexture: MTLTexture?
    
    // Synchronization
    let textureLock = NSLock()
    
    // MARK: - MTKView
    var mtkView: MTKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Metal
       // initializeMetal()
        
        // Set up MTKView
        setupMTKView()
        
        // Initialize Texture Cache
       // initializeTextureCache()
        
        // Initialize AVFoundation
        //initializeCaptureSession()
    }
    
    // MARK: - Metal Setup
    func initializeMetal() {
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        device = defaultDevice
        commandQueue = device.makeCommandQueue()
        
        // Load Shaders
        let library = device.makeDefaultLibrary()
        vertexFunction = library?.makeFunction(name: "vertex_passthrough")
        fragmentFunction = library?.makeFunction(name: "fragment_passthrough")
        
        // Create Render Pipeline
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "Camera Render Pipeline"
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError("Failed to create pipeline state: \(error)")
        }
    }
    
    // MARK: - MTKView Setup
    func setupMTKView() {
        mtkView = MTKView(frame: view.bounds, device: device)
        mtkView.delegate = self
        mtkView.framebufferOnly = false
        mtkView.contentScaleFactor = UIScreen.main.scale
        mtkView.enableSetNeedsDisplay = false
        mtkView.preferredFramesPerSecond = 60
        mtkView.clearColor = MTLClearColor(red: 255, green: 200, blue: 110, alpha: 1)
        view.addSubview(mtkView)
    }
    
    // MARK: - Texture Cache Initialization
    func initializeTextureCache() {
        var cache: CVMetalTextureCache?
        let status = CVMetalTextureCacheCreate(nil, nil, device, nil, &cache)
        if status == kCVReturnSuccess {
            textureCache = cache
        } else {
            fatalError("Unable to create texture cache")
        }
    }
    
    // MARK: - AVFoundation Setup
    func initializeCaptureSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        // Select the default camera
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: .back) else {
            fatalError("Unable to access back camera!")
        }
        
        // Add video input
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                fatalError("Unable to add video input")
            }
        } catch {
            fatalError("Error creating video input: \(error)")
        }
        
        // Add video output
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:
                                        Int(kCVPixelFormatType_32BGRA)]
        
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            fatalError("Unable to add video output")
        }
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    // MARK: - Convert CVPixelBuffer to MTLTexture
    func texture(from pixelBuffer: CVPixelBuffer) -> MTLTexture? {
        guard let textureCache = textureCache else { return nil }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        var cvMetalTexture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(nil, textureCache,
                                                               pixelBuffer,
                                                               nil,
                                                               .bgra8Unorm,
                                                               width,
                                                               height,
                                                               0,
                                                               &cvMetalTexture)
        if status == kCVReturnSuccess, let cvMetalTexture = cvMetalTexture {
            return CVMetalTextureGetTexture(cvMetalTexture)
        } else {
            print("Failed to create Metal texture from pixel buffer")
            return nil
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension MTKViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        if let texture = texture(from: pixelBuffer) {
            textureLock.lock()
            currentCameraTexture = texture
            textureLock.unlock()
        }
    }
}

// MARK: - MTKViewDelegate
extension MTKViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle view size or orientation changes if needed
    }
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor else { return }
        
        // Create command buffer
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        commandBuffer.label = "Camera Render Command Buffer"
        
        // Create render command encoder
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }
        renderEncoder.label = "Camera Render Encoder"
        
        // Set pipeline state
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // Set vertices and texture coordinates
        let vertexData: [Float] = [
            // Vertex positions   // Texture coordinates
            -1,  1, 0, 1,          0, 1,
            -1, -1, 0, 1,          0, 0,
             1, -1, 0, 1,          1, 0,
             1,  1, 0, 1,          1, 1
        ]
        let vertexBuffer = device.makeBuffer(bytes: vertexData,
                                             length: vertexData.count * MemoryLayout<Float>.size,
                                             options: [])
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // Define the index buffer
        let indices: [UInt16] = [0, 1, 2, 2, 3, 0]
        guard let indexBuffer = device.makeBuffer(bytes: indices,
                                                 length: indices.count * MemoryLayout<UInt16>.size,
                                                 options: []) else {
            fatalError("Failed to create index buffer")
        }
        
        // Set texture if available
        textureLock.lock()
        if let cameraTexture = currentCameraTexture {
            renderEncoder.setFragmentTexture(cameraTexture, index: 0)
        }
        textureLock.unlock()
        
        // Set sampler
        let sampler = MTLSamplerDescriptor()
        sampler.minFilter = .linear
        sampler.magFilter = .linear
        let samplerState = device.makeSamplerState(descriptor: sampler)
        renderEncoder.setFragmentSamplerState(samplerState, index: 0)
        
        // Draw call without using setIndexBuffer
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: indices.count,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)
        
        // End encoding
        renderEncoder.endEncoding()
        
        // Present the drawable
        commandBuffer.present(drawable)
        
        // Commit the command buffer
        commandBuffer.commit()
    }
}
