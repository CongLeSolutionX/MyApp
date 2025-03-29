//
//  StyledGeminiModelCardView.swift
//  MyApp
//
//  Created by Cong Le on 3/29/25.
//
import SwiftUI

// MARK: - Shared Extensions (Required - Assumed Present)
// extension Color { ... init(hex:) ... }

// MARK: - Enhanced Gemini Model Profile Card View (Intuitive & Accessible)

struct EnhancedGeminiProfileCard: View {

    // --- Style Colors (Refined Palette) ---
    let cardBackground = Color(hex: "#212121")
    let shadowLight = Color(hex: "#2C2C2C") // Slightly lighter outer shadow
    let shadowDark = Color(hex: "#1A1A1A")  // Slightly darker outer shadow
    let titleColor = Color(hex: "#C8F0E1") // Slightly adjusted green/cyan
    let primaryTextColor = Color(hex: "#E0E0E0") // Main body text (off-white)
    let secondaryTextColor = Color(hex: "#A0A0A0") // Less important text, labels
    let accentColor = Color(hex: "#82D8FF") // Bluish accent for icons, links, buttons
    let subtleDividerColor = Color(hex: "#353535") // Softer divider
    let sectionBackgroundColor = Color(hex: "#282828").opacity(0.5) // Subtle bg for sections

    let imageBackground = Color(hex: "#313131")
    let imageShadowLight = Color.white.opacity(0.08) // Subtler inset shadow
    let imageShadowDark = Color.black.opacity(0.3)   // Subtler inset shadow

    // Status colors
    let supportedTextColor = Color(hex: "#A5E8C2") // Soft green text
    let supportedBackgroundColor = Color(hex: "#A5E8C2").opacity(0.15)
    let unsupportedTextColor = Color(hex: "#B0B0B0") // Neutral grey text
    let unsupportedBackgroundColor = Color(hex: "#B0B0B0").opacity(0.15)

    // --- Data Properties (Adding Icons to Capabilities) ---
    struct Capability: Identifiable {
        let id = UUID()
        let name: String
        let isSupported: Bool
        let iconName: String // SF Symbol name relevant to the capability
    }

    // ... (modelName, modelDescription, etc. - Same data as before)
    let modelName = "Gemini 2.5 Pro Experimental"
    let modelDescription = "State-of-the-art thinking model for complex reasoning, analysis of large datasets, codebases, and long documents." // Slightly shortened for profile view
    let modelCode = "gemini-2.5-pro-exp-03-25"
    let supportedInputs = "Audio, images, video, text"
    let supportedOutputs = "Text"
    let inputTokenLimit = "1,048,576"
    let outputTokenLimit = "65,536"
    let latestUpdate = "March 2025"
    let knowledgeCutoff = "January 2025"

    // Capabilities with mapped icons
    let capabilities: [Capability] = [
        Capability(name: "Structured outputs", isSupported: true, iconName: "arrow.down.doc"),
        Capability(name: "Function calling", isSupported: true, iconName: "phone.arrow.up.right"),
        Capability(name: "Code execution", isSupported: true, iconName: "play.rectangle.on.rectangle"),
        Capability(name: "Search grounding", isSupported: true, iconName: "magnifyingglass"),
        Capability(name: "Native tool use", isSupported: true, iconName: "wrench.and.screwdriver"),
        Capability(name: "Thinking", isSupported: true, iconName: "brain.head.profile"),
        Capability(name: "Caching", isSupported: false, iconName: "archivebox"),
        Capability(name: "Tuning", isSupported: false, iconName: "slider.horizontal.3"),
        Capability(name: "Image generation", isSupported: false, iconName: "photo"),
        Capability(name: "Audio generation", isSupported: false, iconName: "waveform"),
        Capability(name: "Live API", isSupported: false, iconName: "antenna.radiowaves.left.and.right"),
    ]

    // Layout Definition for Capabilities Grid (Adaptive)
    let capabilityGridLayout: [GridItem] = [
        GridItem(.adaptive(minimum: 140), alignment: .leading) // Min width for chips
    ]

    // --- State for Tap Effect ---
    @State private var isTapped = false

    // --- Body with Enhanced Layout ---
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // --- Top Profile Section ---
            HStack(alignment: .top, spacing: 18) { // Increased spacing
                profileImagePlaceholder() // Reusing the placeholder function slightly modified visually
                    .padding(.leading, 0)

                VStack(alignment: .leading, spacing: 6) {
                    Text(modelName)
                        .font(.system(size: 20, weight: .semibold)) // Make title stand out
                        .foregroundColor(titleColor)
                        .lineLimit(2)

                    Text(modelDescription)
                        .font(.system(size: 14))
                        .foregroundColor(primaryTextColor.opacity(0.9))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    Button { print("Try in Google AI Studio tapped") } label: {
                        Label("Try in Studio", systemImage: "sparkles")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .buttonStyle(.bordered)
                    .tint(accentColor) // Use accent color for button
                    .controlSize(.regular) // Slightly larger touch target
                    .padding(.top, 8)
                }
                Spacer() // Ensure text fills available space
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 20) // Space before details

            // --- Details Section - Visually Grouped ---
            VStack(alignment: .leading, spacing: 18) { // Increased spacing between detail sections

                // --- Core Properties ---
                VStack(alignment: .leading, spacing: 12) {
                    Text("Core Properties")
                       .font(.system(size: 16, weight: .semibold))
                       .foregroundColor(primaryTextColor)
                       .padding(.bottom, 4)

                    EnhancedPropertyRow(icon: "barcode", label: "Model ID", value: modelCode, primaryColor: primaryTextColor, secondaryColor: secondaryTextColor) // Changed Icon
                    EnhancedDivider(color: subtleDividerColor)
                    EnhancedPropertyRowMultiLine(
                        icon: "arrow.left.arrow.right.square", // Changed Icon
                        label: "Data Types",
                        lines: [("Input", supportedInputs), ("Output", supportedOutputs)],
                        primaryColor: primaryTextColor, secondaryColor: secondaryTextColor, keyColor: titleColor.opacity(0.8)
                    )
                    EnhancedDivider(color: subtleDividerColor)
                    EnhancedPropertyRow(
                        icon: "arrow.up.arrow.down.circle", // Changed Icon
                        label: "Token Limits",
                        value: "Input: \(inputTokenLimit)\nOutput: \(outputTokenLimit)", // Combine value for simpler row
                        primaryColor: primaryTextColor, secondaryColor: secondaryTextColor,
                        infoText: "Max units of text processed per request." // Info tooltip text
                    )
                }
                .padding()
                .background(sectionBackgroundColor) // Subtle background for grouping
                .cornerRadius(12)

                // --- Capabilities ---
                VStack(alignment: .leading, spacing: 12) {
                    Text("Capabilities")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(primaryTextColor)

                    LazyVGrid(columns: capabilityGridLayout, alignment: .leading, spacing: 12) {
                        ForEach(capabilities) { capability in
                            CapabilityChipView( // Using the new Chip view
                                capability: capability,
                                supportedTextColor: supportedTextColor,
                                supportedBackgroundColor: supportedBackgroundColor,
                                unsupportedTextColor: unsupportedTextColor,
                                unsupportedBackgroundColor: unsupportedBackgroundColor,
                                chipBackgroundColor: cardBackground // Chip bg matches card bg for seamless look
                            )
                        }
                    }
                }
                 // No extra background needed if chips are distinct enough

                // --- Metadata ---
                VStack(alignment: .leading, spacing: 12) {
                     Text("Metadata")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(primaryTextColor)
                        .padding(.bottom, 4)

                     // Make version row look more interactive/link-like
                      HStack {
                           Image(systemName: "list.bullet.clipboard") // Changed Icon
                               .foregroundColor(accentColor.opacity(0.8))
                               .frame(width: 20, alignment: .center)
                           Text("Current Version")
                                .font(.system(size: 14))
                                .foregroundColor(primaryTextColor)
                           Spacer()
                           Button { print("Version patterns tapped") } label: {
                               HStack(spacing: 4) {
                                   Text(modelCode) // Show the version code directly
                                    .font(.system(size: 14, weight: .light)) // Use light weight for value/link

                                   Image(systemName: "link") // Link icon
                                    .font(.system(size: 12))

                               }
                               .foregroundColor(accentColor) // Use Accent color for link
                           }
                          
                      }
                      EnhancedDivider(color: subtleDividerColor)
                      EnhancedPropertyRow(
                        icon: "calendar.badge.clock", // Changed Icon
                        label: "Knowledge Cutoff",
                        value: knowledgeCutoff,
                        primaryColor: primaryTextColor, secondaryColor: secondaryTextColor,
                        infoText: "Data used for training ends around this date."
                      )
                      EnhancedDivider(color: subtleDividerColor)
                      EnhancedPropertyRow(icon: "sparkles.rectangle.stack", label: "Last Updated", value: latestUpdate, primaryColor: primaryTextColor, secondaryColor: secondaryTextColor) // Changed Icon

                }
                .padding()
                .background(sectionBackgroundColor)
                .cornerRadius(12)


            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

        }
        .background(cardBackground)
        .cornerRadius(20)
        // Neumorphic Shadows
        .shadow(color: shadowDark, radius: 10, x: 6, y: 6)
        .shadow(color: shadowLight, radius: 10, x: -6, y: -6)
        // Tap Effect
        .scaleEffect(isTapped ? 1.02 : 1.0)
        .offset(y: isTapped ? -5 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isTapped)
        .onTapGesture { isTapped.toggle() }
    }

    // MARK: - Modified Profile Image Placeholder
    @ViewBuilder
    private func profileImagePlaceholder() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12) // Slightly softer corners
                .fill(imageBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(imageShadowDark, lineWidth: 2) // Thinner stroke
                        .blur(radius: 2)
                        .offset(x: 1.5, y: 1.5)
                        .mask(RoundedRectangle(cornerRadius: 12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(imageShadowLight, lineWidth: 2)
                        .blur(radius: 2)
                        .offset(x: -1.5, y: -1.5)
                        .mask(RoundedRectangle(cornerRadius: 12))
                )

            Image(systemName: "brain.head.profile") // Gemini Icon
                .resizable()
                .scaledToFit()
                .foregroundColor(accentColor.opacity(0.8)) // Use accent color
                .padding(16)
        }
        .frame(width: 65, height: 65) // Slightly smaller placeholder
    }
}


// MARK: - Enhanced & New Helper Views

struct EnhancedDivider: View {
    let color: Color
    var body: some View {
        Divider().background(color).padding(.vertical, 2) // Use system divider with color tint
    }
}

// Simplified Row supporting optional info text
struct EnhancedPropertyRow: View {
    let icon: String
    let label: String
    let value: String
    let primaryColor: Color
    let secondaryColor: Color
    var infoText: String? = nil // Optional info text

    var body: some View {
        HStack(alignment: infoText == nil ? .center : .top, spacing: 10) { // Align top if info text exists
            Image(systemName: icon)
                .foregroundColor(primaryColor.opacity(0.7))
                .font(.system(size: 18))
                .frame(width: 25, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                 Text(label)
                     .font(.system(size: 14))
                     .foregroundColor(primaryColor)

                 // Display info text if provided
                 if let info = infoText {
                      HStack(spacing: 3) {
                         Image(systemName: "info.circle")
                              .font(.system(size: 11))
                              .foregroundColor(secondaryColor.opacity(0.8))
                          Text(info)
                             .font(.system(size: 11))
                             .foregroundColor(secondaryColor.opacity(0.8))
                      }
                 }
            }
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .light)) // Lighter weight for value
                .foregroundColor(secondaryColor)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// Simplified Multi-line version
struct EnhancedPropertyRowMultiLine: View {
    let icon: String
    let label: String
    let lines: [(String, String)]
    let primaryColor: Color
    let secondaryColor: Color
    let keyColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(primaryColor.opacity(0.7))
                .font(.system(size: 18))
                .frame(width: 25, alignment: .center)
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(primaryColor)
                .padding(.top, 2) // Align label better with multi-line content
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                ForEach(lines, id: \.0) { lineItem in
                    HStack(spacing: 5) {
                        Text(lineItem.0 + ":")
                           .font(.system(size: 12, weight: .medium)) // Medium weight key
                           .foregroundColor(keyColor) // Use specific key color
                        Text(lineItem.1)
                            .font(.system(size: 13, weight: .light)) // Lighter weight value
                            .foregroundColor(secondaryColor)
                            .multilineTextAlignment(.trailing)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

// New View for Capability Chips
struct CapabilityChipView: View {
    typealias Capability = EnhancedGeminiProfileCard.Capability

    let capability: Capability
    let supportedTextColor: Color
    let supportedBackgroundColor: Color
    let unsupportedTextColor: Color
    let unsupportedBackgroundColor: Color
    let chipBackgroundColor: Color // To blend with card or section

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: capability.iconName)
                .foregroundColor(capability.isSupported ? supportedTextColor : unsupportedTextColor.opacity(0.7))
                .font(.system(size: 14)) // Icon size within chip
                .frame(width: 18, alignment: .center)

            Text(capability.name)
                .font(.system(size: 13)) // Slightly smaller text in chip
                .foregroundColor(capability.isSupported ? supportedTextColor : unsupportedTextColor)
                .lineLimit(1)

            Spacer() // Push status tag to the right if needed, or remove for compact chips

             // Status indicator (optional, could be just color coding the chip/icon)
             Circle()
                 .fill(capability.isSupported ? supportedTextColor : unsupportedTextColor.opacity(0.5))
                 .frame(width: 6, height: 6)

        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(capability.isSupported ? supportedBackgroundColor : unsupportedBackgroundColor) // Use status bg for chip bg
        .cornerRadius(15) // Pill shape
        // Optional subtle border matching card background to lift it slightly
         .overlay(
             RoundedRectangle(cornerRadius: 15)
              .stroke(chipBackgroundColor.opacity(0.5), lineWidth: 1)
         )
    }
}


// MARK: - Preview

struct EnhancedGeminiProfileCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(hex: "#1E1E1E").edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
                    EnhancedGeminiProfileCard()
                        .padding() // Normal width

                    EnhancedGeminiProfileCard()
                        .frame(width: 320) // Constrained width example
                        .padding()
                }
                .padding(.vertical)
            }
        }
        .preferredColorScheme(.dark)
    }
}
