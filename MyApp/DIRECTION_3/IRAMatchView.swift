//
//  IRAMatchView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

// Define custom colors for reusability based on the screenshot
extension Color {
    static let darkGreenBackground = Color(red: 10 / 255, green: 46 / 255, blue: 30 / 255) // Approximation
    static let limeAccent = Color(red: 201 / 255, green: 255 / 255, blue: 86 / 255) // Approximation
    static let buttonTextColor = Color.black // Or a very dark green
    static let inactiveDotColor = Color.gray.opacity(0.5)
}

struct IRAMatchView: View {
    var body: some View {
        ZStack {
            // 1. Background Color
            Color.darkGreenBackground
                .ignoresSafeArea()

            // 2. Main Content Stack
            VStack(spacing: 20) {
                Spacer() // Pushes content down slightly from the top

                // 3. Main Graphic (Replace "graphic_3percent" with your actual asset name)
                Image("My-meme-heineken")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200) // Adjust frame as needed
                    .padding(.bottom, 30)

                // 4. Text Content Block
                VStack(spacing: 15) {
                    Text("3% IRA match")
                        .font(.largeTitle.bold())
                        .foregroundColor(.limeAccent)
                        .multilineTextAlignment(.center)

                    Text("Earn a 3% match on contributions with Robinhood Gold or 1% without. All IRA and 401(k) transfers earn 1%.")
                        .font(.body)
                        .foregroundColor(.limeAccent)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40) // Add horizontal padding for wrapping

                    Button(action: {
                        // Action for limitations link
                        print("Limitations link tapped")
                    }) {
                        Text("Limitations apply")
                            .font(.callout)
                            .foregroundColor(.limeAccent)
                            .underline()
                    }
                }

                // 5. Page Indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.limeAccent) // Active dot
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.inactiveDotColor) // Inactive dot
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.inactiveDotColor) // Inactive dot
                        .frame(width: 8, height: 8)
                }
                .padding(.top, 20)
                .padding(.bottom, 10) // Space before button

                Spacer() // Pushes button towards the bottom

                // 6. Action Button
                Button(action: {
                    // Action for "Get started" button
                    print("Get started tapped")
                }) {
                    Text("Get started")
                        .font(.headline.bold())
                        .foregroundColor(.buttonTextColor)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity) // Make button wide
                        .background(Color.limeAccent)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20) // Padding around the button

                Spacer().frame(height: 20) // Adds some padding at the very bottom before tab bar area
            }
            .padding(.bottom, 20) // Overall bottom padding for the VStack content
        }
    }
}

struct IRAMatchView_Previews: PreviewProvider {
    static var previews: some View {
        IRAMatchView()
    }
}
