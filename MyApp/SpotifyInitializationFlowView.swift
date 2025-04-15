//
//  SpotifyInitializationFlowView.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import SwiftUI
import WebKit // Required for WKWebView

// MARK: - Data Model for Flow Steps

enum FlowStep {
    case includeScript
    case definePlaceholder
    case scriptLoaded
    case apiReadyCallbackCalled
    case getElement
    case defineOptions
    case defineControllerCallback
    case createControllerCalled
    case controllerCreated
    case controllerReady

    var title: String {
        switch self {
        case .includeScript: return "1. Include Script Tag"
        case .definePlaceholder: return "2. Define Placeholder"
        case .scriptLoaded: return "3. Script Loaded"
        case .apiReadyCallbackCalled: return "4. onSpotifyIframeApiReady Called"
        case .getElement: return "5. Get Element"
        case .defineOptions: return "6. Define Options"
        case .defineControllerCallback: return "7. Define Callback(Ctrl)"
        case .createControllerCalled: return "8. Call createController"
        case .controllerCreated: return "9. Controller Created (Internal)"
        case .controllerReady: return "10. Controller Ready"
        }
    }

    var description: String {
        switch self {
        case .includeScript: return "<script src='...'>"
        case .definePlaceholder: return "<div id='embed-iframe'>"
        case .scriptLoaded: return "Browser loads Spotify's script"
        case .apiReadyCallbackCalled: return "API signals readiness via global function"
        case .getElement: return "JS: document.getElementById(...)"
        case .defineOptions: return "JS: { uri, width?, height? }"
        case .defineControllerCallback: return "JS: callback = (EmbedController) => {...}"
        case .createControllerCalled: return "JS: IFrameAPI.createController(...)"
        case .controllerCreated: return "API creates iFrame & Controller"
        case .controllerReady: return "Controller passed to JS callback"
        }
    }

    var color: Color {
        switch self {
        case .includeScript, .definePlaceholder: return .pink.opacity(0.7) // User Setup HTML
        case .scriptLoaded, .apiReadyCallbackCalled: return .blue.opacity(0.6) // API Loading
        case .getElement, .defineOptions, .defineControllerCallback, .createControllerCalled: return .purple.opacity(0.7) // User Code JS
        case .controllerCreated, .controllerReady: return .green.opacity(0.7) // Controller Ready
        }
    }
}

// MARK: - SwiftUI View for Visualization

struct SpotifyInitializationFlowView: View {
    // State to simulate flow progression (in a real app, this would be driven by WKWebView callbacks)
    @State private var currentStepIndex = 0
    let timer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()

    let steps: [FlowStep] = [
        .includeScript,
        .definePlaceholder,
        .scriptLoaded,
        .apiReadyCallbackCalled,
        .getElement,
        .defineOptions,
        .defineControllerCallback,
        .createControllerCalled,
        .controllerCreated,
        .controllerReady
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 10) {
                Text("Spotify iFrame API Initialization Flow")
                    .font(.title2)
                    .padding(.bottom)

                // --- Visual Flow ---
                ForEach(0..<steps.count, id: \.self) { index in
                    FlowStepView(step: steps[index], isActive: index <= currentStepIndex)
                    if index < steps.count - 1 {
                        Image(systemName: "arrow.down")
                            .font(.title)
                            .foregroundColor(index < currentStepIndex ? .blue : .gray.opacity(0.5))
                           // .transition(.opacity)
                           .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1), value: currentStepIndex)

                    }
                }
            }
            .padding()
        }
        .onReceive(timer) { _ in
            if currentStepIndex < steps.count - 1 {
                withAnimation(.easeInOut(duration: 1.0)) {
                     currentStepIndex += 1
                }
            } else {
                timer.upstream.connect().cancel() // Stop timer when flow completes
            }
        }
        .onAppear {
           // Reset on appear if needed
           // currentStepIndex = 0
        }
    }
}

// MARK: - Individual Step View

struct FlowStepView: View {
    let step: FlowStep
    let isActive: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(step.title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(step.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(maxWidth: 250) // Control width
        .background(isActive ? step.color : Color.gray.opacity(0.4))
        .cornerRadius(8)
        .shadow(color: isActive ? step.color.opacity(0.4) : .clear, radius: 5, x: 0, y: 3)
        .scaleEffect(isActive ? 1.0 : 0.95)
        .opacity(isActive ? 1.0 : 0.7)
        // .transition(.slide) // Add transition if desired
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isActive)
    }
}

// MARK: - Preview

struct SpotifyInitializationFlowView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyInitializationFlowView()
    }
}

/*
 Note: This SwiftUI code provides a *visual representation* of the flow described
 in the Mermaid diagram "1. API Initialization and Controller Creation Flow".
 It uses state and timers to simulate the progression through the steps.

 In a real iOS application using the Spotify iFrame API, you would:
 1. Use a `WKWebView` (likely within a `UIViewRepresentable`) to load the HTML
    page containing the Spotify iFrame script والمكان العنصر.
 2. Inject JavaScript to define the `window.onSpotifyIframeApiReady` function.
 3. Use `WKScriptMessageHandler` in the `UIViewRepresentable`'s Coordinator to
    receive messages *from* the JavaScript (`onSpotifyIframeApiReady` being called).
 4. When the message indicating API readiness is received, evaluate JavaScript *from*
    Swift (`webView.evaluateJavaScript(...)`) to call `IFrameAPI.createController`.
 5. The callback provided to `createController` would live in the JavaScript environment.
    Further interactions (like `EmbedController.loadUri`) would be done by evaluating
    more JavaScript strings from Swift.
 6. The state changes in this SwiftUI view (`currentStepIndex`) would be driven by
    these interactions with the WKWebView, not a simple timer.
*/
