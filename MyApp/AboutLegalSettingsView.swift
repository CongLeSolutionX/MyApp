//
//  AboutLegalSettingsView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

struct AboutLegalSettingsView: View {

    // --- App Information (Use actual data or constants) ---
    let appName = "ExampleApp Pro" // Or read from Bundle info dictionary
    let developerName = "CongLeSolutionX.tech"
    let developerWebsite = "https://CongLeSolutionX.tech"
    let termsURL = "https://CongLeSolutionX.tech/terms"
    let privacyURL = "https://CongLeSolutionX.tech/privacy"
    let licensesURL = "https://CongLeSolutionX.tech/licenses" // Or navigate to an internal list

    // --- Accent Color (Optional: Read from previous settings for consistency) ---
    // If needed for styling elements, otherwise can be omitted here.
    // private var accentColor: Color { ... }

    var body: some View {
        List { // Using List instead of Form for less visual overhead on info screens
            // --- App Info Section ---
            Section {
                HStack(spacing: 15) {
                    // App Icon Placeholder
//                    Image(systemName: "app.badge.fill") // Replace with actual App Icon if possible
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 60, height: 60)
//                        .foregroundColor(.gray) // Placeholder color
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.secondary.opacity(0.5), lineWidth: 0.5)
//                        )
                    Image("My-meme-orange_1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading) {
                        Text(appName)
                            .font(.headline)
                        Text("Version \(appVersion()) (Build \(buildNumber()))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Developed by \(developerName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8) // Add some vertical padding
            }

            // --- Legal Links Section ---
            Section(header: Text("Legal")) {
                linkRow(title: "Terms of Service", urlString: termsURL, icon: "doc.text")
                linkRow(title: "Privacy Policy", urlString: privacyURL, icon: "lock.shield")
            }

            // --- Licenses Section ---
            Section(header: Text("Acknowledgements")) {
                linkRow(title: "Open Source Licenses", urlString: licensesURL, icon: "scroll")
                // You could add other acknowledgements here if needed
            }

             // --- Website / Contact Section ---
             Section(header: Text("More Information")) {
                linkRow(title: developerName, urlString: developerWebsite, icon: "safari")
             }
        }
        .listStyle(.insetGrouped) // Give it a modern grouped list style
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    // --- Helper View for Link Rows ---
    @ViewBuilder
    private func linkRow(title: String, urlString: String, icon: String) -> some View {
        Button {
            openURL(urlString)
        } label: {
            HStack {
                Label(title, systemImage: icon)
                Spacer()
                Image(systemName: "arrow.up.right.square")
                    .font(.caption) // Make the external link icon smaller
                    .foregroundColor(.secondary)
            }
            .foregroundColor(Color(uiColor: .label)) // Ensure text color adapts
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
        // UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    // Get app version string
    private func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }

     // Get build number string
     private func buildNumber() -> String {
         return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
     }
}

// --- Previews ---
struct AboutLegalSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                AboutLegalSettingsView()
            }
            .previewDisplayName("Default (Light)")

            NavigationView {
                 AboutLegalSettingsView()
                     .environment(\.colorScheme, .dark) // Test dark mode
             }
             .previewDisplayName("Default (Dark)")

             NavigationView {
                 AboutLegalSettingsView()
                     .environment(\.locale, Locale(identifier: "es")) // Example: Test localization
             }
             .previewDisplayName("Spanish Locale")
        }
    }
}

// --- Placeholder App Icon Retrieval (Advanced/Optional) ---
// Getting the actual app icon programmatically in SwiftUI previews is tricky.
// For a *real* build, you might load it like this within the view:
/*
 private var appIcon: UIImage? {
     guard let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last else { return nil }
     return UIImage(named: lastIcon)
 }

 // And use it in the body:
 if let icon = appIcon {
     Image(uiImage: icon)
         .resizable()
         // ... rest of modifiers ...
 } else {
     // Fallback Image(systemName: ...)
 }
*/
