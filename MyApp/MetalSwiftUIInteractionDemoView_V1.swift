////
////  MetalSwiftUIInteractionDemoView.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//import SwiftUI
//import MetalKit
//import Combine // For Color conversion
//
//// MARK: - Metal Shaders (Modified)
//
//let metalShaderSourceWithInteraction = """
//using namespace metal;
//
//// Structure for vertex data (position and color)
//struct Vertex {
//    float4 position [[position]];
//    float4 color;
//};
//
//// Data passed from vertex to fragment shader
//struct VertexOut {
//    float4 position [[position]];
//    float4 color;
//};
//
//// *** New: Uniforms Structure passed to the shader ***
//struct Uniforms {
//    float time;        // For Z-axis rotation (automatic)
//    float rotationX;   // For X-axis rotation (gesture controlled)
//    float rotationY;   // For Y-axis rotation (gesture controlled)
//};
//
//// Helper function for rotation matrix
//float4x4 rotationMatrix(float angle, float3 axis) {
//    float c = cos(angle);
//    float s = sin(angle);
//    float t = 1.0 - c;
//    float x = axis.x;
//    float y = axis.y;
//    float z = axis.z;
//
//    return float4x4(
//        float4(t*x*x + c,   t*x*y - s*z, t*x*z + s*y, 0.0),
//        float4(t*x*y + s*z, t*y*y + c,   t*y*z - s*x, 0.0),
//        float4(t*x*z - s*y, t*y*z + s*x, t*z*z + c,   0.0),
//        float4(0.0,         0.0,         0.0,         1.0)
//    );
//}
//
//// ---- Vertex Shader (Modified) ----
//vertex VertexOut vertex_main(
//    uint vertexID [[vertex_id]],
//    constant float3 *vertices [[buffer(0)]],
//    constant float4 *colors [[buffer(1)]],
//    constant Uniforms &uniforms [[buffer(2)]] // *** Use Uniforms struct ***
//) {
//    VertexOut out;
//
//    // Get initial vertex position
//    float4 initialPos = float4(vertices[vertexID], 1.0);
//
//    // 1. Apply gesture-controlled X rotation
//    float4x4 rotX = rotationMatrix(uniforms.rotationX, float3(1.0, 0.0, 0.0));
//    float4 rotatedXPos = rotX * initialPos;
//
//    // 2. Apply gesture-controlled Y rotation
//    float4x4 rotY = rotationMatrix(uniforms.rotationY, float3(0.0, 1.0, 0.0));
//    float4 rotatedXYPos = rotY * rotatedXPos;
//
//    // 3. Apply automatic Z rotation based on time (from slider speed)
//    float4x4 rotZ = rotationMatrix(uniforms.time, float3(0.0, 0.0, 1.0));
//    float4 finalPos = rotZ * rotatedXYPos;
//
//    out.position = finalPos;
//    out.color = colors[vertexID];
//    return out;
//}
//
//// ---- Fragment Shader (Unchanged) ----
//fragment float4 fragment_main(VertexOut in [[stage_in]]) {
//    return in.color;
//}
//"""
//
//// MARK: - Color Conversion Helper (Unchanged)
//extension Color {
//    func toMTLClearColor() -> MTLClearColor {
//        #if os(macOS)
//        let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor.clear
//        var red: CGFloat = 0; var green: CGFloat = 0; var blue: CGFloat = 0; var alpha: CGFloat = 0
//        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//        return MTLClearColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
//        #else
//        let uiColor = UIColor(self)
//        var red: CGFloat = 0; var green: CGFloat = 0; var blue: CGFloat = 0; var alpha: CGFloat = 0
//        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//        return MTLClearColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
//        #endif
//    }
//}
//
//// MARK: - Metal Renderer Class (Modified)
//
//class MetalRenderer: NSObject {
//    let device: MTLDevice
//    let commandQueue: MTLCommandQueue
//    var pipelineState: MTLRenderPipelineState
//    var vertexBuffer: MTLBuffer
//    var colorBuffer: MTLBuffer
//    var uniformBuffer: MTLBuffer // *** Renamed from timeBuffer to uniformBuffer ***
//
//    // --- Control Parameters ---
//    var rotationSpeed: Float = 0.5 // For automatic Z rotation
//    var rotationX: Float = 0.0     // Gesture controlled X rotation
//    var rotationY: Float = 0.0     // Gesture controlled Y rotation
//    private var time: Float = 0.0  // Internal accumulated time for Z rotation
//
//    // Struct matching the shader's Uniforms struct
//    struct Uniforms {
//        var time: Float
//        var rotationX: Float
//        var rotationY: Float
//    }
//
//    init?(mtkView: MTKView) {
//        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
//        self.device = device
//        mtkView.device = device
//
//        guard let commandQueue = device.makeCommandQueue() else { return nil }
//        self.commandQueue = commandQueue
//
//        // Geometry and Color data (unchanged)
//        let vertices: [SIMD3<Float>] = [
//             SIMD3<Float>( 0.0,  0.5, 0.0), SIMD3<Float>(-0.5, -0.5, 0.0), SIMD3<Float>( 0.5, -0.5, 0.0)
//        ]
//        let colors: [SIMD4<Float>] = [
//             SIMD4<Float>(1.0, 0.0, 0.0, 1.0), SIMD4<Float>(0.0, 1.0, 0.0, 1.0), SIMD4<Float>(0.0, 0.0, 1.0, 1.0)
//        ]
//        guard let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<SIMD3<Float>>.stride, options: []) else { return nil }
//        self.vertexBuffer = vertexBuffer
//        guard let colorBuffer = device.makeBuffer(bytes: colors, length: colors.count * MemoryLayout<SIMD4<Float>>.stride, options: []) else { return nil }
//        self.colorBuffer = colorBuffer
//
//        // *** Create Uniform Buffer ***
//        // Ensure buffer size matches the Uniforms struct
//        let uniformBufferSize = MemoryLayout<Uniforms>.stride
//        guard let uniformBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared) else { return nil }
//        self.uniformBuffer = uniformBuffer
//
//        // Load Shaders and Pipeline State (using new shader source)
//        do {
//            let library = try device.makeLibrary(source: metalShaderSourceWithInteraction, options: nil) // Use updated shader
//            guard let vertexFunction = library.makeFunction(name: "vertex_main"),
//                  let fragmentFunction = library.makeFunction(name: "fragment_main") else { return nil }
//
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.vertexFunction = vertexFunction
//            pipelineDescriptor.fragmentFunction = fragmentFunction
//            pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
//            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//        } catch {
//            print("Error creating Metal pipeline state: \(error)")
//            return nil
//        }
//        super.init()
//    }
//
//    // Draw Function (Modified to update full Uniforms struct)
//    func draw(in view: MTKView) {
//        guard let drawable = view.currentDrawable,
//              let renderPassDescriptor = view.currentRenderPassDescriptor,
//              let commandBuffer = commandQueue.makeCommandBuffer(),
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
//        else { return }
//
//        // --- Update automatic Z rotation time ---
//        let deltaTime: Float = 1.0 / 60.0 // Approximate delta time
//        time += deltaTime * rotationSpeed * 2.0 * Float.pi // Update accumulated Z angle
//
//        // --- Update Uniform Buffer on GPU ---
//        let uniformData = Uniforms(time: time, rotationX: rotationX, rotationY: rotationY)
//        let uniformPtr = uniformBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
//        uniformPtr[0] = uniformData // Copy the whole struct
//
//        // --- Configure Render Encoder ---
//        renderEncoder.setRenderPipelineState(pipelineState)
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        renderEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2) // Bind uniform buffer to index 2
//
//        // --- Issue Draw Call ---
//        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
//
//        // --- Finalize ---
//        renderEncoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//}
//
//// MARK: - Coordinator (Modified to Handle Gestures)
//
//class Coordinator: NSObject, MTKViewDelegate {
//    var parent: MetalViewRepresentable
//    var renderer: MetalRenderer
//    var panStartPoint: CGPoint?       // Store starting point of pan
//    var lastRotationX: Float = 0.0    // Store rotation from previous gesture state
//    var lastRotationY: Float = 0.0
//
//    init(_ parent: MetalViewRepresentable, renderer: MetalRenderer) {
//        self.parent = parent
//        self.renderer = renderer
//        super.init()
//    }
//
//    // Delegate method called per frame
//    func draw(in view: MTKView) {
//        renderer.draw(in: view)
//    }
//
//    // Delegate method called on resize
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        // Handle resize if needed
//    }
//
//    // --- Gesture Handling ---
//    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
//        guard let view = gesture.view else { return }
//        let translation = gesture.translation(in: view) // Get drag distance
//
//        switch gesture.state {
//        case .began:
//            // Store the starting state
//            panStartPoint = translation
//            // Store the current renderer rotation when gesture begins
//            lastRotationX = renderer.rotationX
//            lastRotationY = renderer.rotationY
//
//        case .changed:
//            // Calculate delta rotation based on drag distance from start
//            // Adjust sensitivity by changing the divisor
//            let deltaX = Float(translation.y - (panStartPoint?.y ?? 0)) / 100.0 // Vertical drag -> X rotation
//            let deltaY = Float(translation.x - (panStartPoint?.x ?? 0)) / 100.0 // Horizontal drag -> Y rotation
//
//            // Apply delta to the rotation state that existed when the gesture began
//            renderer.rotationX = lastRotationX + deltaX
//            renderer.rotationY = lastRotationY + deltaY
//            // Note: Directly setting renderer properties triggers the draw loop implicitly
//
//            // No need to reset translation if calculating delta from start point each time
//            // gesture.setTranslation(.zero, in: view) // Only reset if calculating delta from last frame
//
//        case .ended, .cancelled, .failed:
//            // Reset start point
//            panStartPoint = nil
//            // Rotation remains where the user left it
//
//        default:
//            break
//        }
//    }
//}
//
//// MARK: - UIViewRepresentable (Modified to add Gesture Recognizer)
//
//struct MetalViewRepresentable: UIViewRepresentable {
//    @Binding var rotationSpeed: Float
//    @Binding var backgroundColor: Color
//
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//
//        // Renderer initialization
//        guard let renderer = MetalRenderer(mtkView: mtkView) else {
//            fatalError("MetalRenderer could not be initialized")
//        }
//        renderer.rotationSpeed = rotationSpeed // Set initial speed
//        mtkView.clearColor = backgroundColor.toMTLClearColor() // Set initial color
//
//        // Store renderer in coordinator and set delegate
//        context.coordinator.renderer = renderer
//        mtkView.delegate = context.coordinator
//
//        // --- Add Gesture Recognizer ---
//        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
//        mtkView.addGestureRecognizer(panGesture)
//        mtkView.isUserInteractionEnabled = true // Ensure view can receive touches
//
//        // MTKView configuration
//        mtkView.enableSetNeedsDisplay = false
//        mtkView.isPaused = false
//
//        return mtkView
//    }
//
//    // Updates based on SwiftUI state changes (unchanged logic)
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // Update automatic rotation speed
//        context.coordinator.renderer.rotationSpeed = rotationSpeed
//        // Update background color
//        uiView.clearColor = backgroundColor.toMTLClearColor()
//    }
//
//    // Creates the Coordinator (unchanged logic)
//    func makeCoordinator() -> Coordinator {
//        guard let placeholderDevice = MTLCreateSystemDefaultDevice(),
//            let placeholderRenderer = MetalRenderer(mtkView: MTKView(frame: .zero, device: placeholderDevice)) else {
//            fatalError("Could not create placeholder renderer")
//        }
//       return Coordinator(self, renderer: placeholderRenderer)
//   }
//}
//
//// MARK: - SwiftUI Content View (Unchanged)
//
//struct ContentView: View {
//    @State private var speed: Float = 0.5
//    @State private var bgColor: Color = Color(red: 0.1, green: 0.1, blue: 0.15)
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Metal View Area
//            ZStack { // Use ZStack to potentially overlay instructions
//                 MetalViewRepresentable(rotationSpeed: $speed, backgroundColor: $bgColor)
//                 Text("Drag to rotate X/Y")
//                    .foregroundColor(.white.opacity(0.7))
//                    .font(.caption)
//                    .padding(5)
//                    .background(Color.black.opacity(0.5))
//                    .cornerRadius(5)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
//                    .padding()
//            }
//
//            // Controls Area (Unchanged)
//            VStack {
//                Text("Controls").font(.headline).padding(.top)
//                HStack {
//                    Text("Z-Speed:")
//                    Slider(value: $speed, in: 0.0...2.0)
//                }.padding(.horizontal)
//                 ColorPicker("Background", selection: $bgColor)
//                     .padding(.horizontal)
//                Spacer()
//            }
//            .padding(.bottom)
//            .background(Color(.systemGray6))
//            .frame(height: 150)
//        }
//        .background(Color(.systemGray6))
//        .edgesIgnoringSafeArea(.all)
//    }
//}
//
//// MARK: - Preview Prvider (Unchanged)
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
//// MARK: - App Entry Point (If needed)
///*
//@main
//struct MetalSwiftUIInteractionApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//*/
