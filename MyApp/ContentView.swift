//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}

import SwiftUI
import UIKit
import OpenGLES // Main OpenGL ES framework
import GLKit    // Although deprecated, handy for some utilities if needed, but we'll avoid relying on it heavily.

// MARK: - OpenGL ES View (UIView Subclass)

class OpenGLESView: UIView {

    private var eaglLayer: CAEAGLLayer!
    private var context: EAGLContext?
    private var framebuffer: GLuint = 0
    private var renderbuffer: GLuint = 0
    private var framebufferWidth: GLint = 0
    private var framebufferHeight: GLint = 0

    // For animation/drawing loop
    private var displayLink: CADisplayLink?
    private var startTime: TimeInterval = 0

    // === Initialization and Setup ===

    // Specify that the layer class for this view is CAEAGLLayer
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
        setupContext()
        setupDisplayLink() // Start the animation loop
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
        setupContext()
        setupDisplayLink() // Start the animation loop
    }

    private func setupLayer() {
        eaglLayer = self.layer as? CAEAGLLayer

        guard let eaglLayer = eaglLayer else {
            print("Error: Could not get CAEAGLLayer")
            return
        }

        // Configure the layer
        eaglLayer.isOpaque = true // Assume opaque for performance
        // Set the pixel format (RGBA8 is common)
        eaglLayer.drawableProperties = [
            kEAGLDrawablePropertyRetainedBacking: false, // Discard buffer after presentation
            kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
        ]
        // Set content scale factor for Retina displays
        self.contentScaleFactor = UIScreen.main.scale
        eaglLayer.contentsScale = UIScreen.main.scale
    }

    private func setupContext() {
        // Use OpenGL ES 3 if available, otherwise fall back to 2
        context = EAGLContext(api: .openGLES3) ?? EAGLContext(api: .openGLES2)

        guard let context = context, EAGLContext.setCurrent(context) else {
            print("Error: Failed to create or set EAGLContext")
            return
        }
        print("EAGLContext created successfully (API Version: \(context.api))")
    }

    // === Framebuffer Setup (Called during layout) ===

    override func layoutSubviews() {
        super.layoutSubviews()

        // Setup framebuffer only if context is valid
        guard let context = context, EAGLContext.setCurrent(context) else { return }

        // Destroy previous buffers before creating new ones based on potentially new size
        destroyFramebuffer()
        // Create new framebuffer based on current layer bounds
        createFramebuffer()

        // Update the OpenGL viewport
        glViewport(0, 0, framebufferWidth, framebufferHeight)

        // Start drawing if display link isn't running (optional, depends on your logic)
        // if displayLink == nil {
        //     setupDisplayLink()
        // }
    }

    private func createFramebuffer() {
        guard let context = context, EAGLContext.setCurrent(context) else { return }
        guard eaglLayer != nil else { return }

        // 1. Create Framebuffer Object (FBO)
        glGenFramebuffers(1, &framebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
        if framebuffer == 0 {
             print("Error: Failed to generate framebuffer")
             return
        }

        // 2. Create Renderbuffer Object (RBO) for color attachment
        glGenRenderbuffers(1, &renderbuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderbuffer)
         if renderbuffer == 0 {
             print("Error: Failed to generate renderbuffer")
              destroyFramebuffer() // Clean up FBO if RBO fails
             return
        }

        // 3. Allocate storage for the renderbuffer using the EAGLLayer
        // This connects the renderbuffer to the layer's drawing surface.
        if !context.renderbufferStorage(Int(GL_RENDERBUFFER), from: eaglLayer) {
            print("Error: Failed to allocate renderbuffer storage")
             destroyFramebuffer() // Clean up FBO/RBO
            return
        }

        // 4. Attach the renderbuffer to the framebuffer's color attachment point
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), renderbuffer)

        // 5. Get the dimensions of the framebuffer
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_WIDTH), &framebufferWidth)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_HEIGHT), &framebufferHeight)

        // 6. Check Framebuffer Status
        let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        if status != GLenum(GL_FRAMEBUFFER_COMPLETE) {
            print("Error: Framebuffer is incomplete! Status: \(status)")
             destroyFramebuffer() // Clean up if incomplete
             return
        }

         print("Framebuffer created successfully (\(framebufferWidth) x \(framebufferHeight))")

    }

    // === Rendering ===

    @objc private func render(displayLink: CADisplayLink) {
        guard let context = context, EAGLContext.setCurrent(context) else { return }
        guard framebuffer != 0 else {
             print("Render skipped: Framebuffer not ready.")
             // Attempt to recreate if needed (be cautious of performance)
             createFramebuffer()
             if framebuffer == 0 { return } // Still not ready, skip frame
             glViewport(0, 0, framebufferWidth, framebufferHeight) // Set viewport again
             return
        }

        if startTime == 0 { startTime = displayLink.timestamp }
        let elapsedTime = displayLink.timestamp - startTime

        // Simple animation: Cycle background color
        let red = Float(0.5 + 0.5 * sin(elapsedTime))
        let green = Float(0.5 + 0.5 * sin(elapsedTime + Double.pi * 2.0/3.0))
        let blue = Float(0.5 + 0.5 * sin(elapsedTime + Double.pi * 4.0/3.0))

        // 1. Bind the framebuffer created earlier
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)

        // ** Your OpenGL ES Drawing Code Goes Here **
        // For this example, we just clear the color buffer

        // Set the clear color
        glClearColor(red, green, blue, 1.0)
        // Clear the color buffer
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

        // ** End of OpenGL Drawing Code **

        // 2. Bind the renderbuffer (necessary for presentation)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderbuffer)

        // 3. Present the renderbuffer to the layer.
        if !context.presentRenderbuffer(Int(GL_RENDERBUFFER)) {
            print("Error: Failed to present renderbuffer")
        }
    }

    // === Animation Loop ===

    private func setupDisplayLink() {
        startTime = 0 // Reset start time
        displayLink = CADisplayLink(target: self, selector: #selector(render(displayLink:)))
        displayLink?.preferredFramesPerSecond = 60 // Target 60 FPS
        displayLink?.add(to: .current, forMode: .default)
         print("DisplayLink started.")
    }

    private func invalidateDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
         print("DisplayLink invalidated.")
    }

    // === Cleanup ===

    private func destroyFramebuffer() {
         guard let context = context, EAGLContext.setCurrent(context) else { return }

        if framebuffer != 0 {
            glDeleteFramebuffers(1, &framebuffer)
            framebuffer = 0
             print("Framebuffer destroyed.")
        }
        if renderbuffer != 0 {
            glDeleteRenderbuffers(1, &renderbuffer)
            renderbuffer = 0
             print("Renderbuffer destroyed.")
        }
    }

    private func tearDownGL() {
        guard let context = context else { return }
        if EAGLContext.current() == context {
             destroyFramebuffer()
            EAGLContext.setCurrent(nil)
             print("EAGLContext reset.")
        }
        // context = nil // Let ARC handle the context release
    }

    deinit {
         print("OpenGLESView deinit")
        invalidateDisplayLink()
        tearDownGL()
    }

    // Invalidate displaylink when view is removed
    override func removeFromSuperview() {
         super.removeFromSuperview()
        invalidateDisplayLink()
        tearDownGL() // Ensure cleanup when removed from hierarchy
    }
     override func didMoveToWindow() {
         super.didMoveToWindow()
         if self.window == nil {
             // View was removed from the window hierarchy
             invalidateDisplayLink()
             tearDownGL()
         } else {
             // View was added to the window hierarchy
             // Ensure context is current and display link is running if needed
             if displayLink == nil || displayLink?.isPaused ?? true {
                 // Check if context needs resetup or if displaylink needs restart
                 if context != nil && EAGLContext.current() != context {
                      EAGLContext.setCurrent(context)
                 }
                  if framebuffer == 0 && context != nil {
                       createFramebuffer() // Try creating framebuffer again if needed
                       glViewport(0, 0, framebufferWidth, framebufferHeight)
                  }
                 // Assuming display link should always run when visible
                  if displayLink == nil && context != nil && framebuffer != 0 {
                       setupDisplayLink()
                  } else if displayLink?.isPaused ?? false {
                      displayLink?.isPaused = false // Resume if was paused
                  }
             }
         }
     }
}

// MARK: - SwiftUI View Representable

struct OpenGLESViewRepresentable: UIViewRepresentable {

    // You could pass data from SwiftUI here using @Binding or properties if needed

    func makeUIView(context: Context) -> OpenGLESView {
        // Create and return the custom OpenGL ES UIView
        let uiView = OpenGLESView()
        // Perform any initial setup that depends on the context or coordinator if necessary
        return uiView
    }

    func updateUIView(_ uiView: OpenGLESView, context: Context) {
        // This method is called when SwiftUI state changes that might affect this view.
        // For this example, the view updates itself via CADisplayLink,
        // so we don't necessarily need to do anything here unless
        // we want to pass data *from* SwiftUI *to* the OpenGL view.
        // For example:
        // uiView.someProperty = swiftUIValue
        // uiView.setNeedsLayout() // Or trigger a redraw if needed based on new data
        print("OpenGLESViewRepresentable updateUIView called")
    }

    func makeCoordinator() -> Coordinator {
        // Create a coordinator if you need to handle delegate callbacks
        // from the OpenGLESView (though not used in this simple example).
        Coordinator(self)
    }

    // Optional: Dismantle the view if needed
    static func dismantleUIView(_ uiView: OpenGLESView, coordinator: Coordinator) {
         print("OpenGLESViewRepresentable dismantleUIView called")
         // The view's deinit and removeFromSuperview handle cleanup,
         // but you could add extra explicit cleanup here if required.
         // uiView.invalidateDisplayLink() // Already handled in view's lifecycle methods
         // uiView.tearDownGL()         // Already handled
    }

    // --- Coordinator ---
    // Not strictly needed for this simple example as OpenGLESView manages its own
    // drawing loop and doesn't have delegate methods we need to handle here.
    // But it's part of the pattern if you needed callbacks.
    class Coordinator: NSObject {
        var parent: OpenGLESViewRepresentable

        init(_ parent: OpenGLESViewRepresentable) {
            self.parent = parent
        }

        // Add methods here if OpenGLESView had delegate callbacks
        // e.g., @objc func somethingHappened() { ... }
    }
}

// MARK: - SwiftUI Content View

struct ContentView: View {
    var body: some View {
        VStack {
            Text("OpenGL ES via UIViewRepresentable")
                .font(.headline)
                .padding(.top)

            OpenGLESViewRepresentable()
                // Give it a frame or let it expand
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .border(Color.red) // Add border to visualize frame
                 .ignoresSafeArea() // Optional: Allow it to go edge-to-edge
        }
    }
}

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - App Entry Point (Required if this is the main app file)
/*
@main
struct OpenGLESApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
