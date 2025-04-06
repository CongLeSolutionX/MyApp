//
//  ChromeAIThemeInfoView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

// Define a custom dark gray color similar to the image background
extension Color {
    static let googleDarkGray = Color(red: 0.23, green: 0.25, blue: 0.26) // Approximate color
}

// Define a structure for clarity, though not strictly necessary for this fix
struct InstructionItem {
    let number: String
    let attributedText: AttributedString
}

struct ChromeAIThemeInfoView: View {

    // Prepare instructions data
    // Using InstructionItem struct for potential future clarity/Identifiable conformance
    let instructions: [InstructionItem] = [
        InstructionItem(number: "1", attributedText: createAttributedString(prefix: "In settings, turn on ", boldPart: "Create themes with AI", suffix: ".")),
        InstructionItem(number: "2", attributedText: createAttributedString(prefix: "Open a ", boldPart: "New tab +", suffix: " and at the bottom of the page, click ", boldPart2: "Customize Chrome 🪄", suffix2: ".")),
        InstructionItem(number: "3", attributedText: createAttributedString(prefix: "Under ", boldPart: "Appearance", suffix: ", click ", boldPart2: "Change theme", suffix2: ".")),
        InstructionItem(number: "4", attributedText: createAttributedString(prefix: "Under ", boldPart: "Themes", suffix: ", click ", boldPart2: "Create with AI", suffix2: ".")),
        InstructionItem(number: "5", attributedText: createAttributedString(prefix: "Choose from subjects, styles, moods, and colors, and click ", boldPart: "Create", suffix: "."))
    ]

    var body: some View {
        ZStack {
            // 1. Background Color
            Color.googleDarkGray
                .ignoresSafeArea() // Extend background to screen edges

            // 2. Content Stack
            VStack(alignment: .leading, spacing: 16) {
                // 3. Main Title
                Text("Create a unique image using AI to set as your Chrome theme")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // 4. Date
                Text("March 2024")
                    .font(.subheadline)
                    .foregroundColor(.gray) // Use gray for less prominence

                // 5. Descriptive Paragraph
                Text("Combine your imagination with subject, style, mood, and color options to bring your custom theme to life.")
                    .font(.body)
                    .foregroundColor(.white)
                    .lineSpacing(4) // Add some line spacing for readability

                // 6. Numbered Instructions
                VStack(alignment: .leading, spacing: 10) {
                    // Use 0..<count for direct Range<Int> conformance
                    ForEach(0..<instructions.count, id: \.self) { index in
                        let item = instructions[index]
                        Text(item.number + ". ")
                            .foregroundColor(.white)
                         + Text(item.attributedText) // Append the attributed string
                             // Ensure default styling for the AttributedString part matches
                            .font(.body)
                            .foregroundColor(.white)
//                            .lineSpacing(4)
                    }
                }
                .padding(.top, 10) // Add some space before instructions

                Spacer() // Push content towards the top if needed, prevents centering
            }
            .padding(20) // Add padding around the entire content stack
        }
    }

    // Helper function to create AttributedString with optional bold parts
    static func createAttributedString(prefix: String, boldPart: String, suffix: String, boldPart2: String? = nil, suffix2: String? = nil) -> AttributedString {
        var attributedString = AttributedString(prefix)

        var boldSection = AttributedString(boldPart)
        boldSection.inlinePresentationIntent = .stronglyEmphasized // Equivalent to bold
        attributedString.append(boldSection)

        attributedString.append(AttributedString(suffix))

        if let boldPart2 = boldPart2, let suffix2 = suffix2 {
            var boldSection2 = AttributedString(boldPart2)
            boldSection2.inlinePresentationIntent = .stronglyEmphasized
            attributedString.append(boldSection2)
            attributedString.append(AttributedString(suffix2))
        }

        return attributedString
    }
}

// MARK: - Preview
struct ChromeAIThemeInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ChromeAIThemeInfoView()
    }
}
