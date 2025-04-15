//
//  MetalSwiftUIInteractionDemoView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import SwiftUI
import MetalKit
import Combine
import simd // For matrix types like float4x4

// MARK: - Matrix Helper Functions (Essential for 3D)

// Creates a translation matrix
func matrix_translation(_ t: SIMD3<Float>) -> float4x4 {
    return float4x4(
        [1, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 0, 1, 0],
        [t.x, t.y, t.z, 1]
    )
}

// Creates a rotation matrix around an axis
func matrix_rotation(angle: Float, axis: SIMD3<Float>) -> float4x4 {
    let c = cos(angle)
    let s = sin(angle)
    let t = 1 - c
    let x = axis.x, y = axis.y, z = axis.z
    
    return float4x4(
        [t*x*x + c,   t*x*y + s*z, t*x*z - s*y, 0],
        [t*x*y - s*z, t*y*y + c,   t*y*z + s*x, 0],
        [t*x*z + s*y, t*y*z - s*x, t*z*z + c,   0],
        [0,           0,           0,           1]
    )
}

// Creates a scaling matrix
func matrix_scaling(_ s: SIMD3<Float>) -> float4x4 {
    return float4x4(
        [s.x, 0,   0,   0],
        [0,   s.y, 0,   0],
        [0,   0,   s.z, 0],
        [0,   0,   0,   1]
    )
}

// Creates a perspective projection matrix (Right-Handed)
// fovy: vertical field of view in radians
// aspect: width / height
// nearZ: near clipping plane distance
// farZ: far clipping plane distance
func matrix_perspective_right_hand(fovyRadians fovy: Float, aspectRatio aspect: Float, nearZ: Float, farZ: Float) -> float4x4 {
    let ys = 1 / tanf(fovy * 0.5)
    let xs = ys / aspect
    let zs = farZ / (nearZ - farZ)
    return float4x4(
        [xs,  0,  0, 0],
        [ 0, ys,  0, 0],
        [ 0,  0, zs, -1],
        [ 0,  0, zs * nearZ, 0]
    )
    // Note: Adjust signs if using Left-Handed coordinates or different conventions
}

// Creates a look-at view matrix (Right-Handed)
func matrix_look_at_right_hand(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> float4x4 {
    let z = normalize(eye - center)
    let x = normalize(cross(up, z))
    let y = cross(z, x)
    let t = SIMD3<Float>(-dot(x, eye), -dot(y, eye), -dot(z, eye))
    
    return float4x4(
        [x.x, y.x, z.x, 0],
        [x.y, y.y, z.y, 0],
        [x.z, y.z, z.z, 0],
        [t.x, t.y, t.z, 1]
    )
    // Note: Adjust signs/order if using Left-Handed coordinates
}

// MARK: - Metal Shaders (Modified for MVP)

let metalShaderSourceMVP = """
using namespace metal;

// Structure for vertex data (position and color)
struct Vertex {
    float3 position; // Model space position
    float4 color;
};

// Data passed from vertex to fragment shader
struct VertexOut {
    float4 position [[position]]; // Clip space position
    float4 color;
};

// *** Uniforms Structure with MVP Matrices ***
struct Uniforms {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};

// ---- Vertex Shader (Modified for MVP) ----
vertex VertexOut vertex_main(
    uint vertexID [[vertex_id]],
    constant float3 *vertices [[buffer(0)]],    // Model space vertices
    constant float4 *colors [[buffer(1)]],
    constant Uniforms &uniforms [[buffer(2)]] // MVP Uniforms
) {
    VertexOut out;

    float4 modelPos = float4(vertices[vertexID], 1.0);

    // Transform vertex position using Model-View-Projection matrices
    // Final position = Projection * View * Model * Vertex
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * modelPos;

    out.color = colors[vertexID]; // Pass color through
    return out;
}

// ---- Fragment Shader (Unchanged) ----
fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return in.color;
}
"""

// MARK: - Color Conversion Helper (Unchanged)
extension Color {
    func toMTLClearColor() -> MTLClearColor {
#if os(macOS)
        let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor.clear
        var red: CGFloat = 0; var green: CGFloat = 0; var blue: CGFloat = 0; var alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return MTLClearColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
#else
        let uiColor = UIColor(self)
        var red: CGFloat = 0; var green: CGFloat = 0; var blue: CGFloat = 0; var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return MTLClearColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
#endif
    }
}

// MARK: - Object Definition

struct RenderableObject {
    var position: SIMD3<Float> = [0, 0, 0]
    var rotation: SIMD3<Float> = [0, 0, 0] // Stores angles in radians
    var scale: SIMD3<Float> = [1, 1, 1]
    
    // Calculates the model matrix for this object
    func calculateModelMatrix() -> float4x4 {
        let scaleMatrix = matrix_scaling(scale)
        let rotXMatrix = matrix_rotation(angle: rotation.x, axis: [1, 0, 0])
        let rotYMatrix = matrix_rotation(angle: rotation.y, axis: [0, 1, 0])
        let rotZMatrix = matrix_rotation(angle: rotation.z, axis: [0, 0, 1])
        let translateMatrix = matrix_translation(position)
        
        // Combine transformations: Scale -> Rotate -> Translate
        // Matrix multiplication order is important and often read right-to-left
        return translateMatrix * rotZMatrix * rotYMatrix * rotXMatrix * scaleMatrix
    }
}

// MARK: - Metal Renderer Class (Modified for Scene & Camera)

class MetalRenderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState
    var vertexBuffer: MTLBuffer // Shared vertex data for all triangles
    var colorBuffer: MTLBuffer  // Shared color data for all triangles
    var uniformBuffer: MTLBuffer // Holds MVP Uniforms (updated per object)
    
    // --- Scene Objects ---
    var objects: [RenderableObject] = []
    
    // --- Camera Parameters (Orbit Camera) ---
    var cameraDistance: Float = 5.0
    var cameraPitch: Float = 0.0 // Angle up/down (radians)
    var cameraYaw: Float = 0.0   // Angle left/right (radians)
    var cameraTarget: SIMD3<Float> = [0, 0, 0] // Point the camera looks at
    var cameraUp: SIMD3<Float> = [0, 1, 0]     // Up direction
    
    // --- Viewport / Projection ---
    var aspectRatio: Float = 1.0
    var fieldOfView: Float = Float.pi / 3.0 // 60 degrees vertical FOV
    var nearZ: Float = 0.1
    var farZ: Float = 100.0
    
    // --- Animation ---
    var globalZRotationSpeed: Float = 0.5
    
    // Struct matching the shader's Uniforms struct
    struct Uniforms {
        var modelMatrix: float4x4
        var viewMatrix: float4x4
        var projectionMatrix: float4x4
    }
    
    init?(mtkView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        self.device = device
        mtkView.device = device
        
        guard let commandQueue = device.makeCommandQueue() else { return nil }
        self.commandQueue = commandQueue
        
        // Geometry and Color data (Shared for all triangles)
        let vertices: [SIMD3<Float>] = [
            SIMD3<Float>( 0.0,  0.5, 0.0), SIMD3<Float>(-0.5, -0.5, 0.0), SIMD3<Float>( 0.5, -0.5, 0.0)
        ]
        let colors: [SIMD4<Float>] = [
            SIMD4<Float>(1.0, 0.0, 0.0, 1.0), SIMD4<Float>(0.0, 1.0, 0.0, 1.0), SIMD4<Float>(0.0, 0.0, 1.0, 1.0) // Same colors for all
        ]
        guard let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<SIMD3<Float>>.stride, options: []) else { return nil }
        self.vertexBuffer = vertexBuffer
        guard let colorBuffer = device.makeBuffer(bytes: colors, length: colors.count * MemoryLayout<SIMD4<Float>>.stride, options: []) else { return nil }
        self.colorBuffer = colorBuffer
        
        // --- Create Uniform Buffer for MVP ---
        let uniformBufferSize = MemoryLayout<Uniforms>.stride
        guard let uniformBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared) else { return nil }
        self.uniformBuffer = uniformBuffer
        
        // Load Shaders and Pipeline State (using MVP shader source)
        do {
            let library = try device.makeLibrary(source: metalShaderSourceMVP, options: nil) // Use MVP shader
            guard let vertexFunction = library.makeFunction(name: "vertex_main"),
                  let fragmentFunction = library.makeFunction(name: "fragment_main") else { return nil }
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Error creating Metal pipeline state: \(error)")
            return nil
        }
        
        // --- Initialize Scene Objects ---
        objects = [
            RenderableObject(position: [-1.5, 0, 0]),
            RenderableObject(position: [ 0, 0, 0]),
            RenderableObject(position: [ 1.5, 0, 0])
        ]
        
        super.init()
    }
    
    // --- Camera Calculation ---
    func calculateViewMatrix() -> float4x4 {
        // Calculate camera position based on distance, pitch, yaw from target
        let cosPitch = cos(cameraPitch)
        let sinPitch = sin(cameraPitch)
        let cosYaw = cos(cameraYaw)
        let sinYaw = sin(cameraYaw)
        
        let x = cameraDistance * cosPitch * sinYaw
        let y = cameraDistance * sinPitch
        let z = cameraDistance * cosPitch * cosYaw
        
        let eyePosition = cameraTarget + SIMD3<Float>(x, y, z)
        
        return matrix_look_at_right_hand(eye: eyePosition, center: cameraTarget, up: cameraUp)
    }
    
    func calculateProjectionMatrix() -> float4x4 {
        return matrix_perspective_right_hand(fovyRadians: fieldOfView, aspectRatio: aspectRatio, nearZ: nearZ, farZ: farZ)
    }
    
    // Draw Function (Modified for Multiple Objects and MVP)
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else { return }
        
        // --- Update Aspect Ratio (in case view size changes) ---
        let size = view.drawableSize
        if size.width > 0 && size.height > 0 { // Avoid division by zero
            aspectRatio = Float(size.width / size.height)
        }
        
        // --- Calculate View and Projection Matrices (once per frame) ---
        let viewMatrix = calculateViewMatrix()
        let projectionMatrix = calculateProjectionMatrix()
        
        // --- Configure Render Encoder (static state) ---
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0) // Shared vertex data
        renderEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)  // Shared color data
        
        // --- Update object rotations (apply global Z rotation) ---
        let deltaTime: Float = 1.0 / 60.0 // Approximate time step
        let angleDelta = deltaTime * globalZRotationSpeed * 2.0 * Float.pi
        for i in 0..<objects.count {
            objects[i].rotation.z += angleDelta // Rotate each object around its Z axis
        }
        
        // --- Loop through objects and draw each one ---
        for object in objects {
            // Calculate Model Matrix for this object
            let modelMatrix = object.calculateModelMatrix()
            
            // Prepare Uniforms for this object
            var uniforms = Uniforms(modelMatrix: modelMatrix, viewMatrix: viewMatrix, projectionMatrix: projectionMatrix)
            
            // Update Uniform Buffer on GPU
            let uniformPtr = uniformBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
            uniformPtr[0] = uniforms
            
            // Bind the updated uniform buffer for this draw call
            renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2) // Bind uniform buffer
            
            // Issue Draw Call for this object
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        } // End object loop
        
        // --- Finalize ---
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - Coordinator (Modified to Control Camera Orbit)

class Coordinator: NSObject, MTKViewDelegate {
    var parent: MetalViewRepresentable
    var renderer: MetalRenderer
    var panStartPoint: CGPoint?       // Store starting point of pan
    var lastCameraPitch: Float = 0.0  // Store camera pitch from previous gesture state
    var lastCameraYaw: Float = 0.0    // Store camera yaw from previous gesture state
    
    // Sensitivity factors for camera control
    let pitchSensitivity: Float = 0.008
    let yawSensitivity: Float = 0.008
    
    init(_ parent: MetalViewRepresentable, renderer: MetalRenderer) {
        self.parent = parent
        self.renderer = renderer
        // Set initial camera state in renderer if desired
        self.renderer.cameraPitch = Float.pi / 6.0 // Start slightly looking down
        self.lastCameraPitch = self.renderer.cameraPitch
        self.lastCameraYaw = self.renderer.cameraYaw
        super.init()
    }
    
    // Delegate method called per frame
    func draw(in view: MTKView) {
        renderer.draw(in: view)
    }
    
    // Delegate method called on resize
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Update aspect ratio in the renderer when the view size changes
        if size.height > 0 { // Avoid division by zero
            renderer.aspectRatio = Float(size.width / size.height)
        }
        // No need to redraw explicitly, draw(in:) will be called
    }
    
    // --- Gesture Handling (Camera Orbit) ---
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: view) // Get drag distance
        
        switch gesture.state {
        case .began:
            panStartPoint = translation
            // Store the current camera rotation when gesture begins
            lastCameraPitch = renderer.cameraPitch
            lastCameraYaw = renderer.cameraYaw
            
        case .changed:
            if let start = panStartPoint {
                // Calculate delta angles based on drag distance from start
                let deltaPitch = Float(translation.y - start.y) * pitchSensitivity // Vertical drag -> Pitch
                let deltaYaw = Float(translation.x - start.x) * yawSensitivity   // Horizontal drag -> Yaw
                
                // Apply delta to the camera state that existed when the gesture began
                var newPitch = lastCameraPitch + deltaPitch
                let newYaw = lastCameraYaw + deltaYaw
                
                // Clamp pitch to prevent flipping over the top/bottom
                let pitchLimit = Float.pi / 2.0 - 0.01 // Just shy of 90 degrees
                newPitch = max(-pitchLimit, min(pitchLimit, newPitch))
                
                // Update renderer directly
                renderer.cameraPitch = newPitch
                renderer.cameraYaw = newYaw
            }
            
        case .ended, .cancelled, .failed:
            panStartPoint = nil // Reset start point
            // Camera rotation remains where the user left it
            
        default:
            break
        }
    }
}

// MARK: - UIViewRepresentable (Largely Unchanged, passes gesture)

struct MetalViewRepresentable: UIViewRepresentable {
    @Binding var globalZRotationSpeed: Float // Renamed binding
    @Binding var backgroundColor: Color
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        
        // Renderer initialization
        guard let renderer = MetalRenderer(mtkView: mtkView) else {
            fatalError("MetalRenderer could not be initialized")
        }
        renderer.globalZRotationSpeed = globalZRotationSpeed // Set initial speed
        mtkView.clearColor = backgroundColor.toMTLClearColor() // Set initial color
        
        // Store renderer in coordinator and set delegate
        // Coordinator's init now sets initial camera pitch
        context.coordinator.renderer = renderer
        mtkView.delegate = context.coordinator
        
        // --- Add Gesture Recognizer (Unchanged setup) ---
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        mtkView.addGestureRecognizer(panGesture)
        mtkView.isUserInteractionEnabled = true
        
        // MTKView configuration
        mtkView.enableSetNeedsDisplay = false // Use display link timer
        mtkView.isPaused = false
        mtkView.preferredFramesPerSecond = 60 // Match renderer assumption
        
        return mtkView
    }
    
    // Updates based on SwiftUI state changes
    func updateUIView(_ uiView: MTKView, context: Context) {
        // Update global rotation speed for all objects
        context.coordinator.renderer.globalZRotationSpeed = globalZRotationSpeed
        // Update background color
        uiView.clearColor = backgroundColor.toMTLClearColor()
    }
    
    // Creates the Coordinator instance
    func makeCoordinator() -> Coordinator {
        // Create a temporary placeholder renderer needed for Coordinator init
        guard let placeholderDevice = MTLCreateSystemDefaultDevice(),
              let placeholderRenderer = MetalRenderer(mtkView: MTKView(frame: .zero, device: placeholderDevice)) else {
            fatalError("Could not create placeholder renderer for coordinator")
        }
        // The actual renderer will be assigned in makeUIView
        return Coordinator(self, renderer: placeholderRenderer)
    }
}

// MARK: - SwiftUI Content View (Adjusted Labels)

struct ContentView: View {
    @State private var rotationSpeed: Float = 0.5 // Controls Z-rotation of all objects
    @State private var bgColor: Color = Color(red: 0.1, green: 0.15, blue: 0.2) // Slightly different bg
    
    var body: some View {
        VStack(spacing: 0) {
            // Metal View Area
            ZStack {
                MetalViewRepresentable(globalZRotationSpeed: $rotationSpeed, backgroundColor: $bgColor)
                Text("Drag to orbit camera") // Updated instruction
                    .foregroundColor(.white.opacity(0.7))
                    .font(.caption)
                    .padding(5)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding()
            }
            
            // Controls Area
            VStack {
                Text("Controls").font(.headline).padding(.top)
                HStack {
                    Text("Object Z-Speed:") // Label reflects control
                    Slider(value: $rotationSpeed, in: 0.0...2.0)
                }.padding(.horizontal)
                ColorPicker("Background", selection: $bgColor)
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.bottom)
            .background(Color(.systemGray6))
            .frame(height: 150) // Keep controls visible
        }
        .background(Color(.systemGray6))
        .edgesIgnoringSafeArea(.bottom) // Allow metal view full space, but keep top safe area
    }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
