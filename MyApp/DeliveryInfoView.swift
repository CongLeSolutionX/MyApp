//
//  DeliveryInfoView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

struct DeliveryInfoView: View {
    static let starbucksGreen = Color(red: 0, green: 0.384, blue: 0.278)
    static let systemBackground = Color(.systemBackground)
    static let secondaryText = Color(.secondaryLabel)
    static let doordashRed = Color.red
    
    var body: some View {
        VStack(spacing: 0) {
            // --- Top Green Section ---
            ZStack(alignment: .bottom) {
                Self.starbucksGreen
                    .frame(height: 210) // Slightly taller? Adjust as needed
                    .edgesIgnoringSafeArea(.top)
                
                Image("starbucks_delivery_illustration") // Use your asset
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180) // Adjust if needed
                    .padding(.bottom, 30) // Increase padding to push image higher
                
                // Placeholder:
                Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 30) // Apply same padding
            }
            .frame(height: 210) // Match ZStack height
            
            // --- Content Section ---
            VStack(spacing: 0) { // Start with 0 spacing, manage with padding
                // Headline
                Text("Today deserves delivery")
                    .font(.system(size: 26, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding(.top, 35) // Padding below green area
                    .padding(.bottom, 30) // Padding before buttons
                
                // Buttons
                VStack(spacing: 18) { // Spacing between buttons
                    Button("Get started") { /* Action */ }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14) // Button height
                        .background(Self.starbucksGreen)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    
                    Button("Delivery FAQs") { /* Action */ }
                        .fontWeight(.medium)
                        .foregroundColor(Self.starbucksGreen)
                }
                .padding(.horizontal, 65) // Increased horizontal padding makes buttons narrower centrally
                
                Spacer() // Pushes footer down
                
                
                // Footer
                VStack(spacing: 12) { // Spacing in footer
                    HStack(spacing: 5) {
                        VStack {
                            Image("My-meme-original") // doordash_logo // Replace with your asset name
                                .resizable()
                                .scaledToFill()
                                .frame(height: 150) // Adjust size
                            Spacer()
                            
                            
                            Text("POWERED BY CongLeSolutionX")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Self.secondaryText)
                        }
                    }
                    
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
                        .lineSpacing(3)
                        .padding(.horizontal, 30) // More padding for disclaimer text sides
                }
                .padding(.bottom, 25) // Padding before tab bar
            }
            .background(Self.systemBackground)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Self.systemBackground)
        .edgesIgnoringSafeArea(.bottom) // Let TabView handle bottom safe area
    }
}

// MARK: - Preview
#Preview {
    DeliveryInfoView()
}
