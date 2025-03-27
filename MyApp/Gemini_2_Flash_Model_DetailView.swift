//
//  GeminiModelView.swift
//  MyApp
//
//  Created by Cong Le on 3/27/25.
//

import SwiftUI

// MARK: - Data Structures and Enums

/// Represents the status of a capability.
enum Gemini_2_Flash_Model_CapabilityStatus: String {
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
struct Gemini_2_Flash_Model_Capability: Identifiable {
    let id = UUID()
    let name: String
    let status: Gemini_2_Flash_Model_CapabilityStatus
}

// MARK: - Reusable Views

/// A view to display a status badge with appropriate styling.
struct Gemini_2_Flash_Model_StatusBadge: View {
    let status: Gemini_2_Flash_Model_CapabilityStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.15))
            .foregroundColor(status.color)
            .cornerRadius(8)
    }
}

/// A view row representing a property and its description/value.
struct Gemini_2_Flash_Model_PropertyRow<Value: View>: View {
    let iconName: String
    let propertyName: String
    @ViewBuilder let valueView: Value // Use ViewBuilder for flexible value content
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: iconName)
                .foregroundColor(.blue)
                .frame(width: 20, alignment: .center) // Consistent icon width
            
            Text(propertyName)
                .fontWeight(.medium)
                .frame(width: 150, alignment: .leading) // Align property names
            
            valueView // The custom value content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8) // Add vertical spacing between rows
    }
}

// MARK: - Main Detail View

struct Gemini_2_Flash_Model_DetailView: View {
    // Data for Capabilities Grid
    let capabilities: [Gemini_2_Flash_Model_Capability] = [
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
        // Add more capabilities if needed
    ]
    
    // Define grid columns
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3) // Adjust count as needed
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // --- Header Section ---
                VStack(alignment: .leading, spacing: 10) {
                    Text("Gemini 2.0 Flash")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Gemini 2.0 Flash delivers next-gen features and improved capabilities, including superior speed, native tool use, multimodal generation, and a 1M token context window.")
                        .foregroundColor(.secondary)
                    
                    Button {
                        // Action for the button
                        print("Try in Google AI Studio tapped")
                    } label: {
                        Label("Try in Google AI Studio", systemImage: "sparkles") // Using sparkles as a placeholder
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue) // Example tint
                }
                .padding(.bottom)
                
                // --- Model Details Section ---
                VStack(alignment: .leading, spacing: 15) {
                    Text("Model details")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        // --- Model Code ---
                        Gemini_2_Flash_Model_PropertyRow(iconName: "rectangle.stack", propertyName: "Model code") {
                            Text("models/gemini-2.0-flash")
                                .font(.system(.body, design: .monospaced)) // Monospaced for code
                        }
                        Divider()
                        
                        // --- Supported Data Types ---
                        Gemini_2_Flash_Model_PropertyRow(iconName: "doc.text", propertyName: "Supported data types") {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("**Inputs:** Audio, images, video, and text")
                                Text("**Output:** Text, images (experimental), and audio(coming soon)")
                            }
                        }
                        Divider()
                        
                        // --- Token Limits ---
                        Gemini_2_Flash_Model_PropertyRow(iconName: "gauge.high", propertyName: "Token limits[*]") {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("**Input token limit:** 1,048,576")
                                Text("**Output token limit:** 8,192")
                            }
                        }
                        Divider()
                        
                        // --- Capabilities ---
                        Gemini_2_Flash_Model_PropertyRow(iconName: "wrench.and.screwdriver", propertyName: "Capabilities") {
                            // Use LazyVGrid for the capabilities layout
                            LazyVGrid(columns: columns, alignment: .leading, spacing: 15) {
                                ForEach(capabilities) { capability in
                                    VStack(alignment: .leading) {
                                        Text(capability.name)
                                            .font(.subheadline)
                                            .fontWeight(.regular)
                                        Gemini_2_Flash_Model_StatusBadge(status: capability.status)
                                    }
                                }
                            }
                        }
                        Divider()
                        
                        // --- Versions ---
                        Gemini_2_Flash_Model_PropertyRow(iconName: "list.bullet.rectangle", propertyName: "Versions") {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Read the **model version patterns** for more details.") // Assuming link styling would be handled elsewhere
                                Text("• **Latest:** gemini-2.0-flash")
                                Text("• **Stable:** gemini-2.0-flash-001")
                                Text("• **Experimental:** gemini-2.0-flash-exp")
                                Text("• **Experimental:** gemini-2.0-flash-thinking-exp-01-21")
                            }
                            .font(.subheadline)
                        }
                        Divider()
                        
                        // --- Latest Update ---
                        Gemini_2_Flash_Model_PropertyRow(iconName: "calendar", propertyName: "Latest update") {
                            Text("February 2025")
                        }
                        Divider()
                        
                        // --- Knowledge Cutoff ---
                        Gemini_2_Flash_Model_PropertyRow(iconName: "brain.head.profile", propertyName: "Knowledge cutoff") {
                            Text("August 2024")
                        }
                        
                    }
                    .padding() // Inner padding for the content rows
                    .background(Color(UIColor.systemGray6)) // Subtle background like the screenshot
                    .cornerRadius(10) // Rounded corners for the card effect
                    .overlay( // Optional border
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
            }
            .padding() // Overall padding for the main VStack
        }
    }
}

// MARK: - Preview

#Preview {
    Gemini_2_Flash_Model_DetailView()
        .preferredColorScheme(.dark)
}
