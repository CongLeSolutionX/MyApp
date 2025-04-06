//
//  MaterialCardView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

struct MaterialCardView: View {
    // Mimicking the customizable properties from the image
    @State private var showSecondaryAction: Bool = true
    @State private var headerText: String = "Header"
    @State private var subheadText: String = "Subhead"
    @State private var titleText: String = "Title"
    @State private var subtitleText: String = "Subtitle"
    @State private var supportingText: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor"

    // Example state for button enabled status (not directly in properties, but typical)
    @State private var isButton1Enabled: Bool = true
    @State private var isButton2Enabled: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // --- Header Section ---
            HStack(alignment: .center, spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Text(String(headerText.first ?? "A")) // Use first letter of header, default 'A'
                        .font(.headline)
                        .foregroundColor(.purple)
                }

                // Header and Subhead
                VStack(alignment: .leading) {
                    Text(headerText)
                        .font(.headline) // Or customize typeface as per M3 properties
                        .foregroundColor(.primary)
                    Text(subheadText)
                        .font(.subheadline) // Or customize typeface
                        .foregroundColor(.secondary)
                }

                Spacer() // Pushes the action icon to the right

                // Secondary Action (Optional)
                if showSecondaryAction {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                        .padding(.leading, 8) // Add some padding if needed
                }
            }
            .padding([.horizontal, .top], 16) // Standard padding for header
            .padding(.bottom, 8) // Less padding below header

            // --- Media Placeholder Section ---
            Rectangle()
                .fill(Color.gray.opacity(0.2)) // Placeholder color
                .frame(height: 180) // Example height, adjust as needed
                .overlay(
                    // Simple representation of the shapes inside placeholder
                    ZStack {
                        Triangle_V2()
                            .fill(Color.gray.opacity(0.6))
                            .frame(width: 50, height: 40)
                            .offset(y: -30)
                        Rectangle()
                             .fill(Color.gray.opacity(0.6))
                             .frame(width: 40, height: 40)
                             .offset(x: -35, y: 30)
                        Circle()
                             .fill(Color.gray.opacity(0.6))
                             .frame(width: 40, height: 40)
                             .offset(x: 35, y: 30)
                    }
                )
                .padding(.bottom, 8)

            // --- Text Content Section ---
            VStack(alignment: .leading, spacing: 4) {
                Text(titleText)
                    .font(.title3) // Material Design might map differently, adapt as needed
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.top, 8) // Add padding above title if media isn't present or just for spacing

                Text(subtitleText)
                    .font(.body) // Adapt font as needed
                    .foregroundColor(.secondary)

                Text(supportingText)
                    .font(.body) // Adapt font as needed
                    .foregroundColor(.secondary)
                    .lineLimit(nil) // Allow multiple lines
                    .padding(.top, 8) // Space between subtitle and supporting text
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16) // Padding below text content

            // --- Action Buttons Section ---
            HStack(spacing: 8) {
                Button("Enabled") {
                    // Action for Button 1
                }
                .buttonStyle(.bordered) // Outlined style
                .disabled(!isButton1Enabled)
                .foregroundColor(isButton1Enabled ? .purple : .gray) // Match M3 style
                .tint(.purple) // Border color

                Button("Enabled") {
                    // Action for Button 2
                }
                .buttonStyle(.borderedProminent) // Filled style
                .disabled(!isButton2Enabled)
                .tint(.purple) // Background color

                Spacer() // Push buttons to the left if needed, or remove for full width spread
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16) // Padding below buttons
        }
        .background(Color(uiColor: .systemBackground)) // Use system background for light/dark mode compatibility
        .cornerRadius(12) // Standard corner radius, adjust as needed
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Subtle shadow like Material
        .padding() // Outer padding for the whole card from screen edges
    }
}

// Helper Shape for the placeholder
struct Triangle_V2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// Preview Provider for Canvas
struct MaterialCardView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialCardView()
            .previewLayout(.sizeThatFits) // Preview card size
            // Example of overriding state for preview:
            // .environment(\.colorScheme, .light) // Test light mode
             .environment(\.colorScheme, .dark) // Test dark mode
    }
}
