//
//  SubscriptionOverviewView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI
import MusicKit // Make sure MusicKit is imported

// MARK: - Data Models and State Management

/// Observable object to manage subscription status and updates.
@MainActor // Ensure UI updates happen on the main thread
class SubscriptionViewModel: ObservableObject {
    @Published var subscription: MusicSubscription?
    @Published var error: Error?
    @Published var isLoading: Bool = false

    init() {
        // Initial check when the view model is created
        Task {
            await checkSubscriptionStatus()
            await observeSubscriptionUpdates()
        }
    }

    /// Fetches the current subscription status.
    func checkSubscriptionStatus() async {
        isLoading = true
        defer { isLoading = false } // Ensure isLoading is set to false when done
        do {
            let currentSubscription = try await MusicSubscription.current
            self.subscription = currentSubscription
            self.error = nil
            print("Subscription Status:")
            print("- Can Play Catalog: \(currentSubscription.canPlayCatalogContent)")
            print("- Can Become Subscriber: \(currentSubscription.canBecomeSubscriber)")
            print("- Has Cloud Library Enabled: \(currentSubscription.hasCloudLibraryEnabled)")
        } catch let fetchError {
            self.error = fetchError
            self.subscription = nil // Clear previous status on error
            print("Error checking subscription status: \(fetchError.localizedDescription)")
            if let subError = fetchError as? MusicSubscription.Error {
                 print("MusicSubscription.Error code: \(subError.rawValue)")
            }
        }
    }

    /// Observes ongoing changes to the subscription status.
    func observeSubscriptionUpdates() async {
        print("Observing subscription updates...")
        // Using .task structure handles cancellation automatically
        // Note: This part would ideally run continuously within a view's lifecycle
        // using .task modifier for robustness. Here, it's initiated once.
        // For continuous observation in a real app, attach this to a view's .task.
//        do {
            for await updatedSubscription in MusicSubscription.subscriptionUpdates {
                // Ensure updates are published on the main thread
                await MainActor.run {
                    print("Subscription updated:")
                    print("- Can Play Catalog: \(updatedSubscription.canPlayCatalogContent)")
                    print("- Can Become Subscriber: \(updatedSubscription.canBecomeSubscriber)")
                    print("- Has Cloud Library Enabled: \(updatedSubscription.hasCloudLibraryEnabled)")
                    self.subscription = updatedSubscription
                    self.error = nil // Clear any previous errors on successful update
                }
            }
//        } catch {
//            await MainActor.run {
//                self.error = error
//                 print("Error observing subscription updates: \(error.localizedDescription)")
//                 if let subError = error as? MusicSubscription.Error {
//                     print("MusicSubscription.Error code: \(subError.rawValue)")
//                 }
//            }
//        }
    }

    /// Formats error messages for display.
    var formattedError: String? {
        guard let error = error else { return nil }

        if let subError = error as? MusicSubscription.Error {
            switch subError {
            case .unknown:
                return "An unknown subscription error occurred."
            case .permissionDenied:
                return "Permission denied. Please grant access to Apple Music in Settings."
            case .privacyAcknowledgementRequired:
                return "Please acknowledge the Apple Music privacy policy."
            @unknown default:
                 return "An unexpected subscription error occurred (\(subError.rawValue))."
            }
        } else {
            return "Error: \(error.localizedDescription)"
        }
    }
}

// MARK: - SwiftUI Views

/// Displays the current Apple Music subscription status.
struct SubscriptionStatusView: View {
    @ObservedObject var viewModel: SubscriptionViewModel

    var body: some View {
        GroupBox("Subscription Status") {
            VStack(alignment: .leading, spacing: 8) {
                if viewModel.isLoading {
                    ProgressView("Loading Status...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let errorMsg = viewModel.formattedError {
                    Text("Error: \(errorMsg)")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                         // Add a button to retry fetching status
                         Button("Retry Status Check") {
                             Task {
                                 await viewModel.checkSubscriptionStatus()
                             }
                         }
                         .buttonStyle(.bordered)
                         .padding(.top, 5)

                } else if let sub = viewModel.subscription {
                    StatusRow(label: "Can Play Catalog Content", value: sub.canPlayCatalogContent)
                    StatusRow(label: "Can Become Subscriber", value: sub.canBecomeSubscriber)
                    StatusRow(label: "Cloud Library Enabled", value: sub.hasCloudLibraryEnabled)
                    Divider()
                    Text("Status last updated: \(Date(), style: .time)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                     // Add a button to manually refresh status
                     Button("Refresh Status") {
                         Task {
                             await viewModel.checkSubscriptionStatus()
                         }
                     }
                     .buttonStyle(.bordered)
                     .padding(.top, 5)

                } else {
                    Text("Subscription status not available.")
                        .foregroundColor(.secondary)
                         // Add a button to retry fetching status if initially unavailable
                         Button("Check Status") {
                             Task {
                                 await viewModel.checkSubscriptionStatus()
                             }
                         }
                         .buttonStyle(.bordered)
                         .padding(.top, 5)
                }
            }
            .padding(.vertical, 5) // Add padding inside the GroupBox
        }
        // Attach the observation task here for continuous updates within this view's lifecycle
        .task {
            await viewModel.observeSubscriptionUpdates()
        }
    }
}

/// Helper view for displaying a label and a boolean status icon.
struct StatusRow: View {
    let label: String
    let value: Bool

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Image(systemName: value ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(value ? .green : .red)
        }
    }
}

/// Demonstrates triggering the Music Subscription Offer sheet.
struct SubscriptionOfferView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var isShowingOffer = false

    // Explicitly specify the type from the MusicKit framework
    let exampleItemID: MusicKit.MusicItemID? = MusicKit.MusicItemID("123456789") // Optional

    @State private var offerOptions: MusicSubscriptionOffer.Options = {
        var options = MusicSubscriptionOffer.Options()
        options.messageIdentifier = .playMusic
        // options.affiliateToken = "YOUR_AFFILIATE_TOKEN"
        // options.campaignToken = "YOUR_CAMPAIGN_TOKEN"
        return options
    }()

    var canPresentOffer: Bool {
        viewModel.subscription?.canBecomeSubscriber ?? false
    }

    var body: some View {
        GroupBox("Subscription Offer") {
            VStack(spacing: 15) {
                // ... (rest of the VStack content remains the same) ...

                if viewModel.isLoading {
                     Text("Checking eligibility...") // Keep this part
                        .font(.caption)
                        .foregroundColor(.secondary)
                 } else if canPresentOffer {
                    Text("Present an Apple Music subscription offer sheet.")
                        .font(.callout)
                        .multilineTextAlignment(.center)

                    Button("Show Subscription Offer") {
                        // Now the assignment should work because types match
                        offerOptions.itemID = exampleItemID
                        isShowingOffer = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading)
                } else if viewModel.subscription != nil {
                     Text("User is likely already subscribed or cannot subscribe.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                 } else if viewModel.error != nil {
                     Text("Cannot determine offer eligibility due to an error.")
                         .font(.callout)
                         .foregroundColor(.red)
                         .multilineTextAlignment(.center)
                 }
            }
             .padding(.vertical, 10)
            .musicSubscriptionOffer(
                isPresented: $isShowingOffer,
                options: offerOptions
            ) { error in
                if let error = error {
                    print("Error loading subscription offer: \(error.localizedDescription)")
                } else {
                    print("Subscription offer sheet loaded successfully.")
                }
            }
        }
         .task {
             await viewModel.checkSubscriptionStatus()
         }
         #if !(os(tvOS) || os(watchOS) || os(visionOS)) // Check if offer is supported
         // Offer related modifiers only if supported
         #else
         // Fallback for unsupported platforms
         Group {
             Text("Subscription offers are not available on this platform.")
                 .font(.caption)
                 .foregroundColor(.secondary)
                 .padding()
         }
         #endif
    }
}

// MARK: - Main Content View

struct SubscriptionContentView: View {
    // Use a single ViewModel instance shared between subviews
    @StateObject private var subscriptionViewModel = SubscriptionViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    SubscriptionStatusView(viewModel: subscriptionViewModel)

                    #if os(iOS) || os(macOS) // Only include offer view where available
                    SubscriptionOfferView()
                     #endif

                    Spacer() // Pushes content to the top
                }
                .padding() // Add padding around the main VStack
            }
            .navigationTitle("Music Subscription")
            .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     // Example: Button to manually trigger a background refresh
                     Button {
                          Task {
                              await subscriptionViewModel.checkSubscriptionStatus()
                          }
                     } label: {
                         Label("Refresh", systemImage: "arrow.clockwise")
                     }
                 }
            }
        }
    }
}

// MARK: - Previews

struct SubscriptionContentView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionContentView()
    }
}

// MARK: - Helper Extensions (Optional but good practice)

extension MusicSubscription.Error {
    // Provide more user-friendly descriptions if needed
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return NSLocalizedString("An unknown subscription error occurred.", comment: "MusicSubscription.Error unknown")
        case .permissionDenied:
            return NSLocalizedString("Permission to access Apple Music was denied.", comment: "MusicSubscription.Error permissionDenied")
        case .privacyAcknowledgementRequired:
            return NSLocalizedString("Please acknowledge the Apple Music privacy policy in the Music app.", comment: "MusicSubscription.Error privacyAcknowledgementRequired")
        @unknown default:
            return NSLocalizedString("An unexpected subscription error occurred.", comment: "MusicSubscription.Error default" )
        }
    }

     public var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            #if os(iOS)
            return NSLocalizedString("You can grant access in the Settings app.", comment: "MusicSubscription.Error permissionDenied recovery iOS")
            #elseif os(macOS)
            return NSLocalizedString("You can grant access in System Settings > Privacy & Security.", comment: "MusicSubscription.Error permissionDenied recovery macOS")
            #else
            return nil
            #endif
        case .privacyAcknowledgementRequired:
            return NSLocalizedString("Please open the Music app to continue.", comment: "MusicSubscription.Error privacyAcknowledgementRequired recovery")
        default:
            return nil
        }
    }
}

#if os(iOS) || os(macOS)
// Add extensions for offer types if needed, though they are simple structs/enums
extension MusicSubscriptionOffer.Action {
    public var description: String { rawValue }
}

extension MusicSubscriptionOffer.MessageIdentifier {
     public var description: String { rawValue }
}
#endif
