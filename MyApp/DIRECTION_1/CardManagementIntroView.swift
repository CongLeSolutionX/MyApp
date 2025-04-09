////
////  CardManagementIntroView.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//
//// --- Data Model for Card Info (Mock) ---
//struct MockCardDetails {
//    let cardNickname: String = "CongLeSolutionX Gold Card"
//    let last4Digits: String = "1234" // Often shown even before activation
//    let creditLimit: Int = 15000 // Example limit
//    let estimatedDeliveryDays: Int = Int.random(in: 5...10) // Randomize slightly
//    let virtualCardAvailable: Bool = Bool.random() // Simulate if virtual card is ready
//    let appleWalletEligible: Bool = true // Assume eligible
//}
//
//// --- Card Management Intro View ---
//struct CardManagementIntroView: View {
//    @Environment(\.dismiss) var dismiss // To potentially dismiss this view
//    @State private var cardDetails: MockCardDetails = MockCardDetails() // Load mock data
//
//    // State for simulated actions
//    @State private var showingWalletAlert = false
//    @State private var showingVirtualCardAlert = false
//    @State private var showingBenefitsSheet = false
//
//    var body: some View {
//        NavigationView { // Embed in NavigationView for a title bar
//            ScrollView {
//                VStack(alignment: .leading, spacing: 20) { // Use leading alignment
//
//                    // --- Header Section ---
//                    VStack(alignment: .center, spacing: 8) { // Centered header text
//                        Image(systemName: "sparkles") // More celebratory icon
//                            .font(.system(size: 40, weight: .light))
//                            .foregroundColor(Color.rhGold)
//                        Text("Welcome to CongLeSolutionX Gold Card!")
//                            .font(.title2)
//                            .fontWeight(.bold)
//                            .multilineTextAlignment(.center)
//                            .foregroundColor(Color.rhBlack)
//                        Text("Your card ending in \(cardDetails.last4Digits) is on its way.")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                            .multilineTextAlignment(.center)
//                    }
//                    .frame(maxWidth: .infinity) // Ensure header text is centered
//                    .padding(.vertical)
//
//                    // --- Card Info Section ---
//                    GroupBox(label: Label("Card Details", systemImage: "creditcard.fill")) {
//                        VStack(alignment: .leading, spacing: 12) {
//                             InfoRow(label: "Status", value: "Active") // Card is active upon approval
//                            InfoRow(label: "Credit Limit", value: formatCurrency(cardDetails.creditLimit))
//                            InfoRow(label: "Estimated Delivery", value: "\(cardDetails.estimatedDeliveryDays) business days")
//                        }
//                        .padding(.vertical, 5) // Add slight vertical padding inside GroupBox
//                    }
//                    .groupBoxStyle(PlainGroupBoxStyle()) // Use a less prominent style
//
//                    // --- Action Buttons Section ---
//                    VStack(spacing: 15) {
//                        if cardDetails.appleWalletEligible {
//                            ActionButton(
//                                title: "Add to Apple Wallet",
//                                systemImage: "wallet.pass.fill",
//                                action: {
//                                    print("Simulating Add to Apple Wallet...")
//                                    // In a real app: Initiate PassKit add pass flow
//                                    showingWalletAlert = true
//                                }
//                            )
//                        }
//
//                        if cardDetails.virtualCardAvailable {
//                            ActionButton(
//                                title: "View Virtual Card Details",
//                                systemImage: "creditcard.and.123",
//                                action: {
//                                    print("Simulating View Virtual Card...")
//                                    // In a real app: Likely requires Face ID/Passcode
//                                    // Navigate to a secure view
//                                    showingVirtualCardAlert = true
//                                }
//                            )
//                        } else {
//                             ActionButton(
//                                 title: "Virtual Card (Coming Soon)",
//                                 systemImage: "creditcard.and.123",
//                                 action: {},
//                                 disabled: true // Disable if not available
//                             )
//                         }
//
//                        ActionButton(
//                            title: "Explore Card Benefits",
//                            systemImage: "gift.fill",
//                            action: {
//                                print("Showing Benefits...")
//                                showingBenefitsSheet = true
//                            }
//                        )
//
//                         ActionButton(
//                             title: "Manage Card Settings",
//                             systemImage: "gearshape.fill",
//                             action: {
//                                 print("Navigate to Card Settings (Simulated)")
//                                 // Navigate to a more detailed settings screen
//                             },
//                             style: .secondary // Use a secondary style for less primary actions
//                         )
//                    }
//
//                    Spacer() // Pushes content up
//                }
//                .padding() // Add padding around the main VStack
//            }
//            .background(Color.rhBeige.ignoresSafeArea()) // Background color
//            .navigationTitle("Your Gold Card")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") {
//                        dismiss() // Dismiss this management intro view
//                    }
//                    .foregroundColor(Color.rhGold) // Theme color for the button
//                }
//            }
//            // --- Alerts and Sheets for Simulated Actions ---
//            .alert("Add to Wallet", isPresented: $showingWalletAlert) {
//                Button("OK", role: .cancel) {}
//            } message: {
//                Text("In a real application, this would open the Apple Wallet interface to add your Robinhood Gold Card.")
//            }
//            .alert("View Virtual Card", isPresented: $showingVirtualCardAlert) {
//                Button("OK", role: .cancel) {}
//            } message: {
//                Text("Accessing virtual card details typically requires authentication (Face ID/Passcode). This feature is simulated.")
//            }
//            .sheet(isPresented: $showingBenefitsSheet) {
//                // Present a view detailing the card benefits
//                CardBenefitsView()
//            }
//        }
//        // Apply theme colors if needed for Navigation Bar appearance
//         .accentColor(Color.rhGold) // Sets tint color for navigation items
//         // .navigationViewStyle(.stack) // Optional: Explicitly set style if needed
//    }
//
//    // --- Helper Function for Currency Formatting ---
//    private func formatCurrency(_ amount: Int) -> String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.maximumFractionDigits = 0 // Assuming whole dollar limits for simplicity
//        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
//    }
//}
//
//// --- Helper View for Info Rows ---
//struct InfoRow: View {
//    let label: String
//    let value: String
//
//    var body: some View {
//        HStack {
//            Text(label)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//            Spacer()
//            Text(value)
//                .font(.subheadline)
//                .fontWeight(.medium) // Make value slightly bolder
//                .foregroundColor(Color.rhBlack)
//        }
//    }
//}
//
//// --- Custom Action Button ---
//enum ActionButtonStyle {
//    case primary
//    case secondary
//}
//
//struct ActionButton: View {
//    let title: String
//    let systemImage: String
//    let action: () -> Void
//    var style: ActionButtonStyle = .primary
//    var disabled: Bool = false
//
//    var body: some View {
//        Button(action: action) {
//            HStack {
//                Image(systemName: systemImage)
//                    .font(.headline) // Slightly smaller icon
//                Text(title)
//                    .font(.headline)
//                Spacer() // Pushes icon and text left
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(backgroundColor)
//            .foregroundColor(foregroundColor)
//            .cornerRadius(10)
//            .opacity(disabled ? 0.5 : 1.0) // Indicate disabled state
//        }
//        .disabled(disabled)
//    }
//
//    // --- Style Computed Properties ---
//    private var backgroundColor: Color {
//        switch style {
//        case .primary:
//            return disabled ? Color.gray.opacity(0.3) : Color.rhButtonDark
//        case .secondary:
//             return disabled ? Color.gray.opacity(0.1) : Color.gray.opacity(0.2) // Lighter background
//        }
//    }
//
//    private var foregroundColor: Color {
//         switch style {
//         case .primary:
//             return disabled ? Color.secondary : Color.rhButtonTextGold
//         case .secondary:
//             return disabled ? Color.secondary : Color.rhBlack // Darker text for light background
//         }
//     }
//}
//
//// --- Placeholder View for Benefits Sheet ---
//struct CardBenefitsView: View {
//     @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        NavigationView {
//            List {
//                Section("Travel") {
//                    Label("Airport Lounge Access", systemImage: "airplane")
//                     Label("No Foreign Transaction Fees", systemImage: "globe")
//                }
//                Section("Points & Rewards") {
//                    Label("3x Points on Dining", systemImage: "fork.knife")
//                    Label("2x Points on Travel", systemImage: "airplane.circle")
//                    Label("1x Points on Everything Else", systemImage: "cart")
//                }
//                 Section("Security") {
//                     Label("Fraud Protection", systemImage: "shield.lefthalf.filled")
//                 }
//            }
//            .listStyle(.insetGrouped) // Nice styling for benefits list
//            .navigationTitle("Card Benefits")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) { // Or trailing
//                    Button("Close") {
//                        dismiss()
//                    }
//                    .foregroundColor(Color.rhGold)
//                }
//            }
//        }
//    }
//}
//
//// --- Custom GroupBox Style (Optional, for cleaner look) ---
//struct PlainGroupBoxStyle: GroupBoxStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        VStack(alignment: .leading) {
//            configuration.label
//                .font(.headline) // Style the label
//                .padding(.bottom, 5)
//            configuration.content
//        }
//        .padding()
//        .background(Color.white.opacity(0.6)) // Slightly transparent white background
//        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
//    }
//}
//
//// --- Previews ---
//struct CardManagementIntroView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardManagementIntroView()
//            .environment(\.colorScheme, .light) // Force light mode for preview consistency
//             // You might need to inject theme colors if they are environment objects
//             
//    }
//}
//
//// --- Re-add Color Extension if needed in this file ---
//// (Assuming it's defined elsewhere or add it here)
//// extension Color { ... }
