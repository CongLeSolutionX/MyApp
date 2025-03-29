//
//  StyledGeminiModelCardView.swift
//  MyApp
//
//  Created by Cong Le on 3/29/25.
//

import SwiftUI

// MARK: - Shared Extensions (Required for Styling)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // Default to black
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Combined Styled Gemini Model Card View

struct StyledGeminiModelCardView: View {

    // --- Style Colors (from CardDesignView) ---
    let cardBackground = Color(hex: "#212121")
    let shadowLight = Color(hex: "#272727")
    let shadowDark = Color(hex: "#1b1b1b")
    let titleColor = Color(hex: "#b2eccf") // Use for primary text, headers, icons
    let bodyColor = Color(hex: "#B8B8B8")  // Use for secondary text, values
    let subtleDividerColor = Color(hex: "#313131") // Use for dividers instead of system default

    // Text color for supported/unsupported status (adapted from CardDesignView palette)
    let supportedTextColor = Color(hex: "#b2eccf") // Greenish title color
    let supportedBackgroundColor = Color(hex: "#b2eccf").opacity(0.15)
    let unsupportedTextColor = Color(hex: "#B3B3B3") // Footer color (greyish)
    let unsupportedBackgroundColor = Color(hex: "#B3B3B3").opacity(0.15)

    // --- Data Properties (from GeminiModelDetailView) ---
    struct Capability: Identifiable { // Make identifiable for ForEach
        let id = UUID()
        let name: String
        let isSupported: Bool
    }

    let modelName = "Gemini 2.5 Pro Experimental"
    let modelDescription = "Gemini 2.5 Pro Experimental is our state-of-the-art thinking model, capable of reasoning over complex problems in code, math, and STEM, as well as analyzing large datasets, codebases, and documents using long context."
    let modelCode = "gemini-2.5-pro-exp-03-25"
    let supportedInputs = "Audio, images, video, and text"
    let supportedOutputs = "Text"
    let inputTokenLimit = "1,048,576"
    let outputTokenLimit = "65,536"
    let latestUpdate = "March 2025"
    let knowledgeCutoff = "January 2025"

    let capabilities: [Capability] = [
        Capability(name: "Structured outputs", isSupported: true),
        Capability(name: "Caching", isSupported: false),
        Capability(name: "Tuning", isSupported: false),
        Capability(name: "Function calling", isSupported: true),
        Capability(name: "Code execution", isSupported: true),
        Capability(name: "Search grounding", isSupported: true),
        Capability(name: "Image generation", isSupported: false),
        Capability(name: "Native tool use", isSupported: true),
        Capability(name: "Audio generation", isSupported: false),
        Capability(name: "Live API", isSupported: false),
        Capability(name: "Thinking", isSupported: true)
    ]

    // Grid layout definition
    let capabilityGridLayout: [GridItem] = [
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading)
    ]

    // --- State for Hover/Tap Effect (from CardDesignView) ---
    @State private var isTapped = false // Renamed from isHovering for clarity on iOS

    // --- Body Combining Structure and Style ---
    var body: some View {
        VStack(alignment: .leading, spacing: 20) { // Increased spacing between sections

            // --- Section 1: Header ---
            VStack(alignment: .leading, spacing: 8) {
                Text(modelName)
                    .font(.system(size: 20, weight: .bold)) // Larger title
                    .foregroundColor(titleColor)

                Text(modelDescription)
                    .font(.system(size: 15))
                    .foregroundColor(bodyColor)
                    .lineLimit(nil) // Allow multiple lines

                Button {
                    print("Try in Google AI Studio tapped")
                    // Add external link opening if needed
                } label: {
                    Label("Try in Google AI Studio", systemImage: "sparkles")
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.bordered) // Use bordered, not prominent
                .tint(titleColor) // Tint the button border/text
                .padding(.top, 8)
            }
            .padding(.bottom, 10) // Add padding below header section

            // --- Section 2: Basic Properties ---
            VStack(alignment: .leading, spacing: 12) {
                StyledPropertyRow(icon: "display", label: "Model code", value: modelCode, titleColor: titleColor, bodyColor: bodyColor)
                StyledDivider(color: subtleDividerColor)
                StyledPropertyRowMultiLine(
                    icon: "square.stack.3d.up",
                    label: "Supported data types",
                    lines: [("Inputs", supportedInputs), ("Output", supportedOutputs)],
                    titleColor: titleColor, bodyColor: bodyColor
                )
                StyledDivider(color: subtleDividerColor)
                StyledPropertyRowMultiLine(
                    icon: "arrow.clockwise.circle",
                    label: "Token limits [*]",
                    lines: [("Input token limit", inputTokenLimit), ("Output token limit", outputTokenLimit)],
                    titleColor: titleColor, bodyColor: bodyColor
                )
            }
            .padding(.bottom, 10) // Add padding below properties section

            // --- Section 3: Capabilities ---
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "wrench.and.screwdriver")
                        .foregroundColor(titleColor) // Use title color for icon
                    Text("Capabilities")
                        .font(.system(size: 18, weight: .semibold)) // Match CardView title style
                        .foregroundColor(titleColor)
                }

                LazyVGrid(columns: capabilityGridLayout, alignment: .leading, spacing: 15) {
                    ForEach(capabilities) { capability in
                         StyledCapabilityItemView(
                            capability: capability,
                            supportedTextColor: supportedTextColor,
                            supportedBackgroundColor: supportedBackgroundColor,
                            unsupportedTextColor: unsupportedTextColor,
                            unsupportedBackgroundColor: unsupportedBackgroundColor,
                            bodyColor: bodyColor // Pass bodyColor for capability name text
                         )
                    }
                }
            }
            .padding(.bottom, 10) // Add padding below capabilities section

            // --- Section 4: Metadata ---
             VStack(alignment: .leading, spacing: 12) {
                // Complex Value Example (Using Button for Action)
                 StyledPropertyRowComplexValue(
                     icon: "list.number",
                     label: "Versions",
                     titleColor: titleColor,
                     bodyColor: bodyColor // Pass body color for potential nested text
                 ) {
                     VStack(alignment: .trailing, spacing: 4) {
                         Button("Read version patterns >") {
                             print("Version patterns tapped")
                             // Add navigation or link opening
                         }
                         .font(.system(size: 13))
                         .foregroundColor(titleColor.opacity(0.8)) // Slightly muted link

                         Text("• Experimental: \(modelCode)")
                             .font(.system(size: 13)) // Match footer style size
                             .foregroundColor(bodyColor) // Use body color for value
                             .multilineTextAlignment(.trailing)
                     }
                 }
                 StyledDivider(color: subtleDividerColor)
                 StyledPropertyRow(icon: "calendar", label: "Latest update", value: latestUpdate, titleColor: titleColor, bodyColor: bodyColor)
                 StyledDivider(color: subtleDividerColor)
                 StyledPropertyRow(icon: "brain.head.profile", label: "Knowledge cutoff", value: knowledgeCutoff, titleColor: titleColor, bodyColor: bodyColor)
            }

            Spacer() // Push content to top if card size is fixed or large

        }
        .padding(25) // Slightly increased padding for more content
        .frame(width: 350) // Slightly wider to accommodate grid if needed
        // Remove fixed height or make it much larger: .frame(minHeight: 600)
        .background(cardBackground)
        .cornerRadius(25) // Slightly larger corner radius
        // Outer Shadows (Neumorphic Style)
        .shadow(color: shadowDark, radius: 10, x: 6, y: 6) // Slightly larger shadow
        .shadow(color: shadowLight, radius: 10, x: -6, y: -6)
        // Tap Effect (Simulating Hover)
        .scaleEffect(isTapped ? 1.03 : 1.0)
        .offset(y: isTapped ? -10 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isTapped)
        .onTapGesture {
            isTapped.toggle()
        }
    }
}

// MARK: - Helper Views Adapted for Styling

struct StyledDivider: View {
    let color: Color
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(color)
            .padding(.vertical, 4) // Add some vertical space around divider
    }
}

struct StyledPropertyRow: View {
    let icon: String
    let label: String
    let value: String
    let titleColor: Color
    let bodyColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) { // Add spacing
            Image(systemName: icon)
                .foregroundColor(titleColor) // Use title color for icon
                .frame(width: 20, alignment: .center)
            Text(label)
                .font(.system(size: 15, weight: .medium)) // Use styled font
                .foregroundColor(titleColor) // Use title color for label
                .frame(minWidth: 100, alignment: .leading) // Adjust minWidth if needed
            Spacer()
            Text(value)
                .font(.system(size: 15)) // Use styled font
                .foregroundColor(bodyColor) // Use body color for value
                .multilineTextAlignment(.trailing)
        }
    }
}

struct StyledPropertyRowMultiLine: View {
    let icon: String
    let label: String
    let lines: [(String, String)]
    let titleColor: Color
    let bodyColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(titleColor)
                .frame(width: 20, alignment: .center)
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(titleColor)
                .frame(minWidth: 100, alignment: .leading)
            Spacer()
            VStack(alignment: .trailing, spacing: 5) { // Increased spacing
                ForEach(lines, id: \.0) { lineItem in
                    VStack(alignment: .trailing, spacing: 2) { // Reduced spacing in sub-VStack
                        Text(lineItem.0) // Key (e.g., "Inputs")
                           .font(.system(size: 13, weight: .semibold)) // Smaller, bold key
                           .foregroundColor(titleColor.opacity(0.9)) // Slightly muted title color
                        Text(lineItem.1) // Value
                            .font(.system(size: 14)) // Slightly smaller value text
                            .foregroundColor(bodyColor)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
    }
}

struct StyledPropertyRowComplexValue<Content: View>: View {
    let icon: String
    let label: String
    let titleColor: Color
    let bodyColor: Color // Pass potentially for nested content styling
    @ViewBuilder let valueContent: Content

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(titleColor)
                .frame(width: 20, alignment: .center)
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(titleColor)
                .frame(minWidth: 100, alignment: .leading)
            Spacer()
            valueContent // Embed the custom view content
        }
    }
}

struct StyledCapabilityItemView: View {
    typealias Capability = StyledGeminiModelCardView.Capability // Use outer type

    let capability: Capability
    let supportedTextColor: Color
    let supportedBackgroundColor: Color
    let unsupportedTextColor: Color
    let unsupportedBackgroundColor: Color
    let bodyColor: Color // For the capability name

    var body: some View {
        VStack(alignment: .leading, spacing: 5) { // Adjusted spacing
            Text(capability.name)
                .font(.system(size: 14)) // Use body font size
                .foregroundColor(bodyColor) // Use body color for name

            // Styled Status View Logic (Inlined for simplicity here)
            Text(capability.isSupported ? "Supported" : "Not supported")
                .font(.system(size: 11, weight: .medium)) // Smaller font for status
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .foregroundColor(capability.isSupported ? supportedTextColor : unsupportedTextColor)
                .background(capability.isSupported ? supportedBackgroundColor : unsupportedBackgroundColor)
                .cornerRadius(5)
        }
    }
}

// MARK: - Preview for the Combined View

struct StyledGeminiModelCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Need a dark background for the preview to see the neumorphic effect
        ZStack {
            Color(hex: "#1E1E1E").edgesIgnoringSafeArea(.all) // Dark background like CardDesignView
            StyledGeminiModelCardView()
        }
        .preferredColorScheme(.dark) // Ensure dark mode elements if using system colors anywhere
    }
}
