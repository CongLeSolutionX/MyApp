//
//  ProAccessView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

// Define custom colors for reusability
struct AppColors {
    static let background = Color(red: 0.08, green: 0.08, blue: 0.1) // Dark background
    static let primaryPurple = Color(red: 0.6, green: 0.3, blue: 0.9) // Accent purple
    static let secondaryText = Color.gray
    static let cardBackground = Color.black.opacity(0.3)
    static let bestOfferBackground = Color(red: 0.4, green: 0.2, blue: 0.6) // Darker purple for badge
}

// Represents the selection state
enum SubscriptionOption: Hashable {
    case yearly
    case weekly
}

struct ProAccessView: View {
    @State private var isFreeTrialEnabled = false
    @State private var selectedOption: SubscriptionOption? = .yearly // Default to yearly

    var body: some View {
        ZStack {
            // Background Color
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    // Top Badge and Close Button (Simplified alignment)
                    HStack {
                        Spacer()
                        PixiProBadge()
                        Spacer()
                    }
                    .overlay(alignment: .topTrailing) {
                        CloseButton()
                    }
                    .padding(.top)
                    .padding(.horizontal)

                    // Header Text
                    VStack(spacing: 8) {
                        Text("Get Pro Access")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Get unlimited messages, access to AI experts, and unlock Pro Tools.")
                            .font(.headline)
                            .fontWeight(.regular)
                            .foregroundColor(AppColors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .padding(.bottom)

                    // Feature List
                    VStack(alignment: .leading, spacing: 20) {
                        FeatureItemRow(icon: "bolt.fill", title: "Unlimited Messages", subtitle: "Use Pixi for all your needs")
                        FeatureItemRow(icon: "gauge.medium", title: "The Fastest Models", subtitle: "GPT-4o, Claude Sonnet 3.5")
                        FeatureItemRow(icon: "camera.viewfinder", title: "Advanced AI Tools", subtitle: "Smart Camera, AI Art")
                    }
                    .padding(.horizontal, 25)

                    // Free Trial Toggle
                    FreeTrialToggle(isEnabled: $isFreeTrialEnabled)
                        .padding(.horizontal)
                        .padding(.top)

                    // Subscription Options
                    VStack(spacing: 15) {
                        SubscriptionOptionRow(
                            title: "Yearly Access",
                            price: "$49.99 per year",
                            priceDetail: "$0.96 per week",
                            isBestOffer: true,
                            isSelected: selectedOption == .yearly
                        ) {
                            selectedOption = .yearly
                        }

                        SubscriptionOptionRow(
                            title: "Weekly Access",
                            price: "$7.99 per week",
                            priceDetail: nil,
                            isBestOffer: false,
                            isSelected: selectedOption == .weekly
                        ) {
                            selectedOption = .weekly
                        }
                    }
                    .padding(.horizontal)

                    // Continue Button
                    Button("Continue") {
                        // Handle continue action
                        print("Continue tapped. Selected: \(selectedOption ?? .none), Free Trial: \(isFreeTrialEnabled)")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                    .padding(.top) // Add padding above the button

                    Spacer() // Push footer links down

                } // End Main VStack
                .padding(.bottom, 5) // Add padding below the ScrollView content

            } // End ScrollView

            // Footer Links - positioned at the bottom outside the ScrollView
            VStack {
                 Spacer() // Pushes the HStack to the bottom
                 FooterLinks()
                     .padding(.bottom, 10) // Adjust padding as needed
                     .padding(.horizontal)
             }

        } // End ZStack
    }
}

// MARK: - Reusable Subviews

struct PixiProBadge: View {
    var body: some View {
        Text("PIXI PRO")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(AppColors.primaryPurple)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppColors.primaryPurple, lineWidth: 1.5)
            )
    }
}

struct CloseButton: View {
    var body: some View {
        Button {
            // Handle close action
            print("Close tapped")
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(10)
                .background(Color.white.opacity(0.15))
                .clipShape(Circle())
        }
    }
}

struct FeatureItemRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppColors.primaryPurple)
                .frame(width: 30) // Consistent icon alignment

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            Spacer() // Push content to the left
        }
    }
}

struct FreeTrialToggle: View {
    @Binding var isEnabled: Bool

    var body: some View {
        HStack {
            Text("Enable Free Trial")
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .tint(AppColors.primaryPurple) // Color for the toggle switch
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.1), lineWidth: 1) // Subtle border
        )
    }
}

struct SubscriptionOptionRow: View {
    let title: String
    let price: String
    let priceDetail: String?
    let isBestOffer: Bool
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text(price)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }

                Spacer()

                if let detail = priceDetail {
                    VStack(alignment: .trailing) {
                         Spacer() // Pushes price detail down
                         Text(detail)
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                     }
                    .frame(height: 35) // Align vertically with main text
                } else {
                     // Placeholder to maintain height consistency if needed
                     VStack { Spacer(); Text("").font(.caption) }.frame(height: 35).hidden()
                 }

            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(15)
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(isSelected ? AppColors.primaryPurple : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1) // Highlight if selected

                    if isBestOffer {
                        BestOfferBadge()
                            .offset(x: 0, y: -27) // Position badge above the row
                    }
                }
            )
        }
        .buttonStyle(.plain) // Remove default button styling
    }
}

struct BestOfferBadge: View {
    var body: some View {
         HStack{ // Use HStack to allow Spacer pushes
             Spacer() // Pushes badge to the right
             Text("BEST OFFER")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppColors.bestOfferBackground)
                .cornerRadius(20) // Fully rounded ends
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.primaryPurple)
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0) // Subtle press effect
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct FooterLinks: View {
    var body: some View {
        HStack(spacing: 20) { // Add spacing between links
            Button("Restore Purchases") { /* Handle action */ }
            Spacer()
            Button("Privacy Policy") { /* Handle action */ }
            Spacer()
            Button("Terms of Use") { /* Handle action */ }
        }
        .buttonStyle(FooterLinkStyle())
    }
}

struct FooterLinkStyle: ButtonStyle {
       func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .foregroundColor(AppColors.secondaryText.opacity(configuration.isPressed ? 0.7 : 1.0))
    }
}

// MARK: - Preview
struct ProAccessView_Previews: PreviewProvider {
    static var previews: some View {
        ProAccessView()
    }
}
