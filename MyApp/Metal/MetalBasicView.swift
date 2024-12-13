//
//  MetalBasicView.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//

import SwiftUI
import MetalKit

struct MTKViewWrapper: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MTKView {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU is not supported")
        }
        
        let mtkView = MTKView(frame: .zero, device: device)
        mtkView.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)
        
        // Create mesh
        let allocator = MTKMeshBufferAllocator(device: device)
        let mdlMesh = MDLMesh(sphereWithExtent: [0.85, 0.65, 0.5], segments: [100, 100], inwardNormals: false, geometryType: .triangles, allocator: allocator)
        
        let mesh = try! MTKMesh(mesh: mdlMesh, device: device)
           
        // Create command queue
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Could not create a command queue")
        }
        
        // Shader code
        let shader = """
        #include <metal_stdlib>
        using namespace metal;

        struct VertexIn {
            float4 position [[attribute(0)]];
        };

        vertex float4 vertex_main(const VertexIn vertex_in [[stage_in]]) {
            return vertex_in.position;
        }

        fragment float4 fragment_main() {
            return float4(1, 0, 0, 1);
        }
        """
        
        // Compile shader
        let library = try! device.makeLibrary(source: shader, options: nil)
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "fragment_main")
        
         
        // Pipeline descriptor
       let pipelineDescriptor = MTLRenderPipelineDescriptor()
         pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
         pipelineDescriptor.vertexFunction = vertexFunction
         pipelineDescriptor.fragmentFunction = fragmentFunction
         pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
        
       // Pipeline state
         let pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        
        // Set up rendering inside a closure
        mtkView.delegate = context.coordinator
        context.coordinator.renderer = Renderer(metalView: mtkView, mesh: mesh, commandQueue: commandQueue, pipelineState: pipelineState)
        return mtkView
        
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        }
    
    func makeCoordinator() -> Coordinator {
         Coordinator()
    }
    
    
    class Coordinator: NSObject, MTKViewDelegate {
        var renderer: Renderer?
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        }
        
         func draw(in view: MTKView) {
              renderer?.draw()
         }
    }
}

// MARK: - Renderer
class Renderer {
    let metalView: MTKView
    let mesh: MTKMesh
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState
    
    init(metalView: MTKView, mesh: MTKMesh, commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState) {
        self.metalView = metalView
        self.mesh = mesh
        self.commandQueue = commandQueue
        self.pipelineState = pipelineState
       
    }
    
    func draw() {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderPassDescriptor = metalView.currentRenderPassDescriptor,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
           else { return }

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        
         guard let submesh = mesh.submeshes.first else { return }

        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer,indexBufferOffset: 0)
        
        renderEncoder.endEncoding()
        
         guard let drawable = metalView.currentDrawable else { return }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
// MARK: - MetalBasicView in SwiftUI
struct MetalBasicView: View {
    var body: some View {
        MTKViewWrapper()
    }
}

// MARK: - Preview
#Preview("Metal View - Sphere Example") {
    MetalBasicView()
}

