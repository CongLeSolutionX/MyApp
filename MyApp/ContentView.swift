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
import MessageUI // Required for Mail Compose ViewController

// MARK: - Mail Compose View (UIViewControllerRepresentable)

struct MailComposeView: UIViewControllerRepresentable {

    // Binding to control the presentation state of the mail sheet
    @Binding var isPresented: Bool
    // Binding to receive the result (sent, saved, cancelled, failed)
    // Using Swift's Result type to handle success (MFMailComposeResult) or failure (Error)
    @Binding var result: Result<MFMailComposeResult, Error>?

    // Configuration for the email
    var recipients: [String]? = nil
    var subject: String = ""
    var messageBody: String = ""
    var isHtml: Bool = false
    // TODO: Add attachment support if needed (data, mimeType, fileName)

    // Creates the Coordinator instance
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, result: $result)
    }

    // Creates the MFMailComposeViewController instance
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator // Set the delegate
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        vc.setMessageBody(messageBody, isHTML: isHtml)
        // TODO: Add attachments if configured: vc.addAttachmentData(...)
        return vc
    }

    // This method is called when the SwiftUI view state changes,
    // but for a modal presentation like mail compose, we typically don't need
    // to update the view controller after it's been presented.
    // Configuration happens in makeUIViewController.
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // No explicit update needed here for this use case.
    }

    // MARK: - Coordinator (Delegate Handler)

    // The Coordinator acts as the delegate for the MFMailComposeViewController.
    // It conforms to NSObject (required for delegates) and MFMailComposeViewControllerDelegate.
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var isPresented: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(isPresented: Binding<Bool>, result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isPresented = isPresented
            _result = result
        }

        // This is the required delegate method that gets called when the user
        // interacts with the mail composer (sends, saves, cancels, or if it fails).
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith mailComposeResult: MFMailComposeResult,
                                   error: Error?) {

            // If there's an error, set the result binding to failure
            if let error = error {
                result = .failure(error)
            } else {
                // Otherwise, set the result binding to success with the specific outcome
                result = .success(mailComposeResult)
            }

            // IMPORTANT: Dismiss the view controller by setting the binding.
            // Setting isPresented to false signals SwiftUI to dismiss the sheet.
            // Do NOT call controller.dismiss(animated: true) directly here.
            isPresented = false
        }
    }
}

// MARK: - Content View (Example Usage)

struct ContentView: View {

    // State to control presenting the mail sheet
    @State private var isShowingMailView = false
    // State to store the result from the mail composer
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    // State to show an alert if mail is not available
    @State private var showMailNotAvailableAlert = false

    // Check if the device can send email
    private var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let result = mailResult {
                    Text("Mail Result: \(resultDescription(for: result))")
                        .padding()
                } else {
                     Text("Tap the button to compose an email.")
                       .padding()
                       .foregroundColor(.secondary)
                }

                Button {
                    // Check if mail can be sent before attempting to present
                    if canSendMail {
                        // Reset previous result before showing
                        self.mailResult = nil
                        // Trigger the presentation of the mail sheet
                        self.isShowingMailView = true
                    } else {
                        // Show an alert if mail is not configured
                        self.showMailNotAvailableAlert = true
                        print("Mail services are not available")
                    }
                } label: {
                    Label("Compose Email", systemImage: "square.and.pencil")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canSendMail) // Disable button visually if mail not available

                // Display note if mail is unavailable
                if !canSendMail {
                    Text("Cannot send mail. Please configure a mail account in the Settings app.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                Spacer() // Push content to the top
            }
            .navigationTitle("Mail Composer Demo")
            // Present the MailComposeView as a sheet
            .sheet(isPresented: $isShowingMailView) {
                // Content of the sheet
                MailComposeView(
                    isPresented: $isShowingMailView, // Pass binding to control presentation
                    result: $mailResult,            // Pass binding to receive result
                    recipients: ["recipient@example.com"], // Example recipient
                    subject: "Hello from SwiftUI!",
                    messageBody: "This email was composed using <b>MFMailComposeViewController</b> presented via SwiftUI.",
                    isHtml: true // Example: Send as HTML
                )
            }
            // Alert shown if mail services are not available
            .alert("Mail Unavailable", isPresented: $showMailNotAvailableAlert) {
                Button("OK") { } // Simple dismiss button
            } message: {
                Text("Your device is not configured to send email. Please set up an email account in the Settings app.")
            }
        }
    }

    // Helper function to get a user-friendly description of the result
    func resultDescription(for result: Result<MFMailComposeResult, Error>) -> String {
        switch result {
        case .success(let mailResult):
            switch mailResult {
            case .cancelled:
                return "Cancelled"
            case .saved:
                return "Saved as Draft"
            case .sent:
                return "Sent Successfully"
            case .failed:
                return "Failed to Send"
            @unknown default:
                return "Unknown Outcome"
            }
        case .failure(let error):
            return "Failed with Error: \(error.localizedDescription)"
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
struct MailComposeDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
