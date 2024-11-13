//
//  AccessibilityExamplesView_macOS.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//

import SwiftUI

/// The contents view for a specific example.
private struct macOSExampleView: View {
    private var example: ExampleView

    init(_ example: ExampleView) {
        self.example = example
    }

    @ViewBuilder
    var innerExampleView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                example.view
                    .padding(.all, example.wantsPadding ? 8 : 0)
            }
            Spacer()
        }
    }

    var body: some View {
        if example.wantsScrollView {
            ScrollView {
                innerExampleView
            }
        } else {
            VStack {
                innerExampleView
                Spacer()
            }
        }
    }
}

/// The top-level view for all examples.
struct ExamplesMacOSView: View {
    var body: some View {
        NavigationView {
            List(examples, id: \.name) { example in
                NavigationLink(example.name) {
                    macOSExampleView(example)
                }
            }
            Text("No Content")
        }
    }
}

// MARK: - Preview

#Preview {
    ExamplesMacOSView()
}
