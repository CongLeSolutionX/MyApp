//
//  GestureInteroperability.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//


import SwiftUI
import UIKit

// --- Custom Gesture Recognizer (Example) ---
// You could use any standard UIGestureRecognizer or a custom subclass.
// Here, we just configure a standard one for simplicity.
class DoubleTapGestureRecognizer: UITapGestureRecognizer {
    convenience override init(target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.numberOfTapsRequired = 2
    }
}

// --- Representable to Bridge the Gesture ---
struct DoubleTapGestureRepresentable: UIGestureRecognizerRepresentable {
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        return .init(action: self.action)
    }
    
    // Type alias for clarity
    typealias Recognizer = DoubleTapGestureRecognizer
    
    // Callback action to perform in SwiftUI when the gesture is recognized
    var action: () -> Void
    
    // Create the underlying UIKit gesture recognizer instance
    func makeUIGestureRecognizer(context: Context) -> Recognizer {
        let recognizer = Recognizer(target: context.coordinator, action: #selector(Coordinator.handleGesture))
        return recognizer
    }
    
    // Keep the recognizer updated if needed (not necessary for this simple example)
    func updateUIGestureRecognizer(_ recognizer: Recognizer, context: Context) {
        // Update recognizer properties if they depend on SwiftUI state
    }
    
    // Coordinator acts as the target for the UIKit gesture recognizer
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    // Coordinator Class
    class Coordinator: NSObject {
        var action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func handleGesture(_ gesture: Recognizer) {
            // Only trigger the action when the gesture ends successfully
            if gesture.state == .ended {
                action()
            }
        }
    }
}

// --- SwiftUI View Using the Bridged Gesture ---
struct GestureInteropView: View {
    @State private var doubleTapCount = 0
    @State private var backgroundColor = Color.blue
    
    var body: some View {
        VStack {
            Text("Double Tap Me!")
                .font(.title)
                .padding(50)
                .background(backgroundColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            // Apply the bridged gesture using the .gesture modifier
                .gesture(
                    DoubleTapGestureRepresentable {
                        // This closure is executed when the double tap occurs
                        print("Double tap detected!")
                        self.doubleTapCount += 1
                        // Animate the background color change
                        withAnimation(.easeInOut) {
                            self.backgroundColor = (self.doubleTapCount % 2 == 0) ? .blue : .purple
                        }
                    }
                )
            
            Text("Double Taps: \(doubleTapCount)")
                .padding(.top)
        }
        .navigationTitle("Gesture Interop")
    }
}

// --- Preview ---
#Preview {
    NavigationView { // Added NavigationView for better preview context
        GestureInteropView()
    }
}

import SwiftUI
import UIKit

class AnimateWithSwiftUIViewController: UIViewController {
    
    private lazy var animatedView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .systemIndigo
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Animate View", for: .normal)
        button.addTarget(self, action: #selector(didTapAnimateButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var isCentered = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(animatedView)
        animatedView.center = view.center // Initial position
        isCentered = true
        
        view.addSubview(toggleButton)
        NSLayoutConstraint.activate([
            toggleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    @objc private func didTapAnimateButton() {
        // 1. Define the SwiftUI Animation
        let swiftUIAnimation: SwiftUI.Animation = .spring(duration: 0.8, bounce: 0.4)
        // let swiftUIAnimation: SwiftUI.Animation = .easeInOut(duration: 1.0)
        
        // 2. Define the target state
        let targetCenter: CGPoint
        if isCentered {
            targetCenter = CGPoint(x: view.bounds.midX, y: view.bounds.minY + 150)
        } else {
            targetCenter = view.center
        }
        isCentered.toggle()
        
        // 3. Use UIView.animate with the SwiftUI Animation
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveEaseInOut) {
            // This closure contains the changes to animate
            self.animatedView.center = targetCenter
            self.animatedView.transform = self.isCentered ? .identity : CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.animatedView.layer.cornerRadius = self.isCentered ? 10 : 25
        } completion: { _ in
            print("UIKit Animation completed using SwiftUI definition!")
        }
    }
}

// --- To Preview this UIViewController in SwiftUI ---
struct AnimateWithSwiftUIViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AnimateWithSwiftUIViewController {
        AnimateWithSwiftUIViewController()
    }
    
    func updateUIViewController(_ uiViewController: AnimateWithSwiftUIViewController, context: Context) {
        // No update needed for this example
    }
}

// --- SwiftUI Preview ---
#Preview {
    AnimateWithSwiftUIViewControllerRepresentable()
        .ignoresSafeArea()
    
}

import SwiftUI
import UIKit

// --- Simple UIKit View to be wrapped ---
class ColorChangingView: UIView {
    var color: UIColor = .systemBlue {
        didSet {
            // Directly set background color without animation here
            // Animation will be handled by the Representable's context
            backgroundColor = color
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// --- UIViewRepresentable ---
struct ColorChangingViewRepresentable: UIViewRepresentable {
    // Bind to SwiftUI state
    @Binding var targetColor: Color // Use SwiftUI Color

    func makeUIView(context: Context) -> ColorChangingView {
        // Create the initial UIKit view
        let uiView = ColorChangingView()
        uiView.color = UIColor(targetColor) // Set initial color
        return uiView
    }

    func updateUIView(_ uiView: ColorChangingView, context: Context) {
        // This method is called when SwiftUI state changes (`targetColor`)

        // Use context.animate to bridge the SwiftUI animation
        context.animate {
            // Apply the changes to the UIKit view inside the context's block
            uiView.color = UIColor(targetColor)
        }
        // Any changes made *outside* context.animate will not be animated
        // by the SwiftUI transaction.
    }
}

// --- SwiftUI View Using the Representable ---
struct RepresentableAnimationView: View {
    @State private var currentColor: Color = .blue

    private let colors: [Color] = [.blue, .green, .red, .orange, .purple, .yellow]

    var body: some View {
        VStack(spacing: 30) {
            Text("Animating UIView via Representable")
                .font(.headline)

            // Use the UIViewRepresentable
            ColorChangingViewRepresentable(targetColor: $currentColor)
                .frame(width: 150, height: 150)

            Button("Change Color (Animated)") {
                // Trigger state change within a SwiftUI animation block
                withAnimation(.easeInOut(duration: 1.0)) {
                    currentColor = colors.randomElement() ?? .gray
                }
            }

            Button("Change Color (Instant)") {
                 // Trigger state change *without* a SwiftUI animation block
                currentColor = colors.randomElement() ?? .black
            }
        }
        .navigationTitle("Representable Animation")
    }
}

// --- Preview ---
#Preview {
    NavigationView { // Added NavigationView for better preview context
        RepresentableAnimationView()
    }
}
