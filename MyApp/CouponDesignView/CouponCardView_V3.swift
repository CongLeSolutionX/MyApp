//
//  CouponCardView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

import SwiftUI
import Combine // Needed for ObservableObject later if we used a ViewModel

struct Coupon: Identifiable {
    let id = UUID()
    var companyName: String
    var offerDescription: String
    var expiryDate: Date
    var applicableItems: [String] = ["tshirt.fill", "figure.stand", "jacket.fill"] // Sample Icons
    var allApplicableItemsDescription: String = "Applicable on all regular priced T-shirts, figurines, and jackets." // For detail view
    var companyIconName: String = "tag.fill"
    var footerIconLeft: String = "barcode.viewfinder" // Changed for more relevance?
    var footerIconRight: String = "wave.3.right.circle.fill" // Slightly fancier NFC icon
    var primaryColorHex: String = "194F30" // Dark Green
    var secondaryColorHex: String = "F3DD51" // Yellow
    var isUsed: Bool = false
    var termsAndConditions: String = "Offer valid for in-store purchases only. Cannot be combined with other offers. Limit one per customer. Expires on the date shown. Management reserves all rights."
    var storeID: String? = "store_123" // Optional ID for linking to store details

    // Computed properties remain the same
    var primaryColor: Color { Color(hex: primaryColorHex) ?? .green }
    var secondaryColor: Color { Color(hex: secondaryColorHex) ?? .yellow }
    var formattedExpiryDate: String {
        expiryDate.formatted(date: .long, time: .omitted)
    }
}

// --- Color Hex Extension (remains the same) ---
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

import SwiftUI

// --- Haptic Feedback Generator ---
class HapticManager {
    static let shared = HapticManager() // Singleton
    private init() {}

    func trigger(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

struct CouponView: View {
    // Use @State for coupon data passed in if we need to modify it locally
    // If modifications should persist upstream, use @Binding
    @State var coupon: Coupon // Use @State to allow marking as used

    // State for modals and alerts
    @State private var showActionSheet = false
    @State private var showNFCSimulationAlert = false
    @State private var nfcSimulationMessage = ""
    @State private var showTermsAlert = false
    @State private var showApplicableItemsAlert = false
    @State private var showReportIssueAlert = false

    @Environment(\.dismiss) var dismiss

    // --- Computed Property for Action Sheet Buttons ---
    private var actionSheetButtons: [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []

        if !coupon.isUsed {
            buttons.append(.default(Text("Mark as Used")) { handleMarkAsUsed() })
        }
        buttons.append(.default(Text("View Terms & Conditions")) {
             HapticManager.shared.impact(.light)
             showTermsAlert = true
        })
        buttons.append(.default(Text("Share Coupon")) { handleShare() })
        if coupon.storeID != nil { // Only show if store ID exists
            buttons.append(.default(Text("View Store Details")) { handleViewDetails() })
        }
        buttons.append(.destructive(Text("Report Issue")) { handleReportIssue() })
        buttons.append(.destructive(Text("Remove Coupon")) { handleRemove() })
        buttons.append(.cancel())

        return buttons
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    CouponCard(coupon: $coupon) // Pass binding if Card needs to modify
                        .onTapGesture {
                            // Quick tap action: Show Terms & Conditions
                            HapticManager.shared.impact(.light)
                            showTermsAlert = true
                        }
                        .accessibilityAction(named: "View Terms") { // Custom accessibility action
                             showTermsAlert = true
                        }
                        // Separate tap gesture for item section handled within CouponCard itself
                        .padding(.horizontal)

                    HoldNearReaderPrompt(isUsed: coupon.isUsed)
                        .onTapGesture {
                            simulateNFCInteraction()
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityHint("Tap to simulate using the coupon with an NFC reader.")
                        .accessibilityAction(named: "Simulate NFC Use") { // Custom action
                            simulateNFCInteraction()
                        }

                    Spacer()
                }
                .padding(.bottom)
            }
            .navigationTitle(coupon.companyName) // Set title dynamically
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        HapticManager.shared.impact(.light)
                        dismiss()
                    }
                    .accessibilityLabel("Dismiss Coupon View")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.shared.impact(.medium)
                        showActionSheet = true
                    } label: {
                        Image(systemName: "ellipsis.circle.fill") // Filled icon looks more actionable
                            .imageScale(.large)
                            .accessibilityLabel("More Options")
                    }
                }
            }
            // --- Action Sheet ---
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Coupon Options"),
                    message: Text("Manage this coupon for \(coupon.companyName)."),
                    buttons: actionSheetButtons // Use computed property
                )
            }
            // --- Alerts ---
            .alert("NFC Interaction", isPresented: $showNFCSimulationAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: { Text(nfcSimulationMessage) })

            .alert("Terms & Conditions", isPresented: $showTermsAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: { Text(coupon.termsAndConditions) })

             .alert("Applicable Items", isPresented: $showApplicableItemsAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: { Text(coupon.allApplicableItemsDescription) })

            .alert("Report Issue", isPresented: $showReportIssueAlert, actions: {
                 Button("Submit Report", role: .destructive) { /* Send report */ print("Issue Reported") }
                 Button("Cancel", role: .cancel) { }
             }, message: { Text("Please briefly describe the issue you encountered with this coupon.") })
        }
        // .accentColor(coupon.primaryColor) // Can uncomment if needed
    }

    // --- Action Handlers ---
    func simulateNFCInteraction() {
        guard !coupon.isUsed else {
            nfcSimulationMessage = "This coupon has already been used."
            HapticManager.shared.trigger(.warning)
            showNFCSimulationAlert = true
            return
        }

        // Simulate success/failure randomly
        let success = Bool.random()
        if success {
            nfcSimulationMessage = "Coupon applied! \(coupon.offerDescription) discount added."
            coupon.isUsed = true // Update the state directly
            HapticManager.shared.trigger(.success)
            // In a real app: API call, update persistent storage
        } else {
            nfcSimulationMessage = "Failed to connect. Please try again or show barcode."
            HapticManager.shared.trigger(.error)
        }
        showNFCSimulationAlert = true
    }

    func handleMarkAsUsed() {
        print("Mark as Used action triggered")
        HapticManager.shared.impact(.medium)
        coupon.isUsed = true
        // Add confirmation? API call?
    }

    func handleShare() {
        print("Share action triggered")
        HapticManager.shared.impact(.light)
        // Integrate with UIActivityViewController or ShareLink
        // Example using ShareLink (iOS 16+) - Basic Implementation
        guard let url = URL(string: "https://example.com/coupon/\(coupon.id)") else { return }
        let activityVC = UIActivityViewController(activityItems: ["Check out this coupon!", url], applicationActivities: nil)
        // Get the current scene and present the VC
         guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController else {
             print("Could not find root view controller to present share sheet.")
             return
         }
        rootVC.present(activityVC, animated: true, completion: nil)

    }

    func handleViewDetails() {
        print("View Details action triggered for store ID: \(coupon.storeID ?? "N/A")")
        HapticManager.shared.impact(.light)
        // Navigate to a store details screen passing coupon.storeID
    }

     func handleReportIssue() {
        print("Report Issue action triggered")
        HapticManager.shared.trigger(.warning)
        showReportIssueAlert = true
        // Implemented via alert for now
    }

    func handleRemove() {
        print("Remove action triggered")
        HapticManager.shared.trigger(.warning) // Use warning for destructive actions
        // Add confirmation alert highly recommended here!
        // Call a function to remove the coupon from data source
        dismiss() // Dismiss after removal
    }
}

// --- Subview for the Coupon Card (Accepts Binding to allow modification) ---
struct CouponCard: View {
    @Binding var coupon: Coupon
    @State private var showItemsAlertFromTap = false // State specific to this view

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CouponHeader(
                companyName: coupon.companyName,
                iconName: coupon.companyIconName,
                color: coupon.secondaryColor
            )
            .padding([.top, .leading, .trailing])
            .padding(.bottom, 10)

            ItemDisplaySection(
                itemIcons: coupon.applicableItems,
                color: coupon.secondaryColor
            )
            .padding(.horizontal)
            .padding(.bottom)
            .contentShape(Rectangle()) // Make the whole area tappable
            .onTapGesture {
                HapticManager.shared.impact(.light)
                showItemsAlertFromTap = true // Trigger alert specific to this tap
            }
            .accessibilityHint("Tap to view all applicable items.")
            .accessibilityAction(named: "View Applicable Items") {
                 showItemsAlertFromTap = true
            }

            OfferDetailsSection(
                offer: coupon.offerDescription,
                expiryDateString: coupon.formattedExpiryDate,
                color: coupon.secondaryColor
            )
            .padding(.horizontal)

            CouponFooter(
                iconLeft: coupon.footerIconLeft,
                iconRight: coupon.footerIconRight,
                color: coupon.secondaryColor,
                isUsed: coupon.isUsed // Pass usage status for potential footer changes
            )
            .padding([.bottom, .horizontal])
            .padding(.top, 10)
        }
        .background(coupon.primaryColor)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3) // Enhanced shadow
        .overlay( // Add a subtle overlay if used
            //coupon.isUsed ? Color.black.opacity(0.4).cornerRadius(15) : Color.clear
            coupon.isUsed ? Color.black.opacity(0.4) : Color.clear
        )
        .animation(.easeInOut, value: coupon.isUsed) // Animate the overlay
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Coupon for \(coupon.companyName). \(coupon.offerDescription). Expires \(coupon.formattedExpiryDate). \(coupon.isUsed ? "Status: Used." : "Status: Available.")")
        // Alert specific to tapping the ItemDisplaySection
        .alert("Applicable Items", isPresented: $showItemsAlertFromTap, actions: {
            Button("OK", role: .cancel) { }
        }, message: { Text(coupon.allApplicableItemsDescription) })
    }
}

// --- Subviews (Header, ItemDisplay, OfferDetails - Mostly unchanged visually) ---
// Assume CouponHeader, OfferDetailsSection remain largely the same as before visually
// Add minor updates for accessibility or data handling if needed.

// --- Header Subview (Accessibility focus) ---
struct CouponHeader: View {
    let companyName: String
    let iconName: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.title3) // Slightly larger icon
                .accessibilityHidden(true) // Decorative if name is present
            Text(companyName)
                .font(.headline)
                .fontWeight(.semibold) // Slightly bolder
        }
        .foregroundColor(color)
        .accessibilityElement(children: .combine) // Combine for screen reader
        .accessibilityLabel("\(companyName) Coupon")
    }
}

// --- Item Display Subview (Accessibility) ---
struct ItemDisplaySection: View {
    let itemIcons: [String]
    let color: Color

    var body: some View {
        HStack(spacing: 15) {
            Spacer()
            ForEach(itemIcons.indices, id: \.self) { index in
                Image(systemName: itemIcons[index])
                     .accessibilityLabel("Icon for applicable item type \(index + 1)") // More specific
                if index < itemIcons.count - 1 {
                     Text("•").font(.caption).foregroundColor(color.opacity(0.7))
                 }
            }
            Spacer()
        }
        .font(.largeTitle)
        .foregroundColor(color)
        .padding(.vertical, 25)
        .background( // Add subtle inner background
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.6), lineWidth: 2) // Slightly muted stroke
        )
        // Accessibility handled by the parent CouponCard tap gesture now
    }
}

// --- Offer Details (Accessibility) ---
struct OfferDetailsSection: View {
    let offer: String
    let expiryDateString: String
    let color: Color

    var body: some View {
        HStack(alignment: .lastTextBaseline) { // Align text better
            VStack(alignment: .leading) {
                Text("OFFER")
                    .font(.caption)
                    .foregroundColor(color.opacity(0.8))
                    .accessibilityLabel("Offer details:") // Label for the group
                Text(offer)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8) // Allow text to shrink slightly
                    .accessibilityValue(offer)
            }
            .accessibilityElement(children: .combine)

            Spacer()

            VStack(alignment: .trailing) { // Align expiry to the right
                Text("EXPIRES")
                    .font(.caption)
                    .foregroundColor(color.opacity(0.8))
                    .accessibilityLabel("Expiration date:")
                Text(expiryDateString)
                    .font(.subheadline) // Slightly smaller expiry
                    .fontWeight(.medium)
                    .accessibilityValue(expiryDateString)
            }
             .accessibilityElement(children: .combine)
        }
        .foregroundColor(color)
    }
}

// --- Footer Subview (Potentially dynamic based on state) ---
struct CouponFooter: View {
     let iconLeft: String
     let iconRight: String
     let color: Color
     let isUsed: Bool

     var body: some View {
         HStack {
             Image(systemName: iconLeft) // e.g., barcode icon
                 .font(.title3)
                 .foregroundColor(color.opacity(isUsed ? 0.5 : 1.0)) // Dim if used
                 .accessibilityLabel("Barcode symbol")
                 .accessibilityHint(isUsed ? "Coupon used" : "Show barcode to cashier if needed.")
             Spacer()
             Image(systemName: iconRight) // NFC icon
                 .font(.title)
                 .foregroundColor(color.opacity(isUsed ? 0.5 : 1.0)) // Dim if used
                 .accessibilityLabel("NFC Payment Available")
                 .accessibilityHint(isUsed ? "Coupon used" : "Usable with NFC readers.")
         }
         .foregroundColor(color)
     }
}

// --- "Hold Near Reader" Prompt (Unchanged functionally) ---
struct HoldNearReaderPrompt: View {
    let isUsed: Bool

    var body: some View {
        VStack {
             Image(systemName: isUsed ? "checkmark.circle.fill" : "sensor.tag.radiowaves.forward.fill")
                 .font(.system(size: 60))
                 .foregroundColor(isUsed ? .green : .accentColor) // Use accent color for active state
                 .padding(.bottom, 5)
                 .symbolEffect(.pulse, options: isUsed ? .default : .repeating, isActive: !isUsed) // Pulse effect when active
                 .animation(.easeInOut, value: isUsed) // Animate icon change
                 .accessibilityHidden(true)

            Text(isUsed ? "Coupon Used" : "Hold Near Reader")
                .font(.callout)
                .foregroundColor(.secondary)
                .fontWeight(isUsed ? .semibold : .regular)
        }
        .opacity(isUsed ? 0.6 : 1.0) // Dim further if used
    }
}

// --- Preview Provider ---
#Preview {
    // Create more detailed mock data
    let mockCoupon = Coupon(
        companyName: "Uniform Goods Co.",
        offerDescription: "15% OFF",
        expiryDate: Calendar.current.date(byAdding: .month, value: 2, to: Date())!, // Expires in 2 months
        applicableItems: ["tshirt.fill", "figure.stand", "jacket.fill", "bag.fill"], // Added one more item
        allApplicableItemsDescription: "Applicable on all regular priced T-shirts, figurines, jackets, and bags. Excludes clearance items.",
        companyIconName: "hanger", // More relevant icon
        footerIconLeft: "barcode.viewfinder",
        footerIconRight: "wave.3.right.circle.fill",
        primaryColorHex: "4A90E2", // Blue
        secondaryColorHex: "F8E71C", // Yellow
        isUsed: false,
        termsAndConditions: "Limited time offer. Valid only at participating Uniform Goods Co. locations. Cannot be combined with employee discount. Show coupon at checkout or use via NFC. Full terms at uniformgoods.com/coupon-terms.",
        storeID: "ugc_sf_001"
    )

    // Present within a TabView or similar to ensure Nav Bar is fully rendered
    return TabView {
        CouponView(coupon: mockCoupon)
            .tabItem { Label("Coupon", systemImage: "tag") }
    }
}
