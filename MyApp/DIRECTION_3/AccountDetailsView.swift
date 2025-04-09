//
//  AccountDetailsView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
// import Charts // Uncomment if using SwiftUI Charts

// --- Mock Data Models ---

enum TransactionType: String, CaseIterable, Identifiable {
    case contribution = "Contribution"
    case withdrawal = "Withdrawal"
    case dividend = "Dividend"
    case interest = "Interest"
    case buy = "Buy"
    case sell = "Sell"

    var id: String { self.rawValue }

    var displayColor: Color {
        switch self {
        case .contribution, .dividend, .interest, .buy: return .green
        case .withdrawal, .sell: return .red
        }
    }
}

struct Transaction: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let description: String
    let type: TransactionType
    let amount: Decimal
    let status: String? // e.g., "Pending", "Completed"

    var formattedAmount: String {
        let plusMinus = (type == .withdrawal || type == .sell) ? "-" : "+"
        let valueString = Formatters.currencyFormatter.string(from: abs(amount) as NSDecimalNumber) ?? "$0.00"
        return "\(plusMinus)\(valueString)"
    }

    var formattedDate: String {
         Formatters.shortDateFormatter.string(from: date)
    }
}

struct AccountDetails: Identifiable {
    let id: String // Account Number or unique ID
    let accountType: IRAAccountType
    let maskedAccountNumber: String
    let ownerName: String
    let currentBalance: Decimal
    let balanceChangeToday: Decimal // For display only in mock
    let balanceChangePercentToday: Double // For display only in mock
    let contributionLimitThisYear: Decimal // Example: 2024 limit
    let recentTransactions: [Transaction]

    // Convenience Formatters
    var formattedBalance: String {
        Formatters.currencyFormatter.string(from: currentBalance as NSDecimalNumber) ?? "$0.00"
    }

    var formattedContributionLimit: String {
        Formatters.currencyFormatter.string(from: contributionLimitThisYear as NSDecimalNumber) ?? "$?.??"
    }

     var formattedBalanceChange: String {
        let plusMinus = balanceChangeToday >= 0 ? "+" : ""
        let amountString = Formatters.currencyFormatter.string(from: abs(balanceChangeToday) as NSDecimalNumber) ?? "$0.00"
        let percentString = String(format: "%.2f%%", abs(balanceChangePercentToday * 100))
        let sign = balanceChangeToday >= 0 ? "+" : "" // Percent sign already handled by abs
        return "\(plusMinus)\(amountString) (\(sign)\(percentString)) Today"
    }

    var balanceChangeColor: Color {
        balanceChangeToday >= 0 ? .green : .red
    }
}

// --- Reusable Subviews ---

struct InfoRow: View {
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
        .padding(.vertical, 4)
    }
}

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack(spacing: 4) {
                     Text(transaction.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                     if let status = transaction.status {
                         Text("(\(status))")
                              .font(.caption)
                              .foregroundColor(.orange) // Indicate pending status visually
                     }
                }
            }
            Spacer()
            Text(transaction.formattedAmount)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(transaction.type.displayColor)
        }
        .padding(.vertical, 6)
    }
}

// --- Main View ---

struct AccountDetailsView: View {
    // In a real app, this would be fetched via a ViewModel (@StateObject)
    let accountDetails: AccountDetails

    // Placeholder for Navigation Link Active State
    @State private var showingAllTransactions = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Account Header
                Text("\(accountDetails.accountType.rawValue) \(accountDetails.maskedAccountNumber)")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                    .padding(.top) // Add padding at the top of the scroll content

                // Balance Section
                VStack(alignment: .leading) {
                    Text("Current Balance")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Text(accountDetails.formattedBalance)
                        .font(.system(size: 36, weight: .bold))
                        // Allow balance to wrap if extremely large
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                     // Optional Balance Change
                     Text(accountDetails.formattedBalanceChange)
                          .font(.subheadline)
                          .fontWeight(.medium)
                          .foregroundColor(accountDetails.balanceChangeColor)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                // --- Optional Performance Chart ---
                // Replace with actual chart implementation if needed
                VStack {
//                    Chart {
//                        // Chart content goes here... requires data mapping
//                    }
//                    .frame(height: 150)
                    Rectangle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 150)
                        .overlay(Text("Performance Chart Area").font(.caption).foregroundColor(.secondary))
                }
                .padding(.horizontal)
                .padding(.bottom)

                // --- List Section for Info and Transactions ---
                 // Wrapping List in VStack and giving it a frame helps control its size
                 // within the ScrollView, preventing nested scroll issues.
                List {
                    Section(header: Text("Key Information").font(.headline)) {
                        InfoRow(label: "Account Type", value: accountDetails.accountType.rawValue)
                        InfoRow(label: "Account Number", value: accountDetails.maskedAccountNumber)
                        InfoRow(label: "Owner", value: accountDetails.ownerName)
                        InfoRow(label: "Contribution Limit (2024)", value: accountDetails.formattedContributionLimit)
                    }

                    Section(header: Text("Recent Transactions").font(.headline)) {
                        ForEach(accountDetails.recentTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }

                        // NavigationLink to full transaction history
                        NavigationLink(destination: FullTransactionHistoryView(accountId: accountDetails.id), isActive: $showingAllTransactions) {
                             Text("View All Transactions")
                                 .font(.callout)
                                 .foregroundColor(.accentColor) // Use theme color
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Use PlainListStyle inside ScrollView
                // Calculate a sensible height based on content. Adjust as needed.
                .frame(height: calculateListHeight())
                .padding(.horizontal) // Add padding to List if needed

                // Action Buttons
                VStack(spacing: 10) {
                     Button { contributeAction() } label: {
                          Label("Contribute", systemImage: "plus.circle.fill")
                               .frame(maxWidth: .infinity)
                     }
                     .buttonStyle(.borderedProminent)

                     Button { withdrawAction() } label: {
                           Label("Withdraw", systemImage: "minus.circle.fill")
                               .frame(maxWidth: .infinity)
                     }
                     .buttonStyle(.bordered)

                     Button { statementsAction() } label: {
                          Label("View Statements", systemImage: "doc.text.fill")
                               .frame(maxWidth: .infinity)
                     }
                     .buttonStyle(.bordered)
                }
                .padding() // Padding around the button section

            } // End Main VStack in ScrollView
        } // End ScrollView
        .background(Color(UIColor.systemGroupedBackground)) // Match List background if needed
        .navigationTitle("Account Details") // Or use the Account Name
        .navigationBarTitleDisplayMode(.inline)
    }

     // --- Helper Functions ---
     private func calculateListHeight() -> CGFloat {
         // Estimate height: Adjust these values based on your Row heights and padding
         let infoRowCount = 4.0
         let transactionRowCount = min(Double(accountDetails.recentTransactions.count), 5.0) // Show max 5 recent initially
         let viewAllRowHeight = 1.0
         let rowHeightEstimate: CGFloat = 45
         let headerHeightEstimate: CGFloat = 35
         let sectionPadding: CGFloat = 20

         let infoSectionHeight = (infoRowCount * rowHeightEstimate) + headerHeightEstimate + sectionPadding
         let transactionSectionHeight = (transactionRowCount * rowHeightEstimate) + viewAllRowHeight * rowHeightEstimate + headerHeightEstimate + sectionPadding

         // Add some buffer
         let totalHeight = infoSectionHeight + transactionSectionHeight + 30
         // Set practical min/max heights
         return max(300, min(totalHeight, 600))
     }

    // --- Action Handlers (Placeholders) ---
    func contributeAction() {
        print("Action: Contribute Tapped for account \(accountDetails.id)")
        // TODO: Navigate back to the contribution flow, potentially pre-filling account info
    }

    func withdrawAction() {
        print("Action: Withdraw Tapped for account \(accountDetails.id)")
        // TODO: Navigate to the withdrawal flow
    }

    func statementsAction() {
        print("Action: View Statements Tapped for account \(accountDetails.id)")
        // TODO: Navigate to a statements view/PDF viewer
    }
}

// --- Placeholder for Full Transaction History ---
struct FullTransactionHistoryView: View {
    let accountId: String
    var body: some View {
        Text("Full Transaction History for Account \(accountId)")
            .navigationTitle("All Transactions")
    }
}

// --- Additional Formatters ---
extension Formatters { // Extend the existing Formatters struct
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy" // e.g., "Jan 5, 2024"
        return formatter
    }()
}

// --- Preview Provider ---
struct AccountDetailsView_Previews: PreviewProvider {
    static let mockDetails = AccountDetails(
        id: "IRA-TRAD-1234",
        accountType: .traditional,
        maskedAccountNumber: "(...1234)",
        ownerName: "Jane Doe",
        currentBalance: 52750.50,
        balanceChangeToday: 150.25, // Mock positive change
        balanceChangePercentToday: 0.00285, // Mock positive change %
        contributionLimitThisYear: 7000.00, // Example 2024 limit
        recentTransactions: [
            Transaction(date: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, description: "Contribution - 2024", type: .contribution, amount: 2500.50, status: "Completed"), // The one just made!
            Transaction(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, description: "Dividend Reinvestment - VTI", type: .dividend, amount: 55.10, status: "Completed"),
            Transaction(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, description: "Buy - VTI", type: .buy, amount: 1500.00, status: "Completed"),
            Transaction(date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, description: "Contribution - 2023", type: .contribution, amount: 1000.00, status: "Completed"),
             Transaction(date: Calendar.current.date(byAdding: .month, value: -2, to: Date())!, description: "Withdrawal - Transfer Out", type: .withdrawal, amount: 500.00, status: "Completed")
        ]
    )

    static var previews: some View {
        NavigationView {
            AccountDetailsView(accountDetails: mockDetails)
        }
    }
}
