//
//  BasicDialogView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

struct BasicDialogView: View {
    // Properties for customizable content
    let title: String
    let description: String
    let action1Title: String
    let action2Title: String
    let action1: () -> Void
    let action2: () -> Void

    // Approximate colors from the screenshot
    private let backgroundColor = Color(red: 0.95, green: 0.93, blue: 0.98) // Light Lavender/Purple tint
    private let titleColor = Color.black.opacity(0.87)
    private let descriptionColor = Color.black.opacity(0.6)
    private let actionButtonColor = Color(red: 0.4, green: 0.22, blue: 0.72) // Purple Button Text

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // --- Title ---
            Text(title)
                .font(.title2) // Matches visual weight better than .title
                .fontWeight(.semibold)
                .foregroundColor(titleColor)
                .padding(.bottom, 8) // Spacing between title and description

            // --- Description ---
            Text(description)
                .font(.subheadline) // Appropriate size for body text
                .foregroundColor(descriptionColor)
                .lineSpacing(4) // Improves readability for multi-line text
                .padding(.bottom, 24) // Spacing between description and actions

            // --- Actions ---
            HStack(spacing: 8) { // Spacing between buttons
                Spacer() // Pushes buttons to the right

                Button(action: action2) {
                    Text(action2Title)
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(actionButtonColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 10) // Standard touch target size
                }

                Button(action: action1) {
                    Text(action1Title)
                         .font(.callout)
                         .fontWeight(.medium)
                         .foregroundColor(actionButtonColor)
                         .padding(.horizontal, 8)
                         .padding(.vertical, 10) // Standard touch target size
                }
            }
            .frame(maxWidth: .infinity) // Ensures HStack takes full width for Spacer
        }
        .padding(24) // Overall padding inside the dialog
        .background(backgroundColor)
        .cornerRadius(28) // Significant corner rounding as per image
        .frame(width: 312) // Fixed width as specified
        // Add a subtle shadow to lift the dialog off the background
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// --- Example Usage Preview ---
struct BasicDialogView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Dark background similar to the screenshot context
            Color.black.opacity(0.85)
                .edgesIgnoringSafeArea(.all)

            BasicDialogView(
                title: "Basic dialog title",
                description: "A dialog is a type of modal window that appears in front of app content to provide critical information, or prompt for a decision to be made.",
                action1Title: "Action 1",
                action2Title: "Action 2",
                action1: { print("Action 1 tapped") },
                action2: { print("Action 2 tapped") }
            )
        }
    }
}
