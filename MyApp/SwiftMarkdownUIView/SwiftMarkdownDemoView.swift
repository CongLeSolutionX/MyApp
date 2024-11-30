//
//  SwiftMarkdownDemoView.swift
//  MyApp
//
//  Created by Cong Le on 11/30/24.
//
// Source: https://github.com/gonzalezreal/swift-markdown-ui

import SwiftUI
import MarkdownUI

// MARK: - Swift Markdown Demo View
struct MarkdownThemeOption: Hashable {
  let nameMarkdownTheme: String
  let themeForMarkdownSyntax: Theme

  static func == (lhs: MarkdownThemeOption, rhs: MarkdownThemeOption) -> Bool {
    lhs.nameMarkdownTheme == rhs.nameMarkdownTheme
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.nameMarkdownTheme)
  }

  static let basic = MarkdownThemeOption(nameMarkdownTheme: "Basic", themeForMarkdownSyntax: .basic)
  static let docC = MarkdownThemeOption(nameMarkdownTheme: "DocC", themeForMarkdownSyntax: .docC)
  static let gitHub = MarkdownThemeOption(nameMarkdownTheme: "GitHub", themeForMarkdownSyntax: .gitHub)
}

struct SwiftMarkdownDemoView<Content: View>: View {
  private let themeOptions: [MarkdownThemeOption]
  private let about: MarkdownContent?
  private let content: Content

  @State private var themeOption = MarkdownThemeOption(nameMarkdownTheme: "Basic", themeForMarkdownSyntax: .basic)

  init(
    themeOptions: [MarkdownThemeOption] = [.gitHub, .docC, .basic],
    @ViewBuilder content: () -> Content
  ) {
    self.themeOptions = themeOptions
    self.about = nil
    self.content = content()
  }

  init(
    themeOptions: [MarkdownThemeOption] = [.gitHub, .docC, .basic],
    @MarkdownContentBuilder about: () -> MarkdownContent,
    @ViewBuilder content: () -> Content
  ) {
    self.themeOptions = themeOptions
    self.about = about()
    self.content = content()
  }

  var body: some View {
    Form {
      if let about {
        Section {
          DisclosureGroup("About this demo") {
            Markdown {
              about
            }
          }
        }
      }

      if !self.themeOptions.isEmpty {
        Section {
          Picker("Theme", selection: $themeOption) {
            ForEach(self.themeOptions, id: \.self) { option in
              Text(option.nameMarkdownTheme).tag(option)
            }
          }
        }
      }

      self.content
        .textSelection(.enabled)
        .markdownTheme(self.themeOption.themeForMarkdownSyntax)
        // Some themes may have a custom background color that we need to set as
        // the row's background color.
        .listRowBackground(self.themeOption.themeForMarkdownSyntax.textBackgroundColor)
        // By resetting the state when the theme changes, we avoid mixing the
        // the previous theme block spacing preferences with the new theme ones,
        // which can only happen in this particular use case.
        .id(self.themeOption.nameMarkdownTheme)
    }
    .onAppear {
      self.themeOption = self.themeOptions.first ?? .basic
    }
  }
}

// MARK: - Demo for Swift Markdown UI
struct SwiftMarkdownDemoView_Previews: PreviewProvider {
  static var previews: some View {
    SwiftMarkdownDemoView {
      "Add some text **describing** what this demo is about."
    } content: {
      Markdown {
        Heading(.level2) {
          "Title"
        }
        "Show an awesome **MarkdownUI** feature!"
      }
    }
  }
}
