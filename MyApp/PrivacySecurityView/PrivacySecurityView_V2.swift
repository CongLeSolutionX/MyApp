////
////  PrivacySecurityView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//
//import SwiftUI
//import LocalAuthentication // Needed for Face ID/Touch ID
//
//struct PrivacySecurityView: View {
//    // --- State Management ---
//    // Use @AppStorage directly for persistence within this view's scope
//    @AppStorage("appLockEnabled_v1") private var appLockEnabled: Bool = false // Added suffix for potential migration
//    @AppStorage("shareAnalyticsEnabled_v1") private var shareAnalyticsEnabled: Bool = true
//
//    // Passed accent color for consistent tinting
//    let accentColor: Color
//    
//
//    // Environment actions
//    @Environment(\.openURL) var openURL
//    @Environment(\.colorScheme) var colorScheme // For potential UI adjustments
//
//    // State for biometric checks and alerts
//    @State private var canUseBiometrics: Bool = false
//    @State private var showingAuthErrorAlert = false
//    @State private var authErrorMessage = ""
//
//    // --- URLs ---
//    // Replace with your actual URLs
//    let privacyPolicyURL = URL(string: "https://github.com/CongLeSolutionX/PrivacyPolicy")! // Example URL
//    let termsOfServiceURL = URL(string: "https://github.com/CongLeSolutionX/TermsOfService")! // Example URL
//    let appSettingsURL = URL(string: UIApplication.openSettingsURLString)! // Opens app's settings in System Settings
//
//    // MARK: - Body
//    var body: some View {
//        Form {
//            securitySection
//            dataUsageSection
//            permissionsSection
//            legalSection
//        }
//        .navigationTitle("Privacy & Security")
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear(perform: checkBiometricAvailability) // Check biometrics when view appears
//        .alert("Authentication Failed", isPresented: $showingAuthErrorAlert) { // Alert for auth errors
//            Button("OK") { } // Simple dismiss button
//        } message: {
//            Text(authErrorMessage) // Show the specific error message
//        }
//    }
//
//    // MARK: - View Sections (Using @ViewBuilder for cleaner structure)
//
//    @ViewBuilder
//    private var securitySection: some View {
//        Section {
//            if canUseBiometrics {
//                Toggle("App Lock (Face ID / Touch ID)", isOn: $appLockEnabled)
//                    .tint(accentColor)
//                    .onChange(of: appLockEnabled) { _, newValue in
//                        handleAppLockToggleChange(isEnabling: newValue)
//                    }
//            } else {
//                Text("App Lock requires Face ID or Touch ID to be enabled and configured on your device.")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//            // Add other security settings here if needed (e.g., Change Passcode)
//            // Example: NavigationLink("Change App Passcode", destination: ChangePasscodeView())
//
//        } header: {
//            Text("Security")
//        } footer: {
//            if self.canUseBiometrics {
//                Text("When enabled, requires biometric authentication whenever the app is launched or brought to the foreground after a period of inactivity.")
//            }
//        }
//    }
//
//    @ViewBuilder
//    private var dataUsageSection: some View {
//        Section {
//            Toggle("Share Analytics & Diagnostics", isOn: $shareAnalyticsEnabled)
//                .tint(accentColor)
//                .onChange(of: shareAnalyticsEnabled) { _, newValue in
//                    // Simulate enabling/disabling analytics service
//                    if newValue {
//                        print("Analytics sharing ENABLED. (Simulating AnalyticsService.shared.enableCollection())")
//                        // AnalyticsService.shared.enableCollection() // Actual call
//                    } else {
//                        print("Analytics sharing DISABLED. (Simulating AnalyticsService.shared.disableCollection())")
//                        // AnalyticsService.shared.disableCollection() // Actual call
//                    }
//                    // You might also need consent management logic here
//                }
//        } header: {
//            Text("Data Usage")
//        } footer: {
//            Text("Help improve this app by sharing anonymous usage data and crash reports. This data does not include personal information.")
//        }
//    }
//
//    @ViewBuilder
//    private var permissionsSection: some View {
//        Section("App Permissions") {
//            Button {
//                print("Opening App Settings in System Settings app...")
//                openURL(appSettingsURL)
//            } label: {
//                Label("Manage Permissions in Settings", systemImage: "gearshape.fill") // Use a more relevant icon
//                    .foregroundColor(accentColor) // Apply tint to the label content directly for Button
//            }
//            .accessibilityHint("Opens the iOS Settings app to manage permissions for this application.")
//        }
//    }
//
//    @ViewBuilder
//    private var legalSection: some View {
//        Section("Legal Information") {
//            Button {
//               print("Opening Privacy Policy URL: \(privacyPolicyURL)...")
//               openURL(privacyPolicyURL)
//            } label: {
//               Label("Privacy Policy", systemImage: "lock.shield.fill")
//                   .foregroundColor(accentColor)
//            }
//            .accessibilityHint("Opens the Privacy Policy in your web browser.")
//
//            Button {
//                print("Opening Terms of Service URL: \(termsOfServiceURL)...")
//                openURL(termsOfServiceURL)
//            } label: {
//                Label("Terms of Service", systemImage: "doc.text.fill")
//                    .foregroundColor(accentColor)
//            }
//            .accessibilityHint("Opens the Terms of Service in your web browser.")
//        }
//    }
//
//    // MARK: - Logic Functions
//
//    private func checkBiometricAvailability() {
//           let context = LAContext()
//           var error: NSError?
//
//           // Check if the device can evaluate the policy (has sensor, is enabled)
//           let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
//
//           // Update the state variable ON THE MAIN THREAD
//           DispatchQueue.main.async {
//               self.canUseBiometrics = canEvaluate
//           }
//
//           if !canEvaluate {
//               if let nsError = error {
//                   print("Biometric check failed: \(nsError.localizedDescription) (Code: \(nsError.code))")
//                   // Optionally show an alert to the user based on the error code
//                   // Example: LAError.biometryNotEnrolled might prompt them to set it up
//                    self.authErrorMessage = "Biometrics not available: \(nsError.localizedDescription)"
//                    self.showingAuthErrorAlert = true // if you want to show errors
//               } else {
//                   print("Biometrics not available for an unknown reason.")
//                    self.authErrorMessage = "Biometrics are not available on this device."
//                    self.showingAuthErrorAlert = true // if you want to show errors
//               }
//                // If biometrics somehow became unavailable while toggle was ON, turn it off.
//               if appLockEnabled {
//                    print("Biometrics became unavailable, disabling App Lock.")
//                    appLockEnabled = false // Force disable if hardware state changed
//               }
//           } else {
//               print("Biometrics are available.")
//           }
//       }
//
//    private func handleAppLockToggleChange(isEnabling: Bool) {
//        if isEnabling {
//            // --- Attempting to ENABLE App Lock ---
//            print("Attempting to enable App Lock, initiating authentication...")
//            authenticateUserToConfirmAppLock()
//        } else {
//            // --- Disabling App Lock ---
//            // No authentication required to disable.
//            print("App Lock Disabled by user.")
//            // Add any cleanup logic needed when disabling App Lock here.
//            // e.g., clear sensitive timers, flags etc.
//        }
//    }
//
//    private func authenticateUserToConfirmAppLock() {
//        // This function is called *only* when the user tries to *enable* the toggle.
//        let context = LAContext()
//        context.localizedCancelTitle = "Cancel" // Optional: Customize cancel button title
//        let reason = "Authenticate with Face ID or Touch ID to enable the App Lock feature."
//
//        // Perform the actual biometric evaluation
//        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
//            // IMPORTANT: Update UI on the main thread
//            DispatchQueue.main.async {
//                if success {
//                    // --- Authentication Successful ---
//                    print("Authentication successful for enabling App Lock.")
//                    // The toggle state (`appLockEnabled`) is already `true` due to the user interaction.
//                    // No need to change it here. We just confirmed it.
//                    // Add any additional setup logic needed after successful enable here.
//                } else {
//                    // --- Authentication Failed ---
//                    print("Authentication failed when trying to enable App Lock.")
//                    // Provide specific feedback based on the error
//                    if let error = authenticationError as? LAError {
//                       self.authErrorMessage = localizedErrorString(for: error.code)
//                    } else {
//                       self.authErrorMessage = authenticationError?.localizedDescription ?? "An unknown authentication error occurred."
//                       print("Non-LAError during authentication: \(authenticationError?.localizedDescription ?? "Unknown")")
//                    }
//                    self.showingAuthErrorAlert = true
//
//                    // ***** CRITICAL: Revert the toggle state *****
//                    // Since authentication failed, we cannot enable App Lock.
//                    self.appLockEnabled = false
//                }
//            }
//        }
//    }
//
//    // Helper to provide more user-friendly error messages for LAError codes
//    private func localizedErrorString(for errorCode: LAError.Code) -> String {
//        switch errorCode {
//        case .authenticationFailed:
//            return "Authentication failed. Please try again."
//        case .userCancel:
//            return "Authentication was cancelled."
//        case .userFallback:
//            return "Password fallback is not supported for enabling App Lock." // Or handle fallback if desired
//        case .systemCancel:
//            return "Authentication was cancelled by the system."
//        case .passcodeNotSet:
//            return "Please set a device passcode to use App Lock."
//        case .biometryNotAvailable:
//            return "Face ID or Touch ID is not available on this device."
//        case .biometryNotEnrolled:
//            // Suggest opening settings to enroll
//            return "Face ID or Touch ID is not set up. Please enroll in Settings to use App Lock."
//        case .biometryLockout:
//            return "Too many failed attempts. Face ID/Touch ID is locked. Please use your passcode."
//        case .appCancel, .invalidContext, .notInteractive:
//            return "An internal authentication error occurred. Please try again later."
//        case .touchIDNotAvailable:
//            return "Touch ID is not available"
//        case .touchIDNotEnrolled:
//            return "Touch ID is not enrolled"
//        case .touchIDLockout:
//            return "Touch ID is lockout"
//        @unknown default:
//            return "An unknown authentication error occurred."
//        }
//    }
//}
//
//// MARK: - Previews
//struct PrivacySecurityView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Wrap in NavigationView for preview context
//            PrivacySecurityView(accentColor: .purple)
//                .previewDisplayName("Light Mode - Default")
//
//            PrivacySecurityView(accentColor: .green)
//                .preferredColorScheme(.dark)
//                .previewDisplayName("Dark Mode - Green Accent")
//                // Simulate Biometrics Unavailable
//                .onAppear {
//                    // In a real preview, you'd mock LAContext or inject state.
//                    // For simplicity, we can't directly disable biometrics here easily.
//                    // Preview will show the toggle if system CAN use biometrics.
//                    print("Preview: Assuming biometrics are available for layout.")
//                }
//    }
//}
