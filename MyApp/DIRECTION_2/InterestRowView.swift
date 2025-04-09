//
//  InterestRowView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//


import SwiftUI

/// A view that displays a row with a label and a corresponding value,
/// commonly used for showing interest-related information.
/// It can optionally display an info icon next to the label.
struct InterestRowView: View {
    let label: String
    let value: String
    var showInfoIcon: Bool = false // Default to false

    var body: some View {
        HStack {
            HStack(spacing: 4) { // Group label and icon
                Text(label)
                    .font(.subheadline) // Adjusted font for potentially longer labels
                    .foregroundColor(.secondary) // Standard color for labels
                
                if showInfoIcon {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                        .font(.caption) // Make icon slightly smaller
                }
            }
            Spacer() // Pushes value to the trailing edge
            Text(value)
                .font(.subheadline) // Match label font size
                .fontWeight(.medium) // Give value slightly more emphasis
                .foregroundColor(.primary) // Standard color for primary data
        }
        // Apply padding to the HStack itself for consistent spacing if needed,
        // or manage padding within the parent container (like CashSectionView).
        // .padding(.vertical, 4) // Example padding if needed directly here
    }
}

// MARK: - Previews

#Preview("Standard Row") {
    VStack {
        InterestRowView(label: "Interest accrued this month", value: "$0.90")
        Divider()
        InterestRowView(label: "Lifetime interest paid", value: "$100.60")
    }
    .padding()
}

#Preview("Row with Info Icon") {
    VStack {
        InterestRowView(label: "Cash earning interest", value: "$1,090.77", showInfoIcon: true)
    }
    .padding()
}

#Preview("Combined in List") {
    List {
        InterestRowView(label: "Interest accrued this month", value: "$0.90")
        InterestRowView(label: "Lifetime interest paid", value: "$100.60")
        InterestRowView(label: "Cash earning interest", value: "$1,090.77", showInfoIcon: true)
    }
}
