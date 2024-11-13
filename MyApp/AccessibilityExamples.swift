//
//  AccessibilityExamples.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//


import SwiftUI

//MARK: -  Visual Helpers

/// A view that pairs a set of examples with a grouping label.
struct LabeledExample<Content: View>: View {
    private var text: Text
    private var content: Content

    init(_ text: Text, @ViewBuilder content: (() -> Content)) {
        self.text = text
        self.content = content()
    }

    init(_ key: LocalizedStringKey, @ViewBuilder content: (() -> Content)) {
        self.init(Text(key), content: content)
    }

    var body: some View {
        GroupBox(label: text) {
            VStack(alignment: .leading, spacing: 10) {
                content
            }
        }
    }
}

/// The default corner radius to use for rounding.
let defaultCornerRadius: CGFloat = 10

/// A view for representing an accessibility element visually.
struct AccessibilityElementView: View {
    let color: Color
    let text: Text

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: defaultCornerRadius)
        text.padding(8)
            .frame(minWidth: 128, alignment: .center)
            .background {
                shape.fill(color)
            }
            .overlay {
                shape.strokeBorder(.white, lineWidth: 2)
            }
            .overlay {
                shape.strokeBorder(.gray, lineWidth: 1)
            }
    }
}
