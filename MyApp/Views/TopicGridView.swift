//
//  TopicGridView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI



// MARK: - Flexible Topic Grid View

struct TopicGridView: View {
    let topics: [Topic]
    @Binding var selectedTopics: Set<Topic>
    @State private var availableWidth: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(topics, id: \.self) { topic in
                TopicItemView(topic: topic, isSelected: selectedTopics.contains(topic)) {
                    if selectedTopics.contains(topic) {
                        selectedTopics.remove(topic)
                    } else {
                        selectedTopics.insert(topic)
                    }
                }
                .padding(4)
                .alignmentGuide(.leading, computeValue: { d in
                    if (abs(width - d.width) > geometry.size.width) {
                        width = 0
                        height -= d.height
                    }
                    let result = width
                    if topic == self.topics.last! {
                        width = 0 //last item
                    } else {
                        width -= d.width
                    }
                    return result
                })
                .alignmentGuide(.top, computeValue: {d in
                    let result = height
                    if topic == self.topics.last! {
                        height = 0 // last item
                    }
                    return result
                })
            }
        }
    }
}

#Preview {
    EmptyView()
//    TopicGridView(topics: [Topic](), selectedTopics: Set<Topic>(), availableWidth: CGFloat(100))
}
