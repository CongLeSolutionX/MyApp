////
////  HelpAndSupportView.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//import MessageUI // Required for sending email
//
//struct HelpAndSupportView: View {
//
//    // --- State (for Mail Composer) ---
//    @State private var showMailComposer = false
//    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
//    @State private var mailSubject = "" // To pre-fill subject based on action
//    @State private var mailBody = "" // To pre-fill body with diagnostic info etc.
//
//    // --- Mock Data / Configuration ---
//    private let faqURL = URL(string: "https://www.yourapp.com/faq")! // Replace with actual FAQ URL
//    private let tutorialsURL = URL(string: "https://www.yourapp.com/tutorials")! // Replace with actual Tutorials URL
//    private let supportEmail = "support@yourapp.com" // Replace with actual support email
//    private let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
//    private let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
//    private let systemVersion = UIDevice.current.systemVersion
////    private let deviceModel = UIDevice.modelName // Using a helper extension
//
//    var body: some View {
//        Form {
//            // --- Self-Help Section ---
//            Section(header: Text("Find Answers")) {
//                // FAQ / Knowledge Base Link
//                Link(destination: faqURL) {
//                    Label("Frequently Asked Questions", systemImage: "questionmark.circle")
//                }
//
//                // Tutorials Link (Optional)
//                 Link(destination: tutorialsURL) {
//                     Label("Tutorials & Guides", systemImage: "book.closed")
//                 }
//                 // You could hide this if tutorialsURL is nil
//            }
//
//            // --- Contact Section ---
//            Section(header: Text("Get in Touch")) {
//                // Contact Support Button
//                Button {
//                    prepareAndShowMailComposer(
//                        subject: "Support Request - App v\(appVersion)",
//                        body: generateDiagnosticInfo(for: "Support Request")
//                    )
//                } label: {
//                    Label("Contact Support", systemImage: "envelope")
//                }
//                // Disable if email is not available on device
//                 .disabled(!MFMailComposeViewController.canSendMail())
//
//                // Report a Bug / Feedback Button
//                Button {
//                    prepareAndShowMailComposer(
//                        subject: "Bug Report/Feedback - App v\(appVersion)",
//                        body: generateDiagnosticInfo(for: "Bug Report / Feedback")
//                    )
//                } label: {
//                    Label("Report a Bug / Feedback", systemImage: "ladybug") // Or "bubble.left.and.bubble.right" for feedback
//                }
//                 .disabled(!MFMailComposeViewController.canSendMail())
//
//                // Inform user if mail is unavailable
//                 if !MFMailComposeViewController.canSendMail() {
//                     Text("Please configure an email account in the Mail app to contact support or send feedback.")
//                         .font(.caption)
//                         .foregroundColor(.secondary)
//                 }
//            }
//
//            // --- Diagnostic Info Section (Read-only) ---
//             Section(header: Text("App Information"), footer: Text("This information may be helpful for support.")) {
//                 InfoRow(label: "App Version", value: "\(appVersion) (\(buildNumber))")
//                 InfoRow(label: "iOS Version", value: systemVersion)
////                 InfoRow(label: "Device", value: deviceModel)
//             }
//
//        }
//        .navigationTitle("Help & Support")
//        .navigationBarTitleDisplayMode(.inline)
//        // --- Mail Composer Sheet ---
//         .sheet(isPresented: $showMailComposer) {
//             MailComposeView(
//                 subject: mailSubject,
//                 recipients: [supportEmail],
//                 messageBody: mailBody,
//                 result: $mailResult
//             )
//         }
//         // Optional: Show alert based on mailResult after dismissal
////         .onChange(of: mailResult) { result in
////             handleMailResult(result)
////         }
//    }
//
//    // --- Helper Functions ---
//
//    private func prepareAndShowMailComposer(subject: String, body: String) {
//        guard MFMailComposeViewController.canSendMail() else {
//            print("Mail services are not available")
//            // Optionally show an alert here too
//            return
//        }
//        self.mailSubject = subject
//        self.mailBody = body
//        self.showMailComposer = true
//    }
//
//    private func generateDiagnosticInfo(for context: String) -> String {
//        // Pre-populate the email body with useful diagnostic information
//        // Add more relevant app-specific state if needed (e.g., last screen visited, sync status)
//        return """
//        ------------------------------
//        Context: \(context)
//        App Version: \(appVersion) (\(buildNumber))
//        iOS Version: \(systemVersion)
//        Device: \("deviceModel")
//        ------------------------------
//
//        Please describe the issue or provide your feedback below:
//
//        """
//    }
//
//    private func handleMailResult(_ result: Result<MFMailComposeResult, Error>?) {
//        guard let result = result else { return } // Only handle non-nil results
//
//        switch result {
//        case .success(let composeResult):
//            switch composeResult {
//            case .sent:
//                print("Mail sent successfully")
//                // Optional: Show a "Thank you" alert
//            case .saved:
//                print("Mail saved as draft")
//            case .cancelled:
//                print("Mail cancelled")
//            case .failed:
//                print("Mail failed to send")
//                // Optional: Show an error alert
//            @unknown default:
//                print("Mail compose result unknown")
//            }
//        case .failure(let error):
//            print("Error showing mail composer: \(error.localizedDescription)")
//            // Optional: Show an error alert
//        }
//        // Reset result after handling
//        self.mailResult = nil
//    }
//}
//
//// --- Helper View for Info Rows ---
//struct InfoRow: View {
//    let label: String
//    let value: String
//
//    var body: some View {
//        HStack {
//            Text(label)
//                .foregroundColor(.primary)
//            Spacer()
//            Text(value)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.trailing) // Allow wrapping for long device names
//        }
//    }
//}
//
//// --- Mail Compose View Representable ---
//// (Needs to be included or imported from another file)
//struct MailComposeView: UIViewControllerRepresentable {
//    // Properties required for the mail composer
//    var subject: String
//    var recipients: [String]
//    var messageBody: String
//    // Callback for the result
//    @Binding var result: Result<MFMailComposeResult, Error>?
//
//    // Coordinator to handle delegate methods
//    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
//        @Binding var result: Result<MFMailComposeResult, Error>?
//        let parent: MailComposeView
//
//        init(_ parent: MailComposeView, result: Binding<Result<MFMailComposeResult, Error>?>) {
//             self.parent = parent
//             self._result = result
//        }
//
//        func mailComposeController(_ controller: MFMailComposeViewController,
//                                   didFinishWith result: MFMailComposeResult,
//                                   error: Error?) {
//            defer {
//                controller.dismiss(animated: true)
//            }
//            if let error = error {
//                self.result = .failure(error)
//            } else {
//                self.result = .success(result)
//            }
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self, result: $result)
//    }
//
//    func makeUIViewController(context: Context) -> MFMailComposeViewController {
//        let vc = MFMailComposeViewController()
//        vc.mailComposeDelegate = context.coordinator
//        vc.setSubject(subject)
//        vc.setToRecipients(recipients)
//        vc.setMessageBody(messageBody, isHTML: false)
//        return vc
//    }
//
//    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
//        // No update needed typically
//    }
//}
//
////// --- UIDevice Extension for Model Name ---
////// (Needs to be included or imported)
////public extension UIDevice {
////    static let modelName: String = {
////        var systemInfo = utsname()
////        uname(&systemInfo)
////        let machineMirror = Mirror(reflecting: systemInfo.machine)
////        let identifier = machineMirror.children.reduce("") { identifier, element in
////            guard let value = element.value as? Int8, value != 0 else { return identifier }
////            return identifier + String(UnicodeScalar(UInt8(value)))
////        }
////        // Basic mapping (can be expanded for more models)
////        switch identifier {
////        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
////        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
////        case "iPhone10,3", "iPhone10,6": return "iPhone X"
////        case "iPhone11,2":               return "iPhone XS"
////        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
////        case "iPhone11,8":               return "iPhone XR"
////        case "iPhone12,1":               return "iPhone 11"
////        case "iPhone12,3":               return "iPhone 11 Pro"
////        case "iPhone12,5":               return "iPhone 11 Pro Max"
////        case "iPhone13,1":               return "iPhone 12 mini"
////        case "iPhone13,2":               return "iPhone 12"
////        case "iPhone13,3":               return "iPhone 12 Pro"
////        case "iPhone13,4":               return "iPhone 12 Pro Max"
////        case "iPhone14,4":               return "iPhone 13 mini"
////        case "iPhone14,5":               return "iPhone 13"
////        case "iPhone14,2":               return "iPhone 13 Pro"
////        case "iPhone14,3":               return "iPhone 13 Pro Max"
////        case "iPhone14,7":               return "iPhone 14"
////        case "iPhone14,8":               return "iPhone 14 Plus"
////        case "iPhone15,2":               return "iPhone 14 Pro"
////        case "iPhone15,3":               return "iPhone 14 Pro Max"
////        case "iPhone15,4":               return "iPhone 15"
////        case "iPhone15,5":               return "iPhone 15 Plus"
////        case "iPhone16,1":               return "iPhone 15 Pro"
////        case "iPhone16,2":               return "iPhone 15 Pro Max"
////        case "iPhoneSE", "iPhone12,8":   return "iPhone SE (2nd generation)" // Approx Match
////        case "iPhone14,6":               return "iPhone SE (3rd generation)"
////        case "iPod9,1":                  return "iPod touch (7th generation)"
////        case "iPad6,11", "iPad6,12":     return "iPad (5th generation)"
////        case "iPad7,5", "iPad7,6":       return "iPad (6th generation)"
////        // ... Add many more iPad, Simulator identifiers
////        case "i386", "x86_64", "arm64":  return "Simulator \(mapToDevice(identifier))"
////        default:                         return identifier
////        }
////    }()
////
////     // Helper for Simulator
////     private static func mapToDevice(_ identifier: String) -> String {
////         #if os(iOS)
////         return "on \(modelName)" // Recursive call might be problematic, simplify
////         #elseif os(tvOS)
////         return "on Apple TV"
////         #elseif os(watchOS)
////         return "on Apple Watch"
////         #endif
////         return "" // Fallback
////     }
////}
////
////// --- Previews ---
////struct HelpAndSupportView_Previews: PreviewProvider {
////    static var previews: some View {
////        NavigationView {
////            HelpAndSupportView()
////        }
////        .previewDisplayName("Default Preview")
////    }
////}
//#Preview("HelpAndSupportView") {
//    HelpAndSupportView()
//}
