////
////  ContentView.swift
////  MyApp
////
////  Created by Cong Le on 8/19/24.
////
////
////import SwiftUI
////
////// Step 2: Use in SwiftUI view
////struct ContentView: View {
////    var body: some View {
////        UIKitViewControllerWrapper()
////            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
////    }
////}
////
////// Before iOS 17, use this syntax for preview UIKit view controller
////struct UIKitViewControllerWrapper_Previews: PreviewProvider {
////    static var previews: some View {
////        UIKitViewControllerWrapper()
////    }
////}
////
////// After iOS 17, we can use this syntax for preview:
////#Preview {
////    ContentView()
////}
//
//import SwiftUI
//import MessageUI // Import the MessageUI framework
//
//// MARK: - Message Compose View Representable
//
//struct MessageComposeView: UIViewControllerRepresentable {
//
//    // Configuration for the message
//    let recipients: [String]
//    let body: String?
//
//    // Callback to inform the calling view about the result
//    // Provides more context than just dismissing the sheet
//    var completion: ((_ result: MessageComposeResult) -> Void)
//
//    // Check if the device can actually send messages
//    // It's crucial to check this *before* trying to present the view controller.
//    static func canSendText() -> Bool {
//        MFMessageComposeViewController.canSendText()
//    }
//
//    // Creates the Coordinator instance
//    func makeCoordinator() -> Coordinator {
//        Coordinator(completion: completion)
//    }
//
//    // Creates the MFMessageComposeViewController instance
//    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
//        let vc = MFMessageComposeViewController()
//        vc.recipients = recipients
//        vc.body = body
//        // Set the delegate to our Coordinator
//        vc.messageComposeDelegate = context.coordinator
//        return vc
//    }
//
//    // Updates the view controller instance (rarely needed for MFMessageComposeViewController)
//    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
//        // If recipients or body could change dynamically *while* the sheet is presented,
//        // you could update them here, but it's generally not the standard interaction model.
//        // uiViewController.recipients = recipients
//        // uiViewController.body = body
//    }
//
//    // MARK: - Coordinator Class
//
//    // The Coordinator acts as the delegate for MFMessageComposeViewController
//    // It needs to inherit from NSObject to conform to the delegate protocol.
//    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
//        var completion: ((_ result: MessageComposeResult) -> Void)
//
//        init(completion: @escaping (_ result: MessageComposeResult) -> Void) {
//            self.completion = completion
//        }
//
//        // Delegate method called when the user finishes composing (sends or cancels)
//        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
//            // Pass the result back to the SwiftUI view via the completion handler
//            completion(result)
//
//            // Dismiss the presented view controller
//            // The delegate is responsible for dismissal
//            controller.dismiss(animated: true)
//        }
//    }
//}
//
//// MARK: - SwiftUI Content View (Example Usage)
//
//struct ContentView: View {
//    // State to control the presentation of the message sheet
//    @State private var isShowingMessageComposer = false
//
//    // State to hold the result (for displaying feedback)
//    @State private var messageResult: MessageComposeResult? = nil
//    @State private var showingResultAlert = false
//
//    // Example message details
//    let recipientPhoneNumber = "1234567890" // Replace with a valid number for testing
//    let messageBody = "Hello from my SwiftUI app!"
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                Image(systemName: "message.fill")
//                    .font(.system(size: 60))
//                    .foregroundColor(.blue)
//
//                Text("Send Message Demo")
//                    .font(.title)
//
//                Button {
//                    // --- IMPORTANT: Check if the device can send messages FIRST ---
//                    if MessageComposeView.canSendText() {
//                        // If yes, trigger the presentation
//                        self.isShowingMessageComposer = true
//                    } else {
//                        // If no, show an error message to the user
//                        print("Device cannot send text messages.")
//                        // Optionally, show an alert here as well
//                        // self.messageResult = .failed // Indicate failure immediately
//                        // self.showingResultAlert = true
//                    }
//                } label: {
//                    Label("Compose Message", systemImage: "square.and.pencil")
//                        .font(.headline)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding(.horizontal)
//
//                // Display result feedback if available
//                if let result = messageResult {
//                    Text("Last Result: \(resultDescription(result))")
//                        .padding(.top)
//                        .foregroundColor(result == .sent ? .green : (result == .failed ? .red : .orange))
//                }
//
//                Spacer()
//            }
//            .navigationTitle("MessageUI Demo")
//            // --- Present the sheet ---
//            .sheet(isPresented: $isShowingMessageComposer) {
//                // --- Content of the sheet ---
//                MessageComposeView(recipients: [recipientPhoneNumber], body: messageBody) { result in
//                    // --- Completion Handler ---
//                    // This code runs when the Coordinator calls the completion callback
//                    print("Message composer finished with result: \(result.rawValue)")
//                    self.messageResult = result
//                    self.showingResultAlert = true // Trigger alert after dismissal
//                    // isShowingMessageComposer is automatically set to false by .sheet dismissal
//                }
//                // Recommended: Allow the MessageUI view controller to ignore safe areas
//                // if you want it potentially fullscreen (behavior can vary by iOS version)
//                .ignoresSafeArea()
//            }
//            // Optional: Show an alert based on the result
//            .alert("Message Status", isPresented: $showingResultAlert, presenting: messageResult) { result in
//                 // Define buttons or actions for the alert based on the result
//                 Button("OK") { /* Optionally clear the result state */ }
//            } message: { result in
//                 Text(resultDescription(result))
//            }
//
//        }
//        .navigationViewStyle(.stack) // Consistent navigation appearance
//    }
//
//    // Helper function to convert result enum to a user-friendly string
//    func resultDescription(_ result: MessageComposeResult) -> String {
//        switch result {
//        case .cancelled:
//            return "Message cancelled."
//        case .sent:
//            return "Message sent successfully."
//        case .failed:
//            return "Message failed to send."
//        @unknown default:
//            return "Unknown result."
//        }
//    }
//}
//
//// MARK: - Preview Provider
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
//// MARK: - App Entry Point (If this is the main app file)
///*
//@main
//struct MessageUIDemoApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//*/
