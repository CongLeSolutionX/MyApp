//
//  HelpSupportSettingsView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
import MessageUI // Needed for potentially composing emails

struct HelpSupportSettingsView: View {

    // --- State for Mail Composer (Optional) ---
    @State private var showingMailComposeView = false
    @State private var mailComposeResult: Result<MFMailComposeResult, Error>? = nil // To handle completion

    // --- Accent Color (Read from previous settings for consistency) ---
    private var accentColor: Color {
        let data = UserDefaults.standard.data(forKey: "appAccentColor") ?? Color.rhGold.toData()
        return Color(data: data) ?? .rhGold
    }

    var body: some View {
        Form {
            // --- Help Resources Section ---
            Section(header: Text("Help Resources")) {
                // Link to FAQ / Help Center (typically opens a URL)
                Button {
                    openURL("https://your-app.com/help") // Placeholder action
                } label: {
                    HStack {
                        Label("FAQ & Help Center", systemImage: "questionmark.circle")
                        Spacer()
                        Image(systemName: "arrow.up.right.square") // Icon indicating external link
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(Color(uiColor: .label)) // Ensure text color adapts
                }

                // Link to Tutorials (if applicable)
                Button {
                   openURL("https://your-app.com/tutorials") // Placeholder action
                } label: {
                    HStack {
                        Label("View Tutorials", systemImage: "play.rectangle")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                           .foregroundColor(.secondary)
                    }
                    .foregroundColor(Color(uiColor: .label))
                }
            }

            // --- Contact & Feedback Section ---
            Section(header: Text("Get Support & Provide Feedback")) {
                // Contact Support Button
                Button {
                    // Option 1: Open Mail Composer (if MFMailComposeViewController is available)
                    if MFMailComposeViewController.canSendMail() {
                         showingMailComposeView = true
                    } else {
                        // Option 2: Provide fallback or link to a web form
                        print("Mail services are not available. Showing fallback/web form.")
                        openURL("https://your-app.com/support-request")
                    }
                } label: {
                    Label("Contact Support", systemImage: "envelope")
                     .foregroundColor(Color(uiColor: .label)) // Ensure text color adapts
                }
                // Disable if mail cannot be sent (alternative: hide or show different UI)
                 // .disabled(!MFMailComposeViewController.canSendMail()) // Example of disabling

                // Report a Problem Button
                Button {
                   // Similar logic, could pre-fill subject for bug reports
                   print("Navigating to 'Report a Problem' screen or opening mail composer...")
                   // Example: Could open mail with a specific subject
                   openEmail(subject: "Problem Report - App v\(appVersion())")
                } label: {
                   Label("Report a Problem", systemImage: "exclamationmark.bubble") // Or "ant.circle" for bugs
                    .foregroundColor(Color(uiColor: .label))
                }

                // Give Feedback Button (Optional)
                 Button {
                    print("Navigating to feedback form/survey...")
                    openURL("https://your-app.com/feedback")
                 } label: {
                    Label("Provide Feedback", systemImage: "star")
                     .foregroundColor(Color(uiColor: .label))
                 }
            }

            // --- App Info Section (Often combined here or in 'About') ---
             Section(header: Text("App Information")) {
                 HStack {
                     Text("Version")
                     Spacer()
                     Text(appVersion())
                         .foregroundColor(.secondary)
                 }
             }

        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
        // Present the Mail Compose View modally
        .sheet(isPresented: $showingMailComposeView) {
            MailComposeView(result: $mailComposeResult) { composer in
                // Configure the mail composer
                composer.setToRecipients(["support@your-app.com"])
                composer.setSubject("Support Request - App v\(appVersion())")
                composer.setMessageBody("\n\n\n-----\nPlease describe your issue above.\nDevice Info: \(deviceInfo())\nApp Version: \(appVersion())", isHTML: false)
            }
        }
    }

    // --- Helper Functions ---

    // Placeholder for opening URLs
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL string: \(urlString)")
            return
        }
        print("Attempting to open URL: \(url)")
        // In a real app, use UIApplication.shared.open(url)
        // UIApplication.shared.open(url)
    }

     // Placeholder for opening email (could directly use mailto: or trigger MFMailCompose)
     private func openEmail(subject: String = "") {
         let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
         let urlString = "mailto:support@your-app.com?subject=\(encodedSubject)"
         openURL(urlString) // Use the same URL opening mechanism
     }

    // Get app version string
    private func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }

     // Basic device info for support emails
     private func deviceInfo() -> String {
         let device = UIDevice.current
         return "\(device.model) - iOS \(device.systemVersion)"
     }
}

// --- MailComposeView Wrapper (Helper for SwiftUI integration) ---
struct MailComposeView: UIViewControllerRepresentable {
    @Binding var result: Result<MFMailComposeResult, Error>?
    var configure: (MFMailComposeViewController) -> Void // Closure to configure the composer

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        configure(vc) // Apply configuration
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // No update needed usually
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, result: $result)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailComposeView
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(_ parent: MailComposeView, result: Binding<Result<MFMailComposeResult, Error>?>) {
            self.parent = parent
            self._result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer {
                controller.dismiss(animated: true)
            }
            if let error = error {
                self.result = .failure(error)
                print("Mail composer failed with error: \(error.localizedDescription)")
            } else {
                self.result = .success(result)
                 print("Mail composer finished with result: \(result.rawValue)") // Log result code
                 // Handle different results if needed (e.g., show confirmation)
                 switch result {
                 case .sent:
                     print("Mail sent successfully.")
                 case .saved:
                      print("Mail saved as draft.")
                 case .cancelled:
                      print("Mail cancelled.")
                 case .failed:
                      print("Mail failed to send.")
                 @unknown default:
                      print("Mail finished with unknown result.")
                 }
            }
        }
    }
}

// --- Previews ---
struct HelpSupportSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                HelpSupportSettingsView()
            }
            .previewDisplayName("Default (Light)")

            NavigationView {
                 HelpSupportSettingsView()
                     .environment(\.colorScheme, .dark) // Test dark mode
             }
             .previewDisplayName("Default (Dark)")

            // Simulate case where mail is not available
             // (Difficult to simulate directly in Preview without modifying the view structure)
             NavigationView {
                 HelpSupportSettingsView()
                     .environment(\.locale, Locale(identifier: "fr")) // Example: Test localization
             }
             .previewDisplayName("French Locale")
        }

    }
}

// --- Color Extension (Ensure this is accessible) ---
// If not already defined globally:
/*
 extension Color {
     static let rhGold = Color(red: 0.7, green: 0.5, blue: 0.1)
     // toData() and init?(data: Data) methods needed here if not global
     // Add Codable conformance as defined in AppearanceSettingsView
 }
 extension Color: Codable { ... } // Assuming defined elsewhere
 */
