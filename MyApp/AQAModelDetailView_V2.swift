//
//  AQAModelDetailView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

import SwiftUI

// MARK: - Data Structure (Slightly Modified for Clarity)

struct AQAModelDetailView_V2_ModelInfoProperty: Identifiable {
    let id = UUID()
    let iconName: String
    let label: String // Renamed from propertyName
    let value: String // Renamed from description
    let detailValue: String? // Optional second line for value
    let isBadge: Bool? // Keep the badge flag
    var footnoteMarker: String? // To attach markers like [*]
}

// MARK: - Reusable Card View Modifier

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.secondarySystemGroupedBackground)) // Subtle background color
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2) // Subtle shadow
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardBackground())
    }
}

// MARK: - Reusable Row for Inside Cards

struct AQAModelDetailView_V2_PropertyRowModern: View {
    let property: AQAModelDetailView_V2_ModelInfoProperty

    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Image(systemName: property.iconName)
                .font(.callout) // Slightly smaller icon
                .foregroundColor(.accentColor) // Use accent color for icons
                .frame(width: 25, alignment: .center) // Consistent icon area

            Text("\(property.label)\(property.footnoteMarker ?? "")") // Add marker directly to label
                .font(.callout)
                .foregroundColor(.secondary) // Subtle label color

            Spacer() // Push value to the right

            if property.isBadge ?? false {
                Text(property.value)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                    .foregroundColor(.green)
                    .cornerRadius(6)
            } else {
                VStack(alignment: .trailing) { // Align value text to the right
                    Text(property.value)
                        .font(.callout.weight(.medium)) // Emphasize the value
                        .multilineTextAlignment(.trailing)
                    if let detail = property.detailValue {
                        Text(detail)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
        .padding(.vertical, 6) // Reduced vertical padding within rows for density
    }
}

// MARK: - Main Card-Based View

struct AQAModelDetailCardView: View {

    // Group properties logically for cards
    let coreSpecs: [AQAModelDetailView_V2_ModelInfoProperty] = [
        AQAModelDetailView_V2_ModelInfoProperty(iconName: "number.square", label: "Model Code", value: "models/aqa", detailValue: nil, isBadge: false),
        AQAModelDetailView_V2_ModelInfoProperty(iconName: "doc.text", label: "Input Type", value: "Text", detailValue: nil, isBadge: false),
        AQAModelDetailView_V2_ModelInfoProperty(iconName: "doc.text.fill", label: "Output Type", value: "Text", detailValue: nil, isBadge: false), // Slightly different icon
        AQAModelDetailView_V2_ModelInfoProperty(iconName: "globe", label: "Language", value: "English", detailValue: nil, isBadge: false)
    ]

    let limits: [AQAModelDetailView_V2_ModelInfoProperty] = [
        AQAModelDetailView_V2_ModelInfoProperty(iconName: "arrow.down.right.square", label: "Input Tokens", value: "7,168", detailValue: nil, isBadge: false, footnoteMarker: "[*]"), // Changed icon
        AQAModelDetailView_V2_ModelInfoProperty(iconName: "arrow.up.right.square", label: "Output Tokens", value: "1,024", detailValue: nil, isBadge: false, footnoteMarker: "[*]"), // Changed icon
        AQAModelDetailView_V2_ModelInfoProperty(iconName: "gauge.medium", label: "Rate Limit", value: "1,500", detailValue:"req/min", isBadge: false, footnoteMarker: "[**]") // Changed icon, detailValue
    ]

    let statusAndConfig: [AQAModelDetailView_V2_ModelInfoProperty] = [
        AQAModelDetailView_V2_ModelInfoProperty(iconName: "shield.lefthalf.filled", label: "Safety Settings", value: "Supported", detailValue: nil, isBadge: true),
        AQAModelDetailView_V2_ModelInfoProperty(iconName: "calendar", label: "Last Updated", value: "December 2023", detailValue: nil, isBadge: false)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) { // Spacing between cards

                // --- Card 1: Introduction ---
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("AQA Model") // Slightly modified title
                            .font(.title2.bold())
                        Image(systemName: "link")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    Text("Perform **Attributed Question-Answering (AQA)** over documents, grounding answers in provided sources and estimating answerability.")
                        .font(.subheadline) // Slightly smaller description
                        .foregroundColor(.secondary)
                }
                .cardStyle() // Apply reusable card style

                // --- Card 2: Core Specifications ---
                VStack(alignment: .leading, spacing: 0) { // No spacing for divider lines
                     Text("Core Specifications")
                        .font(.headline)
                        .padding([.bottom, .leading, .trailing], 8) // Add padding around title

                    Divider().padding(.horizontal) // Add horizontal padding to divider

                    ForEach(coreSpecs) { spec in
                        AQAModelDetailView_V2_PropertyRowModern(property: spec)
                        // Add divider conditionally if not the last item
                        if spec.id != coreSpecs.last?.id {
                            Divider().padding(.horizontal)
                        }
                    }
                }
                .cardStyle()

                // --- Card 3: Usage Limits ---
                 VStack(alignment: .leading, spacing: 0) {
                     Text("Usage Limits")
                        .font(.headline)
                        .padding([.bottom, .leading, .trailing], 8)

                    Divider().padding(.horizontal)

                    ForEach(limits) { limit in
                        AQAModelDetailView_V2_PropertyRowModern(property: limit)
                         if limit.id != limits.last?.id {
                            Divider().padding(.horizontal)
                        }
                    }
                }
                .cardStyle()

                // --- Card 4: Status & Configuration ---
                VStack(alignment: .leading, spacing: 0) {
                    Text("Status & Configuration")
                       .font(.headline)
                       .padding([.bottom, .leading, .trailing], 8)

                   Divider().padding(.horizontal)

                    ForEach(statusAndConfig) { item in
                        AQAModelDetailView_V2_PropertyRowModern(property: item)
                         if item.id != statusAndConfig.last?.id {
                            Divider().padding(.horizontal)
                        }
                    }
                }
                .cardStyle()

                // --- Footer Section (Not in a card for better flow) ---
                VStack(alignment: .leading, spacing: 8) {
                    // Using Link for actual tappable links
                    Link("See examples to explore capabilities", destination: URL(string: "https://example.com/aqa-examples")!) // Placeholder URL
                        .font(.footnote)

                    Text("[*] A token is roughly 4 characters (Gemini). 100 tokens ≈ 60-80 English words.")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("[**] Rate limits apply per project, per minute.") // Example revised footnote
                        .font(.caption)
                        .foregroundColor(.gray)
                        // .hidden() // Only hide if not present
                }
                .padding(.horizontal) // Align with card content padding

            }
            .padding() // Padding around the entire ScrollView content
        }
        .background(Color(.systemGroupedBackground)) // Main background for contrast
        .navigationTitle("AQA Model Details") // Add a title if used in NavigationView
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview Provider

struct AQAModelDetailCardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Wrap in NavigationView for context
             AQAModelDetailCardView()
        }
        // Preview in dark mode too
         NavigationView {
             AQAModelDetailCardView()
        }
        .preferredColorScheme(.dark)
    }
}
