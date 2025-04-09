//
//  StockRowView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

// MARK: - Data Structure for Stock Information

///// Represents the basic information needed to display a stock in a list row.
//struct StockInfo: Identifiable {
//    /// Unique identifier for the stock entry.
//    let id = UUID()
//    /// The stock ticker symbol (e.g., "AAPL", "XOM").
//    let symbol: String
//    /// The full company name (e.g., "Apple Inc.", "Exxon Mobil Corp.").
//    /// Although not directly displayed *in* this row view, it's often part of the data model
//    /// used to populate the row and is needed for navigation details.
//    let companyName: String
//    /// A string describing the quantity of shares held (e.g., "10 shares", "0.5 shares").
//    let shares: String
//    /// The current market value per share, formatted as a string (e.g., "$175.30").
//    let value: String
//    /// The color to use for graphical elements (like the sparkline and value background/text),
//    /// typically indicating the direction of the day's price change (e.g., green for up, red for down).
//    let graphColor: Color
//}

// MARK: - Placeholder for Sparkline Graph

/// A simple placeholder view representing a small sparkline graph.
/// In a real app, this would be replaced with an actual chart view.
struct StockSparklinePlaceholder: View {
    /// The color used to draw the sparkline, indicating price movement.
    let color: Color

    var body: some View {
        // Basic visual representation of a sparkline.
        GeometryReader { geometry in
            Path { path in
                // Simulate some generic line movement within the view's bounds.
                let midY = geometry.size.height / 2
                let width = geometry.size.width
                
                path.move(to: CGPoint(x: 0, y: midY + 5))
                path.addLine(to: CGPoint(x: width * 0.2, y: midY - 5))
                path.addLine(to: CGPoint(x: width * 0.4, y: midY + 2))
                path.addLine(to: CGPoint(x: width * 0.6, y: midY - 3))
                path.addLine(to: CGPoint(x: width * 0.8, y: midY + 4))
                path.addLine(to: CGPoint(x: width * 1.0, y: midY - 2))
            }
            .stroke(color, lineWidth: 1.5) // Draw the line with the specified color.
        }
        .background(Color.gray.opacity(0.05)) // Subtle background for the chart area.
        .cornerRadius(3)
    }
}

// MARK: - Stock Row View Implementation

/// A view that displays a single row of stock information within a portfolio list.
/// It shows the stock symbol, shares owned, a mini graph (sparkline), and the current value.
struct StockRowView: View {
    /// The `StockInfo` data model containing the details for this specific row.
    let stock: StockInfo

    var body: some View {
        HStack(spacing: 15) {
            // Left section: Stock symbol and number of shares.
            VStack(alignment: .leading) {
                Text(stock.symbol)
                    .font(.headline) // Make the symbol prominent.
                    .lineLimit(1)   // Ensure symbol doesn't wrap.
                Text(stock.shares)
                    .font(.caption) // Smaller text for share details.
                    .foregroundColor(.secondary) // Use secondary color for less emphasis.
                    .lineLimit(1)
            }

            Spacer() // Pushes the graph and value to the right.

            // Middle section: Sparkline graph placeholder.
            StockSparklinePlaceholder(color: stock.graphColor)
                .frame(width: 60, height: 30) // Fixed size for the graph area.

            Spacer() // Optional: Add another spacer for more separation if desired.

            // Right section: Current value with color indicator.
            Text(stock.value)
                .font(.footnote) // Smaller font for the value.
                .fontWeight(.bold) // Make the value bold.
                .padding(.horizontal, 10) // Horizontal padding inside the background.
                .padding(.vertical, 5)    // Vertical padding inside the background.
                // Use the stock's graphColor for background and text to indicate price movement.
                .background(stock.graphColor.opacity(0.15)) // Subtle background color.
                .foregroundColor(stock.graphColor)          // Text color matches the indicator.
                .cornerRadius(5)                           // Rounded corners for the background.
                .frame(minWidth: 70, alignment: .trailing) // Ensure minimum width and align text right.
                .lineLimit(1)                              // Prevent value from wrapping.
        }
        .padding(.vertical, 10) // Vertical padding for the entire row for spacing in a list.
        // Ensure the background is clear or system-defined, especially important
        // if this row is placed inside a NavigationLink or Button.
        .background(Color(.systemBackground))
    }
}

// MARK: - Example Usage (for Preview)

#Preview {
    // Create sample data for previewing the StockRowView.
    let sampleStockUp = StockInfo(
        symbol: "AAPL",
        companyName: "Apple Inc.",
        shares: "10.5 shares",
        value: "$175.50",
        graphColor: .green // Simulate upward movement
    )
    
    let sampleStockDown = StockInfo(
        symbol: "REAL",
        companyName: "The RealReal, Inc.",
        shares: "250.45 shares",
        value: "$4.76",
        graphColor: .red // Simulate downward movement
    )

    // Display the StockRowView in a VStack for context.
    return VStack(spacing: 0) {
        StockRowView(stock: sampleStockUp)
        Divider() // Show a divider typical in lists.
        StockRowView(stock: sampleStockDown)
        Divider()
    }
    .padding(.horizontal) // Add horizontal padding similar to a list container.
}
