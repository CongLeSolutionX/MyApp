////
////  Renderer.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import MetalKit
//
///// Represents a tuple of five `SIMD2<Float>` values. Used for storing positions and impulses.
//typealias FloatTuple = (SIMD2<Float>, SIMD2<Float>, SIMD2<Float>, SIMD2<Float>, SIMD2<Float>)
//
//// MARK: - FloatTuple Operators
//
///// Divides each element of a `FloatTuple` by a scalar.
///// - Parameters:
/////   - rhs: The `FloatTuple` dividend.
/////   - lhs: The scalar divisor.
///// - Returns: A new `FloatTuple` with each element divided by the scalar.
//func / (rhs: FloatTuple, lhs: Float) -> FloatTuple {
//    return FloatTuple(rhs.0 / lhs, rhs.1 / lhs, rhs.2 / lhs, rhs.3 / lhs, rhs.4 / lhs)
//}
//
///// Subtracts two FloatTuples element-wise.
///// - Parameters:
/////   - rhs: The `FloatTuple` minuend.
/////   - lhs: The `FloatTuple` subtrahend.
///// - Returns: A new FloatTuple representing the difference.
//func - (rhs: FloatTuple, lhs: FloatTuple) -> FloatTuple {
//    return FloatTuple(rhs.0 - lhs.0, rhs.1 - lhs.1, rhs.2 - lhs.2, rhs.3 - lhs.3, rhs.4 - lhs.4)
//}
//
//// MARK: - Data Structures
//
///// Struct containing static data needed for rendering.
//struct StaticData {
//    /// Touch/mouse positions, scaled by `ScreenScaleAdjustment`
//    var positions: FloatTuple
//    /// Touch/mouse impulses (difference between current and previous positions), scaled by `ScreenScaleAdjustment`
//    var impulses: FloatTuple
//    /// Scalar impulse values (strength and unused component)
//    var impulseScalar: SIMD2<Float>
//    /// Texture coordinate offsets `(1/width, 1/height)`
//    var offsets: SIMD2<Float>
//    /// Screen dimensions (width, height).
//    var screenSize: SIMD2<Float>
//    /// Radius of the ink effect
//    var inkRadius: simd_float1
//}
//
///// Struct representing vertex data.
//struct VertexData {
//    /// Vertex position.
//    let position: SIMD2<Float>
//    /// Texture coordinates.
//    let texCoord: SIMD2<Float>
//}
//
//
//// MARK: - Renderer Class
//
///// Metal-based renderer for fluid simulation.
//class Renderer: NSObject {
//    /// Maximum number of inflight buffers.
//    static let MaxBuffers = 3
//    
//    /// Adjustment factor for slab texture size.
//    /// Higher values reduce performance impact but lower visual quality.
//    /// Range: `[0.5, 3.0]`
//    static let ScreenScaleAdjustment: Float = 1.0
//    
//    // MARK:  - Vertex and Index Data
//    
//    /// Vertex data for a quad.
//    static let vertexData: [VertexData] = [
//        VertexData(position: SIMD2<Float>(x: -1.0, y: -1.0), texCoord: SIMD2<Float>(x: 0.0, y: 1.0)),
//        VertexData(position: SIMD2<Float>(x: 1.0, y: -1.0), texCoord: SIMD2<Float>(x: 1.0, y: 1.0)),
//        VertexData(position: SIMD2<Float>(x: -1.0, y: 1.0), texCoord: SIMD2<Float>(x: 0.0, y: 0.0)),
//        VertexData(position: SIMD2<Float>(x: 1.0, y: 1.0), texCoord: SIMD2<Float>(x: 1.0, y: 0.0)),
//    ]
//    
//    /// Quad indices
//    static let indices: [UInt16] = [2, 1, 0, 1, 2, 3]
//    
//    // MARK: - Metal Buffers
//
//    /// Metal buffer for vertex data
//    private let vertData = MetalDevice.sharedInstance.makeBuffer(from: Renderer.vertexData, options: [.storageModeShared])
//    /// Metal buffer for index data
//    private let indexData = MetalDevice.sharedInstance.makeBuffer(from: Renderer.indices, options: [.storageModeShared])
//    
//    // MARK: - Shaders
//    
//    // Fluid simulation shaders
//    private let applyForceVectorShader: RenderShader = RenderShader(fragmentShader: "applyForceVector", vertexShader: "vertexShader", pixelFormat: .rg16Float)
//    private let applyForceScalarShader: RenderShader = RenderShader(fragmentShader: "applyForceScalar", vertexShader: "vertexShader", pixelFormat: .rg16Float)
//    private let advectShader: RenderShader = RenderShader(fragmentShader: "advect", vertexShader: "vertexShader", pixelFormat: .rg16Float)
//    private let divergenceShader: RenderShader = RenderShader(fragmentShader: "divergence", vertexShader: "vertexShader", pixelFormat: .rg16Float)
//    private let jacobiShader: RenderShader = RenderShader(fragmentShader: "jacobi", vertexShader: "vertexShader", pixelFormat: .rg16Float)
//    private let vorticityShader: RenderShader = RenderShader(fragmentShader: "vorticity", vertexShader: "vertexShader", pixelFormat: .rg16Float)
//    private let vorticityConfinementShader: RenderShader = RenderShader(fragmentShader: "vorticityConfinement", vertexShader: "vertexShader", pixelFormat: .rg16Float)
//    private let gradientShader: RenderShader = RenderShader(fragmentShader: "gradient", vertexShader: "vertexShader", pixelFormat: .rg16Float)
//    
//    // Visualization shaders
//    private let renderVector: RenderShader = RenderShader(fragmentShader: "visualizeVector", vertexShader: "vertexShader")
//    private let renderScalar: RenderShader = RenderShader(fragmentShader: "visualizeScalar", vertexShader: "vertexShader")
//    
//    // MARK: - Interaction Data
//
//    /// Current touch/mouse positions
//    private var positions: FloatTuple?
//    /// Previous touch/mouse positions
//    private var directions: FloatTuple?
//    
//    // MARK: - Simulation Surfaces
//    
//    /// Velocity slab
//    private var velocity: Slab!
//    /// Density slab
//    private var density: Slab!
//    /// Velocity divergence slab
//    private var velocityDivergence: Slab!
//    /// Velocity vorticity slab
//    private var velocityVorticity: Slab!
//    /// Pressure slab
//    private var pressure: Slab!
//    
//    // MARK: - Rendering Resources
//    
//    /// Array of uniform buffers
//    private var uniformsBuffers: [MTLBuffer] = []
//    /// Index of the next available uniform buffer
//    private var avaliableBufferIndex: Int = 0
//    /// Semaphore for managing inflight buffers
//    private let semaphore = DispatchSemaphore(value: MaxBuffers)
//    
//    /// Index of the currently displayed slab `(0: density, 1: pressure, 2: velocity, 3: vorticity)`
//    private var currentIndex = 0
//
//    // MARK: - Initialization
//
//    /// Initializes the renderer with a given `MetalKit` view.
//    /// - Parameter metalView: The `MTKView` to render into
//    init(metalView: MTKView) {
//        super.init()
//        print("Im initializing the renderer")
//        metalView.device = MetalDevice.sharedInstance.device
//        metalView.colorPixelFormat = .bgra8Unorm
//        metalView.framebufferOnly = true
//        metalView.preferredFramesPerSecond = 60
//        
//        mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
//    }
//    
//    func nextSlab() {
//        currentIndex = (currentIndex + 1) % 4
//    }
//    
//    func updateInteraction(points: FloatTuple?, in view: MTKView) {
//        positions = points
//    }
//    
//    private final func initSurfaces(width: Int, height: Int) {
//        velocity = Slab(width: width, height: height, format: .rg16Float, name: "Velocity")
//        density = Slab(width: width, height: height, format: .rg16Float, name: "Density")
//        velocityDivergence = Slab(width: width, height: height, format: .rg16Float, name: "Divergence")
//        velocityVorticity = Slab(width: width, height: height, format: .rg16Float, name: "Vorticity")
//        pressure = Slab(width: width, height: height, format: .rg16Float, name: "Pressure")
//    }
//    
//    private final func initBuffers(width: Int, height: Int) {
//        let bufferSize = MemoryLayout<StaticData>.stride
//        
//        var staticData = StaticData(positions: (SIMD2<Float>(), SIMD2<Float>(), SIMD2<Float>(), SIMD2<Float>(), SIMD2<Float>()),
//                                    impulses: (SIMD2<Float>(), SIMD2<Float>(), SIMD2<Float>(), SIMD2<Float>(), SIMD2<Float>()),
//                                    impulseScalar: SIMD2<Float>(),
//                                    offsets: SIMD2<Float>(1.0/Float(width), 1.0/Float(height)),
//                                    screenSize: SIMD2<Float>(Float(width), Float(height)),
//                                    inkRadius: 150 / Renderer.ScreenScaleAdjustment)
//        
//        uniformsBuffers.removeAll()
//        for _ in 0..<Renderer.MaxBuffers {
//            let buffer = MetalDevice.sharedInstance.device.makeBuffer(bytes: &staticData, length: bufferSize, options: .storageModeShared)!
//            
//            uniformsBuffers.append(buffer)
//        }
//    }
//    
//    private final func nextBuffer(positions: FloatTuple?, directions: FloatTuple?) -> MTLBuffer {
//        let buffer = uniformsBuffers[avaliableBufferIndex]
//        
//        let bufferData = buffer.contents().bindMemory(to: StaticData.self, capacity: 1)
//        
//        if let positions = positions, let directions = directions {
//            let alteredPositions = positions / Renderer.ScreenScaleAdjustment
//            let impulses = (positions - directions) / Renderer.ScreenScaleAdjustment
//            
//            bufferData.pointee.positions = alteredPositions
//            bufferData.pointee.impulses = impulses
//            bufferData.pointee.impulseScalar = SIMD2<Float>(0.8, 0.0)
//        }
//        
//        avaliableBufferIndex = (avaliableBufferIndex + 1) % Renderer.MaxBuffers
//        return buffer
//    }
//    
//    private final func drawSlab() -> Slab {
//        switch currentIndex {
//        case 1:
//            return pressure
//        case 2:
//            return velocity
//        case 3:
//            return velocityVorticity
//        default:
//            return density
//        }
//    }
//}
//
////Fluid dynamics step methods
//extension Renderer {
//    private final func advect(commandBuffer: MTLCommandBuffer, dataBuffer: MTLBuffer, velocity: Slab, source: Slab, destination: Slab) {
//        advectShader.calculateWithCommandBuffer(buffer: commandBuffer, indices: indexData, count: Renderer.indices.count, texture: destination.pong) { (commandEncoder) in
//            commandEncoder.setVertexBuffer(self.vertData, offset: 0, index: 0)
//            commandEncoder.setFragmentTexture(velocity.ping, index: 0)
//            commandEncoder.setFragmentTexture(source.ping, index: 1)
//            
//            commandEncoder.setFragmentBuffer(dataBuffer, offset: 0, index: 0)
//        }
//        
//        destination.swap()
//    }
//    
//    private final func applyForceVector(commandBuffer: MTLCommandBuffer, dataBuffer: MTLBuffer, destination: Slab) {
//        applyForceVectorShader.calculateWithCommandBuffer(buffer: commandBuffer, indices: indexData, count: Renderer.indices.count, texture: destination.pong) { (commandEncoder) in
//            commandEncoder.setVertexBuffer(self.vertData, offset: 0, index: 0)
//            commandEncoder.setFragmentTexture(destination.ping, index: 0)
//            
//            commandEncoder.setFragmentBuffer(dataBuffer, offset: 0, index: 0)
//        }
//        
//        destination.swap()
//    }
//    
//    private final func applyForceScalar(commandBuffer: MTLCommandBuffer, dataBuffer: MTLBuffer, destination: Slab) {
//        applyForceScalarShader.calculateWithCommandBuffer(buffer: commandBuffer, indices: indexData, count: Renderer.indices.count, texture: destination.pong) { (commandEncoder) in
//            commandEncoder.setVertexBuffer(self.vertData, offset: 0, index: 0)
//            commandEncoder.setFragmentTexture(destination.ping, index: 0)
//            
//            commandEncoder.setFragmentBuffer(dataBuffer, offset: 0, index: 0)
//        }
//        
//        destination.swap()
//    }
//    
//    private final func computeDivergence(commandBuffer: MTLCommandBuffer, dataBuffer: MTLBuffer, velocity: Slab, destination: Slab) {
//        divergenceShader.calculateWithCommandBuffer(buffer: commandBuffer, indices: indexData, count: Renderer.indices.count, texture: destination.pong) { (commandEncoder) in
//            commandEncoder.setVertexBuffer(self.vertData, offset: 0, index: 0)
//            commandEncoder.setFragmentTexture(velocity.ping, index: 0)
//            
//            commandEncoder.setFragmentBuffer(dataBuffer, offset: 0, index: 0)
//        }
//        
//        destination.swap()
//    }
//    
//    private final func computePressure(commandBuffer: MTLCommandBuffer, dataBuffer: MTLBuffer, x: Slab, b: Slab, destination: Slab) {
//        jacobiShader.calculateWithCommandBuffer(buffer: commandBuffer, indices: indexData, count: Renderer.indices.count, texture: destination.pong) { (commandEncoder) in
//            commandEncoder.setVertexBuffer(self.vertData, offset: 0, index: 0)
//            commandEncoder.setFragmentTexture(x.ping, index: 0)
//            commandEncoder.setFragmentTexture(b.ping, index: 1)
//            
//            commandEncoder.setFragmentBuffer(dataBuffer, offset: 0, index: 0)
//        }
//        
//        destination.swap()
//    }
//    
//    private final func computeVorticity(commandBuffer: MTLCommandBuffer, dataBuffer: MTLBuffer, velocity: Slab, destination: Slab) {
//        vorticityShader.calculateWithCommandBuffer(buffer: commandBuffer, indices: indexData, count: Renderer.indices.count, texture: destination.pong) { (commandEncoder) in
//            commandEncoder.setVertexBuffer(self.vertData, offset: 0, index: 0)
//            commandEncoder.setFragmentTexture(velocity.ping, index: 0)
//            
//            commandEncoder.setFragmentBuffer(dataBuffer, offset: 0, index: 0)
//        }
//        
//        destination.swap()
//    }
//    
//    private final func computeVorticityConfinement(commandBuffer: MTLCommandBuffer, dataBuffer: MTLBuffer, velocity: Slab, vorticity: Slab, destination: Slab) {
//        vorticityConfinementShader.calculateWithCommandBuffer(buffer: commandBuffer, indices: indexData, count: Renderer.indices.count, texture: destination.pong) { (commandEncoder) in
//            commandEncoder.setVertexBuffer(self.vertData, offset: 0, index: 0)
//            commandEncoder.setFragmentTexture(velocity.ping, index: 0)
//            commandEncoder.setFragmentTexture(vorticity.ping, index: 1)
//            
//            commandEncoder.setFragmentBuffer(dataBuffer, offset: 0, index: 0)
//        }
//        
//        destination.swap()
//    }
//    
//    private final func subtractGradient(commandBuffer: MTLCommandBuffer, dataBuffer: MTLBuffer, p: Slab, w: Slab, destination: Slab) {
//        gradientShader.calculateWithCommandBuffer(buffer: commandBuffer, indices: indexData, count: Renderer.indices.count, texture: destination.pong) { (commandEncoder) in
//            commandEncoder.setVertexBuffer(self.vertData, offset: 0, index: 0)
//            commandEncoder.setFragmentTexture(p.ping, index: 0)
//            commandEncoder.setFragmentTexture(w.ping, index: 1)
//            
//            commandEncoder.setFragmentBuffer(dataBuffer, offset: 0, index: 0)
//        }
//        
//        destination.swap()
//    }
//    
//    private final func render(commandBuffer: MTLCommandBuffer, destination: MTLTexture) {
//        if currentIndex >= 2 {
//            renderVector.calculateWithCommandBuffer(buffer: commandBuffer, indices: indexData, count: Renderer.indices.count, texture: destination) { (commandEncoder) in
//                commandEncoder.setVertexBuffer(self.vertData, offset: 0, index: 0)
//                commandEncoder.setFragmentTexture(self.drawSlab().ping, index: 0)
//            }
//        } else {
//            renderScalar.calculateWithCommandBuffer(buffer: commandBuffer, indices: indexData, count: Renderer.indices.count, texture: destination) { (commandEncoder) in
//                commandEncoder.setVertexBuffer(self.vertData, offset: 0, index: 0)
//                commandEncoder.setFragmentTexture(self.drawSlab().ping, index: 0)
//            }
//        }
//    }
//}
//
//extension Renderer: MTKViewDelegate {
//    func draw(in view: MTKView) {
//        semaphore.wait()
//        let commandBuffer = MetalDevice.sharedInstance.newCommandBuffer()
//        
//        let dataBuffer = nextBuffer(positions: positions, directions: directions)
//        
//        commandBuffer.addCompletedHandler({ (commandBuffer) in
//            self.semaphore.signal()
//        })
//        
//        advect(commandBuffer: commandBuffer, dataBuffer: dataBuffer, velocity: velocity, source: velocity, destination: velocity)
//        advect(commandBuffer: commandBuffer, dataBuffer: dataBuffer, velocity: velocity, source: density, destination: density)
//        
//        if let _ = positions, let _ = directions {
//            applyForceVector(commandBuffer: commandBuffer, dataBuffer: dataBuffer, destination: velocity)
//            applyForceScalar(commandBuffer: commandBuffer, dataBuffer: dataBuffer, destination: density)
//        }
//        
//        computeVorticity(commandBuffer: commandBuffer, dataBuffer: dataBuffer, velocity: velocity, destination: velocityVorticity)
//        computeVorticityConfinement(commandBuffer: commandBuffer, dataBuffer: dataBuffer, velocity: velocity, vorticity: velocityVorticity, destination: velocity)
//        
//        computeDivergence(commandBuffer: commandBuffer, dataBuffer: dataBuffer, velocity: velocity, destination: velocityDivergence)
//        
//        for _ in 0..<40 {
//            computePressure(commandBuffer: commandBuffer, dataBuffer: dataBuffer, x: pressure, b: velocityDivergence, destination: pressure)
//        }
//        
//        subtractGradient(commandBuffer: commandBuffer, dataBuffer: dataBuffer, p: pressure, w: velocity, destination: velocity)
//        
//        if let drawable = view.currentDrawable {
//            
//            let nextTexture = drawable.texture
//            render(commandBuffer: commandBuffer, destination: nextTexture)
//            
//            commandBuffer.present(drawable)
//        }
//        
//        commandBuffer.commit()
//        
//        directions = positions
//    }
//    
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        let width = Int(Float(view.bounds.width) / Renderer.ScreenScaleAdjustment)
//        let height = Int(Float(view.bounds.height) / Renderer.ScreenScaleAdjustment)
//        
//        initSurfaces(width: width, height: height)
//        initBuffers(width: width, height: height)
//    }
//}
