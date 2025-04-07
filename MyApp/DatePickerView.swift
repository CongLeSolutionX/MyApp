//
//  DatePickerView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

struct DatePickerView: View {
    // State variable to hold the text field input
    @State private var dateText: String = ""

    // Define custom colors to match the design
    let backgroundColor = Color(red: 0.95, green: 0.93, blue: 0.98) // Approximate light purple
    let primaryTextColor = Color.black
    let secondaryTextColor = Color.gray
    let buttonTextColor = Color(red: 0.4, green: 0.3, blue: 0.6) // Approximate purple for buttons
    let textFieldBorderColor = Color(red: 0.6, green: 0.5, blue: 0.8) // Approximate purple border

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // Main container, align content left, minimal spacing handled by padding
            // Top Section: Title
            Text("Select date")
                .font(.caption) // Smaller font for the top title
                .foregroundColor(secondaryTextColor)
                .padding([.top, .leading, .trailing])
                .padding(.bottom, 8) // Add some space below title

            // Mid Section 1: Main Prompt and Icon
            HStack {
                Text("Enter date")
                    .font(.largeTitle) // Large font for the main prompt
                    .fontWeight(.regular)
                    .foregroundColor(primaryTextColor)

                Spacer() // Pushes the icon to the right

                Image(systemName: "calendar") // System calendar icon
                    .font(.title2)
                    .foregroundColor(secondaryTextColor)
            }
            .padding([.horizontal])
            .padding(.bottom, 12) // Space before the divider

            // Divider
            Divider()
                .padding(.bottom, 16) // Space after the divider

            // Mid Section 2: Text Field
            VStack(alignment: .leading, spacing: 4) {
                // Floating Label "Date" - positioned above the border
                 Text("Date")
                     .font(.caption)
                     .foregroundColor(buttonTextColor) // Use the button color for the label
                     .padding(.leading, 8) // Indent slightly
                     .offset(y: 8) // Lift label slightly above the TextField border line
                     .zIndex(1) // Ensure label is drawn above the TextField border

                 TextField("mm/dd/yyyy", text: $dateText) // Bind to the state variable
                     .padding(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8)) // Internal padding
                     .overlay( // Custom border
                         RoundedRectangle(cornerRadius: 4)
                            .stroke(textFieldBorderColor, lineWidth: 1.5) // Use custom color and thickness
                     )
                     // Optional: Add keyboard type if needed
                     // .keyboardType(.numberPad)
             }
            .padding(.horizontal)
            .padding(.bottom, 20) // Space before the buttons

            // Bottom Section: Action Buttons
            HStack {
                Spacer() // Pushes buttons to the right

                Button("Cancel") {
                    // Add Cancel action here
                    print("Cancel tapped")
                }
                .foregroundColor(buttonTextColor)
                .padding(.horizontal)

                Button("OK") {
                    // Add OK action here
                    print("OK tapped, date: \(dateText)")
                }
                .foregroundColor(buttonTextColor)
                .padding(.trailing) // Only trailing padding for the last button
            }
            .padding(.bottom) // Space at the very bottom
        }
        .background(backgroundColor) // Set the background color for the VStack
        .cornerRadius(16) // Apply rounded corners to the entire view
        .frame(width: 328) // Set the specific width from the design
        // Note: Height is flexible based on content ('Hug' in design terms)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2) // Optional subtle shadow
    }
}

#Preview {
    DatePickerView()
        .padding(50) // Add padding in the preview for visual separation
        .background(Color.black.opacity(0.8)) // Dark background for context
}
