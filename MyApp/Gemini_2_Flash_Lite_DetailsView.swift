//
//  Gemini_2_Flash_Lite_DetailsView.swift
//  MyApp
//
//  Created by Cong Le on 3/27/25.
//

import SwiftUI

// Represents the status badges (Supported/Not supported)
struct StatusBadge: View {
    let text: String
    let isSupported: Bool

    var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundColor(.white)
            .background(isSupported ? Color.green : Color.red.opacity(0.8))
            .cornerRadius(6)
    }
}

// Represents a single item in the Capabilities grid
struct CapabilityItem: View {
    let name: String
    let isSupported: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text(name).font(.subheadline)
            StatusBadge(text: isSupported ? "Supported" : "Not supported", isSupported: isSupported)
        }
    }
}

// Main view representing the documentation page
struct GeminiFlashLiteDetailsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // --- Header Section ---
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        // Approximation of the minus icon circle
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.gray)
                        Text("Gemini 2.0 Flash-Lite")
                            .font(.title)
                            .fontWeight(.semibold)
                    }

                    Text("A Gemini 2.0 Flash model optimized for cost efficiency and low latency.")
                        .font(.body)
                        .foregroundColor(.secondary)

                    Button {
                        // TODO: Implement action to open Google AI Studio
                        print("Try in Google AI Studio tapped")
                    } label: {
                        Label("Try in Google AI Studio", systemImage: "sparkles")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue) // Adjust tint color as needed
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                Divider()

                // --- Model Details Section ---
                Text("Model details")
                    .font(.headline)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 0) {
                    // --- Model code ---
                    DetailRow(icon: "rectangle.on.rectangle.angled", title: "Model code") {
                        Text("models/gemini-2.0-flash-lite")
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8) // Add padding for alignment
                    }
                    Divider().padding(.leading, 40) // Indent divider

                    // --- Supported data types ---
                    DetailRow(icon: "doc.text.image", title: "Supported data types") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Inputs").font(.caption.weight(.bold)).foregroundColor(.secondary)
                            Text("Audio, images, video, and text")
                            Text("Output").font(.caption.weight(.bold)).foregroundColor(.secondary).padding(.top, 4)
                            Text("Text")
                        }
                         .frame(maxWidth: .infinity, alignment: .leading)
                         .padding(.vertical, 8)
                    }
                    Divider().padding(.leading, 40)

                    // --- Token limits ---
                    DetailRow(icon: "target", title: "Token limits[*]") {
                         VStack(alignment: .leading, spacing: 4) {
                             Text("Input token limit").font(.caption.weight(.bold)).foregroundColor(.secondary)
                             Text("1,048,576") // Consider using NumberFormatter for locale-specific display
                             Text("Output token limit").font(.caption.weight(.bold)).foregroundColor(.secondary).padding(.top, 4)
                             Text("8,192")
                         }
                         .frame(maxWidth: .infinity, alignment: .leading)
                         .padding(.vertical, 8)
                    }
                    Divider().padding(.leading, 40)

                    // --- Capabilities ---
                    // Use VStack for aligning title with Grid content
                     VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                             Image(systemName: "wrench.and.screwdriver.fill")
                                 .frame(width: 20) // Consistent icon width
                                 .foregroundColor(.blue)
                             Text("Capabilities")
                                 .font(.callout)
                                 .fontWeight(.medium)
                                 .foregroundColor(.primary)
                             Spacer() // Push grid to the right if needed, or remove for left alignment
                         }
                         .padding(.vertical, 12)

                        // Grid for capabilities layout
                         Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                             GridRow {
                                 CapabilityItem(name: "Structured outputs", isSupported: true)
                                 CapabilityItem(name: "Caching", isSupported: false)
                                 CapabilityItem(name: "Tuning", isSupported: false)
                             }
                             GridRow {
                                 CapabilityItem(name: "Function calling", isSupported: false)
                                 CapabilityItem(name: "Code execution", isSupported: false)
                                 CapabilityItem(name: "Search", isSupported: false)
                             }
                             GridRow {
                                 CapabilityItem(name: "Image generation", isSupported: false)
                                 CapabilityItem(name: "Native tool use", isSupported: false)
                                 CapabilityItem(name: "Audio generation", isSupported: false)
                             }
                              GridRow {
                                 CapabilityItem(name: "Live API", isSupported: false)
                                 // Add Spacer or empty views if needed to fill grid cells
                                 Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                                 Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                             }
                         }
                         .padding(.bottom, 8) // Padding below the grid

                     }
                     .padding(.horizontal) // Apply padding to the capability section container

                    Divider().padding(.leading, 40)

                    // --- Versions ---
                     DetailRow(icon: "number", title: "Versions") {
                         VStack(alignment: .leading, spacing: 4) {
                             // Simulate link - actual Link view might be better
                             Text("Read the model version patterns for more details.")
                                 .foregroundColor(.blue)
                                 .onTapGesture {
                                     print("Navigate to model version patterns")
                                     // TODO: Open URL
                                 }

                             HStack {
                                 Text("• Latest:")
                                 Text("gemini-2.0-flash-lite")
                                     .font(.system(.body, design: .monospaced))
                             }
                             HStack {
                                 Text("• Stable:")
                                 Text("gemini-2.0-flash-lite-001")
                                     .font(.system(.body, design: .monospaced))
                             }
                         }
                         .frame(maxWidth: .infinity, alignment: .leading)
                         .padding(.vertical, 8)
                     }
                    Divider().padding(.leading, 40)

                    // --- Latest update ---
                    DetailRow(icon: "calendar", title: "Latest update") {
                        Text("February 2025")
                         .frame(maxWidth: .infinity, alignment: .leading)
                         .padding(.vertical, 8)
                    }
                    Divider().padding(.leading, 40)

                    // --- Knowledge cutoff ---
                    DetailRow(icon: "brain.head.profile", title: "Knowledge cutoff") {
                         Text("August 2024")
                         .frame(maxWidth: .infinity, alignment: .leading)
                         .padding(.vertical, 8)
                    }
                    // No divider after the last item

                } // End Details VStack
                .background(Color(uiColor: .systemBackground)) // Use system background
                .cornerRadius(10) // Rounded corners for the card effect
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)


            } // End Main VStack
            .padding(.vertical) // Padding for ScrollView content
        } // End ScrollView
        //.navigationTitle("Gemini Model Details") // Optional Navigation Title
    }
}

// Helper View for consistent row layout (Icon, Title, Description Content)
struct DetailRow<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20) // Consistent icon width
                .foregroundColor(.blue) // Or choose appropriate color

            Text(title)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                 // Adjust width as needed for alignment, or remove fixed width
                .frame(minWidth: 120, alignment: .leading)


            //Spacer() // Pushes content to the right edge

            content() // The description part of the row
                 .font(.callout) // Default font for content
                 .foregroundColor(.secondary) // Default color for content

        }
        .padding(.horizontal)
        .padding(.vertical, 12) // Consistent vertical padding for rows
    }
}

// Preview Provider
struct GeminiFlashLiteDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        GeminiFlashLiteDetailsView()
    }
}
