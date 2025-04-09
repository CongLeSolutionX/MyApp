////
////  CreditApplicationStatus.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//
//// --- Enum for Application Status ---
//enum CreditApplicationStatus: CaseIterable { // CaseIterable for easy random selection in simulation
//    case processing // Initial state while fetching
//    case approved
//    case pendingReview
//    case denied
//    case error // Error fetching status
//}
//
//// --- Main Application Status View ---
//struct ApplicationStatusView: View {
//    @Environment(\.dismiss) var dismiss
//
//    // --- State Variables ---
//    @State private var applicationStatus: CreditApplicationStatus = .processing
//    @State private var statusMessage: String = "Checking your application status..."
//    @State private var statusIconName: String = "hourglass" // Default processing icon
//    @State private var statusIconColor: Color = .gray // Default color
//    @State private var isLoading: Bool = true
//    @State private var errorMessage: String? = nil // Optional error message
//
//    var body: some View {
//        VStack(spacing: 24) { // Added spacing for better visual separation
//            Spacer() // Push content towards the center/top
//
//            // --- Loading Indicator ---
//            if isLoading {
//                ProgressView("Checking Status...")
//                    .progressViewStyle(CircularProgressViewStyle(tint: Color.rhGold))
//                    .padding(.bottom, 30) // Add space below indicator
//            } else {
//                // --- Status Icon and Text ---
//                Image(systemName: statusIconName)
//                    .font(.system(size: 70, weight: .light)) // Large, prominent icon
//                    .foregroundColor(statusIconColor)
//                    .padding(.bottom, 10)
//
//                Text(statusTitle) // Dynamic title based on status
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .foregroundColor(Color.rhBlack) // Use theme color
//
//                Text(statusMessage)
//                    .font(.body)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal) // Prevent text from hitting edges
//            }
//
//            // --- Conditional Content Based on Status ---
//            if !isLoading {
//                switch applicationStatus {
//                case .approved:
//                    ApprovedContentView()
//                case .pendingReview:
//                    PendingReviewContentView()
//                case .denied:
//                    DeniedContentView()
//                case .error:
//                    ErrorContentView(
//                        errorMessage: errorMessage ?? "An unknown error occurred.",
//                        retryAction: fetchApplicationStatus // Pass retry action
//                    )
//                case .processing:
//                    EmptyView() // Should not stay in processing state if not loading
//                }
//            }
//
//            Spacer() // Push button to bottom
//
//            // --- Done Button ---
//            Button {
//                dismiss() // Dismiss the entire application flow modal
//            } label: {
//                Text("Done")
//                    .font(.headline)
//                    .foregroundColor(Color.rhButtonTextGold)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.rhButtonDark)
//                    .cornerRadius(10)
//            }
//            .padding(.horizontal)
//            .padding(.bottom) // Add padding at the very bottom
//             // Disable button while initially loading status
//             // .disabled(isLoading) // Maybe allow closing even if loading fails
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity) // Occupy full available space
//        .background(Color.rhBeige.ignoresSafeArea()) // Apply background
//        .onAppear {
//            // Simulate fetching the application status when the view appears
//            fetchApplicationStatus()
//        }
//        .navigationBarHidden(true) // Often status screens hide the nav bar
//    }
//
//    // --- Computed Property for Title ---
//    var statusTitle: String {
//        switch applicationStatus {
//        case .processing: return "Processing..."
//        case .approved: return "Application Approved!"
//        case .pendingReview: return "Application Pending"
//        case .denied: return "Application Denied"
//        case .error: return "Error Checking Status"
//        }
//    }
//
//    // --- Action Logic ---
//    @MainActor // Ensure UI updates happen on the main thread
//    private func fetchApplicationStatus() {
//        isLoading = true
//        applicationStatus = .processing // Reset to processing state
//        statusMessage = "Checking your application status..."
//        statusIconName = "hourglass"
//        statusIconColor = .gray
//        errorMessage = nil
//        print("Attempting to fetch application status...")
//
//        Task {
//            do {
//                // Simulate network delay for fetching status (1-3 seconds)
//                try await Task.sleep(nanoseconds: UInt64.random(in: 1...3) * 1_000_000_000)
//
//                 // Simulate potential fetch error (e.g., 10% chance)
//                 if Bool.random() && Double.random(in: 0...1) < 0.1 {
//                     throw URLError(.timedOut) // Simulate a network timeout
//                 }
//
//                // Simulate random outcome (more likely pending/approved than denied for demo)
//                let randomOutcome = CreditApplicationStatus.allCases.filter { $0 != .processing && $0 != .error }.randomElement() ?? .pendingReview
//
//                print("Simulated status fetched: \(randomOutcome)")
//
//                // Update state based on the simulated outcome
//                applicationStatus = randomOutcome
//
//                switch applicationStatus {
//                case .approved:
//                    statusMessage = "Congratulations! Your Robinhood Gold Card application has been approved."
//                    statusIconName = "checkmark.circle.fill"
//                    statusIconColor = .green
//                    await triggerHapticFeedback(.success)
//                case .pendingReview:
//                    statusMessage = "Thank you for applying. Your application requires further review. We'll notify you via email within 3-5 business days."
//                    statusIconName = "doc.text.magnifyingglass" // More specific icon
//                    statusIconColor = .orange
//                    await triggerHapticFeedback(.warning)
//                case .denied:
//                    statusMessage = "We appreciate your interest, but we were unable to approve your application at this time. A letter with more details will be sent to your address on file."
//                    statusIconName = "xmark.octagon.fill"
//                    statusIconColor = .red
//                    await triggerHapticFeedback(.error)
//                case .processing, .error:
//                     // Should be handled by initial state or catch block
//                     break
//                }
//
//            } catch {
//                print("Error fetching application status: \(error.localizedDescription)")
//                applicationStatus = .error
//                errorMessage = "We couldn't retrieve your application status at this moment. Please try again later."
//                statusMessage = errorMessage!
//                statusIconName = "exclamationmark.triangle.fill"
//                statusIconColor = .red
//                await triggerHapticFeedback(.error)
//            }
//
//            isLoading = false // Stop loading indicator
//        }
//    }
//
//     // --- Haptic Feedback Helper ---
//     @MainActor
//     private func triggerHapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) async {
//         UINotificationFeedbackGenerator().notificationOccurred(type)
//     }
//}
//
//// --- Subviews for Conditional Content ---
//
//struct ApprovedContentView: View {
//    var body: some View {
//        VStack(spacing: 15) {
//            Text("Your card will arrive in 7-10 business days.")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//
//            // Simulate a link/button to temporary details or management (often not immediate)
//             Button {
//                 print("Navigate to card management/details (Simulated)")
//             } label: {
//                 Label("View Card Details (Simulated)", systemImage: "creditcard.fill")
//             }
//             .buttonStyle(.bordered)
//             .tint(Color.rhGold) // Use accent color
//        }
//        .padding(.horizontal)
//    }
//}
//#Preview("ApprovedContentView") {
//    ApprovedContentView()
//}
//
//struct PendingReviewContentView: View {
//    var body: some View {
//        VStack(spacing: 15) {
//             Text("Keep an eye on your email for updates.")
//                 .font(.subheadline)
//                 .foregroundColor(.secondary)
//
//             Button {
//                 print("Open help center or contact support (Simulated)")
//             } label: {
//                 Label("Contact Support", systemImage: "phone.fill")
//             }
//             .buttonStyle(.bordered)
//             .tint(.gray)
//        }
//        .padding(.horizontal)
//    }
//}
//#Preview("PendingReviewContentView") {
//    PendingReviewContentView()
//}
//
//struct DeniedContentView: View {
//    var body: some View {
//        VStack(spacing: 15) {
//             Text("Common reasons for denial include credit history or income verification issues. You will receive specific reasons by mail.")
//                 .font(.caption) // Smaller text for detailed info
//                 .foregroundColor(.secondary)
//
//             Button {
//                  print("Link to credit report info or help center (Simulated)")
//             } label: {
//                  Label("Learn More (Simulated)", systemImage: "questionmark.circle")
//             }
//             .buttonStyle(.bordered)
//             .tint(.gray)
//        }
//        .padding(.horizontal)
//    }
//}
//#Preview("DeniedContentView") {
//    DeniedContentView()
//}
//
//struct ErrorContentView: View {
//    let errorMessage: String
//    let retryAction: () -> Void // Closure to retry fetching
//
//    var body: some View {
//        VStack(spacing: 15) {
//            Text(errorMessage) // Display the specific error
//                .font(.subheadline)
//                .foregroundColor(.red)
//                .multilineTextAlignment(.center)
//
//             Button {
//                 print("Retrying status fetch...")
//                 retryAction() // Call the retry closure
//             } label: {
//                 Label("Retry", systemImage: "arrow.clockwise")
//             }
//             .buttonStyle(.bordered)
//             .tint(.red) // Use red for error retry
//        }
//        .padding(.horizontal)
//    }
//}
//#Preview("ErrorContentView"){
//    ErrorContentView(errorMessage: "Error message here", retryAction: {
//        print( "Retry action triggered.")
//        
//    })
//}
//// --- Previews ---
////struct ApplicationStatusView_Previews: PreviewProvider {
////    static var previews: some View {
////        Group {
////            // Preview specific states
////            ApplicationStatusView(applicationStatus: .approved, isLoading: false)
////                .previewDisplayName("Approved State")
////
////            ApplicationStatusView(applicationStatus: .pendingReview, isLoading: false)
////                .previewDisplayName("Pending State")
////
////            ApplicationStatusView(applicationStatus: .denied, isLoading: false)
////                .previewDisplayName("Denied State")
////
////            ApplicationStatusView(applicationStatus: .error, isLoading: false, errorMessage: "Network connection lost.")
////                .previewDisplayName("Error State")
////
////            ApplicationStatusView(applicationStatus: .processing, isLoading: true)
////                .previewDisplayName("Loading State")
////        }
////        // Add theme colors if needed for preview consistency
////         .environment(\.colorScheme, .light) // Example: Force light mode
////         .background(Color.rhBeige.ignoresSafeArea())
////    }
////}
//
//#Preview("ApplicationStatusView"){
//    ApplicationStatusView()
//}
//
//// --- Re-add Color Extension if needed in this file ---
//// (Assuming it's defined elsewhere or add it here)
// extension Color {
//     static let rhBlack = Color(red: 0.05, green: 0.05, blue: 0.05)
//     static let rhGold = Color(red: 0.8, green: 0.65, blue: 0.3)
//     static let rhBeige = Color(red: 0.96, green: 0.94, blue: 0.91)
//     static let rhButtonDark = Color(red: 0.15, green: 0.15, blue: 0.1)
//     static let rhButtonTextGold = Color(red: 0.9, green: 0.8, blue: 0.5)
//     // ... other colors if used ...
// }
