//
//  DetailsView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

// Represents the main view shown in the screenshot
struct DetailsView: View {

    // State variables to hold the values of the controls
    @State private var headerText: String = "Header"
    @State private var subheadText: String = "Subhead"
    @State private var selectedLayout: String = "Media & text"
    @State private var selectedM3Mode: String = "Auto (Light)"
    @State private var selectedTypeface: String = "Auto (Baseline)"

    let layoutOptions = ["Media & text", "Text only", "Media only"]
    let m3ModeOptions = ["Auto (Light)", "Light", "Dark"]
    let typefaceOptions = ["Auto (Baseline)", "Roboto", "Sans Serif"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // --- Top Bar ---
                TopBarView()

                // --- Preview Section ---
                PreviewSectionView()
                    .padding()
                    .background(Color(UIColor.systemGray6)) // Light background for preview

                // --- Content Section ---
                ContentSectionView()
                    .padding()
                    .background(Color(UIColor.darkGray)) // Dark background for sections

                // --- Properties Section ---
                PropertiesSectionView(
                    headerText: $headerText,
                    subheadText: $subheadText,
                    selectedLayout: $selectedLayout,
                    layoutOptions: layoutOptions
                )
                .padding()
                .background(Color(UIColor.darkGray)) // Dark background

                // --- Variable Modes Section ---
                VariableModesSectionView(
                    selectedM3Mode: $selectedM3Mode,
                    selectedTypeface: $selectedTypeface,
                    m3ModeOptions: m3ModeOptions,
                    typefaceOptions: typefaceOptions
                )
                .padding()
                .background(Color(UIColor.darkGray)) // Dark background
            }
        }
        .background(Color(UIColor.darkGray).edgesIgnoringSafeArea(.all)) // Overall background
        .foregroundColor(.white) // Default text color for dark background
        .preferredColorScheme(.dark) // Hint to the system for dark mode appearance
    }
}

// MARK: - Subviews

struct TopBarView: View {
    var body: some View {
        HStack {
            Text("Details")
                .font(.headline)
            HStack(spacing: 4) {
                Text("Material 3 Design Kit")
                    .font(.caption)
                    .foregroundColor(.gray)
                Image(systemName: "globe")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button {
                // Action for close button
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground)) // Slightly lighter dark gray
    }
}

struct PreviewSectionView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 44, height: 44)
                Text("A")
                    .font(.title3)
                    .foregroundColor(.purple)
            }

            // Header & Subhead
            VStack(alignment: .leading) {
                Text("Header")
                    .font(.headline)
                    .foregroundColor(Color(UIColor.label)) // Adapts to light/dark
                Text("Subhead")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }

            Spacer()

            // Placeholder Graphic
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.systemGray4))
                    .frame(width: 80, height: 80)

                // Simple representation of shapes
                VStack(spacing: 5) {
                    Image(systemName: "triangle.fill")
                        .foregroundColor(Color(UIColor.systemGray2))
                    HStack(spacing: 5) {
                        Image(systemName: "square.fill")
                           .foregroundColor(Color(UIColor.systemGray2))
                        Image(systemName: "circle.fill")
                           .foregroundColor(Color(UIColor.systemGray2))
                    }
                }
                .font(.system(size: 18))

            }
        }
    }
}

struct ContentSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Content")
                .font(.title3)
                .bold()

            HStack {
                // Approximation of the Material Design logo
                Image(systemName: "square.on.square.dashed") // Placeholder Icon
                    .foregroundColor(.gray)
                Text("Material Design · 6 months ago")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Button {
                // Action for Insert instance
            } label: {
                Text("Insert instance")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent) // Gives the blue background style
            .tint(.blue) // Ensure blue color
            .cornerRadius(8)
        }
    }
}

struct PropertiesSectionView: View {
    @Binding var headerText: String
    @Binding var subheadText: String
    @Binding var selectedLayout: String
    let layoutOptions: [String]

    var body: some View {
         VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "sparkles") // Icon for Properties
                    .foregroundColor(.gray)
                Text("Properties")
                    .font(.title3)
                    .bold()
                Spacer()
                Button {
                    // Action for Refresh
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.gray)
                }
            }

            PropertyRowPicker(label: "Layout", selection: $selectedLayout, options: layoutOptions)
            PropertyRowTextField(label: "Header text", text: $headerText)
            PropertyRowTextField(label: "Subhead text", text: $subheadText)
        }
    }
}

struct VariableModesSectionView: View {
    @Binding var selectedM3Mode: String
    @Binding var selectedTypeface: String
    let m3ModeOptions: [String]
    let typefaceOptions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
             Text("Variable modes")
                .font(.headline) // Slightly smaller than section titles
                .bold()

            PropertyRowPicker(label: "M3", selection: $selectedM3Mode, options: m3ModeOptions)
            PropertyRowPicker(label: "Typeface", selection: $selectedTypeface, options: typefaceOptions)
        }
    }
}

// MARK: - Reusable Helper Views

// Helper for rows with a Label and a Picker
struct PropertyRowPicker: View {
    let label: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
                .frame(minWidth: 100, alignment: .leading) // Align labels
            Spacer()
            Picker(label, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu) // Dropdown style
            .tint(.white) // Color for the picker text/chevron
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color(UIColor.systemGray2).opacity(0.4))
            .cornerRadius(6)

        }
    }
}

// Helper for rows with a Label and a TextField
struct PropertyRowTextField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
                .frame(minWidth: 100, alignment: .leading) // Align labels
            Spacer()
            TextField(label, text: $text)
                .textFieldStyle(PlainTextFieldStyle()) // Basic styling
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color(UIColor.systemGray2).opacity(0.4))
                .cornerRadius(6)
        }
    }
}

// MARK: - Preview Provider
struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView()
    }
}
