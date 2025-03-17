//
//  TabBarView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI


// MARK: - Tab Bar View
struct TabBarView: View {
    @Binding var selectedIndex: Int
    
    private let tabs: [(icon: String, label: String)] = [
        ("house.fill", "For you"),
        ("play.rectangle.fill", "Episodes"),
        ("bookmark.fill", "Saved"),
        ("tag.fill", "Interests")
    ]

    var body: some View {
        HStack {
            ForEach(tabs.indices, id: \.self) { index in
                TabBarItem(
                    index: index,
                    selectedIndex: $selectedIndex,
                    icon: tabs[index].icon,
                    label: tabs[index].label
                )
            }
        }
        .padding(.vertical, 8)
        .background(Color("background"))
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    TabBarView(selectedIndex: .constant(1))
}
