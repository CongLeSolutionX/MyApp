////
////  CouponCardView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/21/25.
////
//
//import SwiftUI // Needed for Color
//
//struct Coupon: Identifiable {
//    let id = UUID()
//    var companyName: String
//    var offerDescription: String
//    var expiryDate: Date
//    var applicableItems: [String] = ["tshirt.fill", "figure.stand", "jacket.fill"] // Default items Icons
//    var companyIconName: String = "tag.fill"       // Default icon
//    var footerIconLeft: String = "square.fill"     // Default icon
//    var footerIconRight: String = "wave.3.right" // Default icon
//    var primaryColorHex: String = "194F30" // Dark Green (Hex without #)
//    var secondaryColorHex: String = "F3DD51" // Yellow (Hex without #)
//    var isUsed: Bool = false // Track usage status
//
//    // Computed properties to get actual Colors
//    var primaryColor: Color {
//        Color(hex: primaryColorHex) ?? .green // Fallback color
//    }
//    var secondaryColor: Color {
//        Color(hex: secondaryColorHex) ?? .yellow // Fallback color
//    }
//
//    // Formatted expiry date string
//    var formattedExpiryDate: String {
//         // More robust date formatting
//        let formatter = DateFormatter()
//        formatter.dateStyle = .long
//        formatter.timeStyle = .none
//        return formatter.string(from: expiryDate)
//
//        // Alternative modern Swift formatting:
//        // expiryDate.formatted(date: .long, time: .omitted)
//    }
//}
//
//// --- Helper for Color from Hex String ---
//extension Color {
//    init?(hex: String) {
//        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
//
//        var rgb: UInt64 = 0
//
//        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
//            return nil
//        }
//
//        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
//        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
//        let blue = Double(rgb & 0x0000FF) / 255.0
//
//        self.init(red: red, green: green, blue: blue)
//    }
//}
//
//import SwiftUI
//
//// Use the App Background color defined earlier or a system default
//// extension Color { static let appBackground = Color(.systemGray6) }
//
//struct CouponView: View {
//    // Pass the specific coupon data into this view
//    let coupon: Coupon
//
//    @State private var showActionSheet = false
//    @State private var showNFCSimulationAlert = false
//    @State private var nfcSimulationMessage = ""
//    @State private var isCouponMarkedUsed = false // Local state to reflect usage
//
//    @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // Use a standard background
//                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
//
//                VStack(spacing: 30) {
//                    Spacer()
//
//                    // Pass coupon data down to the card view
//                    CouponCard(coupon: coupon)
//                        .padding(.horizontal) // Give card some breathing room
//
//                    // Make the prompt area tappable for simulation
//                    HoldNearReaderPrompt(isUsed: isCouponMarkedUsed || coupon.isUsed)
//                        .onTapGesture {
//                            simulateNFCInteraction()
//                        }
//                        .accessibilityElement(children: .combine) // Combine icon and text for accessibility
//                        .accessibilityHint("Tap to simulate holding near an NFC reader")
//
//                    Spacer()
//                }
//                .padding(.bottom) // Add padding at the bottom
//            }
//            .navigationBarTitleDisplayMode(.inline) // Keep title area compact
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Done") {
//                        dismiss()
//                    }
//                    .accessibilityLabel("Dismiss Coupon View")
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        showActionSheet = true
//                    } label: {
//                        Image(systemName: "ellipsis.circle")
//                            .accessibilityLabel("More Options")
//                    }
//                }
//            }
//            // --- Action Sheet for Ellipsis Menu ---
//            .actionSheet(isPresented: $showActionSheet) {
//                ActionSheet(
//                    title: Text("Coupon Options"),
//                    message: Text("What would you like to do with this coupon?"),
//                    buttons: [
//                        .default(Text("Share Coupon")) { handleShare() },
//                        .default(Text("View Store Details")) { handleViewDetails() },
//                        .destructive(Text("Remove Coupon")) { handleRemove() },
//                        .cancel()
//                    ]
//                )
//            }
//            // --- Alert for NFC Simulation ---
//            .alert("NFC Interaction", isPresented: $showNFCSimulationAlert) {
//                Button("OK", role: .cancel) { } // Simple dismiss button
//            } message: {
//                Text(nfcSimulationMessage)
//            }
//        }
//        // Use accent color for interactive elements if needed
//        // .accentColor(coupon.primaryColor)
//    }
//
//    // --- Action Handlers ---
//    func simulateNFCInteraction() {
//        guard !isCouponMarkedUsed && !coupon.isUsed else {
//            nfcSimulationMessage = "This coupon has already been used."
//            showNFCSimulationAlert = true
//            return
//        }
//
//        // Simulate success/failure randomly or based on logic
//        if Bool.random() {
//            nfcSimulationMessage = "Coupon successfully applied! 15% discount added."
//            isCouponMarkedUsed = true // Mark as used in local state for immediate feedback
//            // In a real app: Send confirmation to backend, update data model permanently
//        } else {
//            nfcSimulationMessage = "Could not connect to the reader. Please try again."
//        }
//        showNFCSimulationAlert = true
//    }
//
//    func handleShare() {
//        print("Share action triggered")
//        // Integrate with UIActivityViewController or ShareLink
//    }
//
//    func handleViewDetails() {
//        print("View Details action triggered")
//        // Navigate to a store details screen
//    }
//
//    func handleRemove() {
//        print("Remove action triggered")
//        // Add confirmation alert?
//        // Call a function to remove the coupon from data source
//        dismiss() // Dismiss after removal
//    }
//}
//
//// --- Subview for the Coupon Card (Now accepts Coupon data) ---
//struct CouponCard: View {
//    let coupon: Coupon
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            // --- Top Section: Company Info ---
//            CouponHeader(
//                companyName: coupon.companyName,
//                iconName: coupon.companyIconName,
//                color: coupon.secondaryColor
//            )
//            .padding([.top, .horizontal])
//            .padding(.bottom, 10)
//
//            // --- Middle Section: Item Display ---
//            ItemDisplaySection(
//                itemIcons: coupon.applicableItems,
//                color: coupon.secondaryColor
//            )
//            .padding(.horizontal)
//            .padding(.bottom)
//
//            // --- Bottom Section: Offer & Expiry Details ---
//            OfferDetailsSection(
//                offer: coupon.offerDescription,
//                expiryDateString: coupon.formattedExpiryDate, // Use formatted string
//                color: coupon.secondaryColor
//            )
//            .padding(.horizontal)
//
//            // --- Footer Section: Icons ---
//            CouponFooter(
//                iconLeft: coupon.footerIconLeft,
//                iconRight: coupon.footerIconRight,
//                color: coupon.secondaryColor
//            )
//            .padding([.bottom, .horizontal])
//            .padding(.top, 10)
//        }
//        .background(coupon.primaryColor) // Use color from data
//        .cornerRadius(15)
//        .shadow(radius: 5) // Add a subtle shadow for depth
//        // Add accessibility information for the entire card
//        .accessibilityElement(children: .ignore) // Ignore children for combined label
//        .accessibilityLabel("Coupon for \(coupon.companyName). Offer: \(coupon.offerDescription). Expires \(coupon.formattedExpiryDate).")
//
//    }
//}
//
//// --- Header Subview ---
//struct CouponHeader: View {
//    let companyName: String
//    let iconName: String
//    let color: Color
//
//    var body: some View {
//        HStack {
//            Image(systemName: iconName)
//                .accessibilityHidden(true) // Hide decorative icon from accessibility
//            Text(companyName)
//                .font(.headline)
//                .fontWeight(.medium)
//        }
//        .foregroundColor(color)
//    }
//}
//
//// --- Updated Item Display Subview ---
//struct ItemDisplaySection: View {
//    let itemIcons: [String]
//    let color: Color
//
//    var body: some View {
//        HStack(spacing: 15) {
//            Spacer()
//            ForEach(itemIcons.indices, id: \.self) { index in
//                Image(systemName: itemIcons[index])
//                     .accessibilityLabel("Item \(index + 1)") // Basic accessibility
//                if index < itemIcons.count - 1 {
//                    Text("•").font(.caption).foregroundColor(color.opacity(0.7))
//                }
//            }
//            Spacer()
//        }
//        .font(.largeTitle)
//        .foregroundColor(color)
//        .padding(.vertical, 25)
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(color, lineWidth: 2)
//        )
//        .accessibilityElement(children: .combine) // Combine items for accessibility
//        .accessibilityLabel("Applicable items: \(itemIcons.count) item types shown.")
//    }
//}
//
//// --- Updated Offer Details Subview ---
//struct OfferDetailsSection: View {
//    let offer: String
//    let expiryDateString: String // Now receives formatted string
//    let color: Color
//
//    var body: some View {
//        HStack(alignment: .top) {
//            VStack(alignment: .leading) {
//                Text("OFFER")
//                    .font(.caption)
//                    .opacity(0.8)
//                    .accessibilityLabel("Offer Description")
//                Text(offer)
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .accessibilityValue(offer) // Provides value to accessibility
//            }
//            .accessibilityElement(children: .combine) // Group Offer details
//
//            Spacer()
//
//            VStack(alignment: .leading) {
//                Text("EXPIRES")
//                    .font(.caption)
//                    .opacity(0.8)
//                     .accessibilityLabel("Expiration Date")
//                Text(expiryDateString)
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .accessibilityValue(expiryDateString) // Provides value
//            }
//            .accessibilityElement(children: .combine) // Group Expiry details
//        }
//        .foregroundColor(color)
//    }
//}
//
//// --- Updated Footer Subview ---
//struct CouponFooter: View {
//     let iconLeft: String
//     let iconRight: String
//     let color: Color
//
//     var body: some View {
//         HStack {
//             Image(systemName: iconLeft)
//                 .font(.title3)
//                 .accessibilityHidden(true) // Likely decorative
//             Spacer()
//             Image(systemName: iconRight) // NFC/Wireless symbol
//                 .font(.title)
//                 .accessibilityLabel("NFC Payment Available")
//                 .accessibilityHint("This coupon can be used with NFC readers.")
//         }
//         .foregroundColor(color)
//     }
//}
//
//// --- Updated "Hold Near Reader" Prompt ---
//struct HoldNearReaderPrompt: View {
//    let isUsed: Bool // Pass usage status
//
//    var body: some View {
//        VStack {
//            Image(systemName: isUsed ? "checkmark.circle.fill" : "sensor.tag.radiowaves.forward.fill") // Change icon if used
//                 .font(.system(size: 60))
//                 .foregroundColor(isUsed ? .green : .blue) // Change color if used
//                 .padding(.bottom, 5)
//                 .accessibilityHidden(true) // Text describes the action
//
//            Text(isUsed ? "Coupon Used" : "Hold Near Reader")
//                .font(.callout)
//                .foregroundColor(.secondary) // Use secondary text color for better adaptation
//                .fontWeight(isUsed ? .semibold : .regular)
//        }
//        .opacity(isUsed ? 0.7 : 1.0) // Dim if used
//    }
//}
//
//// --- Preview Provider with Mock Data ---
//#Preview {
//    // Create mock data for the preview
//    let mockCoupon = Coupon(
//        companyName: "CongLeSolutionX Goods Co.",
//        offerDescription: "105% OFF",
//        expiryDate: Calendar.current.date(byAdding: .day, value: 60, to: Date()) ?? Date() // Expires in 60 days
//        // Other properties use defaults from the struct definition
//    )
//
//    // Embed in a TabView or similar if needed to show Navigation Bar correctly
//    // For simplicity, previewing CouponView directly.
//    CouponView(coupon: mockCoupon)
//}
