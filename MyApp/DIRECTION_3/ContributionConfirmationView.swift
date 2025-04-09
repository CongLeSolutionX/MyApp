//
//  ContributionConfirmationView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

// Assume previous structs (IRAAccountType, FundingSource) are available

// Structure to hold confirmation details - create this upon successful processing
struct ContributionConfirmationDetails: Identifiable, Hashable {
    let id = UUID() // For Identifiable conformance if needed in lists
    let selectedType: IRAAccountType
    let contributionAmount: Decimal
    let selectedContributionYear: Int
    let fundingSource: FundingSource
    let transactionDate: Date // Timestamp of success
    let referenceNumber: String // Mock reference number

    // Convenience property for display
    var fundingSourceShortDisplay: String {
        return "\(fundingSource.accountName) (...\(fundingSource.accountNumberLast4))"
    }
}

// Reusable Row View for the confirmation details list
struct ReceiptRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.callout)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.callout)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4) // Adjust padding as needed
    }
}

struct ContributionConfirmationView: View {
    // Details passed upon successful confirmation
    let confirmationDetails: ContributionConfirmationDetails

    // Environment variable to dismiss the current view/sheet
    @Environment(\.dismiss) var dismiss

    // Formatters (could be shared/injected for better performance)
    private var formattedAmount: String {
        Formatters.currencyFormatter.string(from: confirmationDetails.contributionAmount as NSDecimalNumber) ?? "$0.00"
    }

    private var formattedDate: String {
        Formatters.dateFormatter.string(from: confirmationDetails.transactionDate)
    }

    var body: some View {
        VStack(spacing: 16) { // Added spacing to VStack
            Spacer() // Pushes content down from top slightly

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Contribution Successful!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 8)

            Text("Your contribution has been submitted.")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)

            // Use List for grouped styling of details
            List {
                Section(header: Text("Confirmation Details").font(.headline)) {
                    ReceiptRow(label: "Account Type", value: confirmationDetails.selectedType.rawValue)
                    ReceiptRow(label: "Amount", value: formattedAmount)
                    ReceiptRow(label: "Contribution Year", value: String(confirmationDetails.selectedContributionYear))
                    ReceiptRow(label: "From Account", value: confirmationDetails.fundingSourceShortDisplay)
                    ReceiptRow(label: "Date Processed", value: formattedDate)
                    ReceiptRow(label: "Confirmation #", value: confirmationDetails.referenceNumber)
                }
            }
            .listStyle(InsetGroupedListStyle())
            // Give the list a max height to prevent it taking too much space
            .frame(maxHeight: calculateListHeight())

            Spacer() // Pushes action buttons down

            // --- Action Buttons ---
            VStack(spacing: 10) {
                Button {
                    viewAccountAction()
                } label: {
                    Text("View Account")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    makeAnotherContributionAction()
                } label: {
                    Text("Make Another Contribution")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    dismissView()
                } label: {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent) // Primary action to close
                .padding(.top, 10) // Add space above Done button
            }
            .padding(.horizontal) // Padding for the button stack

        } // End Main VStack
        .padding(.bottom) // Overall bottom padding
        // Prevent user from swiping back to the review screen
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Confirmation")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Helper function to estimate list height
     private func calculateListHeight() -> CGFloat {
         let rowHeight: CGFloat = 35 // Adjust based on ReceiptRow padding/font
         let headerHeight: CGFloat = 40
         let padding: CGFloat = 20
         let numRows = 6 // We have 6 rows
         let numSections = 1
         let estimatedHeight = (CGFloat(numRows) * rowHeight) + (CGFloat(numSections) * headerHeight) + padding
         // Ensure a minimum height, prevent collapsing if calculation is off
         return max(estimatedHeight, 250)
     }

    // --- Action Handlers (Placeholder Implementations) ---
    func viewAccountAction() {
        print("Action: View Account Tapped")
        // TODO: Implement navigation to the specific IRA account details view
        // This likely involves using the navigation stack controller or coordinator pattern
        // to pop back multiple levels or switch tabs.
        dismiss() // Simple dismiss for now
    }

    func makeAnotherContributionAction() {
        print("Action: Make Another Contribution Tapped")
        // TODO: Implement navigation back to the start of the contribution flow
        // This might involve popping the navigation stack back to the initial screen.
        dismiss() // Simple dismiss for now
    }

    func dismissView() {
        print("Action: Done Tapped")
        // Use the dismiss environment action provided by SwiftUI
        dismiss()
        // In a more complex app, this might trigger a coordinator to reset the flow or
        // navigate back to a specific dashboard/root view.
    }
}

// Centralized Formatters (Good Practice)
struct Formatters {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

// --- Preview Provider ---
struct ContributionConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Wrap for navigation context
            ContributionConfirmationView(
                confirmationDetails: ContributionConfirmationDetails(
                    selectedType: .traditional,
                    contributionAmount: 2500.50,
                    selectedContributionYear: 2024,
                    fundingSource: FundingSource(accountName: "Savings", accountNumberLast4: "5678", institution: "Community Credit Union"),
                    transactionDate: Date(), // Use current date/time for preview
                    referenceNumber: "TRX-ABC123XYZ" // Mock reference
                )
            )
        }
    }
}
