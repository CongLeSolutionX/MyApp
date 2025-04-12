//
//  ContentView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//

import SwiftUI
import MessageUI // Import the MessageUI framework

// MARK: - Message Compose View Representable (Bridge to UIKit)

struct MessageComposeView: UIViewControllerRepresentable {

    // Configuration passed from SwiftUI
    let recipients: [String]
    let body: String?

    // Callback to inform the calling SwiftUI view about the result
    var completion: ((_ result: MessageComposeResult) -> Void)

    // Static check if the device can send messages. Crucial pre-check.
    static func canSendText() -> Bool {
        MFMessageComposeViewController.canSendText()
    }

    // --- UIViewControllerRepresentable Protocol Methods ---

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        // Configure the message content from the properties passed in
        vc.recipients = recipients
        vc.body = body
        // Set the Coordinator as the delegate to receive callbacks
        vc.messageComposeDelegate = context.coordinator
        return vc
    }

    // updateUIViewController is rarely needed for MFMessageComposeViewController
    // as the content is typically set once upon creation. If the recipients/body
    // needed to change *while* the sheet was presented (uncommon), you'd do it here.
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
        // Example (usually commented out):
        // uiViewController.recipients = recipients
        // uiViewController.body = body
    }

    // --- Coordinator Class (Delegate Handler) ---

    // Acts as the delegate for MFMessageComposeViewController.
    // Needs to inherit from NSObject to conform to the UIKit delegate protocol.
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var completion: ((_ result: MessageComposeResult) -> Void)

        init(completion: @escaping (_ result: MessageComposeResult) -> Void) {
            self.completion = completion
        }

        // Delegate method called when the user finishes (sends, cancels, or fails)
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            // 1. Pass the result back to the SwiftUI view via the completion handler
            completion(result)

            // 2. Dismiss the presented view controller. The delegate *must* do this.
            controller.dismiss(animated: true)
        }
    }
}

// MARK: - SwiftUI Content View (Enhanced Example Usage)

struct ContentView: View {
    // --- State Variables ---
    @State private var recipientInput: String = "1234567890" // Default or empty
    @State private var messageBodyInput: String = "Hello from my enhanced SwiftUI app!" // Default message
    @State private var isShowingMessageComposer = false // Controls sheet presentation

    // State for handling results and feedback alerts
    @State private var messageResult: MessageComposeResult? = nil
    @State private var showingResultAlert = false
    @State private var showingCannotSendAlert = false // Alert if device can't send SMS/iMessage

    // Determine if the compose button should be enabled (basic validation)
    var isComposeButtonDisabled: Bool {
        recipientInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // --- Body ---
    var body: some View {
        NavigationView {
            Form { // Using Form for better structure and appearance of input fields
                Section(header: Text("Message Details")) {
                    HStack {
                        Text("To:")
                            .font(.headline)
                        TextField("Recipient Phone Number", text: $recipientInput)
                            .keyboardType(.phonePad) // Suggest appropriate keyboard
                            .textContentType(.telephoneNumber) // Help with autofill
                    }

                    // Use TextEditor for potentially multi-line message body
                    VStack(alignment: .leading) {
                         Text("Message:")
                             .font(.headline)
                             .padding(.bottom, 2) // Small spacing
                         TextEditor(text: $messageBodyInput)
                             .frame(height: 150) // Give it a reasonable default height
                             .border(Color.gray.opacity(0.3), width: 1) // Subtle border
                             .cornerRadius(5)
                    }
                }

                Section {
                    Button {
                        sendMessage() // Encapsulated logic
                    } label: {
                        Label("Compose Message", systemImage: "square.and.pencil")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center) // Center label
                    }
                    // Disable button if recipient is empty
                    .disabled(isComposeButtonDisabled)
                    // Add subtle visual cue for disabled state
                    .opacity(isComposeButtonDisabled ? 0.6 : 1.0)
                }

                // Display feedback about the last attempt
                if let result = messageResult {
                    Section(header: Text("Last Status")) {
                        Text(resultDescription(result))
                            .foregroundColor(resultColor(result))
                    }
                }
            }
            .navigationTitle("Compose Message")
            // --- Sheet Presentation ---
            .sheet(isPresented: $isShowingMessageComposer) {
                // Check necessary because sheet content is prepared *before* canSendText check
                // Although the button action prevents this, it's safer defensively.
                if MessageComposeView.canSendText() {
                     MessageComposeView(recipients: [recipientInput], body: messageBodyInput) { result in
                        // --- Completion Handler ---
                        // This runs *after* the MessageUI sheet is dismissed by the Coordinator
                        handleMessageCompletion(result: result)
                    }
                    // Allow the MessageUI view controller to potentially go edge-to-edge
                    .ignoresSafeArea()
                } else {
                    // Fallback content if somehow shown when cannot send (unlikely with current logic)
                    Text("Error: Device cannot send messages.")
                        .padding()
                        .onAppear {
                             // If this state is reached unexpectedly, dismiss the sheet
                             // and ensure the correct alert is shown.
                             self.isShowingMessageComposer = false
                             self.showingCannotSendAlert = true
                        }
                }
            }
            // --- Alerts for Feedback ---
            .alert("Cannot Send Message", isPresented: $showingCannotSendAlert) {
                Button("OK") { } // Simple dismissal
            } message: {
                Text("Your device is not configured to send text messages (SMS or iMessage). Please check your settings.")
            }
            .alert("Message Status", isPresented: $showingResultAlert, presenting: messageResult) { result in
                 Button("OK") { /* Optionally clear the result state */ }
            } message: { result in
                 Text(resultDescription(result)) // Use helper for consistent messaging
            }
        }
        .navigationViewStyle(.stack) // Use stack style for consistency
    }

    // --- Helper Methods ---

    func sendMessage() {
        // 1. Check if the device can send messages *before* attempting to present
        if MessageComposeView.canSendText() {
            // If yes, trigger the sheet presentation (SwiftUI handles the rest)
            self.isShowingMessageComposer = true
        } else {
            // If no, prevent sheet presentation and show an informative alert
            print("Device cannot send text messages.")
            self.showingCannotSendAlert = true
        }
    }

    func handleMessageCompletion(result: MessageComposeResult) {
         print("Message composer finished with result: \(result.rawValue)")
         self.messageResult = result // Store result for display
         self.showingResultAlert = true // Trigger the result feedback alert
         // `isShowingMessageComposer` is automatically set to false by SwiftUI when the sheet dismisses.
    }

    func resultDescription(_ result: MessageComposeResult) -> String {
        switch result {
        case .cancelled:
            return "Message composition was cancelled."
        case .sent:
            return "Message sent successfully."
        case .failed:
            return "Message failed to send. Please check network connection and recipient number."
        @unknown default:
            // Future-proofing for new cases Apple might add
            return "An unknown result occurred (\(result.rawValue))."
        }
    }

    func resultColor(_ result: MessageComposeResult) -> Color {
         switch result {
         case .cancelled:
             return .orange
         case .sent:
             return .green
         case .failed:
             return .red
         @unknown default:
             return .gray
         }
     }
}

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - App Entry Point (Example)
/*
@main
struct MessageUIDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
