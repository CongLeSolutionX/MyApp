////
////  TransactionDetailsView_WIP.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//
//// --- Helper View for Detail Rows ---
//
//struct DetailRow: View {
//    let label: String
//    let value: String? // Optional to handle missing data
//    var valueAlignment: Alignment = .trailing
//
//    var body: some View {
//        if let value = value, !value.isEmpty { // Only show row if value exists
//            HStack {
//                Text(label)
//                    .font(.callout)
//                    .foregroundColor(.secondary)
//                Spacer()
//                Text(value)
//                    .font(.callout)
//                    .foregroundColor(.primary)
//                    .multilineTextAlignment(valueAlignment == .trailing ? .trailing : .leading) // Adjust alignment
//            }
//            .padding(.vertical, 2) // Add minimal vertical padding
//        } else {
//            EmptyView() // Don't render anything if value is nil or empty
//        }
//    }
//}
//
//// --- Main Detail View ---
//
//struct TransactionDetailView: View {
//    let transaction: Transaction
//
//    // Formatters (reuse or define statically)
//    private static let currencyFormatter: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.currencyCode = "USD" // Or fetch from user preferences/account settings
//        return formatter
//    }()
//
//    private static let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .long
//        formatter.timeStyle = .short
//        return formatter
//    }()
//
//    private static let numberFormatter: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.minimumFractionDigits = 2
//        formatter.maximumFractionDigits = 5 // Allow more for quantity/price
//        return formatter
//    }()
//
//    // Helper to format currency
//    private func formatCurrency(_ decimal: Decimal?) -> String? {
//        guard let decimal = decimal else { return nil }
//        return Self.currencyFormatter.string(from: decimal as NSDecimalNumber)
//    }
//
//    // Helper to format numbers (like quantity)
//     private func formatNumber(_ decimal: Decimal?) -> String? {
//         guard let decimal = decimal else { return nil }
//         return Self.numberFormatter.string(from: decimal as NSDecimalNumber)
//     }
//
//    // Helper for Status Color
//    private func statusColor(_ status: String) -> Color {
//        switch status.lowercased() {
//        case "completed": return .green
//        case "pending": return .orange
//        case "failed", "cancelled": return .red
//        default: return .gray
//        }
//    }
//
//    // Helper for Transaction Type Icon
//    private func transactionIconName(_ type: TransactionType) -> String {
//        switch type {
//        case .contribution: return "arrow.down.circle.fill"
//        case .withdrawal: return "arrow.up.circle.fill"
//        case .dividend: return "giftcard.fill"
//        case .interest: return "percent"
//        case .buy: return "cart.fill.badge.plus"
//        case .sell: return "dollarsign.circle.fill"
//        }
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 15) { // Add spacing between sections
//
//                // --- Header ---
//                VStack(spacing: 5) {
//                    Image(systemName: transactionIconName(transaction.type))
//                        .font(.largeTitle)
//                        .foregroundStyle(transaction.isDebit ? .red : .green)
//                        .padding(.bottom, 5)
//
//                    Text(formatCurrency(transaction.amount) ?? "N/A")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundStyle(transaction.isDebit ? .red : .green)
//
//                    Text(transaction.description)
//                        .font(.headline)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal)
//
//                    Text(transaction.status)
//                        .font(.caption)
//                        .fontWeight(.medium)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 3)
//                        .background(statusColor(transaction.status).opacity(0.2))
//                        .foregroundColor(statusColor(transaction.status))
//                        .cornerRadius(5)
//                }
//                .frame(maxWidth: .infinity, alignment: .center) // Center the header content
//                .padding(.vertical) // Add padding around the header
//
//                Divider()
//
//                // --- General Details ---
//                VStack(alignment: .leading, spacing: 8) { // Consistent spacing within section
//                    Text("Details").font(.title3).fontWeight(.semibold) // Section Header
//                    DetailRow(label: "Date", value: Self.dateFormatter.string(from: transaction.date))
//                    DetailRow(label: "Type", value: transaction.type.rawValue)
//                    DetailRow(label: "Transaction ID", value: transaction.transactionId)
//                    DetailRow(label: "Running Balance", value: formatCurrency(transaction.runningBalance))
//                }
//                .padding(.horizontal) // Add padding to sections
//
//                // --- Conditional Trade Details ---
//                if transaction.type == .buy || transaction.type == .sell {
//                    Divider()
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Trade Information").font(.title3).fontWeight(.semibold)
//                        let securityDisplay = [transaction.securitySymbol, transaction.securityName].compactMap { $0 }.joined(separator: " - ")
//                        DetailRow(label: "Security", value: securityDisplay.isEmpty ? nil : securityDisplay, valueAlignment: .leading)
//                        DetailRow(label: "Quantity", value: formatNumber(transaction.quantity))
//                        DetailRow(label: "Price per Share", value: formatCurrency(transaction.pricePerShare))
//                         DetailRow(label: "Fees", value: formatCurrency(transaction.fees))
//                         // Calculate and show Total Cost/Proceeds if needed
//                         if let quantity = transaction.quantity, let price = transaction.pricePerShare {
//                             let baseAmount = quantity * price
//                             let total = transaction.isDebit ? (baseAmount + (transaction.fees ?? 0)) : (baseAmount - (transaction.fees ?? 0))
//                             DetailRow(label: transaction.isDebit ? "Total Cost" : "Total Proceeds", value: formatCurrency(total))
//                         }
//
//                    }
//                    .padding(.horizontal)
//                }
//
//                // --- Conditional Income Details ---
//                if transaction.type == .dividend || transaction.type == .interest {
//                     Divider()
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Income Information").font(.title3).fontWeight(.semibold)
//                         DetailRow(label: "Source", value: transaction.sourceDescription)
//                    }
//                    .padding(.horizontal)
//                }
//
//                 // --- Conditional Transfer Details ---
//                 if transaction.type == .contribution || transaction.type == .withdrawal {
//                     Divider()
//                    VStack(alignment: .leading, spacing: 8) {
//                         Text("Transfer Information").font(.title3).fontWeight(.semibold)
//                         DetailRow(label: "Method", value: transaction.method)
//                         // Could add Source/Destination Account if available
//                    }
//                    .padding(.horizontal)
//                 }
//
//                // --- Optional Footer Actions ---
//                Divider()
//                VStack(alignment: .center) {
//                    Button {
//                        // Action for reporting issue
//                        print("Report Issue Tapped for Transaction ID: \(transaction.transactionId ?? "N/A")")
//                    } label: {
//                        Label("Report Issue with Transaction", systemImage: "exclamationmark.bubble.fill")
//                    }
//                    .buttonStyle(.bordered)
//                    .padding(.top) // Add padding above the button
//                }
//                 .frame(maxWidth: .infinity, alignment: .center)
//                 .padding(.horizontal)
//
//            } // End Main VStack
//             .padding(.bottom) // Ensure bottom padding inside ScrollView
//
//        } // End ScrollView
//        .navigationTitle("Transaction Details")
//        .navigationBarTitleDisplayMode(.inline) // Keep title compact
//    }
//}
//
//// --- Update Previous Screen (FullTransactionHistoryView) ---
//// Inside the ForEach loop where TransactionRow is used, wrap it in a NavigationLink:
//
///*
//   // In FullTransactionHistoryView.swift -> List -> Section -> ForEach loop
//
//   ForEach(transactionsInSection) { transaction in
//       NavigationLink(destination: TransactionDetailView(transaction: transaction)) { // <-- Wrap here
//            TransactionRow(transaction: transaction)
//       }
//   }
//
//*/
//
//// --- Preview Provider ---
//struct TransactionDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            TransactionDetailView(transaction: sampleBuyTransaction)
//        }
//        .previewDisplayName("Buy Transaction")
//
//        NavigationView {
//            TransactionDetailView(transaction: sampleDividendTransaction)
//        }
//        .previewDisplayName("Dividend Transaction")
//
//         NavigationView {
//             TransactionDetailView(transaction: sampleWithdrawalTransaction)
//         }
//         .previewDisplayName("Withdrawal Transaction")
//    }
//
//    // Sample Data for Previews
//    static let sampleBuyTransaction = Transaction(
//        date: Date().addingTimeInterval(-86400 * 5), // 5 days ago
//        description: "Buy Vanguard Total Stock Market ETF",
//        type: .buy,
//        amount: 2450.75, // The total cost cash impact
//        status: "Completed",
//        transactionId: "TX-BUY-9876",
//        runningBalance: 12345.67,
//        securitySymbol: "VTI",
//        securityName: "Vanguard Total Stock Market ETF",
//        quantity: 10,
//        pricePerShare: 244.50,
//        fees: 5.75
//    )
//
//    static let sampleDividendTransaction = Transaction(
//        date: Date().addingTimeInterval(-86400 * 10), // 10 days ago
//        description: "Dividend - Apple Inc.",
//        type: .dividend,
//        amount: 55.20,
//        status: "Completed",
//        transactionId: "TX-DIV-ABCDE",
//        runningBalance: 14851.62,
//        sourceDescription: "Apple Inc. (AAPL) Q1 Dividend"
//    )
//
//    static let sampleWithdrawalTransaction = Transaction(
//        date: Date().addingTimeInterval(-86400 * 2), // 2 days ago
//        description: "Withdrawal to CHK...1234",
//        type: .withdrawal,
//        amount: 500.00,
//        status: "Pending",
//        transactionId: "TX-W/D-FGHIJ",
//        runningBalance: 14351.62,
//        method: "ACH Transfer"
//    )
//}
