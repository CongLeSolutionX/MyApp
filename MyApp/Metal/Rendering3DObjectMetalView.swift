//
//  Rendering3DObjectMetalView.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//
import SwiftUI
import MetalKit

// MARK: - MetalView
struct Renderring3DObjectMTKViewWrapper: UIViewRepresentable {
    
    @Binding var redraw: Bool // Flag to force redraws
    
    func makeUIView(context: Context) -> MTKView {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal device not supported on this device.")
        }
        let frame = CGRect(x: 0, y: 0, width: 600, height: 600) // Arbitrary size
        let view = MTKView(frame: frame, device: device)
        view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        if (redraw) {
            context.coordinator.redraw(metalView: uiView)
        }
    }

    func makeCoordinator() -> Renderer {
      return Renderer(redraw: $redraw)
    }

    // Renderer class will handle all our metal drawing
    class Renderer : NSObject, MTKViewDelegate {
        
        var commandQueue : MTLCommandQueue?
        var pipelineState : MTLRenderPipelineState?
        var mesh : MTKMesh?
        
        @Binding var redraw : Bool
        
        //initializer
        init(redraw: Binding<Bool>){
            self._redraw = redraw
            super.init()
        }

        //Sets up all the metal setup
        func setupMetal( _ metalView: MTKView){

            guard let device = metalView.device else {
                fatalError("Metal device not supported on this device.")
            }
            
            commandQueue = device.makeCommandQueue()
            
            // Load the 3D Model
            let allocator = MTKMeshBufferAllocator(device: device)

            guard let assetURL = Bundle.main.url(
              forResource: "train",
              withExtension: "usdz") else {
                fatalError("Could not find specified .usdz file")
            }

            let vertexDescriptor = MTLVertexDescriptor()
                   vertexDescriptor.attributes[0].format = .float3
                   vertexDescriptor.attributes[0].offset = 0
                   vertexDescriptor.attributes[0].bufferIndex = 0

                   vertexDescriptor.layouts[0].stride =
                     MemoryLayout<SIMD3<Float>>.stride
                   let meshDescriptor =
                     MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
                   (meshDescriptor.attributes[0] as! MDLVertexAttribute).name =
                     MDLVertexAttributePosition

            let asset = MDLAsset(
                url: assetURL,
                vertexDescriptor: meshDescriptor,
                bufferAllocator: allocator
            )
            
           guard let mdlMesh = asset.childObjects(of: MDLMesh.self).first as? MDLMesh else {
               fatalError("failed to load mdl mesh from provided asset")
           }


           do {
             mesh = try MTKMesh(mesh: mdlMesh, device: device)
            }
           catch {
               fatalError("could not create metal mesh: \(error.localizedDescription)")
            }

                // Shader Setup
            let shader = """
            #include <metal_stdlib>
            using namespace metal;

            struct VertexIn {
              float4 position [[attribute(0)]];
            };

            vertex float4 vertex_main(const VertexIn vertex_in [[stage_in]]) {
              float4 position = vertex_in.position;
              position.y -= 1.0;
              return position;
            }

            fragment float4 fragment_main() {
              return float4(1, 0, 0, 1);
            }
            """

          do{
            let library = try device.makeLibrary(source: shader, options: nil)
                let vertexFunction = library.makeFunction(name: "vertex_main")
                let fragmentFunction = library.makeFunction(name: "fragment_main")
                
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
              pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
              pipelineDescriptor.vertexFunction = vertexFunction
              pipelineDescriptor.fragmentFunction = fragmentFunction

              pipelineDescriptor.vertexDescriptor =
                MTKMetalVertexDescriptorFromModelIO(mesh!.vertexDescriptor)

            pipelineState =  try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
          }
           catch{
               fatalError("Could not set up the metal pipeline: \(error.localizedDescription)")
           }
        }

        //Function that actually draws our content to the screen
        func redraw(metalView: MTKView) {
              guard let commandQueue = commandQueue else{
                  return
              }
                guard let commandBuffer = commandQueue.makeCommandBuffer(),
                  let renderPassDescriptor = metalView.currentRenderPassDescriptor,
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(
                    descriptor:  renderPassDescriptor)
                else { return }

                renderEncoder.setRenderPipelineState(pipelineState!)
            
              guard let mesh = mesh else{
                return
              }

                renderEncoder.setVertexBuffer(
                  mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
                renderEncoder.setTriangleFillMode(.lines)

                for submesh in mesh.submeshes {
                  renderEncoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: submesh.indexCount,
                    indexType: submesh.indexType,
                    indexBuffer: submesh.indexBuffer.buffer,
                    indexBufferOffset: submesh.indexBuffer.offset
                  )
                }
            
                renderEncoder.endEncoding()
            
            guard let drawable = metalView.currentDrawable else {
               return
            }
              
                commandBuffer.present(drawable)
                commandBuffer.commit()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            // Handle resizing if needed, or just redraw
              if (commandQueue == nil) {
                setupMetal(view)
            }
           redraw(metalView: view)
        }
        
        func draw(in view: MTKView) {
           // Handles draws during initial set-up
           if (commandQueue == nil){
               setupMetal(view)
           }
           redraw(metalView: view)
        }
    }
}

// MARK: - Rendering3DObjectMetalView
struct Rendering3DObjectMetalView: View {
    @State private var redrawView = true
    var body: some View {
        VStack{
            Renderring3DObjectMTKViewWrapper(redraw: $redrawView)
        }
        .onAppear{
          redrawView.toggle()
        }
    }
}

// MARK: - Preview
#Preview("Rendering 3D Object on a Metal view") {
    Rendering3DObjectMetalView()
}
