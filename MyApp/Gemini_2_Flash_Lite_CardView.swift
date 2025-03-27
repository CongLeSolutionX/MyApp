//
//  Gemini_2_Flash_Lite_CardView_.swift
//  MyApp
//
//  Created by Cong Le on 3/27/25.
//

import SwiftUI

// Represents the status badges (Supported/Not supported) - Unchanged
struct Gemini_2_Flash_Lite_CardView_StatusBadge: View {
    let text: String
    let isSupported: Bool
    
    var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        // Using slightly softer standard colors
            .foregroundColor(isSupported ? .green.opacity(0.9) : .red.opacity(0.9))
            .background(isSupported ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
            .cornerRadius(6)
    }
}

// Represents a single item in the Capabilities grid - Unchanged
struct Gemini_2_Flash_Lite_CardView_CapabilityItem: View {
    let name: String
    let isSupported: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) { // Added spacing
            Text(name).font(.subheadline)
            Gemini_2_Flash_Lite_CardView_StatusBadge(text: isSupported ? "Supported" : "Not supported", isSupported: isSupported)
        }
        // Ensure grid items don't stretch unnecessarily if content is small
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Main view with modern card design
struct Gemini_2_Flash_Lite_CardView: View {
    let cardCornerRadius: CGFloat = 16
    let cardShadowRadius: CGFloat = 5
    let cardShadowYOffset: CGFloat = 2
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) { // Increased overall spacing
                // --- Header Section (Largely similar, more padding below) ---
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title2) // Slightly adjust icon size if needed
                        Text("Gemini 2.0 Flash-Lite")
                            .font(.title2) // Adjusted font size
                            .fontWeight(.semibold)
                    }
                    
                    Text("A Gemini 2.0 Flash model optimized for cost efficiency and low latency.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button {
                        print("Try in Google AI Studio tapped")
                    } label: {
                        Label("Try in Google AI Studio", systemImage: "sparkles")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .controlSize(.regular) // Explicit control size
                    .padding(.top, 8)
                }
                .padding(.horizontal) // Standard horizontal padding
                .padding(.bottom, 10) // Padding between header and card
                
                // --- Model Details Card ---
                VStack(alignment: .leading, spacing: 0) {
                    // Using DetailRow helper for consistency
                    Gemini_2_Flash_Lite_CardView_DetailRow(icon: "rectangle.on.rectangle.angled", title: "Model code") {
                        Text("models/gemini-2.0-flash-lite")
                            .font(.system(.footnote, design: .monospaced)) // Monospaced footnote often looks cleaner
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Gemini_2_Flash_Lite_CardView_SubtleDivider()
                    
                    Gemini_2_Flash_Lite_CardView_DetailRow(icon: "doc.text.image", title: "Supported data types") {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("**Inputs:** Audio, images, video, and text")
                            Text("**Output:** Text")
                        }
                        .font(.footnote) // Consistent footnote size for details
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Gemini_2_Flash_Lite_CardView_SubtleDivider()
                    
                    Gemini_2_Flash_Lite_CardView_DetailRow(icon: "target", title: "Token limits[*]") {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("**Input:** 1,048,576") // Using Markdown for bold
                            Text("**Output:** 8,192")
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Gemini_2_Flash_Lite_CardView_SubtleDivider()
                    
                    // --- Capabilities ---
                    // Keep title within DetailRow for alignment, content is the Grid
                    Gemini_2_Flash_Lite_CardView_DetailRow(icon: "wrench.and.screwdriver.fill", title: "Capabilities") {
                        // Grid sits within the content part of the DetailRow
                        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 15) { // Increased Spacing
                            GridRow {
                                Gemini_2_Flash_Lite_CardView_CapabilityItem(name: "Structured outputs", isSupported: true)
                                Gemini_2_Flash_Lite_CardView_CapabilityItem(name: "Caching", isSupported: false)
                                Gemini_2_Flash_Lite_CardView_CapabilityItem(name: "Tuning", isSupported: false)
                            }
                            GridRow {
                                Gemini_2_Flash_Lite_CardView_CapabilityItem(name: "Function calling", isSupported: false)
                                Gemini_2_Flash_Lite_CardView_CapabilityItem(name: "Code execution", isSupported: false)
                                Gemini_2_Flash_Lite_CardView_CapabilityItem(name: "Search", isSupported: false)
                            }
                            GridRow {
                                Gemini_2_Flash_Lite_CardView_CapabilityItem(name: "Image generation", isSupported: false)
                                Gemini_2_Flash_Lite_CardView_CapabilityItem(name: "Native tool use", isSupported: false)
                                Gemini_2_Flash_Lite_CardView_CapabilityItem(name: "Audio generation", isSupported: false)
                            }
                            GridRow {
                                Gemini_2_Flash_Lite_CardView_CapabilityItem(name: "Live API", isSupported: false)
                                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical]) // Fill empty cells
                                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                            }
                        }
                        .padding(.top, 8) // Add slight padding between title row and grid
                    }
                    
                    Gemini_2_Flash_Lite_CardView_SubtleDivider()
                    
                    Gemini_2_Flash_Lite_CardView_DetailRow(icon: "number", title: "Versions") {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Read the [model version patterns](...) for more details.") // Use Markdown link (needs handling)
                                .tint(.blue) // Ensure link color
                            
                            HStack(spacing: 4) {
                                Text("• **Latest:**")
                                Text("gemini-2.0-flash-lite")
                                    .font(.system(.footnote, design: .monospaced))
                            }
                            HStack(spacing: 4) {
                                Text("• **Stable:**")
                                Text("gemini-2.0-flash-lite-001")
                                    .font(.system(.footnote, design: .monospaced))
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        // TODO: Add URL opening for the link text
                    }
                    Gemini_2_Flash_Lite_CardView_SubtleDivider()
                    
                    Gemini_2_Flash_Lite_CardView_DetailRow(icon: "calendar", title: "Latest update") {
                        Text("February 2025")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Gemini_2_Flash_Lite_CardView_SubtleDivider()
                    
                    Gemini_2_Flash_Lite_CardView_DetailRow(icon: "brain.head.profile", title: "Knowledge cutoff") {
                        Text("August 2024")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    // No divider after the last item
                    
                } // End Details VStack (Card Content)
                .padding() // Add internal padding to the card content
                .background(Color(.secondarySystemGroupedBackground)) // Semantic background color
                .cornerRadius(cardCornerRadius)
                .shadow(color: Color.black.opacity(0.1), // Softer shadow
                        radius: cardShadowRadius,
                        x: 0, y: cardShadowYOffset)
                .padding(.horizontal) // Padding around the card itself
                
            } // End Main VStack
            .padding(.vertical) // Padding for ScrollView content
        } // End ScrollView
        //.background(Color(.systemGroupedBackground)) // Optional: Set background for the whole view
    }
}

// Helper View for consistent row layout - Adjusted Padding and Alignment
struct Gemini_2_Flash_Lite_CardView_DetailRow<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 15) { // Use firstTextBaseline, increased spacing
            Image(systemName: icon)
                .frame(width: 20, alignment: .center) // Consistent icon width
                .foregroundColor(.accentColor) // Use accent color for icons
            
            Text(title)
                .font(.subheadline)         // Slightly smaller title font
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(width: 110, alignment: .leading) // Adjust width as needed for alignment
            
            content() // The description part of the row
                .frame(maxWidth: .infinity, alignment: .leading) // Ensure content takes remaining space
            
        }
        .padding(.vertical, 14) // Increased vertical padding for more breathing room
        .padding(.horizontal) // Apply horizontal padding within the row if needed, or rely on card padding
    }
}

// Subtle Divider
struct Gemini_2_Flash_Lite_CardView_SubtleDivider: View {
    var body: some View {
        Divider()
            .background(Color(.separator).opacity(0.6)) // Lighter separator color
        // No leading padding needed if applied within the card's padding context
    }
}

// Preview Provider
struct ModernGeminiDetailsCardView_Previews: PreviewProvider {
    static var previews: some View {
        Gemini_2_Flash_Lite_CardView()
        // Add variations for dark mode, different dynamic type sizes if needed
        // .preferredColorScheme(.dark)
    }
}
