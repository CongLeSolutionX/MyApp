//
//  ImageMakerView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

// Placeholder data structures - Added isSelected toggling logic
struct FilterOption: Identifiable {
    let id = UUID()
    let imageNamePlaceholder: String // Using system names or placeholders now
    let label: String
    var isSelected: Bool = false
}

struct PromptSuggestion: Identifiable {
    let id = UUID()
    let text: String
    var isSelected: Bool = false
}

struct ImageMakerView: View {

    // State variables to manage selection
    @State private var filterOptions: [FilterOption] = [
        FilterOption(imageNamePlaceholder: "camera.metering.none", label: "Bowler hat"), // Changed to system names or basic placeholders
        FilterOption(imageNamePlaceholder: "camera.metering.partial", label: ""),
        FilterOption(imageNamePlaceholder: "photo.circle.fill", label: "Realistic", isSelected: true),
        FilterOption(imageNamePlaceholder: "moon.stars.fill", label: ""),
        FilterOption(imageNamePlaceholder: "sparkles", label: "")
    ]

    @State private var promptSuggestions: [PromptSuggestion] = [
        PromptSuggestion(text: "Bowler hat"), // Placeholder prompts
        PromptSuggestion(text: "Spaceship landing on Mars", isSelected: true),
        PromptSuggestion(text: "Woman walking")
    ]

    @State private var selectedFilterId: UUID? = nil // Track selected filter
    @State private var selectedPromptId: UUID? = nil // Track selected prompt

    init() {
        // Initialize selection based on initial data
        _selectedFilterId = State(initialValue: filterOptions.first(where: { $0.isSelected })?.id)
        _selectedPromptId = State(initialValue: promptSuggestions.first(where: { $0.isSelected })?.id)
    }

    var body: some View {
        ZStack {
            // MARK: - Background Placeholder
            LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.red.opacity(0.6), Color.black]), startPoint: .top, endPoint: .bottom)
//            Image("mars_background") // Original Image replaced with Gradient
                .ignoresSafeArea()

            // MARK: - Content VStack
            VStack(spacing: 0) {
                // MARK: - Top Bar
                HStack {
                    Text("Try Image Maker")
                        .font(.headline)
                        .foregroundColor(.white)
                        .shadow(radius: 1)

                    Spacer()

                    // --- Functional Close Button ---
                    Button {
                        // Action for close button
                        print("Close button tapped - Dismissing View (Placeholder Action)")
                        // Add presentation mode dismiss logic here if needed:
                        // presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white.opacity(0.8))
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    // --- End Functional Close Button ---
                }
                .padding(.horizontal)
                .padding(.top, 50) // Adjust padding to clear status bar area

                Spacer() // Pushes content towards the bottom

                // MARK: - Filter Options ScrollView
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 15) {
                        // --- Functional Filter Items ---
                        ForEach($filterOptions) { $option in
                            // Wrap in Button for action
                            Button {
                                print("Filter '\(option.label.isEmpty ? option.imageNamePlaceholder : option.label)' selected.")
                                // Update selection state
                                selectedFilterId = option.id
                                // Update the isSelected property for all options
                                for index in filterOptions.indices {
                                    filterOptions[index].isSelected = (filterOptions[index].id == option.id)
                                }
                            } label: {
                                FilterItemView(option: .constant(option))
                            }
                            .buttonStyle(.plain) // Use plain style to avoid default button styling interference
                        }
                         // --- End Functional Filter Items ---
                    }
                    .padding(.horizontal)
                    .padding(.bottom) // Spacing before prompts
                }

                // MARK: - Prompt Suggestions ScrollView
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                         // --- Functional Prompt Pills ---
                        ForEach($promptSuggestions) { $suggestion in
                            // Wrap in Button for action
                            Button {
                                print("Prompt '\(suggestion.text)' selected.")
                                // Update selection state
                                selectedPromptId = suggestion.id
                                // Update the isSelected property for all suggestions
                                for index in promptSuggestions.indices {
                                    promptSuggestions[index].isSelected = (promptSuggestions[index].id == suggestion.id)
                                }
                            } label: {
                                PromptPillView(suggestion: .constant(suggestion))
                            }
                            .buttonStyle(.plain) // Use plain style
                        }
                        // --- End Functional Prompt Pills ---
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom) // Spacing before the main button

                // MARK: - Create Button (Functional)
                Button {
                    // Action for create image button
                    print("Create your own image tapped")
                    print("Current selected filter ID: \(selectedFilterId?.uuidString ?? "None")")
                    print("Current selected prompt ID: \(selectedPromptId?.uuidString ?? "None")")
                    // Add navigation or image generation logic here
                } label: {
                    HStack {
                        Text("Create your own image")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right") // System image, functional
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 25)
                    .frame(maxWidth: .infinity) // Make button stretch
                    .background(Color.purple) // Use the specific purple color
                    .clipShape(Capsule()) // Rounded corners like a capsule
                }
                .padding(.horizontal)
                .padding(.bottom, 30) // Padding from the bottom edge
            }
        }
        // .statusBar(hidden: true) // Kept commented out to show status bar like original
    }
}

// MARK: - Helper View for Filter Items (Updated for Placeholder Image)
struct FilterItemView: View {
    // Binding allows the view to reflect changes from the parent @State array
    @Binding var option: FilterOption

    var body: some View {
        VStack(spacing: 5) {
             // Use system name as placeholder
            Image(systemName: option.imageNamePlaceholder)
                .resizable()
                .scaledToFit() // Fit might be better for system icons
                .foregroundColor(.white) // Give system icons a color
                .padding(15) // Add padding inside the circle
                .frame(width: 60, height: 60)
                .background(Color.white.opacity(0.15)) // Placeholder background
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(option.isSelected ? Color.white : Color.clear, lineWidth: 2.5) // Make border slightly thicker
                )
                .shadow(radius: 3)

            if !option.label.isEmpty {
                Text(option.label)
                    .font(.caption)
                    .foregroundColor(.white)
                    .shadow(radius: 1)
            }
        }
    }
}

// MARK: - Helper View for Prompt Pills (Now reflects selection state via Binding)
struct PromptPillView: View {
     // Binding allows the view to reflect changes from the parent @State array
    @Binding var suggestion: PromptSuggestion

    var body: some View {
        Text(suggestion.text)
            .font(.subheadline)
            .fontWeight(suggestion.isSelected ? .medium : .regular)
            .foregroundColor(suggestion.isSelected ? .black : .white)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(suggestion.isSelected ? Color.white : Color.white.opacity(0.25))
            .clipShape(Capsule())
            .shadow(radius: suggestion.isSelected ? 2 : 0)
    }
}

// MARK: - Preview Provider
struct ImageMakerView_Previews: PreviewProvider {
    static var previews: some View {
        ImageMakerView()
            .preferredColorScheme(.dark) // Match the dark theme
    }
}
