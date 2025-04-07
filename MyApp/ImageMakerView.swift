////
////  ImageMakerView.swift
////  MyApp
////
////  Created by Cong Le on 4/6/25.
////
//
//import SwiftUI
//
//// Placeholder data structures
//struct FilterOption: Identifiable {
//    let id = UUID()
//    let imageName: String
//    let label: String
//    var isSelected: Bool = false // To potentially highlight selected item
//}
//
//struct PromptSuggestion: Identifiable {
//    let id = UUID()
//    let text: String
//    var isSelected: Bool = false
//}
//
//struct ImageMakerView: View {
//
//    // Placeholder data - replace with actual data source
//    let filterOptions: [FilterOption] = [
//        FilterOption(imageName: "mushroom_style1", label: "Bowler hat"), // Placeholder labels based on visual cues
//        FilterOption(imageName: "mushroom_style2", label: ""),
//        FilterOption(imageName: "mushroom_style3", label: "Realistic", isSelected: true),
//        FilterOption(imageName: "mushroom_style4", label: ""),
//        FilterOption(imageName: "mushroom_style5", label: "")
//    ]
//
//    let promptSuggestions: [PromptSuggestion] = [
//        PromptSuggestion(text: "Bowler hat"), // Placeholder prompts
//        PromptSuggestion(text: "Spaceship landing on Mars", isSelected: true),
//        PromptSuggestion(text: "Woman walking")
//    ]
//
//    var body: some View {
//        ZStack {
//            // MARK: - Background
//            Image("My-meme-original") // Replace with your background image asset name
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea()
//                .blur(radius: 2) // Optional subtle blur like in some parts of the image
//
//            // MARK: - Content VStack
//            VStack(spacing: 0) {
//                // MARK: - Top Bar
//                HStack {
//                    Text("Try Image Maker")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .shadow(radius: 1) // Add shadow for readability
//
//                    Spacer()
//
//                    Button {
//                        // Action for close button
//                        print("Close button tapped")
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 30, height: 30)
//                            .foregroundColor(.white.opacity(0.8))
//                            .background(Color.black.opacity(0.3)) // Subtle background for visibility
//                            .clipShape(Circle())
//                            .shadow(radius: 2)
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.top, 50) // Adjust padding to clear status bar area
//
//                Spacer() // Pushes content towards the bottom
//
//                // MARK: - Filter Options ScrollView
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(alignment: .bottom, spacing: 15) {
//                        ForEach(filterOptions) { option in
//                            FilterItemView(option: option)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.bottom) // Spacing before prompts
//                }
//
//                // MARK: - Prompt Suggestions ScrollView
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 10) {
//                        ForEach(promptSuggestions) { suggestion in
//                             PromptPillView(suggestion: suggestion)
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                .padding(.bottom) // Spacing before the main button
//
//                // MARK: - Create Button
//                Button {
//                    // Action for create image button
//                    print("Create your own image tapped")
//                } label: {
//                    HStack {
//                        Text("Create your own image")
//                            .fontWeight(.semibold)
//                        Image(systemName: "arrow.right")
//                    }
//                    .foregroundColor(.white)
//                    .padding(.vertical, 15)
//                    .padding(.horizontal, 25)
//                    .frame(maxWidth: .infinity) // Make button stretch
//                    .background(Color.purple) // Use the specific purple color
//                    .clipShape(Capsule()) // Rounded corners like a capsule
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 30) // Padding from the bottom edge
//            }
//        }
//        .statusBar(hidden: true) // Hides the system status bar if desired, though the screenshot shows it
//    }
//}
//
//// MARK: - Helper View for Filter Items
//struct FilterItemView: View {
//    let option: FilterOption
//
//    var body: some View {
//        VStack(spacing: 5) {
//            Image(option.imageName) // Replace with your filter image assets
//                .resizable()
//                .scaledToFill()
//                .frame(width: 60, height: 60)
//                .clipShape(Circle())
//                // Add overlay if selected state needs visual distinction
//                .overlay(
//                    Circle()
//                        .stroke(option.isSelected ? Color.white : Color.clear, lineWidth: 2)
//                )
//                .shadow(radius: 3)
//
//            if !option.label.isEmpty {
//                Text(option.label)
//                    .font(.caption)
//                    .foregroundColor(.white)
//                    .shadow(radius: 1)
//            }
//        }
//    }
//}
//
//// MARK: - Helper View for Prompt Pills
//struct PromptPillView: View {
//    let suggestion: PromptSuggestion
//
//    var body: some View {
//        Text(suggestion.text)
//            .font(.subheadline)
//            .fontWeight(suggestion.isSelected ? .medium : .regular)
//            .foregroundColor(suggestion.isSelected ? .black : .white)
//            .padding(.vertical, 8)
//            .padding(.horizontal, 16)
////            .padding(.symmetric(horizontal: 16, vertical: 8))
//            .background(suggestion.isSelected ? Color.white : Color.white.opacity(0.25)) // Different background for selected
//            .clipShape(Capsule())
//            .shadow(radius: suggestion.isSelected ? 2 : 0) // Optional shadow for selected
//    }
//}
//
//// MARK: - Preview Provider
//struct ImageMakerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageMakerView()
//            .preferredColorScheme(.light) // Match the dark theme
//    }
//}
