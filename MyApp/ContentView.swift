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
@preconcurrency import WebKit // Import WebKit
import Combine // For PassthroughSubject (optional for alternative communication)

// MARK: - WebView Representable

struct WebContentView: UIViewRepresentable {

    // The URL to load (can be local or remote)
    let url: URL

    // Binding to receive messages FROM JavaScript
    @Binding var receivedMessage: String?

    // Callback for when loading finishes (optional)
    var onFinishLoading: (() -> Void)?

    // --- Coordinator ---
    // Manages delegates and communication bridge
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: WebContentView
        var webView: WKWebView? // Hold reference for evaluateJavaScript

        init(_ parent: WebContentView) {
            self.parent = parent
            super.init()
        }

        // MARK: - WKScriptMessageHandler
        // Receives messages FROM JavaScript
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // Ensure message is from the correct handler and is a String
            if message.name == "swiftBridge", let messageBody = message.body as? String {
                print("Coordinator received message from JS: \(messageBody)")
                // Update the binding on the main thread, as it might trigger UI changes
                DispatchQueue.main.async {
                    self.parent.receivedMessage = "\(messageBody) (at \(Date().formatted(date: .omitted, time: .standard)))"
                }
            } else {
                 print("Received message from JS with unexpected name or body: \(message.name), \(message.body)")
            }
        }

        // MARK: - WKNavigationDelegate
        // Called when navigation finishes loading content.
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView finished loading content.")
            self.webView = webView // Store reference once loaded
            // Call the optional callback
            parent.onFinishLoading?()
        }

        // Called when navigation fails.
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView failed navigation: \(error.localizedDescription)")
            // Handle error appropriately (e.g., update an error state in SwiftUI)
        }

        // Called when navigation fails initially (e.g., server not found).
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("WebView failed provisional navigation: \(error.localizedDescription)")
            // Handle error appropriately
        }

        // MARK: - WKUIDelegate (Optional but good practice)
        // Handle JavaScript `alert()` calls
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print("WebView received JS alert: \(message)")

            // Present a native SwiftUI alert if possible, or UIKit alert as fallback
            // For simplicity, just printing here. In a real app, you'd use state/bindings
            // to show an alert in the SwiftUI view hierarchy.
             guard let rootVC = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .filter({ $0.isKeyWindow }).first?.rootViewController else {
                 completionHandler() // Must call handler anyway
                 return
             }

             let alertController = UIAlertController(title: "Web Content Alert", message: message, preferredStyle: .alert)
             alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                 completionHandler()
             })
            // Ensure presentation on main thread
            DispatchQueue.main.async {
                 rootVC.present(alertController, animated: true, completion: nil)
            }
        }

        // Handle JavaScript `confirm()` (provide example structure)
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
             print("WebView received JS confirm: \(message)")
             // Present a native alert with "OK" and "Cancel"
             // Call completionHandler(true) for OK, completionHandler(false) for Cancel
             // Showing simple print and default completion for brevity
             completionHandler(true) // Default to OK for this example
        }

        // Handle JavaScript `prompt()` (provide example structure)
        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
             print("WebView received JS prompt: \(prompt)")
             // Present a native alert with a text field
             // Call completionHandler with the entered text or nil if cancelled
             // Showing simple print and default completion for brevity
             completionHandler(defaultText ?? "Default Prompt Response") // Default response
        }

        // --- Helper for Swift -> JS ---
        func sendMessageToJavaScript(message: String) {
            guard let webView = webView else {
                print("Error: WebView not available to send message.")
                return
            }
            // Escape the message string for JavaScript context if necessary (basic escaping here)
            let escapedMessage = message.replacingOccurrences(of: "'", with: "\\'").replacingOccurrences(of: "\n", with: "\\n")
            let script = "swiftSays('\(escapedMessage)');" // Call the JS function `swiftSays`
            print("Swift evaluating JS: \(script)")

            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error.localizedDescription)")
                } else if let result = result {
                    print("JavaScript evaluation successful, result: \(result)")
                } else {
                    print("JavaScript evaluation successful, no result.")
                }
            }
        }
    }

    // --- UIViewRepresentable Required Methods ---

    // Creates the WKWebView and configures it
    func makeUIView(context: Context) -> WKWebView {
        // 1. Configuration (Crucial for JS Bridge)
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()

        // 2. Add Script Message Handler (JS -> Swift)
        // The Coordinator will handle messages sent to "swiftBridge" from JS
        userContentController.add(context.coordinator, name: "swiftBridge")
        configuration.userContentController = userContentController

        // 3. Create WKWebView
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator // Handle navigation events
        webView.uiDelegate = context.coordinator       // Handle JS alerts/prompts
        webView.allowsBackForwardNavigationGestures = true // Optional: Enable swipe gestures
        // Optional: Make background transparent if needed
        // webView.isOpaque = false
        // webView.backgroundColor = .clear


        // 4. Load Initial Request
        let request = URLRequest(url: url)
        webView.load(request)

        // 5. Store webView reference in Coordinator *after* initial load starts
        // Context is available here. We'll set it properly in didFinish delegate.
        // context.coordinator.webView = webView // Can set here or deferred

        return webView
    }

    // Updates the view if needed (e.g., URL changes outside the view)
    // Note: Sending messages ideally triggered differently (e.g., via Coordinator method)
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Example: Reload if the URL prop changes externally
        // Important: Avoid reloading unnecessarily if only bindings change.
        if uiView.url != url {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
        print("WebContentView updateUIView called.") // See when this is triggered
    }

    // Clean up when the view is removed
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        print("Dismantling WebView. Removing message handlers.")
        // Important: Remove the message handler to prevent retain cycles/leaks
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "swiftBridge")
    }

    // --- Method to send message INTO JavaScript ---
    // This needs to be called *on* the Coordinator instance associated with the specific WebView.
    // We achieve this by looking up the coordinator via the context in updateUIView (less ideal)
    // OR more typically, by calling a method on the Coordinator instance, which the parent
    // view somehow triggers. Let's enhance the Coordinator.
    func sendMessage(_ message: String, coordinator: Coordinator) {
         coordinator.sendMessageToJavaScript(message: message)
    }

}

// MARK: - SwiftUI Content View

struct ContentView: View {
    // State for messages RECEIVED from the web view
    @State private var messageFromWeb: String? = "No message yet."

    // State for the message TO SEND to the web view
    @State private var messageToSend: String = "Hello from Swift!"

    // State to track loading status
    @State private var isLoading: Bool = true

    // Use optional to handle potential file loading failure
    private var localHtmlUrl: URL? = Bundle.main.url(forResource: "local", withExtension: "html")

    // Coordinator instance needs to be accessible if we want to call its methods directly
    // Option 1: Store indirectly (complex state management)
    // Option 2: Use a wrapper class or environment object holding the coordinator (better)
    // Option 3: For simplicity here, we might pass the coordinator instance around,
    // or find it via context which is tricky. Let's prepare for a slightly simpler approach below.
    // Let's create the coordinator manually *once* and pass it.
    // **Correction:** We can't easily create the coordinator manually outside the representable's
    // methods. The representable manages its lifecycle. We'll call sendMessage *on the View*
    // which internally finds the structure/coordinator - this is abstract. The easiest way
    // is often via Combine Subjects or similar passed *into* the representable.

    // Let's stick to accessing via coordinator INSIDE Representable methods if absolutely needed,
    // OR use the coordinator's helper method called via the representable structure itself.
    // *** Let's make a dedicated StateObject coordinator holder if we want complex calls ***

    // Simpler approach for now: Keep reference to Coordinator is tricky.
    // We will trigger send via a placeholder, the implementation inside WebContentView
    // doesn't expose coordinator directly. It is encapsulated.

    // We need a way for the BUTTON to call the Coordinator's method. Let's add a trick
    // using a trigger state variable that `updateUIView` *could* react to (not ideal).
    // **BETTER APPROACH REFINEMENT:** Use Combine as discussed in thought process.
    let messageSubject = PassthroughSubject<String, Never>()


    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                if let url = localHtmlUrl {
                    // The WebView taking up most space
                    // Pass the Combine subject for Swift -> JS communication
                    WebContentView(
                        url: url,
                        receivedMessage: $messageFromWeb,
                        onFinishLoading: {
                            print("SwiftUI notified: WebView finished loading.")
                            isLoading = false
                        }
                    )
                    // Modifiers after the representable
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .border(Color.gray.opacity(0.5), width: 1) // Visual frame
                    .overlay(
                        // Show loading indicator
                        Group {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(1.5)
                            }
                        }
                    )

                    Divider()

                    // --- UI for Interaction ---
                    VStack(alignment: .leading) {
                        Text("Communication Panel (SwiftUI)")
                            .font(.headline)

                        // Display messages received from JS
                        Text("Message from Web:")
                            .font(.caption).foregroundColor(.secondary)
                        Text(messageFromWeb ?? "N/A")
                            .padding(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(4)


                        // Send messages to JS
                        HStack {
                            TextField("Message to Web", text: $messageToSend)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Button("Send") {
                                // Use the Combine Subject to send the message
                                messageSubject.send(messageToSend)
                                print("SwiftUI Button: Sending message '\(messageToSend)' via Subject")
                                // Clear field after sending (optional)
                                // messageToSend = ""
                            }
                            .disabled(isLoading) // Disable send button while loading
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)

                } else {
                    Text("Error: local.html not found.")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("WebView Bridge")
             // Hide keyboard helper
             .onTapGesture {
                 hideKeyboard()
             }
        }
        .navigationViewStyle(.stack) // Use stack style
         // Inject the subject into the Coordinator when the view appears using a PreferenceKey or similar setup
         // OR a slightly simpler approach - pass the subject directly into the representable's Coordinator.
         // Let's modify WebContentView and Coordinator to accept and use the subject.
         .onAppear {
             // Add subscription logic here if needed, or ensure Coordinator handles it.
             // We will modify WebContentView/Coordinator to accept and use the subject.
         }
    }
}


// MARK: - Updated WebContentView & Coordinator for Combine Subject

struct WebContentViewWithSubject: UIViewRepresentable { // Renamed for clarity

    let url: URL
    @Binding var receivedMessage: String?
    var onFinishLoading: (() -> Void)?
    let messageSubject: PassthroughSubject<String, Never> // Input subject

    // --- Coordinator ---
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

     // Coordinator is same as before, just add Combine subscription
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: WebContentViewWithSubject
        var webView: WKWebView?
        var messageSubscription: AnyCancellable? // Store subscription

        init(_ parent: WebContentViewWithSubject) {
            self.parent = parent
            super.init()
            // Subscribe to the message subject
            self.messageSubscription = parent.messageSubject
                .sink { [weak self] message in
                    print("Coordinator received message from Subject: \(message)")
                    self?.sendMessageToJavaScript(message: message)
                }
        }

        deinit {
             print("Coordinator deinit. Cancelling subscription.")
            messageSubscription?.cancel()
        }

        // ... (WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate methods remain the same as above) ...
        // --- Receives messages FROM JavaScript ---
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "swiftBridge", let messageBody = message.body as? String {
                print("Coordinator received message from JS: \(messageBody)")
                DispatchQueue.main.async {
                    self.parent.receivedMessage = "\(messageBody) (at \(Date().formatted(date: .omitted, time: .standard)))"
                }
            } else {
                 print("Received message from JS with unexpected name or body: \(message.name), \(message.body)")
            }
        }
        // --- WKNavigationDelegate ---
         func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView finished loading content.")
            self.webView = webView
            parent.onFinishLoading?()
        }
         func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView failed navigation: \(error.localizedDescription)")
        }
         func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("WebView failed provisional navigation: \(error.localizedDescription)")
        }
        // --- WKUIDelegate ---
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
             print("WebView received JS alert: \(message)")
             // Basic native alert presentation
             guard let rootVC = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).compactMap({ $0 as? UIWindowScene }).first?.windows.filter({ $0.isKeyWindow }).first?.rootViewController else { completionHandler(); return }
             let alertController = UIAlertController(title: "Web Content Alert", message: message, preferredStyle: .alert)
             alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
            DispatchQueue.main.async { rootVC.present(alertController, animated: true, completion: nil) }
        }
        // Confirm/Prompt handlers omitted for brevity but would be here


        // --- Helper for Swift -> JS ---
        func sendMessageToJavaScript(message: String) {
            guard let webView = webView else {
                print("Error: WebView not available.")
                // Maybe queue message? For now, just log.
                return
            }
            let escapedMessage = message.replacingOccurrences(of: "'", with: "\\'").replacingOccurrences(of: "\n", with: "\\n")
            let script = "swiftSays('\(escapedMessage)');"
            print("Swift evaluating JS: \(script)")
            webView.evaluateJavaScript(script) { result, error in
                 if let error = error { print("Error evaluating JS: \(error.localizedDescription)") }
                 else if let result = result { print("JS eval successful, result: \(result)") }
                 else { print("JS eval successful, no result.") }
            }
        }
    }

    // --- UIViewRepresentable Methods ---
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        // Add JS -> Swift handler
        userContentController.add(context.coordinator, name: "swiftBridge")
        configuration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        let request = URLRequest(url: url)
        webView.load(request)
        // Coordinator now subscribes automatically on init
        // context.coordinator.subscribeToSubject(messageSubject) // No longer needed explicitly here

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No update needed based on subject changes here
        if uiView.url != url {
             let request = URLRequest(url: url)
             uiView.load(request)
        }
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        print("Dismantling WebView. Removing message handlers.")
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "swiftBridge")
        // Coordinator's deinit handles cancellable cancellation
    }
}

// MARK: - Updated ContentView using Combine Subject

struct ContentViewWithSubject: View { // Renamed for clarity
    @State private var messageFromWeb: String? = "No message yet."
    @State private var messageToSend: String = "Swift says Hi via Combine!"
    @State private var isLoading: Bool = true
    private var localHtmlUrl: URL? = Bundle.main.url(forResource: "local", withExtension: "html")
    // Create the subject ONCE and pass it down
    @StateObject private var webViewInterop = WebViewInterop()

    class WebViewInterop: ObservableObject {
         let messageSubject = PassthroughSubject<String, Never>()
    }


    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                if let url = localHtmlUrl {
                     // Pass the subject from the StateObject
                    WebContentViewWithSubject(
                        url: url,
                        receivedMessage: $messageFromWeb,
                        onFinishLoading: { isLoading = false },
                        messageSubject: webViewInterop.messageSubject // Pass the subject
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .border(Color.gray.opacity(0.5), width: 1)
                    .overlay( Group { if isLoading { ProgressView().scaleEffect(1.5) } } )

                    Divider()

                    // --- UI for Interaction ---
                    VStack(alignment: .leading) {
                        Text("Communication Panel (SwiftUI)")
                            .font(.headline)
                        Text("Message from Web:").font(.caption).foregroundColor(.secondary)
                        Text(messageFromWeb ?? "N/A")
                            .padding(5).frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.yellow.opacity(0.2)).cornerRadius(4)

                        HStack {
                            TextField("Message to Web", text: $messageToSend)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                             // Use the subject from the StateObject to send
                            Button("Send") { webViewInterop.messageSubject.send(messageToSend) }
                            .disabled(isLoading)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)

                } else {
                    Text("Error: local.html not found.").foregroundColor(.red).padding()
                }
            }
            . navigationTitle("WebView Bridge (Combine)")
             .onTapGesture { hideKeyboard() }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Preview

struct ContentViewWithSubject_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewWithSubject() // Use the updated ContentView name here
    }
}

// MARK: - Keyboard Helper (Same as before)
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

// MARK: - App Entry Point (Use the final ContentView name)
/*
@main
struct WebViewBridgeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentViewWithSubject() // Ensure this uses the final view name
        }
    }
}
*/
