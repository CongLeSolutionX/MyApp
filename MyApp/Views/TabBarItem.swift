//
//  TabBarItem.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct TabBarItem: View {
    let index: Int
    @Binding var selectedIndex: Int
    let icon: String
    let label: String

    var body: some View {
        Button(action: {
            selectedIndex = index
        }) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 20)) // Adjust size as needed
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(selectedIndex == index ? Color("primary-container") : Color("on-surface"))
            .frame(maxWidth: .infinity)
        }
    }
}
// MARK: - Preview
#Preview {
    TabBarItem(index: 0, selectedIndex: .constant(0), icon: "car", label: "SwiftUI")
}
