//
//  QuotesView.swift
//  MyApp
//
//  Created by Cong Le on 12/1/24.
//
// Source: https://github.com/gonzalezreal/swift-markdown-ui

import MarkdownUI
import SwiftUI

struct QuotesView: View {
  let content = """
    You can quote text with a `>`.

    > Outside of a dog, a book is man's best friend. Inside of a
    > dog it's too dark to read.

    – Groucho Marx
    """

  var body: some View {
      SwiftMarkdownDemoView {
      Markdown(self.content)

      Section("Customization Example") {
        Markdown(self.content)
      }
      .markdownBlockStyle(\.blockquote) { configuration in
        configuration.label
          .padding()
          .markdownTextStyle {
            FontCapsVariant(.lowercaseSmallCaps)
            FontWeight(.semibold)
            BackgroundColor(nil)
          }
          .overlay(alignment: .leading) {
            Rectangle()
              .fill(Color.teal)
              .frame(width: 4)
          }
          .background(Color.teal.opacity(0.5))
      }
    }
  }
}

// MARK: - Preview
struct BlockquotesView_Previews: PreviewProvider {
  static var previews: some View {
    QuotesView()
  }
}
