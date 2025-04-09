//
//  StockDetailView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
import Charts // Required for potential Chart implementations and Grid

// MARK: - Supporting Data Structures

/// Basic stock information, often passed from the list view.
struct StockInfo: Identifiable {
    let id = UUID()
    let symbol: String
    let companyName: String
    let shares: String // User's shares, may differ from DetailData if fetched separately
    let value: String // List view price, may differ from DetailData
    let graphColor: Color // List view indicator color
}

/// Represents the detailed data for a specific stock.
struct StockDetailData {
    let symbol: String
    let companyName: String
    let currentPrice: Double
    let dayChange: Double // Amount changed today
    let dayChangePercent: Double // Percentage changed today
    let userPosition: StockPosition
    let stats: StockStats
    let about: String
    // Future: Add historical price data for the chart

    // Mock data for demonstration
    static var mockData: StockDetailData {
        StockDetailData(
            symbol: "XOM",
            companyName: "Exxon Mobil Corp.",
            currentPrice: 98.78,
            dayChange: 1.25, // Positive change
            dayChangePercent: 1.28,
            userPosition: StockPosition(
                shares: 4.5912,
                marketValue: 453.51, // 4.5912 * 98.78
                averageCost: 92.50,
                todaysReturn: 5.74, // 4.5912 * 1.25
                todaysReturnPercent: 1.28,
                totalReturn: 28.83, // (98.78 - 92.50) * 4.5912
                totalReturnPercent: 6.80 // (28.83 / (92.50 * 4.5912)) * 100
            ),
            stats: StockStats(
                marketCap: 405_510_000_000, // 405.51B
                peRatio: 8.15,
                volume: 15_890_000, // 15.89M
                avgVolume: 18_230_000, // 18.23M
                high52Week: 119.92,
                low52Week: 83.05,
                dividendYield: 3.68
            ),
            about: "Exxon Mobil Corporation explores for and produces crude oil and natural gas in the United States and internationally. It operates through Upstream, Downstream, and Chemical segments."
        )
    }
    
     static var mockDataDown: StockDetailData { // Mock data for a stock that's down
        StockDetailData(
            symbol: "REAL",
            companyName: "The RealReal, Inc.",
            currentPrice: 4.76,
            dayChange: -0.15, // Negative change
            dayChangePercent: -3.06,
            userPosition: StockPosition(
                shares: 250.45,
                marketValue: 1192.14, // 250.45 * 4.76
                averageCost: 5.50,
                todaysReturn: -37.57, // 250.45 * -0.15
                todaysReturnPercent: -3.06,
                totalReturn: -185.33, // (4.76 - 5.50) * 250.45
                totalReturnPercent: -13.48 // (-185.33 / (5.50 * 250.45)) * 100
            ),
            stats: StockStats(
                marketCap: 465_700_000, // 465.70M
                peRatio: -2.5, // Negative P/E
                volume: 1_250_000, // 1.25M
                avgVolume: 980_000, // 980K
                high52Week: 6.80,
                low52Week: 3.95,
                dividendYield: 0.0 // No dividend
            ),
            about: "The RealReal, Inc. operates an online marketplace for authenticated, consigned luxury goods. It offers a range of luxury goods across various categories, including women's, men's, kids', jewelry, watches, home, and art."
        )
    }
}

/// Represents the user's position in a specific stock.
struct StockPosition {
    let shares: Double
    let marketValue: Double
    let averageCost: Double
    let todaysReturn: Double
    let todaysReturnPercent: Double
    let totalReturn: Double
    let totalReturnPercent: Double
}

/// Represents key statistics for a stock.
struct StockStats {
    let marketCap: Double
    let peRatio: Double
    let volume: Double
    let avgVolume: Double
    let high52Week: Double
    let low52Week: Double
    let dividendYield: Double // Percentage
}

/// Enum for time range selection in the chart.
enum TimeRange: String, CaseIterable, Identifiable {
    case oneDay = "1D"
    case oneWeek = "1W"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case oneYear = "1Y"
    case all = "All"
    var id: String { self.rawValue }
}

// MARK: - Main Stock Detail View

struct StockDetailView: View {
    /// Basic info passed from the previous screen (e.g., portfolio list).
    let stockInfo: StockInfo

    /// Holds the detailed data fetched for this stock.
    /// In a real app, this would likely be an `@StateObject` fetching data asynchronously.
    /// Here, we use `@State` with mock data based on the incoming symbol.
    @State private var detailData: StockDetailData

    /// State variable to track the selected time range in the chart picker.
    @State private var selectedTimeRange: TimeRange = .oneDay

    // Initialize with mock data based on the symbol passed in
    init(stockInfo: StockInfo) {
        self.stockInfo = stockInfo
        // Choose mock data based on symbol (simple example)
        if stockInfo.symbol == "REAL" {
             _detailData = State(initialValue: StockDetailData.mockDataDown)
        } else {
             _detailData = State(initialValue: StockDetailData.mockData)
        }
       
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) { // Added spacing for better visual separation

                // 1. Header: Company Name, Price, Daily Change
                StockDetailHeader(stockInfo: stockInfo, detailData: detailData)

                // 2. Chart Placeholder and Time Range Picker
                VStack(spacing: 15) {
                    DetailedStockChartPlaceholder(color: detailData.dayChange >= 0 ? .green : .red)
                        .frame(height: 200) // Provide ample height for the main chart

                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    // Add onChange(of: selectedTimeRange) { ... } to update chart data
                }

                Divider()

                // 3. User's Position Details
                YourPositionView(positionData: detailData.userPosition)

                Divider()

                // 4. Key Statistics
                StatsView(statsData: detailData.stats)

                Divider()
                
                // 5. Action Buttons (Buy/Sell)
                ActionButtonsView()

                Divider()

                // 6. About Section
                AboutSectionView(aboutText: detailData.about)

                // Add some padding at the bottom of the scroll view
                Spacer(minLength: 20)
            }
            .padding() // Apply padding to the entire content within the ScrollView
        }
        // Set the navigation bar title dynamically using the company name.
        .navigationTitle(stockInfo.companyName)
        // Use inline display mode, common for detail screens.
        .navigationBarTitleDisplayMode(.inline)
         // Optional: Add toolbar items if needed (e.g., watchlist star)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { /* Add to watchlist action */ } label: {
                    Image(systemName: "star") // Example icon
                }
            }
        }
    }
}

// MARK: - Subviews for StockDetailView

/// Displays the header section with price and daily change.
struct StockDetailHeader: View {
    let stockInfo: StockInfo // Might only need symbol/name from here
    let detailData: StockDetailData
    
    // Determine color and prefix based on positive or negative change
    private var priceChangeColor: Color { detailData.dayChange >= 0 ? .green : .red }
    private var priceChangePrefix: String { detailData.dayChange >= 0 ? "+" : "" }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Display company name (can use detailData if more reliable)
            Text(detailData.companyName)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // Display current price, formatted to 2 decimal places.
            Text(String(format: "$%.2f", detailData.currentPrice))
                .font(.largeTitle)
                .fontWeight(.semibold) // Use semibold for emphasis
        
            // Display daily change (value and percentage) horizontally.
            HStack(spacing: 8) {
                Text(String(format: "%@$%.2f", priceChangePrefix, abs(detailData.dayChange)))
                Text(String(format: "(%@%.2f%%)", priceChangePrefix, abs(detailData.dayChangePercent)))
            }
            .font(.headline) // Use headline font for the change figures
            .foregroundColor(priceChangeColor) // Apply color indicator
            
            // Add context for the change period.
            Text("Today")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

/// Placeholder view for the detailed stock chart.
struct DetailedStockChartPlaceholder: View {
    let color: Color
    
    var body: some View {
        // A more visually distinct placeholder than the simple sparkline.
        RoundedRectangle(cornerRadius: 8)
            .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1) // Border
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1))) // Background fill
            .overlay(
                // Simulate a line graph inside
                GeometryReader { geo in
                    Path { path in
                        // Example data points (normalized 0-1 approx)
                        let dataPoints: [CGFloat] = [0.6, 0.5, 0.7, 0.6, 0.8, 0.75, 0.9, 0.8, 0.85]
                        let stepX = geo.size.width / CGFloat(dataPoints.count - 1)
                        
                        // Ensure data points are valid before drawing
                        guard !dataPoints.isEmpty else { return }
                        
                        // Start the path at the first data point
                        path.move(to: CGPoint(x: 0, y: geo.size.height * (1 - dataPoints[0])))
                        
                        // Draw lines connecting subsequent points
                        for i in 1..<dataPoints.count {
                            path.addLine(to: CGPoint(x: CGFloat(i) * stepX, y: geo.size.height * (1 - dataPoints[i])))
                        }
                    }
                    .stroke(color, lineWidth: 2.5) // Use a slightly thicker line for the main chart
                }
                .padding(12) // Padding inside the border for the graph line
                .clipped() // Clip the path drawing to the bounds
            )
    }
}

/// Displays the user's current position in the stock.
struct YourPositionView: View {
    let positionData: StockPosition

    var body: some View {
        VStack(alignment: .leading, spacing: 12) { // Increased spacing
            Text("Your Position")
                .font(.title2)
                .fontWeight(.semibold)

            // Use a Grid for neatly aligned key-value pairs.
            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 8) {
                GridRow {
                    Text("Shares").foregroundStyle(.secondary)
                    Text(String(format: "%.4f", positionData.shares)) // Show more precision for shares
                    Spacer() // Push value to the right if needed, or align columns
                }
                GridRow {
                    Text("Market Value").foregroundStyle(.secondary)
                    Text(String(format: "$%.2f", positionData.marketValue))
                }
                GridRow {
                    Text("Average Cost").foregroundStyle(.secondary)
                    Text(String(format: "$%.2f", positionData.averageCost))
                }
                 GridRow(alignment: .top) { // Align top for potentially multi-line content
                    Text("Today's Return").foregroundStyle(.secondary)
                    // Use the helper view for consistent return formatting/coloring.
                    ReturnTextView(value: positionData.todaysReturn, percentage: positionData.todaysReturnPercent)
                }
                  GridRow(alignment: .top) {
                    Text("Total Return").foregroundStyle(.secondary)
                    ReturnTextView(value: positionData.totalReturn, percentage: positionData.totalReturnPercent)
                }
            }
            .font(.subheadline) // Apply base font to the grid content
        }
    }
}

/// Helper view for displaying return values (+/- sign, color coding).
struct ReturnTextView: View {
    let value: Double
    let percentage: Double? // Percentage is optional

    private var returnColor: Color { value >= 0 ? .green : .red }
    private var returnPrefix: String { value >= 0 ? "+" : "" }

    var body: some View {
        // Display value and percentage (if available) horizontally.
        HStack(spacing: 4) {
            Text(String(format: "%@$%.2f", returnPrefix, abs(value)))
            if let percentage = percentage {
                Text(String(format: "(%@%.2f%%)", returnPrefix, abs(percentage)))
            }
        }
        .foregroundColor(returnColor) // Apply color indicator
        .fontWeight(.medium) // Use medium weight for returns
    }
}

/// Displays key stock statistics in a grid format.
struct StatsView: View {
    let statsData: StockStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) { // Increased spacing
            Text("Stats")
                .font(.title2)
                .fontWeight(.semibold)

            // Use a Grid for a two-column layout of statistics.
            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 10) { // Added spacing
                GridRow {
                    StatItem(label: "Market Cap", value: formatMarketCap(statsData.marketCap))
                    StatItem(label: "P/E Ratio", value: formatPERatio(statsData.peRatio))
                }
                GridRow {
                    StatItem(label: "Volume", value: formatVolume(statsData.volume))
                    StatItem(label: "Avg Volume", value: formatVolume(statsData.avgVolume))
                }
                GridRow {
                    StatItem(label: "52wk High", value: String(format: "$%.2f", statsData.high52Week))
                    StatItem(label: "52wk Low", value: String(format: "$%.2f", statsData.low52Week))
                }
                GridRow {
                    StatItem(label: "Div/Yield", value: formatDividendYield(statsData.dividendYield))
                    // Add another stat here if available, or leave cell empty for alignment
                    Text("") // Empty text can act as a placeholder in the grid cell
                        .gridCellUnsizedAxes(.vertical) // Prevent empty cell from collapsing row height if desired
                }
            }
            .font(.subheadline) // Apply base font to grid content
        }
    }
    
    /// Helper View for a single statistic item (Label + Value).
    struct StatItem: View {
        let label: String
        let value: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundStyle(.secondary) // Smaller label
                Text(value).fontWeight(.medium) // Medium weight value
            }
             .lineLimit(1) // Prevent wrapping
             .minimumScaleFactor(0.8) // Allow text to shrink slightly if needed
        }
    }

    // MARK: Formatting Helpers
    
    private func formatMarketCap(_ value: Double) -> String {
        if value >= 1_000_000_000_000 { return String(format: "$%.2fT", value / 1_000_000_000_000) }
        if value >= 1_000_000_000 { return String(format: "$%.2fB", value / 1_000_000_000) }
        if value >= 1_000_000 { return String(format: "$%.2fM", value / 1_000_000) }
        return String(format: "$%.0f", value) // Fallback for smaller caps
    }

    private func formatVolume(_ value: Double) -> String {
        if value >= 1_000_000_000 { return String(format: "%.2fB", value / 1_000_000_000) }
        if value >= 1_000_000 { return String(format: "%.2fM", value / 1_000_000) }
        if value >= 1_000 { return String(format: "%.2fK", value / 1_000) }
        return String(format: "%.0f", value) // Fallback for smaller volumes
    }
    
    private func formatPERatio(_ value: Double) -> String {
        // Handle negative or zero P/E ratios gracefully
        return value > 0 ? String(format: "%.2f", value) : "--"
    }
    
    private func formatDividendYield(_ value: Double) -> String {
        // Handle zero dividend yield
        return value > 0 ? String(format: "%.2f%%", value) : "--"
    }
}

/// Displays the Buy and Sell action buttons.
struct ActionButtonsView: View {
    var body: some View {
        HStack(spacing: 15) { // Add spacing between buttons
            Button { print("Buy tapped") } label: {
                Text("Buy")
                    .frame(maxWidth: .infinity) // Make button expand
            }
            .buttonStyle(.borderedProminent) // Use a prominent style
            .tint(.green) // Green for Buy

            Button { print("Sell tapped") } label: {
                Text("Sell")
                    .frame(maxWidth: .infinity) // Make button expand
            }
            .buttonStyle(.borderedProminent) // Use a prominent style
            .tint(.red) // Red for Sell
        }
        .font(.headline) // Apply font to button text
        .controlSize(.large) // Make buttons larger
    }
}

/// Displays the "About" section with the company description.
struct AboutSectionView: View {
    let aboutText: String
    @State private var isExpanded: Bool = false // State to handle text expansion

    private let collapsedLineLimit = 4 // Number of lines to show when collapsed

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About")
                .font(.title2)
                .fontWeight(.semibold)

            Text(aboutText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                // Apply line limit based on expansion state
                .lineLimit(isExpanded ? nil : collapsedLineLimit)
            
            // Show "Show More/Less" button only if text exceeds the collapsed limit
            // (This requires calculating if the text is actually truncated, which is tricky in SwiftUI.
            // A simpler approach is to always show the button if the text *might* be long.)
             if aboutText.count > 150 { // Heuristic: show button if text seems long enough
                Button(isExpanded ? "Show Less" : "Show More") {
                    withAnimation(.easeInOut) { // Animate the expansion/collapse
                        isExpanded.toggle()
                    }
                }
                .font(.subheadline).fontWeight(.medium)
                .foregroundColor(.blue) // Use a distinct color for the action
            }
        }
    }
}

// MARK: - Preview Provider

#Preview {
    // Create sample StockInfo to simulate navigation
    let sampleInfo = StockInfo(
        symbol: "XOM",
        companyName: "Exxon Mobil Corporation", // Use full name
        shares: "4.59 shares",
        value: "$98.78",
        graphColor: .green
    )
    
     let sampleInfoDown = StockInfo(
        symbol: "REAL",
        companyName: "The RealReal, Inc.",
        shares: "250.45 shares",
        value: "$4.76",
        graphColor: .red
    )
    
    // Embed the StockDetailView in a NavigationStack for the title bar to render correctly.
    return NavigationStack {
        StockDetailView(stockInfo: sampleInfo) // Preview the "up" stock
        // StockDetailView(stockInfo: sampleInfoDown) // Uncomment to preview the "down" stock
    }
}
