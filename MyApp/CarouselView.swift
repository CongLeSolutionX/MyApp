//
//  CarouselView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

// Simple shapes for placeholder preview
struct Triangle_V3: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct CarouselConfiguratorView: View {
    // State variables for UI controls
    @State private var selectedContext: ContextOption = .mobile
    @State private var selectedLayout: LayoutOption = .hero
    @State private var showTextContent: Bool = true
    @State private var selectedTypeface: TypefaceOption = .auto

    enum ContextOption: String, CaseIterable, Identifiable {
        case mobile = "Mobile"
        case tablet = "Tablet"
        var id: String { self.rawValue }
    }

    enum LayoutOption: String, CaseIterable, Identifiable {
        case hero = "Hero"
        case standard = "Standard"
        case compact = "Compact"
        var id: String { self.rawValue }
    }

    enum TypefaceOption: String, CaseIterable, Identifiable {
        case auto = "Auto (Baseline)"
        case custom = "Custom Font"
        var id: String { self.rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 1. Top Bar (Simplified)
                HStack {
                    Text("Material 3 Design Kit")
                        .font(.headline)
                    Image(systemName: "globe")
                        .foregroundColor(.secondary)
                    Spacer()
                    Button {
                        // Action for close button
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6)) // Approximate color

                // 2. Carousel Preview Area
                HStack(spacing: 10) {
                    CarouselPreviewItem(label: "1st")
                    CarouselPreviewItem(label: "2nd")
                }
                .padding()
                .frame(maxWidth: .infinity) // Make HStack take full width for alignment
                .background(Color(.systemGroupedBackground)) // Light background for preview

                // 3. Main Content Area (Info Panel)
                VStack(alignment: .leading, spacing: 15) {
                    Text("Carousel")
                        .font(.title)
                        .fontWeight(.medium)

                    Text("A Carousel contains a collection of items that can be scrolled on and off the screen.")
                        .foregroundColor(.secondary)

                    HStack(alignment: .top) {
                        Image(systemName: "wrench.and.screwdriver") // Settings icon
                            .foregroundColor(.secondary)
                            .padding(.top, 4) // Align icon better with text

                        Text("Select between Uniform and Non-uniform layouts;\nChoose Mobile or Tablet context\nAn optional item-text's visibility can be toggled on and off")
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }

                    Button("Show less") {
                        // Action to show/hide details
                    }
                    .foregroundColor(.blue) // Standard link color

                    HStack {
                        Image(systemName: "circle.inset.filled") // Placeholder for Material Design logo
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.gray)

                        Text("Material Design · 6 months ago")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Button("Insert instance") {
                        // Action for inserting
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity) // Make button full width

                }
                .padding()
                .background(Color(.secondarySystemBackground)) // Darker grey background
                .cornerRadius(10)
                .padding(.horizontal) // Add padding to contain within screen edges

                // 4. Divider
                Divider().padding(.vertical, 10)

                // 5. Properties Section
                VStack(alignment: .leading, spacing: 15) {
                    // Properties Header
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.secondary)
                        Text("Properties")
                            .font(.headline)
                        Spacer()
                        Button {
                            // Action for refresh
                        } label: {
                             Image(systemName: "arrow.clockwise")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom, 5) // Space below header

                    // Context Picker
                    HStack {
                        Text("Context")
                        Spacer()
                        Picker("Context", selection: $selectedContext) {
                            ForEach(ContextOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.menu) // Resembles dropdown
                        .frame(maxWidth: 150, alignment: .trailing) // Limit width
                         .tint(.secondary) // Match picker color
                    }

                    // Layout Picker
                    HStack {
                        Text("Layout")
                        Spacer()
                        Picker("Layout", selection: $selectedLayout) {
                            ForEach(LayoutOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: 150, alignment: .trailing)
                        .tint(.secondary)
                    }

                    // Text Content Toggle
                    HStack {
                        Text("Text content")
                        Spacer()
                        Toggle("", isOn: $showTextContent)
                            .labelsHidden()
                    }

                    // Variable Modes Header
                    Text("Variable modes")
                        .font(.headline)
                        .padding(.top, 10) // Space above this header

                    // Typeface Picker
                    HStack {
                        Text("Typeface")
                        Spacer()
                        Picker("Typeface", selection: $selectedTypeface) {
                            ForEach(TypefaceOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: 200, alignment: .trailing) // Wider for longer text
                        .tint(.secondary)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground)) // Darker grey background
                .cornerRadius(10)
                .padding(.horizontal) // Add padding to contain within screen edges
                .padding(.bottom) // Add padding at the very bottom
            }
            .foregroundColor(Color(.label)) // Default text color for dark mode compatibility
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Set overall background
    }
}

// Reusable view for the carousel preview items
struct CarouselPreviewItem: View {
    let label: String

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray4)) // Placeholder background
                .frame(width: 150, height: 180) // Approximate size

            VStack(spacing: 10) {
                Spacer() // Push shapes down
                Triangle_V3()
                    .fill(Color(.systemGray))
                    .frame(width: 50, height: 40)

                Rectangle() // Square shape
                    .fill(Color(.systemGray))
                    .frame(width: 40, height: 40)

                Spacer() // Add some space above circle
                Spacer()
            }
            .frame(height: 150) // Contain the shapes vertically

            Text(label)
                .font(.caption)
                .padding(5)
                .background(Circle().fill(Color(.systemGray2)))
                .foregroundColor(.white)
                .padding(8) // Padding from the corner
        }
    }
}

#Preview {
    CarouselConfiguratorView()
        .preferredColorScheme(.dark) // Preview in dark mode to match screenshot context better
}
