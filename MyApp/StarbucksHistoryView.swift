//
//  StarbucksHistoryView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// Define transaction types
enum TransactionType {
    case inStoreOrder
    case reload
    // Add other types if needed (e.g., mobileOrder, eGift)
}

// Define the structure for a single transaction
struct Transaction: Identifiable {
    let id = UUID()
    let type: TransactionType
    let iconName: String
    let title: String
    let detailLine1: String // e.g., Payment method or "Cash"
    let detailLine2: String? // e.g., Location
    let amount: Double
    let starsEarned: Double?
    let date: String // Simple string for display purposes
    let isPositiveAmount: Bool // For reload styling
}

// Sample Data Provider
struct SampleData {
    static let transactions: [Transaction] = [
        Transaction(type: .inStoreOrder, iconName: "doc.text.fill", title: "In-store order", detailLine1: "My Card (7668)", detailLine2: "ORD T3 Gate K4", amount: 9.89, starsEarned: 17.7, date: "2/17/25", isPositiveAmount: false),
        Transaction(type: .reload, iconName: "dollarsign.circle.fill", title: "Reload", detailLine1: "My Card (7668)", detailLine2: nil, amount: 25.00, starsEarned: nil, date: "2/17/25", isPositiveAmount: true),
        Transaction(type: .inStoreOrder, iconName: "doc.text.fill", title: "In-store order", detailLine1: "My Card (7668)", detailLine2: "Grand & Wabash", amount: 6.33, starsEarned: 11.3, date: "2/17/25", isPositiveAmount: false),
        Transaction(type: .inStoreOrder, iconName: "doc.text.fill", title: "In-store order", detailLine1: "Cash", detailLine2: "Grand & Wabash", amount: 0.10, starsEarned: 0.1, date: "2/17/25", isPositiveAmount: false),
        Transaction(type: .inStoreOrder, iconName: "doc.text.fill", title: "In-store order", detailLine1: "My Card (7668)", detailLine2: "ORD T3 Gate K4", amount: 9.89, starsEarned: 17.7, date: "2/14/25", isPositiveAmount: false),
    ]
}

// Custom Starbucks Green Color
extension Color {
//    static let starbucksGreen = Color(red: 0, green: 0.44, blue: 0.29) // Approximate #00704A
    static let lightGrayBackground = Color(UIColor.systemGray6) // Background color
}


import SwiftUI

// MARK: - Main History Screen View
struct StarbucksHistoryView: View {
    @State private var selectedTab: HistoryTab = .ordersRewards
    @State private var selectedMainTab: MainTab = .gift // Set the default selected tab

    enum HistoryTab: String, CaseIterable {
        case ordersRewards = "Orders & Rewards"
        case eGift = "eGift"
    }

    enum MainTab {
        case home, scan, order, gift, offers
    }

    var body: some View {
        // Use TabView for the bottom navigation
        TabView(selection: $selectedMainTab) {
            // Placeholder views for other tabs
            Text("Home Screen").tabItem { Label("Home", systemImage: "house.fill") }.tag(MainTab.home)
            Text("Scan Screen").tabItem { Label("Scan", systemImage: "qrcode.viewfinder") }.tag(MainTab.scan)
            Text("Order Screen").tabItem { Label("Order", systemImage: "cup.and.saucer.fill") }.tag(MainTab.order)

            // The actual History Screen content goes in the "Gift" tab as per the screenshot
            NavigationView {
                VStack(spacing: 0) {
                    TopTabView(selectedTab: $selectedTab)

                    // Content Area based on selected top tab
                    if selectedTab == .ordersRewards {
                        HistoryListView(transactions: SampleData.transactions)
                    } else {
                        // Placeholder for eGift content
                        Spacer()
                        Text("eGift History Goes Here")
                        Spacer()
                    }
                }
                .navigationTitle("History")
                .navigationBarTitleDisplayMode(.large) // Large title style
                .background(Color.lightGrayBackground) // Set background for the content area
                .toolbar { // Add back button simulation (usually handled by NavigationView push)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            // Action for back button
                            print("Back button tapped")
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primary) // Use primary color for nav items
                        }
                    }
                }
            }
            .tabItem { Label("Gift", systemImage: "gift.fill") } // Force fill for active state later if needed
            .tag(MainTab.gift)
            .accentColor(.starbucksGreen) // Set accent color for the TabView

            Text("Offers Screen").tabItem { Label("Offers", systemImage: "star.fill") }.tag(MainTab.offers)
        }
         // Apply accent color globally to TabView items when selected
        .accentColor(.starbucksGreen)
    }
}

// MARK: - Top Tab Selector View
struct TopTabView: View {
    @Binding var selectedTab: StarbucksHistoryView.HistoryTab

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(StarbucksHistoryView.HistoryTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    } label: {
                        Text(tab.rawValue)
                            .font(.system(size: 16, weight: .medium))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(selectedTab == tab ? .primary : .secondary)
                    }
                }
            }
            .padding(.horizontal)
             // Underline Indicator
            HStack {
                ForEach(StarbucksHistoryView.HistoryTab.allCases, id: \.self) { tab in
                    Rectangle()
                        .fill(selectedTab == tab ? Color.starbucksGreen : Color.clear)
                        .frame(height: 3)

                }
            }
            // Explicit divider below tabs
            Divider().background(Color(UIColor.systemGray4))

        }
//        .background(Color.systemBackground) // Give the tab bar a background
    }
}

// MARK: - History List View
struct HistoryListView: View {
    let transactions: [Transaction]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) { // Pin section header
                Section {
                    ForEach(transactions) { transaction in
                        TransactionRowView(transaction: transaction)
                        Divider() // Separator between rows
                            .padding(.leading, 55) // Indent divider like in the screenshot
                    }
                } header: {
                    Text("February") // Section Header
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.lightGrayBackground) // Keep header background consistent
                }
            }
        }
        .background(Color.lightGrayBackground) // Set background for the ScrollView area
    }
}

// MARK: - Transaction Row View
struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            // Icon
            Image(systemName: transaction.iconName)
                .font(.title2)
                .foregroundColor(.secondary)
                .frame(width: 25, alignment: .center) // Align icons horizontally

            // Center Content (Title, Details)
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(transaction.detailLine1)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let detail2 = transaction.detailLine2 {
                    Text(detail2)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer() // Pushes content to sides

            // Right Content (Amount, Stars, Date)
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(transaction.isPositiveAmount ? "+" : "")$\(String(format: "%.2f", transaction.amount))")
                    .font(.headline)
                    .foregroundColor(transaction.isPositiveAmount ? .starbucksGreen : .primary)

                if let stars = transaction.starsEarned {
                    HStack(spacing: 2) {
                        Text(String(format: "%.1f", stars))
                        Image(systemName: "star.fill")
                        Text("earned")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                 Text(transaction.date)
                    .font(transaction.starsEarned == nil ? .subheadline : .caption) // Adjust date font size if stars are absent
                    .foregroundColor(.secondary)

            }

             // Disclosure Indicator (Chevron) - Conditionally shown
            if transaction.type == .inStoreOrder {
                 Image(systemName: "chevron.right")
                     .foregroundColor(.secondary.opacity(0.5))
                     .padding(.leading, 5)
            } else {
                // Add padding to align with rows that *do* have a chevron
                Spacer().frame(width: 15) // Approximate width of chevron + padding
            }

        }
        .padding(.horizontal)
        .padding(.vertical, 12)
//        .background(Color.systemBackground) // Rows have white background
    }
}

// MARK: - Preview
struct StarbucksHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        StarbucksHistoryView()
    }
}
