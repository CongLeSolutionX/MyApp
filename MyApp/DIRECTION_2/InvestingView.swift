//
//  HomeView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

// MARK: - Main ContentView with TabView

struct InvestingView: View {
    var body: some View {
        TabView {
            PortfolioView()
                .tabItem {
                    Label("Investing", systemImage: "chart.line.uptrend.xyaxis")
                }
                // Tag is important for programmatic selection if needed
                .tag(0)

            // Placeholder for other tabs
            Text("Settings Tab")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)

            Text("Transfer Tab")
                .tabItem {
                    Label("Transfer", systemImage: "arrow.left.arrow.right.circle")
                }
                .tag(2)
            
             Text("Cash Tab")
                .tabItem {
                    Label("Cash", systemImage: "dollarsign.circle")
                }
                .tag(3)

            Text("Account Tab")
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle")
                }
                .tag(4)
        }
         // Accent color affects the selected tab item color
        .accentColor(.black)
    }
}

// MARK: - Portfolio Tab Content View

struct PortfolioView: View {
    var body: some View {
        // Using NavigationStack for potential future navigation from chevrons
        NavigationStack {
             // Use a ScrollView to accommodate content exceeding screen height
            ScrollView {
                 // Main vertical stack for all content sections
                VStack(alignment: .leading, spacing: 20) {
                    TopBarView()
                    CashSectionView()
                    CryptoSectionView()
                    StocksSectionView()
                    Spacer() // Pushes content up if it's less than screen height
                }
                .padding(.horizontal) // Add horizontal padding to the entire content
            }
            // Hide the default Navigation Bar title area if needed, as we have a custom top bar
             .navigationBarHidden(true)
            // Ignore safe area for top to allow content potentially closer to status bar if needed
            // .ignoresSafeArea(edges: .top)
        }
    }
}

// MARK: - Top Bar View

struct TopBarView: View {
    var body: some View {
        HStack(alignment: .center) {
            // Balance Information
            VStack(alignment: .leading) {
                Text("$8,437.83")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                Text("Investing")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer() // Pushes icons to the right

            // Action Icons
            HStack(spacing: 20) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                
                // Bell icon with a notification badge overlay
                Image(systemName: "bell.fill")
                     .font(.title2)
                     .overlay(
                         Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(x: 7, y: -7), // Adjust position precisely
                         alignment: .topTrailing
                     )
            }
        }
        .padding(.top) // Add some padding from the very top edge
        .padding(.bottom, 10) // Add padding below the top bar
    }
}

// MARK: - Cash Section View

struct CashSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Section Header
            HStack {
                Text("Cash")
                    .font(.title)
                    .fontWeight(.bold)
                Image(systemName: "info.circle")
                    .foregroundColor(.gray)
                Spacer()
                // APY Badge
                Text("4% APY with Gold")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }

            // Interest Details
            InterestRowView(label: "Interest accrued this month", value: "$0.90")
            Divider()
            InterestRowView(label: "Lifetime interest paid", value: "$100.60")
            Divider()
            InterestRowView(label: "Cash earning interest", value: "$1,090.77", showInfoIcon: true)
            Divider()

            // Deposit Button/Link
            Button("Deposit cash") {
                // TODO: Action for deposit
                print("Deposit cash tapped")
            }
            .font(.headline)
            .foregroundColor(.orange) // Using orange as per screenshot
        }
    }
}

// MARK: - Crypto Section View

struct CryptoSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section Header
            HStack {
                Text("Crypto")
                    .font(.title)
                    .fontWeight(.bold)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Spacer()
            }

            // Subtitle
            HStack {
                Text("Offered by Robinhood Crypto")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Image(systemName: "info.circle")
                    .foregroundColor(.gray)
            }
            
            .padding(.bottom, 5) // Spacing after subtitle

            // Crypto Row
            CryptoRowView(
                symbol: "USDC",
                quantity: "1",
                value: "$1.00",
                graphColor: .green // Green for USDC suggests stability/pegged value
            )
            Divider()
        }
    }
}

// MARK: - Stocks & ETFs Section View

struct StocksSectionView: View {
    // Placeholder data
    let stocks = [
        StockInfo(symbol: "REAL", shares: "250.45 shares", value: "$4.76"),
        StockInfo(symbol: "XOM", shares: "4.59 shares", value: "$98.78"),
        StockInfo(symbol: "IRM", shares: "4.85 shares", value: "$76.46")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section Header
            HStack {
                Text("Stocks & ETFs")
                    .font(.title)
                    .fontWeight(.bold)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.bottom, 5)

            // List of Stocks
            VStack(spacing: 0) { // Use spacing 0 and add dividers in the row/loop
                ForEach(stocks) { stock in
                    StockRowView(stock: stock)
                    Divider()
                }
            }
        }
    }
}

// MARK: - Reusable Row Views

struct InterestRowView: View {
    let label: String
    let value: String
    var showInfoIcon: Bool = false

    var body: some View {
        HStack {
            HStack(spacing: 5) {
                Text(label)
                    .font(.subheadline)
                if showInfoIcon {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.gray)
                         .font(.caption) // Make icon slightly smaller
                }
            }
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4) // Add slight vertical padding for better spacing
    }
}

struct CryptoRowView: View {
    let symbol: String
    let quantity: String
    let value: String
    let graphColor: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(symbol)
                    .font(.headline)
                Text(quantity)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()

            // Placeholder for tiny graph
            Rectangle()
                .fill(graphColor)
                .frame(width: 40, height: 2) // Simple line placeholder
                .padding(.horizontal)

            Spacer()

            // Value Button
            Button(value) {
                // TODO: Action for crypto row
                print("\(symbol) row tapped")
            }
            .buttonStyle(.borderedProminent)
            .tint(graphColor) // Use graphColor for button background
            .font(.footnote)
            .fontWeight(.bold)
            .frame(minWidth: 60) // Ensure minimum button width
        }
         .padding(.vertical, 8)
    }
}

// Placeholder data structure for Stocks
struct StockInfo: Identifiable {
    let id = UUID()
    let symbol: String
    let shares: String
    let value: String
    let graphColor: Color = .orange // Defaulting to orange as seen in screenshot
}

struct StockRowView: View {
    let stock: StockInfo

    var body: some View {
        HStack(spacing: 15) { // Added spacing between elements
            // Stock Info (Left)
            VStack(alignment: .leading) {
                Text(stock.symbol)
                    .font(.headline)
                Text(stock.shares)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()

            // Placeholder for Sparkline Graph (Middle)
            // In a real app, this would use a charting library or custom Path drawing
            StockSparklinePlaceholder(color: stock.graphColor)
                 .frame(width: 60, height: 30) // Give placeholder a defined size

            Spacer()
            
            // Value Button (Right)
            Button(stock.value) {
                // TODO: Action for stock row
                print("\(stock.symbol) row tapped")
            }
            .buttonStyle(.borderedProminent)
            .tint(stock.graphColor) // Use stock's color for the button
            .font(.footnote)
            .fontWeight(.bold)
             .frame(minWidth: 70) // Ensure minimum button width
        }
         .padding(.vertical, 8)
    }
}

// MARK: - Placeholder Views

// Placeholder for the small sparkline graphs in stock rows
struct StockSparklinePlaceholder: View {
    let color: Color
    
    var body: some View {
        // Using a simple path to mimic a generic up/down trend
        Path { path in
            path.move(to: CGPoint(x: 0, y: 15))
            path.addLine(to: CGPoint(x: 10, y: 20))
            path.addLine(to: CGPoint(x: 20, y: 10))
            path.addLine(to: CGPoint(x: 30, y: 15))
            path.addLine(to: CGPoint(x: 40, y: 5))
            path.addLine(to: CGPoint(x: 50, y: 25))
            path.addLine(to: CGPoint(x: 60, y: 20))
        }
        .stroke(color, lineWidth: 1.5)
         // Add a dotted baseline effect (visual approximation)
         .overlay(
             Path { path in
                 path.move(to: CGPoint(x: 0, y: 15))
                 path.addLine(to: CGPoint(x: 60, y: 15))
             }
             .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 0.5, dash: [2]))
         )

    }
}

// MARK: - Preview

#Preview {
    InvestingView()
}
