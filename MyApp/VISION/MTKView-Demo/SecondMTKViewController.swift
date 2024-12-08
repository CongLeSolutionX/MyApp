//
//  SecondMTKViewController.swift
//  MyApp
//
//  Created by Cong Le on 12/8/24.
//

import UIKit
import MetalKit
import AVFoundation

class SecondMTKViewController: UIViewController {
    var mtkView: MTKView!
    
    // Metal properties
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState?
    var vertexBuffer: MTLBuffer?
    var textureCache: CVMetalTextureCache?
    
    // Camera properties
    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureVideoDataOutput!
    var currentTexture: MTLTexture?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Metal
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        
        // Set up MTKView
        mtkView = MTKView(frame: view.bounds, device: device)
        mtkView.delegate = self
        mtkView.framebufferOnly = false
        mtkView.isPaused = false
        mtkView.enableSetNeedsDisplay = false
        mtkView.preferredFramesPerSecond = 60
        mtkView.contentMode = .scaleAspectFit
        mtkView.colorPixelFormat = .bgra8Unorm
        view.addSubview(mtkView)
        
        // Initialize texture cache for camera frames
        CVMetalTextureCacheCreate(nil, nil, device, nil, &textureCache)
        
        // Set up the rendering pipeline
        setupPipeline()
        
        // Set up camera capture session
        setupCamera()
    }
    
    func setupPipeline() {
        // Define the shader functions as a string
        let shaderCode = """
        #include <metal_stdlib>
        using namespace metal;

        struct Vertex {
            float2 position;
            float2 texCoord;
        };

        struct VertexOut {
            float4 position [[position]];
            float2 texCoord;
        };

        vertex VertexOut vertexPassThrough(uint vertexID [[vertex_id]],
                                           const device Vertex *vertexArray [[buffer(0)]]) {
            VertexOut out;
            out.position = float4(vertexArray[vertexID].position, 0.0, 1.0);
            out.texCoord = vertexArray[vertexID].texCoord;
            return out;
        }

        fragment float4 fragmentTexture(VertexOut in [[stage_in]],
                                        texture2d<float> colorTexture [[texture(0)]]) {
            constexpr sampler textureSampler (mag_filter::linear,
                                              min_filter::linear);
            const float4 colorSample = colorTexture.sample(textureSampler, in.texCoord);
            return colorSample;
        }
        """
        
        // Compile the shader code into a library
        let library: MTLLibrary
        do {
            library = try device.makeLibrary(source: shaderCode, options: nil)
        } catch {
            fatalError("Failed to create shader library: \(error)")
        }
        
        // Create vertex and fragment functions
        guard let vertexFunction = library.makeFunction(name: "vertexPassThrough"),
              let fragmentFunction = library.makeFunction(name: "fragmentTexture") else {
            fatalError("Failed to create shader functions")
        }
        
        // Set up the render pipeline descriptor
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "Camera Pipeline"
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        // Create the pipeline state
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Failed to create pipeline state: \(error)")
        }
        
        // Define the quad vertices for rendering
        struct Vertex {
            var position: SIMD2<Float>
            var texCoord: SIMD2<Float>
        }
        
        let quadVertices: [Vertex] = [
            Vertex(position: [-1.0, -1.0], texCoord: [0.0, 1.0]), // Lower-left
            Vertex(position: [ 1.0, -1.0], texCoord: [1.0, 1.0]), // Lower-right
            Vertex(position: [-1.0,  1.0], texCoord: [0.0, 0.0]), // Upper-left
            Vertex(position: [ 1.0,  1.0], texCoord: [1.0, 0.0])  // Upper-right
        ]
        
        // Create the vertex buffer
        vertexBuffer = device.makeBuffer(bytes: quadVertices,
                                         length: MemoryLayout<Vertex>.stride * quadVertices.count,
                                         options: [])
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        // Select the back-facing camera
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: .back) else {
            fatalError("Failed to get the back-facing camera")
        }
        
        // Create an input from the camera
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            fatalError("Failed to create video input")
        }
        
        guard captureSession.canAddInput(videoInput) else {
            fatalError("Cannot add video input")
        }
        captureSession.addInput(videoInput)
        
        // Set up the video data output
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        // Set up the sample buffer delegate
        let videoOutputQueue = DispatchQueue(label: "videoOutputQueue")
        videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
        
        guard captureSession.canAddOutput(videoOutput) else {
            fatalError("Cannot add video output")
        }
        captureSession.addOutput(videoOutput)
        
        // Set the video orientation
        if let videoConnection = videoOutput.connection(with: .video),
           /// The connection's `videoRotationAngle` property can only be set to a certain angle
           /// if this method returns `YES` for that angle.
            /// Only rotation angles of `0`, `90`, `180` and `270` are supported.
           videoConnection.isVideoRotationAngleSupported(CGFloat.zero) {
            videoConnection.videoRotationAngle = .zero
        }
        
        DispatchQueue.main.async { [weak self] in
            // Start the capture session in the background
            self?.captureSession.startRunning()
        }
    }
}

// MARK: - MTKViewDelegate

extension SecondMTKViewController: MTKViewDelegate {
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let currentTexture = self.currentTexture,
              let pipelineState = self.pipelineState,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        // Create a render command encoder
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setRenderPipelineState(pipelineState)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setFragmentTexture(currentTexture, index: 0)
        
        // Draw the textured quad
        commandEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        // End encoding and commit the command buffer
        commandEncoder?.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle view size changes if needed
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension SecondMTKViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let textureCache = self.textureCache else {
            return
        }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        var cvTextureOut: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               textureCache,
                                                               pixelBuffer,
                                                               nil,
                                                               .bgra8Unorm,
                                                               width,
                                                               height,
                                                               0,
                                                               &cvTextureOut)
        
        guard status == kCVReturnSuccess, let cvTexture = cvTextureOut else {
            return
        }
        
        // Get the Metal texture from the Core Video texture
        self.currentTexture = CVMetalTextureGetTexture(cvTexture)
        
        // Request to redraw the view on the main thread
        DispatchQueue.main.async {
            self.mtkView.draw()
        }
    }
}
