//
//  VirtualCardDetailView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
import Combine // Needed for Timer

// --- Mock Data Structure ---
struct VirtualCardInfo {
    let cardNumber: String = "4242 4242 4242 1234" // Example fake number
    let expiryMonth: Int = Int.random(in: 1...12)
    let expiryYear: Int = Calendar.current.component(.year, from: Date()) + Int.random(in: 3...5) // Expire 3-5 years from now
    let cvv: String = String(format: "%03d", Int.random(in: 100...999)) // Random 3-digit CVV
    let cardholderName: String = "CongLeSolutionX" // Example name
    let cardNetwork: String = "Visa" // Or "Mastercard"
    let issuer: String = "I Asked AI Bots"

    var formattedExpiry: String {
        String(format: "%02d/%02d", expiryMonth, expiryYear % 100) // Format as MM/YY
    }
}

// --- Virtual Card Detail View ---
struct VirtualCardDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var cardInfo: VirtualCardInfo = VirtualCardInfo() // Load mock data

    // State for security and feedback
    @State private var showDetails: Bool = false // Details are hidden by default
    @State private var isNumberCopied: Bool = false
    @State private var isExpiryCopied: Bool = false
    @State private var isCvvCopied: Bool = false

    // Timer to reset copy feedback
    @State private var copyFeedbackTimer: AnyCancellable?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                Spacer() // Push card view down slightly

                // --- Card Visual ---
                CardView(
                    cardInfo: cardInfo,
                    showDetails: $showDetails
                )
                .padding(.horizontal)

                // --- Show/Hide Toggle ---
                Button {
                    withAnimation {
                        showDetails.toggle()
                        // Reset copy states when toggling visibility
                        resetCopyStates()
                    }
                } label: {
                    Label(showDetails ? "Hide Details" : "Show Details", systemImage: showDetails ? "eye.slash.fill" : "eye.fill")
                        .font(.headline)
                        .foregroundColor(Color.rhGold) // Use theme color
                }
                .padding(.top, 5)

                // --- Copy Actions ---
                // Only show copy buttons if details are visible
                   if showDetails {
                       VStack(spacing: 15) {
                           CopyButton(
                               label: "Copy Card Number",
                               value: cardInfo.cardNumber.replacingOccurrences(of: " ", with: ""), // Copy without spaces
                               isCopied: $isNumberCopied,
                               resetAction: triggerCopyFeedbackReset
                           )

                           HStack(spacing: 15) {
                               CopyButton(
                                   label: "Copy Expiry",
                                   value: cardInfo.formattedExpiry,
                                   isCopied: $isExpiryCopied,
                                   resetAction: triggerCopyFeedbackReset
                               )
                               CopyButton(
                                   label: "Copy CVV",
                                   value: cardInfo.cvv,
                                   isCopied: $isCvvCopied,
                                   resetAction: triggerCopyFeedbackReset
                               )
                           }
                       }
                       .padding(.horizontal)
                       .transition(.opacity.combined(with: .scale(scale: 0.9))) // Add animation
                       .onDisappear {
                           // Ensure copy states reset if view gets hidden for other reasons
                          resetCopyStates()
                       }
                 } else {
                      // Placeholder to maintain layout spacing when buttons are hidden
                     VStack(spacing: 15) {
                          Rectangle().fill(Color.clear).frame(height: 44) // Approx height of a button
                           HStack(spacing: 15) {
                              Rectangle().fill(Color.clear).frame(height: 44)
                             Rectangle().fill(Color.clear).frame(height: 44)
                          }
                     }
                     .padding(.horizontal)
                 }

                // --- Security Note ---
                Text("For your security, avoid sharing screenshots of this screen.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer() // Pushes content towards center

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure VStack takes full space
            .background(Color.rhBeige.ignoresSafeArea()) // Background color
            .navigationTitle("Virtual Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color.rhGold)
                }
            }
            .onDisappear {
                // Cancel timer if the view disappears
                copyFeedbackTimer?.cancel()
            }
        }
        .accentColor(Color.rhGold) // Apply theme tint color
    }

    // --- Helper Function to Trigger Copy Feedback Reset ---
    func triggerCopyFeedbackReset() {
        // Cancel any existing timer
        copyFeedbackTimer?.cancel()

        // Start a new timer
        copyFeedbackTimer = Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                resetCopyStates()
                copyFeedbackTimer?.cancel() // Stop timer after resetting
            }
    }

     // --- Helper to Reset All Copy States ---
     func resetCopyStates() {
         withAnimation(.easeInOut(duration: 0.3)) { // Add subtle animation
             isNumberCopied = false
             isExpiryCopied = false
             isCvvCopied = false
         }
          copyFeedbackTimer?.cancel() // Ensure timer is cancelled if reset manually
     }
}

// --- Reusable Card Visual Component ---
struct CardView: View {
    let cardInfo: VirtualCardInfo
    @Binding var showDetails: Bool

    private let cornerRadius: CGFloat = 15.0

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Card Background
             LinearGradient(
                 gradient: Gradient(colors: [Color.rhBlack.opacity(0.9), Color.rhBlack]),
                 startPoint: .topLeading,
                 endPoint: .bottomTrailing
             )

            // Card Content
            VStack(alignment: .leading, spacing: 15) {
                 HStack {
                     // Issuer Logo (Placeholder)
                    Text(cardInfo.issuer.uppercased())
                         .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    // Network Logo (Placeholder - Use SF Symbols or actual images)
                     Image(systemName: cardInfo.cardNetwork.lowercased() == "visa" ? "creditcard.fill" : "creditcard") // Example mapping
                        .foregroundColor(.white)
                        .font(.title2)
                }

                Spacer() // Pushes number down

                 // Card Number
                 Text(formattedCardNumber(cardNumber: cardInfo.cardNumber, show: showDetails))
                    .font(.system(.title2, design: .monospaced)) // Monospaced looks good for numbers
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8) // Allow scaling if needed

                // Expiry and CVV Row (aligned)
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("EXPIRES")
                            .font(.system(size: 8, weight: .semibold))
                             .foregroundColor(.white.opacity(0.7))
                        Text(showDetails ? cardInfo.formattedExpiry : "MM/YY")
                             .font(.system(.subheadline, design: .monospaced))
                             .fontWeight(.medium)
                           .foregroundColor(.white)
                    }

                    Spacer() // Push CVV right

                    VStack(alignment: .leading, spacing: 2) {
                        Text("CVV")
                            .font(.system(size: 8, weight: .semibold))
                             .foregroundColor(.white.opacity(0.7))
                         Text(showDetails ? cardInfo.cvv : "***")
                            .font(.system(.subheadline, design: .monospaced))
                             .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                 }

                // Cardholder Name
                 Text(cardInfo.cardholderName.uppercased())
                    .font(.callout)
                     .fontWeight(.medium)
                     .foregroundColor(.white.opacity(0.9))
                     .lineLimit(1)

            }
            .padding(20) // Padding inside the card
        }
        .frame(height: 200) // Standard card aspect ratio approx
        .cornerRadius(cornerRadius)
        // Add a subtle shadow for depth
       .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        // Add a subtle border maybe?
         .overlay(
             RoundedRectangle(cornerRadius: cornerRadius)
                 .stroke(Color.white.opacity(0.1), lineWidth: 1)
         )

    }

     // Helper to format card number with masking
      private func formattedCardNumber(cardNumber: String, show: Bool) -> String {
          let digitsOnly = cardNumber.replacingOccurrences(of: " ", with: "")
          guard digitsOnly.count >= 4 else { return cardNumber } // Should have at least 4 digits

          if show {
              // Insert spaces for readability when shown
              var spacedNumber = ""
              for (index, character) in digitsOnly.enumerated() {
                  spacedNumber.append(character)
                  if (index + 1) % 4 == 0 && index < digitsOnly.count - 1 {
                      spacedNumber.append(" ")
                  }
              }
              return spacedNumber
          } else {
              // Mask all but the last 4 digits
              let lastFour = String(digitsOnly.suffix(4))
             // Use bullet points for masking
              let maskedSection = String(repeating: "•", count: 4) + " " // Group of 4 bullets
              let numberOfGroups = (digitsOnly.count - 4) / 4
              let remainingBullets = (digitsOnly.count - 4) % 4
              var mask = ""
             for _ in 0..<numberOfGroups {
                  mask += maskedSection
              }
             mask += String(repeating: "•", count: remainingBullets)
             return mask.trimmingCharacters(in: .whitespaces) + " " + lastFour // Ensure space before last 4

          }
      }
}

// --- Reusable Copy Button Component ---
struct CopyButton: View {
    let label: String
    let value: String
    @Binding var isCopied: Bool
    let resetAction: () -> Void // Action to call after copy to start timer

    var body: some View {
        Button {
            UIPasteboard.general.string = value
             withAnimation(.easeInOut) { // Animate state change
                 isCopied = true
             }
             resetAction() // Notify parent to start reset timer
        } label: {
            HStack {
                Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                Text(isCopied ? "\(label) Copied!" : label)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            // Use different background/foreground when copied for feedback
            .background(isCopied ? Color.green.opacity(0.8) : Color.gray.opacity(0.2))
            .foregroundColor(isCopied ? Color.white : Color.rhBlack)
            .cornerRadius(10)
            .font(.headline)
            // Disable button briefly after copy? Optional.
             // .disabled(isCopied)
        }
         // Add explicit animation modifier for changes to `isCopied`
          .animation(.easeInOut, value: isCopied)
    }
}

// --- Previews ---
struct VirtualCardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VirtualCardDetailView()
            .environment(\.colorScheme, .light) // Preview in light mode
            // Add theme colors if needed via environment
            // .environmentObject(ThemeManager()) // Example
    }
}

//// --- Add Color Extension if needed ---
//extension Color {
//    static let rhGold = Color(red: 0.8, green: 0.6, blue: 0.0) // Adjust RGB as needed
//    static let rhGreen = Color(red: 0.0, green: 0.7, blue: 0.0)
//    static let rhBlack = Color(red: 0.1, green: 0.1, blue: 0.1)
//    static let rhBeige = Color(red: 0.98, green: 0.97, blue: 0.95) // Off-white
//    static let rhRed = Color(red: 0.8, green: 0.1, blue: 0.1)
//    static let rhButtonTextGold = Color(red: 0.9, green: 0.7, blue: 0.1)
//    static let rhButtonDark = Color(red: 0.15, green: 0.15, blue: 0.15)
//}
