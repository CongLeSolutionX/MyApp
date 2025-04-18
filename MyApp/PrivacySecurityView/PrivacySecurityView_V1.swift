////
////  PrivacySecurityView.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//import LocalAuthentication // Needed for Face ID/Touch ID check
//
//struct PrivacySecurityView: View {
//    @Binding var appLockEnabled: Bool
//    @Binding var shareAnalyticsEnabled: Bool
//    let accentColor: Color
//
//    @Environment(\.openURL) var openURL
//    @State private var canUseBiometrics: Bool = false // Check if device supports Face ID/Touch ID
//
//    // URLs (replace with your actual links)
//    let privacyPolicyURL = URL(string: "https://google.com")!
//    let termsOfServiceURL = URL(string: "https://apple.com")!
//    let appSettingsURL = URL(string: UIApplication.openSettingsURLString)! // Opens app's settings in System Settings
//
//    var body: some View {
//        Form {
//            // --- Security Section ---
//            Section {
//                if canUseBiometrics {
//                    Toggle("App Lock (Face ID / Touch ID)", isOn: $appLockEnabled)
//                        .tint(accentColor)
//                        .onChange(of: appLockEnabled) { _, newValue in
//                            print("App Lock toggled: \(newValue)")
//                            // Add actual logic to enable/disable app lock mechanism
//                            if newValue {
//                                authenticateUserToEnableAppLock() // Prompt for auth when enabling
//                            }
//                        }
//                } else {
//                    Text("App Lock requires Face ID or Touch ID enabled on your device.")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//
//                // Add other security settings if needed (e.g., Change Passcode if app has one)
//
//            } header: {
//                Text("Security")
//            } footer: {
//                if canUseBiometrics {
//                    Text("When enabled, requires authentication whenever the app is launched or brought to the foreground.")
//                }
//            }
//
//            // --- Data Usage Section ---
//            Section {
//                Toggle("Share Analytics & Diagnostics", isOn: $shareAnalyticsEnabled)
//                    .tint(accentColor)
//                    .onChange(of: shareAnalyticsEnabled) { _, newValue in
//                        print("Analytics sharing toggled: \(newValue)")
//                        // Add logic to enable/disable analytics SDKs (e.g., Firebase Analytics, Sentry)
//                    }
//            } header: {
//                Text("Data Usage")
//            } footer: {
//                Text("Help improve LobeHub by sharing anonymous usage data and crash reports.")
//            }
//
//            // --- Permissions Section ---
//            Section("App Permissions") {
//                Button { openURL(appSettingsURL) } label: {
//                    Label("Manage Permissions in Settings", systemImage: "hand.raised.fill")
//                }
//                .tint(accentColor) // Apply tint to button text/icon
//            }
//
//            // --- Legal Section ---
//            Section("Legal") {
//                Button { openURL(privacyPolicyURL) } label: {
//                   Label("Privacy Policy", systemImage: "lock.shield.fill")
//                }
//                .tint(accentColor)
//
//                Button { openURL(termsOfServiceURL)} label: {
//                    Label("Terms of Service", systemImage: "doc.text.fill")
//                }
//                .tint(accentColor)
//            }
//        }
//        .navigationTitle("Privacy & Security")
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear(perform: checkBiometricAvailability) // Check on view appear
//    }
//
//    // Check if biometrics are available
//    private func checkBiometricAvailability() {
//        let context = LAContext()
//        var error: NSError?
//        canUseBiometrics = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
//
//        if !canUseBiometrics {
//            if let error = error {
//                print("Biometric check failed: \(error.localizedDescription)")
//            }
//            // If biometrics become unavailable while toggle was on, turn it off
//            if appLockEnabled {
//                 appLockEnabled = false
//            }
//        }
//    }
//
//    // Optional: Authenticate user immediately when enabling App Lock
//    private func authenticateUserToEnableAppLock() {
//        // This is just a prompt when enabling, the actual lock logic is elsewhere
//        let context = LAContext()
//        let reason = "Authenticate to enable App Lock."
//
//        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
//            DispatchQueue.main.async {
//                if success {
//                    print("Authentication successful for enabling App Lock.")
//                    // Proceed (App Lock is already enabled via the Toggle binding)
//                } else {
//                    print("Authentication failed: \(error?.localizedDescription ?? "Unknown error")")
//                    // Revert the toggle state if authentication fails
//                    appLockEnabled = false
//                }
//            }
//        }
//    }
//}
//
//struct PrivacySecurityView_Previews: PreviewProvider {
//    static var previews: some View {
//            PrivacySecurityView(
//                appLockEnabled: .constant(false),
//                shareAnalyticsEnabled: .constant(true),
//                accentColor: .orange
//            )
//            .previewDisplayName("Light Mode")
//
//            PrivacySecurityView(
//                appLockEnabled: .constant(true),
//                shareAnalyticsEnabled: .constant(false),
//                accentColor: .orange
//            )
//            .preferredColorScheme(.dark)
//            .previewDisplayName("Dark Mode (App Lock On)")
//
//    }
//}
