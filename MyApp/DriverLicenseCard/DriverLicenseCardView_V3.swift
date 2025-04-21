//
//  DriverLicenseCardView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

import SwiftUI
import Combine // Needed for Timers or delays if not using asyncAfter

// MARK: - Presentation State Enum
// To manage the visual state during the simulated presentation
enum PresentationState {
    case idle
    case authenticating // Simulating Face ID / Passcode
    case presenting     // Simulating NFC tap / data transfer
    case success        // Presented successfully
    case failed         // Authentication or presentation failed
}

// MARK: - Data Models (Updated)

struct DriverLicenseInfo: Identifiable {
    let id = UUID()
    let name: String
    let state: String
    let licenseNumber: String
    let expirationDate: Date
    let issueDate: Date
    let photoAssetName: String
    let realIDCompliant: Bool
    var lastPresentedDate: Date? // New: Track last successful presentation
}

struct AppPrivacyInfo {
    let appName: String
    let appIconName: String
    let presentedFields: [String]
    let storedFields: [String]
    let retentionPolicy: String
    let developerWebsite: URL?
    let requiresAgeVerification: Bool // New: Specific flag
}

// MARK: - Main Driver's License View (Updated)

struct DriverLicenseView: View {
    // --- Mock Data Instances ---
    // Use @State for mutable data owned by this view
    @State private var licenseInfo = DriverLicenseInfo(
        name: "Jane Doe",
        state: "California",
        licenseNumber: "****-****-1234",
        expirationDate: Calendar.current.date(byAdding: .year, value: 4, to: Date())!,
        issueDate: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
        photoAssetName: "person.crop.rectangle.stack.fill",
        realIDCompliant: true,
        lastPresentedDate: nil // Initially nil
    )

    // Use 'let' for static configuration data for this view instance
    let requestingAppInfo = AppPrivacyInfo(
        appName: "Example Retail App",
        appIconName: "cart.fill",
        presentedFields: ["ID Photo", "Age Over 21", "Issuing Authority"], // Simplified for demo
        storedFields: ["Age Over 21 Verification Result", "Transaction Timestamp"],
        retentionPolicy: "Stored by app for up to 30 days for verification records.",
        developerWebsite: URL(string: "https://www.example.com/privacy"),
        requiresAgeVerification: true
    )

    // --- State Variables ---
    @State private var showingPrivacySheet = false
    @State private var showReadyInfoCard = true

    // Haptic Feedback Generator
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let successHaptic = UINotificationFeedbackGenerator()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                DriverLicenseCard(
                    name: licenseInfo.name,
                    state: licenseInfo.state,
                    iconName: licenseInfo.photoAssetName,
                    lastPresented: licenseInfo.lastPresentedDate // Pass last presented date
                )
                .padding(.horizontal)

                if showReadyInfoCard {
                    ReadyInfoCard(licenseState: licenseInfo.state) {
                        hapticGenerator.impactOccurred()
                        withAnimation {
                            showReadyInfoCard = false
                        }
                        print("User dismissed the 'Ready to Use' info card.")
                    }
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                Spacer()
            }
            .padding(.top)
            .background(Color(.systemGroupedBackground).ignoresSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        hapticGenerator.impactOccurred()
                        print("Done button tapped. Simulating dismissal of parent flow.")
                        // In a real app: presentationMode.wrappedValue.dismiss() if modal,
                        // or navigate back, or signal completion via delegate/callback.
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        hapticGenerator.impactOccurred()
                        showingPrivacySheet = true
                        print("Ellipsis tapped, showing privacy sheet.")
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showingPrivacySheet) {
                // Pass a BINDING to licenseInfo so the sheet can modify it
                PrivacySheetView(licenseInfo: $licenseInfo, appInfo: requestingAppInfo)
            }
            .onAppear {
                preloadHaptics()
            }
        }
        .navigationViewStyle(.stack)
    }

    private func preloadHaptics() {
        hapticGenerator.prepare()
        successHaptic.prepare()
    }
}

// MARK: - Helper View: Driver's License Card (Updated)
struct DriverLicenseCard: View {
    let name: String
    let state: String
    let iconName: String
    let lastPresented: Date? // Receive last presented date

    var body: some View {
        ZStack(alignment: .leading) {
            // ... (Gradient background remains the same) ...
             RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.9)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)
                 .shadow(color: .black.opacity(0.1), radius: 5, y: 3)

            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(state.uppercased()) // ... State & Title ...
                         .font(.caption)
                         .fontWeight(.medium)
                         .foregroundColor(.white.opacity(0.8))
                         .padding(.bottom, 1)

                    Text("DRIVER'S LICENSE")
                         .font(.caption)
                         .fontWeight(.medium)
                         .foregroundColor(.white.opacity(0.8))

                    Spacer() // Pushes Name to the bottom

                    Text(name) // ... Name ...
                         .font(.title2)
                         .fontWeight(.semibold)
                         .foregroundColor(.white)
                         .minimumScaleFactor(0.8)

                     // Show Last Presented Date if available
                      if let lastPresented {
                          Text("Last Presented: \(lastPresented, style: .relative) ago")
                              .font(.caption2)
                              .foregroundColor(.white.opacity(0.7))
                              .padding(.top, 2)
                      } else {
                           Text("Not presented recently")
                              .font(.caption2)
                              .foregroundColor(.white.opacity(0.6))
                              .padding(.top, 2)
                      }

                }
                Spacer() // Pushes icon block to the right

                 VStack { // Stack icon and optional Real ID badge
                     Image(systemName: iconName) // ... Icon ...
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 50, height: 50)

                     // Add Real ID indicator if compliant (Example)
                     // In reality this might be embedded differently
                     Image(systemName: "star.circle.fill")
                          .foregroundColor(.yellow)
                          .font(.caption)
                          .padding(.top, 4)
                          // .opacity(licenseInfo.realIDCompliant ? 1 : 0) // If passed in
                 }

            }
            .padding()
        }
    }
}

// MARK: - Helper View: ReadyInfoCard (No functional change needed here)
struct ReadyInfoCard: View {
    let licenseState: String
    var onClose: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "checkmark.seal.fill")
                .resizable().scaledToFit().frame(width: 35, height: 35)
                .foregroundColor(.green).padding(8).background(Color.green.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading) {
                Text("\(licenseState) Driver's License").font(.headline)
                Text("Your ID is ready to use in Wallet.").font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill").foregroundColor(.gray.opacity(0.5)).imageScale(.large)
            }
            .buttonStyle(.plain)
        }
        .padding().background(Color(.secondarySystemGroupedBackground)).cornerRadius(15)
    }
}

// MARK: - Privacy Sheet View (Major Updates)

struct PrivacySheetView: View {
    // --- Environment & State ---
    @Environment(\.dismiss) var dismiss
    @State private var showingPrivacyOptions = false
    @State private var presentationState: PresentationState = .idle
    @State private var presentationTimer: Timer? // For simulating delays

    // --- Binding Data ---
    // Allows this view to modify the licenseInfo passed from the parent
    @Binding var licenseInfo: DriverLicenseInfo

    // --- Static Data ---
    let appInfo: AppPrivacyInfo

    // Haptic Feedback
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let successHaptic = UINotificationFeedbackGenerator()
    private let errorHaptic = UINotificationFeedbackGenerator()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    AppInfoSection(appName: appInfo.appName, iconName: appInfo.appIconName)
                        .padding(.top, 5)

                    // Make the ID Card tappable and show presentation state
                    SheetIDCard(state: licenseInfo.state, presentationState: presentationState) // Pass state
                        .onTapGesture {
                            // Initiate presentation only if idle
                            if presentationState == .idle {
                                attemptPresentation()
                            }
                        }
                        // Add subtle animation for state changes
                        .animation(.easeInOut, value: presentationState)

                    InformationListSection(
                        appName: appInfo.appName,
                        presentedFields: appInfo.presentedFields,
                        storedFields: appInfo.storedFields,
                        retentionPolicy: appInfo.retentionPolicy
                    )

                    // Update Face ID section based on state
                    FaceIDSection(presentationState: presentationState)
                        .animation(.easeInOut, value: presentationState)

                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea(.all))
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        hapticGenerator.impactOccurred()
                        cancelPresentationAttempt() // Cancel if in progress
                        dismiss()
                    }
                    // Disable done button during presentation attempt
                    .disabled(presentationState == .authenticating || presentationState == .presenting)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        hapticGenerator.impactOccurred()
                        showingPrivacyOptions = true
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                    }
                     // Disable ellipsis during presentation attempt
                    .disabled(presentationState == .authenticating || presentationState == .presenting)
                }
            }
            .actionSheet(isPresented: $showingPrivacyOptions) { createActionSheet() }
            .onAppear { preloadHaptics() }
            .onDisappear { cancelPresentationAttempt() } // Clean up timer if sheet dismissed abruptly
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Presentation Logic
    private func attemptPresentation() {
        guard presentationState == .idle else { return } // Prevent double taps

        print("Attempting presentation...")
        hapticGenerator.impactOccurred()
        presentationState = .authenticating

        // Simulate Face ID / Authentication delay (e.g., 1.5 seconds)
        presentationTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            // Simulate success/failure of authentication (e.g., always success for demo)
            let authSucceeded = true // Or Bool.random() for variety

            if authSucceeded {
                print("Authentication successful. Presenting...")
                presentationState = .presenting
                hapticGenerator.impactOccurred()

                // Simulate presentation/NFC delay (e.g., 1 second)
                presentationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    // Simulate success/failure of presentation
                    let presentationSucceeded = true // Or Bool.random()

                    if presentationSucceeded {
                        print("Presentation Successful!")
                        presentationState = .success
                        successHaptic.notificationOccurred(.success)
                        // *** Update the Binding ***
                        licenseInfo.lastPresentedDate = Date()

                         // Reset state back to idle after a short delay
                        presentationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                             presentationState = .idle
                        }

                    } else {
                        print("Presentation Failed.")
                        presentationState = .failed
                       errorHaptic.notificationOccurred(.error)
                        // Reset state back to idle after a short delay
                       presentationTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { _ in
                            presentationState = .idle
                       }
                    }
                }
            } else {
                print("Authentication Failed.")
                presentationState = .failed
                errorHaptic.notificationOccurred(.error)
                 // Reset state back to idle after a short delay
                presentationTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { _ in
                    presentationState = .idle
                }
            }
        }
    }

    // Clean up timer if view disappears or process is cancelled
    private func cancelPresentationAttempt() {
        presentationTimer?.invalidate()
        presentationTimer = nil
        if presentationState != .idle && presentationState != .success {
            presentationState = .idle // Reset if cancelled mid-process
        }
    }

    // MARK: - Action Sheet Creation
    private func createActionSheet() -> ActionSheet {
        var buttons: [ActionSheet.Button] = []

        // Learn More Button
        buttons.append(.default(Text("Learn More About Wallet Privacy")) {
            print("Action Sheet: Learn More tapped.")
            guard let url = URL(string: "https://www.apple.com/legal/privacy/data/en/apple-wallet/") else {
                print("Error: Invalid URL for Wallet Privacy")
                return
            }
            // UIApplication.shared.open(url) // Uncomment for actual device test
            print("Simulating opening URL: \(url)")
        })

        // App Privacy Button (only if URL exists)
        if let devURL = appInfo.developerWebsite {
             buttons.append(.default(Text("View \"\(appInfo.appName)\" Privacy Details")) {
                 print("Action Sheet: View App Privacy tapped.")
                 // UIApplication.shared.open(devURL) // Uncomment for actual device test
                 print("Simulating opening URL: \(devURL)")
             })
        } else {
             print("Action Sheet: App Privacy Details URL not available.")
        }

        // Report Problem Button
        buttons.append(.destructive(Text("Report a Problem")) {
             print("Action Sheet: Report a Problem tapped.")
             // In a real app, trigger feedback UI / API call
             print("Simulating feedback mechanism trigger.")
        })

        // Cancel Button
        buttons.append(.cancel {
            print("Action Sheet: Cancelled.")
        })

        return ActionSheet(
            title: Text("Privacy Options"),
            message: Text("Manage settings or learn more about how your data is used."),
            buttons: buttons
        )
    }

    // MARK: - Haptic Preload
    private func preloadHaptics() {
        hapticGenerator.prepare()
        successHaptic.prepare()
        errorHaptic.prepare()
    }
}

// MARK: - Helper Views for Privacy Sheet (Updated for State)

// AppInfoSection remains the same visually
struct AppInfoSection: View {
    let appName: String
    let iconName: String
    var body: some View { /* ... same as before ... */
         VStack {
            Image(systemName: iconName).resizable().scaledToFit().symbolRenderingMode(.hierarchical).foregroundStyle(.tint).frame(width: 60, height: 60).padding(10).background(Color(.secondarySystemGroupedBackground)).clipShape(RoundedRectangle(cornerRadius: 16)).shadow(color: .black.opacity(0.05), radius: 3, y: 2)
            Text(appName).font(.title3).fontWeight(.medium)
        }
    }
}

// SheetIDCard updated to show presentation state
struct SheetIDCard: View {
    let state: String
    let presentationState: PresentationState // Receive state

    var body: some View {
        HStack(spacing: 15) {
             // Icon changes based on state
             currentIcon
                 .font(.system(size: 30)) // Use font size for better scaling of symbols/indicators
                 .frame(width: 45, height: 45) // Slightly larger frame for indicator
                 .foregroundColor(iconColor)
                 .padding(8)
                 .background(iconBackgroundColor)
                 .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading) {
                Text("\(state) Driver's License").font(.headline)
                // Text changes based on state
                Text(statusText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(15)
        // Add a subtle overlay effect during presenting state
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(presentationState == .presenting ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }

    // MARK: - Computed Properties for State UI
    
    @ViewBuilder
    private var currentIcon: some View {
        switch presentationState {
        case .idle:
            Image(systemName: "person.text.rectangle.fill")
        case .authenticating:
            ProgressView().tint(.gray) // Now allowed, as it conforms to View
        case .presenting:
             Image(systemName: "wave.3.right.circle.fill")
        case .success:
            Image(systemName: "checkmark.circle.fill")
        case .failed:
            Image(systemName: "xmark.circle.fill")
        }
    }

    private var statusText: String {
        switch presentationState {
        case .idle: return "Tap card reader to present ID"
        case .authenticating: return "Authenticating with Face ID..."
        case .presenting: return "Hold Near Reader"
        case .success: return "Presented Successfully"
        case .failed: return "Presentation Failed"
        }
    }

    private var iconColor: Color {
         switch presentationState {
         case .idle: return .blue
         case .authenticating: return .secondary // ProgressView has its own tint
         case .presenting: return .blue
         case .success: return .green
         case .failed: return .red
         }
    }

     private var iconBackgroundColor: Color {
         switch presentationState {
         case .idle: return .blue.opacity(0.15)
         case .authenticating: return Color(.systemGray5)
         case .presenting: return .blue.opacity(0.15)
         case .success: return .green.opacity(0.15)
         case .failed: return .red.opacity(0.15)
         }
     }
}

// InformationListSection - Pass appName for dynamic text
struct InformationListSection: View {
    let appName: String
    let presentedFields: [String]
    let storedFields: [String]
    let retentionPolicy: String

    // Helper remains the same
    @ViewBuilder
    private func infoRow(icon: String, text: String) -> some View { /* ... same ... */
        HStack(spacing: 8) {
            Image(systemName: icon).frame(width: 20, alignment: .center)
            Text(text)
        }
        .font(.subheadline)
        .foregroundColor(.primary.opacity(0.9))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Shared with \"\(appName)\"") // Use passed appName
                    .font(.subheadline).bold()
                if !storedFields.isEmpty {
                    Text(retentionPolicy)
                } else {
                    Text("Information is presented but not stored...")
                }
            }
            // ... Rest of the ForEach loops remain the same ...
            VStack(alignment: .leading, spacing: 8) {
                ForEach(presentedFields, id: \.self) { field in
                    infoRow(icon: iconForField(field), text: field)
                }
            }
            if !storedFields.isEmpty {Divider().padding(.vertical, 5); Text("Stored by \"\(appName)\"").font(.subheadline).bold(); ForEach(storedFields, id: \.self) { _ in  } }

        }
        .padding().background(Color(.secondarySystemGroupedBackground)).cornerRadius(15)
    }

    private func iconForField(_ fieldName: String) -> String { /* ... same as before ... */
        switch fieldName.lowercased() {
        case "id photo": return "person.crop.rectangle.stack"; case "full name", "legal name": return "person.text.rectangle"; case "age over 21", "age over 18": return "checkmark.seal"; case "issuing authority": return "building.columns"; case "transaction timestamp": return "clock"; case "address": return "house"; case "date of birth": return "calendar"; default: return "questionmark.circle"
        }
    }
}

// FaceIDSection updated to show status
struct FaceIDSection: View {
    let presentationState: PresentationState

    var body: some View {
        VStack {
            // Show different icon based on state
             iconForState
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(colorForState)
                //.resizable()

            Text(textForState)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 2)
        }
        .padding(.top)
         // Fade in/out the whole section based on relevance
        .opacity(presentationState == .success || presentationState == .authenticating || presentationState == .failed ? 1 : 0)
    }

     @ViewBuilder
     private var iconForState: some View {
         switch presentationState {
         case .authenticating: Image(systemName: "faceid")
         case .success: Image(systemName: "checkmark.circle.fill")
         case .failed: Image(systemName: "xmark.circle.fill")
         default: Image(systemName: "faceid") // Default or idle state
         }
     }

     private var textForState: String {
          switch presentationState {
          case .authenticating: return "Authenticating..."
          case .success: return "Authenticated with Face ID"
          case .failed: return "Authentication Failed"
          default: return "" // Hide text when not relevant
          }
     }

     private var colorForState: Color {
          switch presentationState {
          case .authenticating: return .blue
          case .success: return .green
          case .failed: return .red
          default: return .clear // Hide color when not relevant
          }
     }
}

// MARK: - Preview Provider

struct DriverLicenseView_Previews: PreviewProvider {
    static var previews: some View {
        DriverLicenseView()
            .preferredColorScheme(.dark)
    }
}

// Helper struct/extension potentially for real URL opening
// Needs import UIKit - keep commented out for pure SwiftUI Previews
extension View {
    func openURL(_ url: URL) {
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #else
        print("Platform does not support UIApplication.shared.open. URL: \(url)")
        #endif
    }
}
