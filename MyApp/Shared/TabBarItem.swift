//
//  TabBarItem.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI



// Tab Bar Item & View (Modified for Newsstand Selection Styling)
struct TabBarItem: View {
    let icon: String
    let text: String
    var isSelected: Bool = false
    var isSpecial: Bool = false // Flag for the selected background style

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: isSpecial ? 20 : 22)) // Icon size adjusted based on selection style
                .offset(y: isSelected && isSpecial ? -2 : 0) // Slightly raise selected special icon


            Text(text)
                .font(.caption)
                .offset(y: isSelected && isSpecial ? 2 : 0) // Slightly lower selected special text
        }
        .foregroundColor(isSelected ? (isSpecial ? .white : .accentColor) : .gray) // Text/Icon Color
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(
            ZStack {
                if isSelected && isSpecial {
                    Capsule()
                        .fill(Color.accentColor) // Blue capsule background
                        .frame(width: 65, height: 32) // Adjust size of capsule
                }
            }
        )
    }
}


