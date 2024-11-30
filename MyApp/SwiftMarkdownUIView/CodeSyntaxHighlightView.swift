//
//  CodeSyntaxHighlightView.swift
//  MyApp
//
//  Created by Cong Le on 11/29/24.
//

import MarkdownUI
//import Splash
import SwiftUI

struct CodeSyntaxHighlightView: View {
  @Environment(\.colorScheme) private var colorScheme

  private let content = #"""
    This screen demonstrates how you can integrate a 3rd party library
    to render syntax-highlighted code blocks.

    First, we create a type that conforms to `CodeSyntaxHighlighter`,
    using [John Sundell's Splash](https://github.com/JohnSundell/Splash)
    to highlight code blocks.

    ```swift
    import MarkdownUI
    import Splash
    import SwiftUI

    struct SplashCodeSyntaxHighlighter: CodeSyntaxHighlighter {
      private let syntaxHighlighter: SyntaxHighlighter<TextOutputFormat>

      init(theme: Splash.Theme) {
        self.syntaxHighlighter = SyntaxHighlighter(format: TextOutputFormat(theme: theme))
      }

      func highlightCode(_ content: String, language: String?) -> Text {
        guard language != nil else {
          return Text(content)
        }

        return self.syntaxHighlighter.highlight(content)
      }
    }

    extension CodeSyntaxHighlighter where Self == SplashCodeSyntaxHighlighter {
      static func splash(theme: Splash.Theme) -> Self {
        SplashCodeSyntaxHighlighter(theme: theme)
      }
    }
    ```

    Then we configure the `Markdown` view to use the `SplashCodeSyntaxHighlighter`
    that we just created.

    ```swift
    var body: some View {
      Markdown(self.content)
        .markdownCodeSyntaxHighlighter(.splash(theme: .sunset(withFont: .init(size: 16))))
    }
    ```

    More languages to render:

    ```
    A plain code block without the specifying a language name.
    ```

    ```cpp
    #include <iostream>
    #include <vector>

    int main() {
        std::vector<std::string> fruits = {"apple", "banana", "orange"};
        for (const std::string& fruit : fruits) {
            std::cout << "I love " << fruit << "s!" << std::endl;
        }
        return 0;
    }
    ```

    ```typescript
    interface Person {
      name: string;
      age: number;
    }

    const person = Person();
    ```

    ```ruby
    fruits = ["apple", "banana", "orange"]
    fruits.each do |fruit|
      puts "I love #{fruit}s!"
    end
    ```

    """#

  var body: some View {
    SwiftMarkdownDemoView {
      Markdown(self.content)
        .markdownBlockStyle(\.codeBlock) {
          codeBlock($0)
        }
        .markdownTheme(.gitHub)
        //.markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
    }
  }

  @ViewBuilder
  private func codeBlock(_ configuration: CodeBlockConfiguration) -> some View {
    VStack(spacing: 0) {
      HStack {
        Text(configuration.language ?? "plain text")
          .font(.system(.caption, design: .monospaced))
          .fontWeight(.semibold)
          .foregroundColor(
            Color.black
            //Color(theme.plainTextColor)
          )
        Spacer()

        Image(systemName: "clipboard")
          .onTapGesture {
            copyToClipboard(configuration.content)
          }
      }
      .padding(.horizontal)
      .padding(.vertical, 8)
      .background {
          Color.red
        //Color(theme.backgroundColor)
      }

      Divider()

      ScrollView(.horizontal) {
        configuration.label
          .relativeLineSpacing(.em(0.25))
          .markdownTextStyle {
            FontFamilyVariant(.monospaced)
            FontSize(.em(0.85))
          }
          .padding()
      }
    }
    .background(Color(.secondarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .markdownMargin(top: .zero, bottom: .em(0.8))
  }

//  private var theme: Splash.Theme {
//    // NOTE: We are ignoring the Splash theme font
//    switch self.colorScheme {
//    case .dark:
//      return .wwdc17(withFont: .init(size: 16))
//    default:
//      return .sunset(withFont: .init(size: 16))
//    }
//  }

  private func copyToClipboard(_ string: String) {
    #if os(macOS)
      if let pasteboard = NSPasteboard.general {
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
      }
    #elseif os(iOS)
      UIPasteboard.general.string = string
    #endif
  }
}

struct CodeSyntaxHighlightView_Previews: PreviewProvider {
  static var previews: some View {
    CodeSyntaxHighlightView()
  }
}

// MARK: - Demo View
struct MarkdownThemeOption: Hashable {
  let name: String
  let theme: Theme

  static func == (lhs: MarkdownThemeOption, rhs: MarkdownThemeOption) -> Bool {
    lhs.name == rhs.name
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.name)
  }

  static let basic = MarkdownThemeOption(name: "Basic", theme: .basic)
  static let docC = MarkdownThemeOption(name: "DocC", theme: .docC)
  static let gitHub = MarkdownThemeOption(name: "GitHub", theme: .gitHub)
}

struct SwiftMarkdownDemoView<Content: View>: View {
  private let themeOptions: [MarkdownThemeOption]
  private let about: MarkdownContent?
  private let content: Content

  @State private var themeOption = MarkdownThemeOption(name: "Basic", theme: .basic)

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
              Text(option.name).tag(option)
            }
          }
        }
      }

      self.content
        .textSelection(.enabled)
        .markdownTheme(self.themeOption.theme)
        // Some themes may have a custom background color that we need to set as
        // the row's background color.
        .listRowBackground(self.themeOption.theme.textBackgroundColor)
        // By resetting the state when the theme changes, we avoid mixing the
        // the previous theme block spacing preferences with the new theme ones,
        // which can only happen in this particular use case.
        .id(self.themeOption.name)
    }
    .onAppear {
      self.themeOption = self.themeOptions.first ?? .basic
    }
  }
}
// MARK: Demo for Swift Markdown UI
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
