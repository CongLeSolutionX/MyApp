////
////  CouponCardView_V1.swift
////  MyApp
////
////  Created by Cong Le on 4/21/25.
////
//
//import SwiftUI
//
//// Define custom colors to match the design
//extension Color {
//    static let couponGreen = Color(red: 25 / 255, green: 79 / 255, blue: 48 / 255) // Approximate dark green
//    static let couponYellow = Color(red: 243 / 255, green: 221 / 255, blue: 81 / 255) // Approximate yellow
//    static let appBackground = Color(.systemGray6) // Light gray background
//}
//
//struct CouponView: View {
//    @Environment(\.dismiss) var dismiss // To handle the Done button action
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // Overall background color
//                Color.appBackground.ignoresSafeArea()
//
//                VStack(spacing: 30) {
//                    Spacer() // Push content towards the center vertically
//
//                    // --- Coupon Card ---
//                    CouponCard()
//
//                    // --- Hold Near Reader Prompt ---
//                    HoldNearReaderPrompt()
//
//                    Spacer() // Push content towards the center vertically
//                }
//                .padding(.horizontal) // Add horizontal padding to the main content
//            }
//            .navigationBarTitleDisplayMode(.inline) // Keep title area compact
//            .toolbar {
//                // Navigation Bar Buttons
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Done") {
//                        dismiss() // Action for the Done button
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        // Action for the ellipsis button
//                    } label: {
//                        Image(systemName: "ellipsis.circle")
//                    }
//                }
//            }
//            // Use foreground color for toolbar items if needed, typically defaults correctly
//             .foregroundColor(.primary) // Adjust if default tint isn't right
//        }
//    }
//}
//
//// --- Subview for the Coupon Card ---
//struct CouponCard: View {
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            // --- Top Section: Company Info ---
//            // Comment: Zigzag divider would require a custom Shape or Image here.
//            HStack {
//                Image(systemName: "tag.fill")
//                Text("CongLeSolutionX Goods Co.")
//                    .font(.headline)
//                    .fontWeight(.medium)
//            }
//            .foregroundColor(Color.couponYellow)
//            .padding([.top, .horizontal])
//            .padding(.bottom, 10) // Space before the item display
//
//            // --- Middle Section: Item Display ---
//            ItemDisplaySection()
//                .padding(.horizontal)
//                .padding(.bottom) // Space after item display
//
//            // --- Bottom Section: Offer & Expiry Details ---
//            OfferDetailsSection()
//                 .padding(.horizontal)
//
//            // --- Footer Section: Icons ---
//            CouponFooter()
//                .padding([.bottom, .horizontal])
//                .padding(.top, 10) // Space before footer icons
//        }
//        .background(Color.couponGreen)
//        .cornerRadius(15) // Apply rounded corners to the whole card
//    }
//}
//
//// --- Subview for Item Display within the Coupon ---
//struct ItemDisplaySection: View {
//    var body: some View {
//        HStack(spacing: 15) {
//            Spacer()
//            Image(systemName: "tshirt.fill") // Placeholder for shirt
//            Text("•").font(.caption)
//            Image(systemName: "figure.stand") // Placeholder for pants
//            Text("•").font(.caption)
//            Image(systemName: "jacket.fill") // Placeholder for jacket (use 'hanger' if not available)
//                 .symbolRenderingMode(.hierarchical) // Example rendering mode variation
//            Spacer()
//        }
//        .font(.largeTitle) // Adjust size as needed
//        .foregroundColor(Color.couponYellow)
//        .padding(.vertical, 25)
//        // Comment: Notched corners require a custom Shape for the border/background.
//        // Using a simple RoundedRectangle border as approximation.
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color.couponYellow, lineWidth: 2)
//        )
//    }
//}
//
//// --- Subview for Offer Details ---
//struct OfferDetailsSection: View {
//    var body: some View {
//        HStack(alignment: .top) {
//            VStack(alignment: .leading) {
//                Text("OFFER")
//                    .font(.caption)
//                    .opacity(0.8)
//                Text("15% OFF")
//                    .font(.title2)
//                    .fontWeight(.bold)
//            }
//
//            Spacer() // Pushes Expiry date to the right if needed, but image shows them stacked
//
//            VStack(alignment: .leading) {
//                Text("EXPIRES")
//                    .font(.caption)
//                    .opacity(0.8)
//                Text("AUGUST 21, 2024")
//                    .font(.title2)
//                    .fontWeight(.bold)
//            }
//        }
//        .foregroundColor(Color.couponYellow)
//    }
//}
//
//// --- Subview for Coupon Footer Icons ---
//struct CouponFooter: View {
//     var body: some View {
//         HStack {
//             // Using placeholder square, 'shippingbox.fill' or 'giftcard.fill' might fit theme
//             Image(systemName: "square.fill")
//                 .font(.title3)
//             Spacer()
//             Image(systemName: "wave.3.right") // NFC/Wireless symbol
//                 .font(.title)
//         }
//         .foregroundColor(Color.couponYellow)
//     }
//}
//
//// --- Subview for the "Hold Near Reader" Prompt ---
//struct HoldNearReaderPrompt: View {
//    var body: some View {
//        VStack {
//            // Icon representing NFC reader interaction
//            Image(systemName: "sensor.tag.radiowaves.forward.fill")
//                 .font(.system(size: 60))
//                 .foregroundColor(.blue)
//            Text("Hold Near Reader")
//                .font(.callout)
//                .foregroundColor(.gray)
//        }
//    }
//}
//
//// --- Preview Provider ---
//#Preview {
//    CouponView()
//}
