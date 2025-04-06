//
//  ButtonDesignsView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

// MARK: - Color Approximations
// Approximate Material 3 Colors - Adjust these for precise matching
extension Color {
    static let materialPrimary = Color(red: 0.4, green: 0.3, blue: 0.7) // Purple shade
    static let materialOnPrimary = Color.white
    static let materialSecondaryContainer = Color(white: 0.92) // Light lavender/gray
    static let materialOnSecondaryContainer = Color.materialPrimary
    static let materialOutline = Color.gray.opacity(0.6)
}

// MARK: - Helper for Specific Corner Rounding
// Needed for segmented buttons
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Main ContentView
struct ButtonDesignsView: View {
    // State for toggleable and segmented buttons
    @State private var isIconToggled = false
    @State private var selectedSegment = 0

    // Define grid layout
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    // --- Standard Button ---
                    ButtonExampleView(title: "Button") {
                        Button(action: {}) {
                            Text("Label")
                                .font(.headline)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(FilledButtonStyle())
                    }

                    // --- Extended FAB ---
                    ButtonExampleView(title: "Extended FAB") {
                        Button(action: {}) {
                            Label("Label", systemImage: "pencil")
                                .font(.headline)
                                .padding(.horizontal, 16) // More horizontal padding
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(ExtendedFabButtonStyle())
                    }

                     // --- FAB ---
                    ButtonExampleView(title: "FAB") {
                        Button(action: {}) {
                            Image(systemName: "pencil")
                                .font(.title2.weight(.medium)) // Make icon slightly larger/bolder
                               // .imageScale(.large) // Alternative sizing
                                .frame(width: 56, height: 56) // Standard FAB size
                        }
                        .buttonStyle(CircularFabButtonStyle())
                    }

                    // --- Icon Button (Filled) ---
                    ButtonExampleView(title: "Icon button") {
                        Button(action: {}) {
                             Image(systemName: "gearshape.fill") // Using fill variant
                                .font(.title2)
                                .frame(width: 48, height: 48) // Slightly smaller than FAB
                        }
                         .buttonStyle(CircularIconFilledButtonStyle())
                    }

                     // --- Icon Button Toggleable ---
                    ButtonExampleView(title: "Icon button toggleable") {
                        Button(action: { isIconToggled.toggle() }) {
                             Image(systemName: "gearshape") // Outline variant
                                .font(.title2)
                                .frame(width: 48, height: 48)
                        }
                        .buttonStyle(CircularIconToggleableButtonStyle(isToggled: isIconToggled))
                    }

                    // --- Large FAB ---
                    ButtonExampleView(title: "Large FAB") {
                        Button(action: {}) {
                            Image(systemName: "pencil")
                                .font(.system(size: 36)) // Larger icon
                                .frame(width: 96, height: 96) // Large FAB size
                        }
                        .buttonStyle(LargeFabButtonStyle())
                    }

                    // --- Segmented Button ---
                     ButtonExampleView(title: "Segmented button") {
                        SegmentedButton(selectedSegment: $selectedSegment, options: [
                            SegmentedOption(id: 0, label: "Label", icon: "checkmark"),
                            SegmentedOption(id: 1, label: "Label") // Second segment without icon in example
                        ])
                    }

                    // --- Small FAB ---
                    ButtonExampleView(title: "Small FAB") {
                        Button(action: {}) {
                             Image(systemName: "pencil")
                                .font(.headline) // Smaller icon
                                .frame(width: 40, height: 40) // Small FAB size
                        }
                        .buttonStyle(SmallFabButtonStyle())
                    }

                    // --- Button Segment (End) ---
                    ButtonExampleView(title: "Button segment (end)") {
                        SegmentedButton(selectedSegment: .constant(0), options: [
                             SegmentedOption(id: 0, label: "Label", icon: "checkmark")
                        ], forceStyle: .endOnly) // Display only the end style
                    }

                    // --- Button Segment (Middle) ---
                     ButtonExampleView(title: "Button segment (middle)") {
                        SegmentedButton(selectedSegment: .constant(0), options: [
                             SegmentedOption(id: 0, label: "Label", icon: "checkmark")
                        ], forceStyle: .middleOnly) // Display only the middle style
                    }

                    // --- Button Segment (Start) ---
                     ButtonExampleView(title: "Button segment (start)") {
                        SegmentedButton(selectedSegment: .constant(0), options: [
                             SegmentedOption(id: 0, label: "Label", icon: "checkmark")
                        ], forceStyle: .startOnly) // Display only the start style
                    }
                }
                .padding()
            }
            .background(Color(.secondarySystemBackground)) // Background similar to image
            .navigationTitle("Material 3 Design Kit / Buttons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { // Add back button resemblance
                 ToolbarItem(placement: .navigationBarLeading) {
                     Image(systemName: "chevron.left")
                         .foregroundColor(.primary) // Use default text color
                  }
            }
        }
        .navigationViewStyle(.stack) // Use stack style for better consistency
    }
}

// MARK: - Reusable View for Examples
struct ButtonExampleView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 8) {
            content
                .frame(maxWidth: .infinity, minHeight: 100) // Ensure container size
                .background(Color(.systemBackground)) // White background for button container
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2) // Subtle shadow for container

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Button Styles

struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.materialOnPrimary)
            .background(Color.materialPrimary)
            .clipShape(Capsule()) // Material buttons often use full capsule shape
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ExtendedFabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.materialOnSecondaryContainer)
            .background(Color.materialSecondaryContainer)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.1 : 0.2),
                    radius: configuration.isPressed ? 2 : 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct CircularFabButtonStyle: ButtonStyle {
     func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.materialOnSecondaryContainer)
            .background(Color.materialSecondaryContainer)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.1 : 0.2),
                    radius: configuration.isPressed ? 2 : 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct CircularIconFilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.materialOnPrimary)
            .background(Color.materialPrimary)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct CircularIconToggleableButtonStyle: ButtonStyle {
    let isToggled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.materialOnSecondaryContainer)
            // Show a slightly different background when toggled/active
            .background(isToggled ? Color.materialPrimary.opacity(0.15) : Color.materialSecondaryContainer)
            .clipShape(Circle())
             // Optional: Add a subtle shadow, slightly reduced when toggled/pressed
            .shadow(color: Color.black.opacity(configuration.isPressed || isToggled ? 0.08 : 0.15),
                    radius: configuration.isPressed || isToggled ? 1 : 3, x: 0, y: 1)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.2), value: isToggled) // Animate toggle state change
    }
}

// Common style for squircle FABs, adjusted by frame size
struct SquircleFabButtonStyle: ButtonStyle {
     let cornerRadius: CGFloat

     func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.materialOnSecondaryContainer)
            .background(Color.materialSecondaryContainer)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)) // Continuous gives squircle feel
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.1 : 0.2),
                    radius: configuration.isPressed ? 2 : 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Specific FAB styles using the common Squircle style
struct LargeFabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        SquircleFabButtonStyle(cornerRadius: 28).makeBody(configuration: configuration)
    }
}

struct SmallFabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
         SquircleFabButtonStyle(cornerRadius: 12).makeBody(configuration: configuration)
    }
}

// MARK: - Segmented Button Components

struct SegmentedOption: Identifiable {
    let id: Int
    let label: String
    var icon: String? = nil // Optional icon
}

enum SegmentForceStyle {
    case none, startOnly, middleOnly, endOnly
}

struct SegmentedButton: View {
    @Binding var selectedSegment: Int
    let options: [SegmentedOption]
    var forceStyle: SegmentForceStyle = .none // To show individual segments

    private let cornerRadius: CGFloat = 20 // Capsule-like rounding

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options) { option in
                Button(action: { selectedSegment = option.id }) {
                    SegmentButtonLabel(option: option)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12) // Adjust padding as needed
                        .frame(maxWidth: .infinity) // Make segments expand equally
                }
                .background(backgroundFor(option: option))
                .foregroundColor(foregroundFor(option: option))
//                .clipShape(clipShapeFor(option: option))
            }
        }
        // Add the outer border for the entire segmented control
        .overlay(
             // Only show overlay if it's the full segmented button
             forceStyle == .none ?
                 RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.materialOutline, lineWidth: 1)
                 : nil // No overlay for single demo segments
        )
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3), value: selectedSegment)
    }

    // Determine background color based on selection
    @ViewBuilder
    private func backgroundFor(option: SegmentedOption) -> some View {
        if selectedSegment == option.id {
            Color.materialPrimary.opacity(0.15) // Selected background
        } else {
            Color.clear // Default background
        }
    }

    // Determine text/icon color based on selection
    private func foregroundFor(option: SegmentedOption) -> Color {
        if selectedSegment == option.id {
            return .materialPrimary // Selected foreground
        } else {
            return .materialOutline // Default foreground (adjust if needed)
            // Could also use .primary or .secondary for better contrast depending on theme
        }
    }

    // Determine the clipping shape based on position or forced style
    @ViewBuilder
    private func clipShapeFor(option: SegmentedOption) -> some View {
        let radius = cornerRadius
        let index = options.firstIndex(where: { $0.id == option.id }) ?? 0
        let isFirst = index == 0
        let isLast = index == options.count - 1

        // Apply forced style if specified
        if forceStyle == .startOnly {
            RoundedCorner(radius: radius, corners: [.topLeft, .bottomLeft])
        } else if forceStyle == .middleOnly {
            // Middle segments have no rounding
             Rectangle() // Can also use RoundedRectangle(cornerRadius: 0)
        } else if forceStyle == .endOnly {
            RoundedCorner(radius: radius, corners: [.topRight, .bottomRight])
        }
        // Standard logic for full segmented control
        else if isFirst && isLast { // Single segment case
            RoundedRectangle(cornerRadius: radius)
        } else if isFirst {
            RoundedCorner(radius: radius, corners: [.topLeft, .bottomLeft])
        } else if isLast {
            RoundedCorner(radius: radius, corners: [.topRight, .bottomRight])
        } else {
             // Middle segments have no rounding
             Rectangle()
        }
    }
}

// Label structure for Segmented Buttons
struct SegmentButtonLabel: View {
    let option: SegmentedOption

    var body: some View {
        HStack(spacing: 5) {
            if let iconName = option.icon {
                Image(systemName: iconName)
                    .font(.callout) // Slightly smaller icon
            }
            Text(option.label)
                .font(.caption.weight(.semibold))
                .lineLimit(1) // Prevent text wrapping
        }
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonDesignsView()
    }
}
