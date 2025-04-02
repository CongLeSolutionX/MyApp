//
//  DeliveryInfoView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI


struct DeliveryInfoView: View {
    // Constants for colors (can access from StarbucksOrderView or define locally)
    static let starbucksGreen = Color(red: 0, green: 0.384, blue: 0.278)
    static let systemBackground = Color(.systemBackground)
    static let secondaryText = Color(.secondaryLabel) // For disclaimer text
    static let doordashRed = Color.red // Approximate DoorDash red

    var body: some View {
        VStack(spacing: 0) { // Use spacing 0 and manage padding manually
            // --- Top Green Section with Image ---
            ZStack(alignment: .bottom) {
                // Green Background (extends slightly behind image)
                Self.starbucksGreen
                    .frame(height: 200) // Adjust height as needed
                    .edgesIgnoringSafeArea(.top) // Extend green to top edge

                // Delivery Illustration (Placeholder)
                Image("starbucks_delivery_illustration") // Replace with your asset name
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180) // Adjust size as needed
                    .padding(.bottom, 20) // Pushes image up slightly from the bottom edge of ZStack

                    // If you don't have the asset yet, use a placeholder:
                    // Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                    //     .resizable()
                    //     .scaledToFit()
                    //     .frame(height: 150)
                    //     .foregroundColor(.white.opacity(0.8))
                    //     .padding(.bottom, 20)
            }
            .frame(height: 200) // Match ZStack height

            // --- Content Section (White Background) ---
            VStack(spacing: 25) { // Add spacing between content elements
                // Headline
                Text("Today deserves delivery")
                    .font(.system(size: 26, weight: .semibold)) // Match font size/weight
                    .multilineTextAlignment(.center)

                // Buttons
                VStack(spacing: 15) {
                    Button("Get started") {
                        // TODO: Add action for starting delivery order
                        print("Get Started Tapped")
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity) // Make button wide
                    .padding(.vertical, 14)     // Button height
                    .background(Self.starbucksGreen)
                    .foregroundColor(.white)
                    .clipShape(Capsule())

                    Button("Delivery FAQs") {
                        // TODO: Add action to show FAQs
                        print("Delivery FAQs Tapped")
                    }
                    .fontWeight(.medium)
                    .foregroundColor(Self.starbucksGreen)
                }
                .padding(.horizontal, 60) // Add horizontal padding to center buttons more

                Spacer() // Push footer content down

                // Footer (Powered by + Disclaimer)
                VStack(spacing: 10) {
                    HStack(spacing: 5) {
                        VStack {
                       
                            // DoorDash Logo (Placeholder)
                            Image("My-meme-cordyceps") // doordash_logo // Replace with your asset name
                                 .resizable()
                                 .scaledToFill()
                                 .frame(height: 150) // Adjust size
                            Spacer()
                            Text("POWERED BY CongLeSolutionX")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Self.secondaryText)
                        }
                        Spacer()
                    }
                    
                    
                    Divider()
                    // Placeholder alternative:
                     Image(systemName: "car.fill")
                         .foregroundColor(Self.doordashRed)
                         .imageScale(.small)
                     Text("DOORDASH") // Or just text if logo isn't available
                          .font(.system(size: 10, weight: .bold))
                         .foregroundColor(Self.doordashRed)
                    Text("Menu limited. Menu pricing for delivery may be higher than posted in stores or as marked. Additional fees may apply. Delivery orders are not eligible for Starbucks® Rewards benefits at this time. Check our Delivery FAQs for additional help.")
                        .font(.caption)
                        .foregroundColor(Self.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3) // Add a bit of line spacing
                }
                .padding(.horizontal, 25) // Padding for the footer text
                .padding(.bottom, 20)    // Padding from the bottom edge

            }
            .padding(.top, 30) // Space below the green image area
            .background(Self.systemBackground) // White background for content area
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Take remaining space
        }
        .background(Self.systemBackground) // Ensure entire view has a background
        .edgesIgnoringSafeArea(.bottom) // Allow content to potentially go to bottom edge if needed
    }
}

// MARK: - Preview
#Preview {
    DeliveryInfoView()
}
