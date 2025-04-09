//
//  ReviewContributionView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

// Define IRAAccountType if not already defined globally
// enum IRAAccountType: String { case traditional = "Traditional IRA", roth = "Roth IRA" }

// Define FundingSource if not defined globally or passed differently
// struct FundingSource: Identifiable, Hashable { ... } // As defined previously

// Structure to hold all details for review
struct ContributionDetails: Hashable {
    let selectedType: IRAAccountType
    let contributionAmount: Decimal
    let selectedContributionYear: Int
    let fundingSource: FundingSource // Pass the selected source object
    // Add other relevant IDs or details if needed
}

struct ReviewContributionView: View {
    // Details passed from the previous funding screen
    let details: ContributionDetails

    // State for UI feedback
    @State private var isProcessing: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var navigateToSuccess: Bool = false // To trigger navigation

    // Formatter for currency display
    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        // Ensure we handle Decimal correctly by converting to NSDecimalNumber
        return formatter.string(from: details.contributionAmount as NSDecimalNumber) ?? "$0.00"
    }

    var body: some View {
         // Use ZStack to allow overlaying the ProgressView
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                     Text("Review Your Contribution")
                         .font(.largeTitle)
                         .fontWeight(.bold)
                         .padding(.horizontal)
                         .padding(.top) // Add padding if not in NavView

                     // Using List for grouped visual style
                     List {
                         Section(header: Text("Details").font(.headline)) {
                             ReviewRow(label: "Account Type:", value: details.selectedType.rawValue)
                             ReviewRow(label: "Contribution Year:", value: String(details.selectedContributionYear))
                             ReviewRow(label: "Contribution Amount:", value: formattedAmount, valueFontWeight: .semibold)
                         }

                         Section(header: Text("Funding").font(.headline)) {
                             ReviewRow(label: "From Account:", value: details.fundingSource.displayName, valueFontSize: .caption)
                             // Placeholder for the destination account
                             ReviewRow(label: "To Account:", value: "New \(details.selectedType.rawValue) (...XXXX)", valueFontSize: .caption) // Mock account number
                        }

                        Section(header: Text("Important Information").font(.headline)) {
                             Text("By confirming, you authorize this contribution to your \(details.selectedType.rawValue). Contributions are subject to IRS limits and rules. Consult your tax advisor for eligibility. Funds transfers may take 1-3 business days. [Link to Full Terms & Conditions]")
                                 .font(.footnote)
                                 .foregroundColor(.gray)
                        }
                     }
                     // Reduce default List padding and let VStack control spacing
                     .listStyle(InsetGroupedListStyle()) // Or PlainListStyle
                     .frame(height: calculateListHeight()) // Adjust height dynamically or set fixed

                    Spacer() // Push button down if VStack height allows

                    Button {
                        confirmAction()
                    } label: {
                        Text("Confirm & Contribute")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .disabled(isProcessing) // Disable while processing

                } // End VStack
            } // End ScrollView

            // --- Processing Overlay ---
            if isProcessing {
                 Color.black.opacity(0.3) // Dim background
                     .edgesIgnoringSafeArea(.all)
                 ProgressView("Processing...")
                     .padding()
                     .background(Color(UIColor.systemBackground)) // Use system background
                     .cornerRadius(10)
                     .shadow(radius: 5)
             }

             // --- Navigation to Success Screen ---
             // This should navigate to a dedicated success/confirmation receipt screen
             NavigationLink(destination: Text("Success! Contribution Submitted."), // Placeholder Success View
                            isActive: $navigateToSuccess) { EmptyView() }

        } // End ZStack
        .navigationTitle("Review") // Set title if embedded in NavigationView
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showErrorAlert) {
             Button("OK") {} // Simple dismissal
         } message: {
             Text(errorMessage)
         }
    }

    // Helper function to estimate list height (adjust multipliers as needed)
    // This prevents the List from taking infinite height in ScrollView
    private func calculateListHeight() -> CGFloat {
        // Rough estimate: (rows * rowHeight) + (sections * headerHeight) + padding
        let rowHeight: CGFloat = 45
        let headerHeight: CGFloat = 30
        let padding: CGFloat = 40
        let numRows = 5 // Adjust based on actual rows
        let numSections = 3 // Adjust based on actual sections
        return (CGFloat(numRows) * rowHeight) + (CGFloat(numSections) * headerHeight) + padding
    }

    // --- Action Function ---
    func confirmAction() {
        print("Confirmation button tapped. Details:")
        print(details)

        isProcessing = true // Show loading indicator

        // --- Simulate Network Request/Processing ---
        // In a real app, this would be an async API call.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Simulate 2 second delay
            // --- Mock Success/Failure ---
            let success = Bool.random() // Randomly succeed or fail for demo

             if success {
                print("Contribution successful (simulated).")
                isProcessing = false
                // Trigger navigation to a success screen
                navigateToSuccess = true
             } else {
                print("Contribution failed (simulated).")
                errorMessage = "Unable to process your contribution at this time. Please try again later or contact support."
                isProcessing = false
                showErrorAlert = true // Show the error alert
             }
        }
    }
}

// Helper View for consistent row layout
struct ReviewRow: View {
    let label: String
    let value: String
    var valueFontSize: Font = .body
    var valueFontWeight: Font.Weight = .regular

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .font(valueFontSize)
                .fontWeight(valueFontWeight)
                .foregroundColor(.gray) // Subtle styling for value
                .multilineTextAlignment(.trailing) // Handle longer values
        }
        .padding(.vertical, 2) // Small vertical padding
    }
}

// --- Preview Provider ---
struct ReviewContributionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Wrap in NavigationView for preview context
            ReviewContributionView(
                details: ContributionDetails(
                    selectedType: .roth,
                    contributionAmount: 1000.00,
                    selectedContributionYear: 2024,
                    fundingSource: FundingSource(accountName: "Primary Checking", accountNumberLast4: "1234", institution: "Global Bank")
                )
            )
        }
    }
}
