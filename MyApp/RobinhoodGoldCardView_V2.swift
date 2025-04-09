//
//  RobinhoodGoldCardView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

// --- Data Models (Mock) ---
// In a real app, this might come from a configuration endpoint
struct CardFeatureInfo {
    let material: String = "Stainless steel"
    let weight: String = "17 grams"
    let network: String = "VISA Signature"
    let headline: String = "3% cash back\nacross the board"
    let description: String = "That's right—earn 3% cash back\non all categories."
    let termsURL: URL? = URL(string: "https://robinhood.com/support/articles/gold-card-terms/") // Example
}

// --- Helper Views ---

// Simple View for displaying T&Cs
struct TermsView: View {
    @Environment(\.dismiss) var dismiss
    let termsContent: String = """
    Robinhood Gold Card - Terms and Conditions (Summary)

    1. Eligibility: Must be a Robinhood customer in good standing, meet credit requirements, etc.
    2. 3% Cash Back: Earn 3% cash back on all eligible purchases. Certain exclusions apply (cash advances, balance transfers, etc.). Points redeemable through Robinhood.
    3. Annual Fee: Refer to Cardholder Agreement for fee details.
    4. Material & Weight: Card is made of stainless steel, weighing approximately 17g. Handle with care.
    5. Network: VISA Signature benefits apply. See VISA guide for details.
    6. Data Usage: Your application and usage data will be handled according to Robinhood's privacy policy.

    This is a summary. Please read the full Cardholder Agreement and related documents carefully before applying or using the card.
    """

    var body: some View {
        NavigationView { // Add NavigationView for title and dismiss button
            ScrollView {
                Text(termsContent)
                    .padding()
                    .font(.body)
            }
            .navigationTitle("Terms & Conditions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Simple View for the next step simulation
struct NextStepView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
       NavigationView {
            VStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .padding()
                Text("Application Started!")
                    .font(.title)
                Text("You've successfully started the Robinhood Gold Card application process. Please follow the next steps.")
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
            .navigationTitle("Success")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// --- Main View ---
struct RobinhoodGoldCardView: View {
    @Environment(\.dismiss) var dismiss // For the 'X' button
    @State private var cardInfo = CardFeatureInfo() // Load mock data

    // State for interactions
    @State private var isLoading: Bool = false
    @State private var showTermsSheet: Bool = false
    @State private var showNextStepSheet: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        ZStack {
            // Background Setup (Gradient + Base Color)
            Color.rhBeige.edgesIgnoringSafeArea(.all) // Base background for scroll area
            LinearGradient(
                gradient: Gradient(colors: [.rhBlack, .rhBlack.opacity(0.85), .rhButtonDark.opacity(0.7)]),
                startPoint: .top,
                endPoint: .center // Gradient fades towards the middle
            )
            .frame(height: UIScreen.main.bounds.height * 0.6) // Limit gradient height
            .edgesIgnoringSafeArea(.all)
            .allowsHitTesting(false) // Let taps pass through gradient

            ScrollView {
                VStack(spacing: 0) {
                    // Top Bar with Functional Close Button
                    HStack {
                        Button {
                            dismiss() // Use dismiss environment action
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3.weight(.medium))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(8) // Increase tap area slightly
                                .contentShape(Rectangle()) // Ensure padding is tappable
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Header Text Section (Using data model)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Robinhood Gold Card")
                                .font(.headline)
                                .foregroundColor(Color.rhSerifText.opacity(0.9))
                            Image(systemName: "leaf.fill") // Placeholder
                                .font(.caption)
                                .foregroundColor(Color.rhSerifText.opacity(0.7))
                        }
                        Text(cardInfo.headline)
                            .font(.system(size: 40, weight: .medium, design: .serif))
                            .foregroundColor(Color.rhSerifText)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 30)

                    // Card Placeholder
                    cardPlaceholderView()
                        .padding(.horizontal)
                        .padding(.bottom, 20)

                    // Benefit Description Section
                    VStack(spacing: 15) {
                        Text(cardInfo.description)
                            .font(.title2.weight(.medium))
                            .foregroundColor(Color.rhBodyText)
                            .multilineTextAlignment(.center)

                        // Functional Terms Button
                        Button {
                            showTermsSheet = true // Trigger the sheet
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "info.circle")
                                Text("Terms apply")
                                    .font(.footnote)
                            }
                            .foregroundColor(Color.rhSubtleText)
                            .padding(.vertical, 5) // Add padding for easier tapping
                        }
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .background(Color.rhBeige)

                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal)
                        .padding(.top, 30)

                    // Info Columns Section (Using data model)
                    HStack(alignment: .top, spacing: 20) {
                        InfoColumn(title: "MATERIAL", value: cardInfo.material)
                        Spacer()
                        InfoColumn(title: "WEIGHT", value: cardInfo.weight)
                        Spacer()
                        InfoColumn(title: "NETWORK", value: cardInfo.network, isLogo: true) // Updated title
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.rhBeige)

                    Spacer(minLength: 30)

                    // Functional Continue Button
                    continueButton()
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .background(Color.rhBeige)
                }
            }
             // Dimming overlay when loading
             if isLoading {
                 Color.black.opacity(0.2)
                     .edgesIgnoringSafeArea(.all)
             }
        }
        .sheet(isPresented: $showTermsSheet) {
            TermsView() // Present the Terms view
        }
        .sheet(isPresented: $showNextStepSheet) {
            NextStepView() // Present the simulated next step
        }
        .alert("Error", isPresented: $showErrorAlert, actions: {
            Button("OK", role: .cancel) {} // Simple dismiss action
        }, message: {
            Text(errorMessage) // Display the dynamic error message
        })
        .preferredColorScheme(.dark) // Hint status bar style
        .statusBar(hidden: false) // Ensure status bar is visible
    }

    // Extracted Card Placeholder View
    @ViewBuilder
    private func cardPlaceholderView() -> some View {
        ZStack {
             RoundedRectangle(cornerRadius: 15)
                 .fill(Color.rhGold)
                 .frame(height: 200)
                 .shadow(color: .black.opacity(0.4), radius: 15, y: 10)

            // Chip Placeholder
            HStack {
                 RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 40, height: 30)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black.opacity(0.2), lineWidth: 1))
                 Spacer()
            }
            .padding(.leading, 25).padding(.top, -80)

            // Feather Logo Placeholder
            HStack {
                Spacer()
                Image(systemName: "leaf.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.trailing, 30).padding(.bottom, -70)
        }
    }

    // Extracted Continue Button View (Handles loading state)
    @ViewBuilder
    private func continueButton() -> some View {
         Button {
            Task {
                await performContinueAction()
            }
        } label: {
            ZStack {
                // Button content hidden when loading
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(isLoading ? .clear : Color.rhButtonTextGold) // Hide text when loading

                // Loading Indicator appears when loading
                if isLoading {
                    ProgressView()
                         .progressViewStyle(CircularProgressViewStyle(tint: Color.rhButtonTextGold))
                }
            }
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(Color.rhButtonDark)
            .clipShape(Capsule())
        }
        .disabled(isLoading) // Disable button while loading
    }

    // --- Action Logic ---
    @MainActor // Ensure UI updates happen on the main thread
    private func performContinueAction() async {
        isLoading = true
        errorMessage = "" // Clear previous error

        do {
            // Simulate network delay (1.5 seconds)
            try await Task.sleep(nanoseconds: 1_500_000_000)

            // Simulate success/failure (e.g., 80% success rate)
            let isSuccess = Bool.random() || Bool.random() // Higher chance of true

            if isSuccess {
                print("Simulated eligibility check: Success")
                showNextStepSheet = true // Trigger next step modal
            } else {
                print("Simulated eligibility check: Failed")
                throw URLError(.cancelled) // Simulate a generic error
                // Or: throw CustomError.notEligible
            }

        } catch {
            // Handle simulated error
            errorMessage = "Failed to verify eligibility. Please try again later." // Realistic error message
            showErrorAlert = true
        }

        isLoading = false // End loading state regardless of outcome
    }
}

// Reusable View for the Info Columns (Updated for Network)
struct InfoColumn: View {
    let title: String
    let value: String
    var isLogo: Bool = false // Used for NETWORK (VISA) column

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            if isLogo {
                // Placeholder for VISA logo
                 Text("VISA") // Render as Text for now
                    .font(.system(size: 18, weight: .heavy, design: .default)) // Example Font
                    .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.7)) // VISA Blue approx.
            } else {
                 Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(Color.rhSubtleText)
                    .kerning(1.0)
            }

            Text(value)
                .font(.subheadline)
                .foregroundColor(Color.rhBodyText)
        }
        .frame(minWidth: 70)
    }
}

// ---- Color Definitions (from previous response) ----
extension Color {
    static let rhBlack = Color(red: 0.05, green: 0.05, blue: 0.05)
    static let rhGold = Color(red: 0.8, green: 0.65, blue: 0.3)
    static let rhBeige = Color(red: 0.96, green: 0.94, blue: 0.91) // Slightly adjusted beige
    static let rhButtonDark = Color(red: 0.15, green: 0.15, blue: 0.1)
    static let rhButtonTextGold = Color(red: 0.9, green: 0.8, blue: 0.5)
    static let rhSerifText = Color(red: 0.95, green: 0.93, blue: 0.90)
    static let rhBodyText = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let rhSubtleText = Color(red: 0.4, green: 0.4, blue: 0.4)
}

// --- Preview ---
struct RobinhoodGoldCardView_Functional_Previews: PreviewProvider {
    static var previews: some View {
         // Wrap in a simple container to allow modal presentation in preview
         NavigationView{ EmptyView() }
            .sheet(isPresented: .constant(true)){
                 RobinhoodGoldCardView()
            }

    }
}
