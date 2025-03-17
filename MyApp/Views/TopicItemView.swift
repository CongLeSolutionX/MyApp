//
//  TopicItemView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI



// MARK: - Topic Item View

struct TopicItemView: View {
    let topic: Topic
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: topic.icon)
                Text(topic.name)
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundColor(isSelected ? Color("inverse-on-surface") : Color("on-surface"))
            .background(isSelected ? Color("inverse-surface") : Color("surface"))
            .cornerRadius(20) // Rounded corners for the "chip" style
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("on-surface"), lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

// MARK: - Preview
#Preview {
    TopicItemView(topic: .init(name: "Topic Name", icon: "house"), isSelected: true) { }
}
