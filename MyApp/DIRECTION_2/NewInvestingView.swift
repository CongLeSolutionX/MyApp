//
//  NewInvestingView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//


import SwiftUI

// MARK: - Main ContentView with TabView (Unchanged)
struct NewInvestingView: View {
    var body: some View {
        TabView {
            PortfolioView()
                .tabItem {
                    Label("Investing", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(0)

            Text("Settings Tab")
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(1)

            Text("Transfer Tab")
                .tabItem { Label("Transfer", systemImage: "arrow.left.arrow.right.circle") }
                .tag(2)
            
             Text("Cash Tab")
                .tabItem { Label("Cash", systemImage: "dollarsign.circle") }
                .tag(3)

            Text("Account Tab")
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
                .tag(4)
        }
        .accentColor(.black)
    }
}
#Preview("NewInvestingView") {
    NewInvestingView()
    
}
// MARK: - Portfolio Tab Content View (Unchanged)
struct PortfolioView: View {
    var body: some View {
        NavigationStack { // Ensure NavigationStack wraps the content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TopBarView()
                    //CashSectionView()
                    //CryptoSectionView()
                    //StocksSectionView() // Modified below to include NavigationLinks
                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
        }
    }
}
#Preview("PortfolioView") {
    PortfolioView()
}

// MARK: - Top Bar View (Unchanged) - Add Back if needed
struct TopBarView: View {
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text("$8,437.83")
                    .font(.largeTitle).fontWeight(.medium)
                Text("Investing")
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            HStack(spacing: 20) {
                Image(systemName: "magnifyingglass").font(.title2)
                Image(systemName: "bell.fill").font(.title2)
                     .overlay(Circle().fill(Color.red).frame(width: 8, height: 8).offset(x: 7, y: -7), alignment: .topTrailing)
            }
        }
        .padding(.top).padding(.bottom, 10)
    }
}
#Preview("TopBarView") {
    TopBarView()
}

//
//
//// MARK: - Cash Section View (Unchanged) - Add Back if needed
//struct CashSectionView: View {
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            HStack {
//                Text("Cash").font(.title).fontWeight(.bold)
//                Image(systemName: "info.circle").foregroundColor(.gray)
//                Spacer()
//                Text("4% APY with Gold").font(.caption).fontWeight(.medium).padding(.vertical, 4).padding(.horizontal, 8).background(Color.gray.opacity(0.2)).cornerRadius(10)
//            }
//            InterestRowView(label: "Interest accrued this month", value: "$0.90")
//            Divider()
//            InterestRowView(label: "Lifetime interest paid", value: "$100.60")
//            Divider()
//            InterestRowView(label: "Cash earning interest", value: "$1,090.77", showInfoIcon: true)
//            Divider()
//            Button("Deposit cash") { print("Deposit cash tapped") }
//                .font(.headline).foregroundColor(.orange)
//        }
//    }
//}
//
// MARK: - Crypto Section View (Unchanged) - Add Back if needed
struct CryptoSectionView: View {
     var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Crypto").font(.title).fontWeight(.bold)
                Image(systemName: "chevron.right").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                Spacer()
            }
            HStack {
                Text("Offered by Robinhood Crypto").font(.caption).foregroundColor(.secondary)
                Image(systemName: "info.circle").foregroundColor(.gray)
            }
            .padding(.bottom, 5)
            CryptoRowView(symbol: "USDC", quantity: "1", value: "$1.00", graphColor: .green)
            Divider()
        }
    }
}
#Preview("CryptoSectionView") {
    CryptoSectionView()
}

// MARK: - Stocks & ETFs Section View (MODIFIED)

struct StocksSectionView: View {
    // Placeholder data - IMPORTANT: Add company names for the detail view title
    let stocks = [
        StockInfo(symbol: "REAL", companyName: "The RealReal, Inc.", shares: "250.45 shares", value: "$4.76", graphColor: .red), // Example: Red for down
        StockInfo(symbol: "XOM", companyName: "Exxon Mobil Corp.", shares: "4.59 shares", value: "$98.78", graphColor: .green), // Example: Green for up
        StockInfo(symbol: "IRM", companyName: "Iron Mountain Inc.", shares: "4.85 shares", value: "$76.46", graphColor: .green)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Stocks & ETFs")
                    .font(.title).fontWeight(.bold)
                // Maybe make this chevron navigate to a full list screen later
                Image(systemName: "chevron.right")
                    .font(.caption).fontWeight(.bold).foregroundColor(.gray)
                Spacer()
            }
            .padding(.bottom, 5)

            // List of Stocks - Each row is now a NavigationLink
            VStack(spacing: 0) {
                ForEach(stocks) { stock in
                    // NavigationLink wraps the entire row content
                    NavigationLink(destination: StockDetailView(stockInfo: stock)) {
                        StockRowView(stock: stock)
                            // Apply contentShape to make the whole link area tappable easily
                            .contentShape(Rectangle())
                    }
                    // Make the NavLink look like plain content, not a blue link
                    .buttonStyle(PlainButtonStyle())
                    Divider()
                }
            }
        }
    }
}

//// Placeholder data structure for Stocks (MODIFIED)
//struct StockInfo: Identifiable {
//    let id = UUID()
//    let symbol: String
//    let companyName: String // Added for detail view
//    let shares: String
//    let value: String // Current Price per share
//    let graphColor: Color // Indicates if price is up (green) or down (red) today
//}
//
//
// MARK: - Stock Row View 

//// MARK: - NEW: Stock Detail View
//
//struct StockDetailView: View {
//    // Receive the basic info to identify the stock
//    let stockInfo: StockInfo
//
//    // Mock data specific to the detail view
//    // In a real app, this would be fetched based on stockInfo.symbol
//    @State private var detailData = StockDetailData.mockData // Use static mock data
//
//    // State for the selected time range picker
//    @State private var selectedTimeRange: TimeRange = .oneDay
//
//    enum TimeRange: String, CaseIterable, Identifiable {
//        case oneDay = "1D"
//        case oneWeek = "1W"
//        case oneMonth = "1M"
//        case threeMonths = "3M"
//        case oneYear = "1Y"
//        case all = "All"
//        var id: String { self.rawValue }
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 25) { // Increased spacing
//                // 1. Header Info
//                StockDetailHeader(stockInfo: stockInfo, detailData: detailData)
//
//                // 2. Chart View
//                VStack {
//                    DetailedStockChartPlaceholder(color: detailData.dayChange >= 0 ? .green : .red)
//                         .frame(height: 200) // Give chart more height
//                    
//                    Picker("Time Range", selection: $selectedTimeRange) {
//                        ForEach(TimeRange.allCases) { range in
//                            Text(range.rawValue).tag(range)
//                        }
//                    }
//                    .pickerStyle(.segmented)
//                    // TODO: Update chart based on selectedTimeRange
//                }
//
//                Divider()
//
//                // 3. Your Position Section
//                YourPositionView(positionData: detailData.userPosition)
//
//                Divider()
//
//                // 4. Stats Section
//                StatsView(statsData: detailData.stats)
//
//                Divider()
//                
//                // 5. Action Buttons
//                ActionButtonsView()
//
//                Divider()
//
//                // 6. About Section
//                AboutSectionView(aboutText: detailData.about)
//
//            }
//            .padding() // Add padding around the entire content
//        }
//        // Set the navigation bar title using the company name
//        .navigationTitle(stockInfo.companyName)
//        // Display mode inline is common for detail views
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// MARK: - Stock Detail Subviews
//
//struct StockDetailHeader: View {
//    let stockInfo: StockInfo
//    let detailData: StockDetailData
//    
//    var priceChangeColor: Color {
//        detailData.dayChange >= 0 ? .green : .red
//    }
//     var priceChangePrefix: String {
//        detailData.dayChange >= 0 ? "+" : ""
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//              Text(stockInfo.companyName) // Or use detailData.companyName if available
//                .font(.caption)
//                .foregroundStyle(.secondary)
//              Text(String(format: "$%.2f", detailData.currentPrice))
//                .font(.largeTitle)
//                .fontWeight(.semibold)
//        
//            HStack(spacing: 8) {
//                  Text(String(format: "%@$%.2f", priceChangePrefix, abs(detailData.dayChange)))
//                  Text(String(format: "(%@%.2f%%)", priceChangePrefix, abs(detailData.dayChangePercent)))
//            }
//             .font(.headline)
//            .foregroundColor(priceChangeColor)
//            
//            Text("Today") // Context for the change
//                .font(.caption)
//                .foregroundStyle(.secondary)
//        }
//    }
//}
//
//
//struct DetailedStockChartPlaceholder: View {
//    let color: Color
//    var body: some View {
//        // More complex placeholder than sparkline
//        RoundedRectangle(cornerRadius: 8)
//            .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
//            .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
//            .overlay(
//                GeometryReader { geo in
//                    Path { path in
//                         // Simulate some chart data points
//                        let dataPoints: [CGFloat] = [0.6, 0.5, 0.7, 0.6, 0.8, 0.75, 0.9, 0.8, 0.85]
//                        let stepX = geo.size.width / CGFloat(dataPoints.count - 1)
//                        
//                        path.move(to: CGPoint(x: 0, y: geo.size.height * (1 - dataPoints[0])))
//                        
//                         for i in 1..<dataPoints.count {
//                             path.addLine(to: CGPoint(x: CGFloat(i) * stepX, y: geo.size.height * (1 - dataPoints[i])))
//                         }
//                    }
//                    .stroke(color, lineWidth: 2)
//                }
//                 .padding(10) // Padding inside the border
//            )
//    }
//}
//
//
//struct YourPositionView: View {
//    let positionData: StockPosition
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Your Position")
//                .font(.title2)
//                .fontWeight(.semibold)
//
//            // Using Grid for alignment
//            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 8) {
//                GridRow {
//                    Text("Shares").foregroundStyle(.secondary)
//                    Text(String(format: "%.4f", positionData.shares))
//                }
//                GridRow {
//                    Text("Market Value").foregroundStyle(.secondary)
//                    Text(String(format: "$%.2f", positionData.marketValue))
//                }
//                GridRow {
//                    Text("Average Cost").foregroundStyle(.secondary)
//                    Text(String(format: "$%.2f", positionData.averageCost))
//                }
//                 GridRow {
//                    Text("Today's Return").foregroundStyle(.secondary)
//                    ReturnTextView(value: positionData.todaysReturn, percentage: positionData.todaysReturnPercent)
//                }
//                  GridRow {
//                    Text("Total Return").foregroundStyle(.secondary)
//                   ReturnTextView(value: positionData.totalReturn, percentage: positionData.totalReturnPercent)
//                }
//            }
//             .font(.subheadline) // Apply font to the whole grid
//        }
//    }
//}
//
//// Helper view for return values with color coding
//struct ReturnTextView: View {
//    let value: Double
//    let percentage: Double? // Optional percentage
//    
//     var returnColor: Color {
//        value >= 0 ? .green : .red
//    }
//     var returnPrefix: String {
//        value >= 0 ? "+" : ""
//    }
//
//    var body: some View {
//         HStack(spacing: 4) {
//              Text(String(format: "%@$%.2f", returnPrefix, abs(value)))
//             if let percentage = percentage {
//                Text(String(format: "(%@%.2f%%)", returnPrefix, abs(percentage)))
//             }
//        }
//        .foregroundColor(returnColor)
//        .fontWeight(.medium)
//    }
//}
//
//struct StatsView: View {
//    let statsData: StockStats
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Stats")
//                .font(.title2)
//                .fontWeight(.semibold)
//
//            // Grid for two columns of stats
//             Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 8) {
//                GridRow {
//                    StatItem(label: "Market Cap", value: formatMarketCap(statsData.marketCap))
//                    StatItem(label: "P/E Ratio", value: String(format: "%.2f", statsData.peRatio))
//                }
//                 GridRow {
//                    StatItem(label: "Volume", value: formatVolume(statsData.volume))
//                    StatItem(label: "Avg Volume", value: formatVolume(statsData.avgVolume))
//                }
//                 GridRow {
//                    StatItem(label: "52wk High", value: String(format: "$%.2f", statsData.high52Week))
//                     StatItem(label: "52wk Low", value: String(format: "$%.2f", statsData.low52Week))
//                }
//                  GridRow {
//                    StatItem(label: "Div/Yield", value: statsData.dividendYield > 0 ? String(format: "%.2f%%", statsData.dividendYield) : "--")
//                     // Add another stat if needed or leave empty
//                     Text("").gridCellColumns(1) // Placeholder for alignment if needed
//                 }
//             }
//             .font(.subheadline)
//        }
//    }
//    
//    // Helper View for individual stat item
//    struct StatItem: View {
//        let label: String
//        let value: String
//        
//        var body: some View {
//            VStack(alignment: .leading, spacing: 2) {
//                Text(label).foregroundStyle(.secondary)
//                Text(value).fontWeight(.medium)
//            }
//        }
//    }
//
//     // Formatting Helpers (could be moved to an extension or dedicated formatter)
//    func formatMarketCap(_ value: Double) -> String {
//        if value >= 1_000_000_000_000 {
//            return String(format: "$%.2fT", value / 1_000_000_000_000)
//        } else if value >= 1_000_000_000 {
//            return String(format: "$%.2fB", value / 1_000_000_000)
//        } else if value >= 1_000_000 {
//            return String(format: "$%.2fM", value / 1_000_000)
//        } else {
//            return String(format: "$%.0f", value)
//        }
//    }
//
//    func formatVolume(_ value: Double) -> String {
//         if value >= 1_000_000_000 {
//            return String(format: "%.2fB", value / 1_000_000_000)
//        } else if value >= 1_000_000 {
//            return String(format: "%.2fM", value / 1_000_000)
//        } else if value >= 1_000 {
//            return String(format: "%.2fK", value / 1_000)
//        } else {
//            return String(format: "%.0f", value)
//        }
//    }
//}
//
