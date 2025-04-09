//
//  CryptoRowView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//


import SwiftUI

// Placeholder for the sparkline view potentially used within CryptoRowView
// Based on the context from previous code snippets where StockRowView used it.
struct StockSparklinePlaceholder: View {
    let color: Color

    // Basic placeholder implementation for demonstration
    var body: some View {
         GeometryReader { geo in
            Path { path in
                // Simulate some basic crypto price movement (different from stock example)
                let dataPoints: [CGFloat] = [0.7, 0.75, 0.65, 0.8, 0.78, 0.85, 0.82]
                let stepX = geo.size.width / CGFloat(dataPoints.count - 1)

                guard !dataPoints.isEmpty else { return }

                path.move(to: CGPoint(x: 0, y: geo.size.height * (1 - dataPoints[0])))

                 for i in 1..<dataPoints.count {
                     path.addLine(to: CGPoint(x: CGFloat(i) * stepX, y: geo.size.height * (1 - dataPoints[i])))
                 }
            }
            .stroke(color, lineWidth: 1.5) // Use the provided color for the line
        }
        // Provide a default frame if none is specified at the call site,
        // matching potential usage in a list row.
        .frame(width: 60, height: 30)
    }
}

/// # CryptoRowView
/// A view that displays a single row of cryptocurrency information,
/// typically used within a list in a portfolio or crypto section.
///
/// It shows the crypto symbol, quantity held, a small sparkline graph placeholder,
/// and the current market value of the holding.
struct CryptoRowView: View {
    /// The symbol of the cryptocurrency (e.g., "BTC", "ETH", "USDC").
    let symbol: String

    /// The quantity or amount of the cryptocurrency held by the user (e.g., "0.05", "150.3").
    /// Represented as a String for display flexibility.
    let quantity: String

    /// The current market value of the user's holding for this cryptocurrency (e.g., "$150.75").
    /// Represented as a String for display flexibility.
    let value: String

    /// The color used for the sparkline graph, potentially indicating price movement or branding.
    let graphColor: Color

    var body: some View {
        HStack(spacing: 15) {
            // Placeholder for a Crypto Icon
            // In a real app, load an actual image based on the symbol.
            // Using SF Symbols as a fallback placeholder.
            Image(systemName: "bitcoinsign.circle.fill") // Generic crypto symbol
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                // Use a distinct color or gray if graphColor is only for the graph
                .foregroundColor(.gray)

            // Crypto Symbol and Quantity Held
            VStack(alignment: .leading) {
                Text(symbol)
                    .font(.headline)
                    .fontWeight(.medium) // Slightly emphasize symbol
                Text(quantity)
                    .font(.caption)
                    .foregroundColor(.secondary) // Subdued color for quantity
            }

            Spacer() // Pushes the graph and value to the right

            // Sparkline Graph Placeholder
            StockSparklinePlaceholder(color: graphColor)
                // Explicit frame here ensures consistent size within the HStack
                .frame(width: 60, height: 30)

            Spacer(minLength: 10) // Ensure some separation between graph and value

            // Market Value Display
            Text(value)
                .font(.footnote) // Slightly smaller font for value
                .fontWeight(.medium) // Make value clear
                // Ensure sufficient width and align text to the right for consistency
                .frame(minWidth: 70, alignment: .trailing)
        }
        // Add padding for spacing when used in a list with dividers
        .padding(.vertical, 8)
        // Ensure the background is typically clear or system background
        // to blend with the list it's embedded in.
        .background(Color(.systemBackground)) // Adapts to light/dark mode
    }
}

// MARK: - Previews
struct CryptoRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Preview Section")
                .font(.title2).padding(.bottom)

            CryptoRowView(symbol: "USDC", quantity: "100.50", value: "$100.50", graphColor: .blue)
            Divider() // Typical usage with a divider
            CryptoRowView(symbol: "BTC", quantity: "0.0025", value: "$165.80", graphColor: .orange)
            Divider()
            CryptoRowView(symbol: "ETH", quantity: "0.15", value: "$480.12", graphColor: .purple)
            Divider()
            CryptoRowView(symbol: "SOL", quantity: "5.20", value: "$195.43", graphColor: .green)
        }
        .padding() // Add padding around the VStack for preview visibility
    }
}
