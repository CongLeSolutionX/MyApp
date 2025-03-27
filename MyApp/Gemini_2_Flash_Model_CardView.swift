//
//  Gemini_2_Flash_Model_CardView.swift
//  MyApp
//
//  Created by Cong Le on 3/27/25.
//

import SwiftUI

// MARK: - Data Structures and Enums (Keep from previous version)

/// Represents the status of a capability.
enum Gemini_2_Flash_Model_CardView_CapabilityStatus: String {
    case supported = "Supported"
    case experimental = "Experimental"
    case comingSoon = "Coming soon"
    case notSupported = "Not supported"
    
    /// Provides a color based on the status.
    var color: Color {
        switch self {
        case .supported: return .green
        case .experimental: return .purple
        case .comingSoon: return .orange
        case .notSupported: return .red
        }
    }
}

/// Represents a specific capability of the model.
struct Gemini_2_Flash_Model_CardView_Capability: Identifiable {
    let id = UUID()
    let name: String
    let status: Gemini_2_Flash_Model_CardView_CapabilityStatus
}

// MARK: - Reusable Views (Slightly Enhanced)

/// A view to display a status badge with updated styling.
struct Gemini_2_Flash_Model_CardView_StatusBadge: View {
    let status: Gemini_2_Flash_Model_CardView_CapabilityStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption.weight(.medium)) // Explicitly set weight
            .padding(.horizontal, 10) // Slightly more horizontal padding
            .padding(.vertical, 5)    // Slightly more vertical padding
            .background(status.color.opacity(0.15))
            .foregroundColor(status.color)
            .cornerRadius(8) // Keeping corner radius
            .lineLimit(1) // Ensure badge text stays on one line
    }
}

/// A refined view row for displaying information within the card.
struct Gemini_2_Flash_Model_CardView_InfoRow<Value: View>: View {
    let iconName: String
    let propertyName: String
    @ViewBuilder let valueView: Value
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) { // Increased spacing
            Image(systemName: iconName)
                .foregroundColor(.accentColor) // Use accent color for icons
                .frame(width: 24, alignment: .center) // Slightly larger icon frame
                .padding(.top, 2) // Align icon slightly better with multi-line text
            
            VStack(alignment: .leading, spacing: 4) { // Vertical stack for property name + value
                Text(propertyName)
                    .font(.headline) // Make property name more prominent
                    .foregroundStyle(.secondary) // Dim the property name slightly
                
                valueView // The custom value content
                    .font(.body) // Default font for value
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// A dedicated view for displaying a single capability in the grid.
struct Gemini_2_Flash_Model_CardView_CapabilityItemView: View {
    let capability: Gemini_2_Flash_Model_CardView_Capability
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(capability.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2) // Allow two lines for longer names
                .frame(height: 35, alignment: .top) // Fixed height to help grid alignment
            
            Gemini_2_Flash_Model_CardView_StatusBadge(status: capability.status)
        }
        .padding(10)
        .background(Color(.systemBackground)) // Background for individual item (optional)
        .cornerRadius(8)
        // Optional: Add a subtle border to each item
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}


// MARK: - Main Detail View (Redesigned with Card Layout)

struct Gemini_2_Flash_Model_CardView: View {
    
    // Data for Capabilities Grid (Keep from previous version)
    let capabilities: [Gemini_2_Flash_Model_CardView_Capability] = [
        .init(name: "Structured outputs", status: .supported),
        .init(name: "Caching", status: .comingSoon),
        .init(name: "Tuning", status: .notSupported),
        .init(name: "Function calling", status: .supported),
        .init(name: "Code execution", status: .supported),
        .init(name: "Search", status: .supported),
        .init(name: "Image generation", status: .experimental),
        .init(name: "Native tool use", status: .supported),
        .init(name: "Audio generation", status: .comingSoon),
        .init(name: "Live API", status: .experimental),
        .init(name: "Thinking", status: .experimental)
    ]
    
    // Define grid columns
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3) // Add minimum size
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) { // Increased spacing between header and card
                
                // --- Header Section (Outside the card) ---
                VStack(alignment: .leading, spacing: 12) {
                    Text("Gemini 2.0 Flash")
                        .font(.largeTitle.bold()) // More prominent title
                    
                    Text("Gemini 2.0 Flash delivers next-gen features and improved capabilities, including superior speed, native tool use, multimodal generation, and a 1M token context window.")
                        .font(.subheadline) // Slightly smaller description
                        .foregroundColor(.secondary)
                    
                    Button {
                        // Action for the button
                        print("Try in Google AI Studio tapped")
                    } label: {
                        Label("Try in Google AI Studio", systemImage: "sparkles")
                            .font(.headline) // Make button text bolder
                            .frame(maxWidth: .infinity, alignment: .center) // Make button wider
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large) // Larger button
                    .tint(.blue)
                }
                .padding(.horizontal) // Add horizontal padding to header
                
                // --- Model Details Card ---
                VStack(alignment: .leading, spacing: 20) { // Spacing for sections within the card
                    Text("Model Details")
                        .font(.title2.bold())
                        .padding(.bottom, 5) // Spacing below the card title
                    
                    
                    // --- Section 1: Core Info ---
                    VStack(alignment: .leading, spacing: 18) {
                        Gemini_2_Flash_Model_CardView_InfoRow(iconName: "rectangle.stack", propertyName: "Model code") {
                            Text("models/gemini-2.0-flash")
                                .font(.system(.body, design: .monospaced))
                        }
                        
                        Gemini_2_Flash_Model_CardView_InfoRow(iconName: "list.bullet.rectangle", propertyName: "Versions") {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Read the **model version patterns** for more details.")
                                Text("• **Latest:** gemini-2.0-flash")
                                Text("• **Stable:** gemini-2.0-flash-001")
                                Text("• **Experimental:** gemini-2.0-flash-exp")
                                Text("• **Experimental:** gemini-2.0-flash-thinking-exp-01-21")
                            }
                            .font(.subheadline) // Use subheadline for version details
                        }
                        
                        Gemini_2_Flash_Model_CardView_InfoRow(iconName: "calendar", propertyName: "Latest update") {
                            Text("February 2025")
                        }
                        
                        Gemini_2_Flash_Model_CardView_InfoRow(iconName: "brain.head.profile", propertyName: "Knowledge cutoff") {
                            Text("August 2024")
                        }
                    }
                    
                    Divider().padding(.vertical, 8) // Clearer section divider
                    
                    // --- Section 2: Input/Output Specs ---
                    VStack(alignment: .leading, spacing: 18) {
                        Gemini_2_Flash_Model_CardView_InfoRow(iconName: "doc.text.image", propertyName: "Supported data types") { // Updated icon
                            VStack(alignment: .leading, spacing: 5) {
                                Text("**Inputs:** Audio, images, video, text")
                                Text("**Output:** Text, images (experimental), audio (coming soon)")
                            }
                        }
                        Gemini_2_Flash_Model_CardView_InfoRow(iconName: "arrow.left.arrow.right.circle", propertyName: "Token limits[*]") { // Updated icon
                            VStack(alignment: .leading, spacing: 5) {
                                Text("**Input:** 1,048,576") // Simplified label
                                Text("**Output:** 8,192")   // Simplified label
                            }
                        }
                    }
                    
                    Divider().padding(.vertical, 8) // Clearer section divider
                    
                    // --- Section 3: Capabilities ---
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Capabilities")
                            .font(.title3.bold()) // Slightly smaller headline for subsection
                        
                        
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) { // Grid spacing
                            ForEach(capabilities) { capability in
                                Gemini_2_Flash_Model_CardView_CapabilityItemView(capability: capability)
                            }
                        }
                    }
                    
                }
                .padding(20) // Generous padding inside the card
                .background(Color(.secondarySystemGroupedBackground)) // Common card background color
                .cornerRadius(16) // Larger corner radius for modern feel
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4) // Softer shadow
                .padding(.horizontal) // Add horizontal padding *around* the card
                
            }
            .padding(.vertical) // Add padding to the top/bottom of the ScrollView content
        }
    }
}

// MARK: - Preview

#Preview {
    Gemini_2_Flash_Model_CardView()
        .preferredColorScheme(.dark)
}
