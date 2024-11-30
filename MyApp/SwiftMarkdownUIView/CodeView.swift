//
//  CodeView.swift
//  MyApp
//
//  Created by Cong Le on 11/30/24.
//
// Source: https://github.com/gonzalezreal/swift-markdown-ui


import MarkdownUI
import SwiftUI

struct CodeView: View {
  private let content = #"""
    You can call out code or a command within a sentence with single backticks.
    The text within the backticks will not be formatted.

    ```
    Use `git status` to list all new or modified files that haven't yet been committed.
    ```

    Use `git status` to list all new or modified files that haven't yet been committed.

    To format code or text into its own distinct block, either use triple backticks
    (` ``` `) or indent each line by 4 spaces.

    ~~~
    After creating a group, any modifier you apply to the group affects
    all of that group’s members.

    ```swift
    Group {
        Text("SwiftUI")
        Text("Combine")
        Text("Swift System")
    }
    .font(.headline)
    ```
    ~~~

    After creating a group, any modifier you apply to the group affects
    all of that group’s members.

    ```swift
    Group {
        Text("SwiftUI")
        Text("Combine")
        Text("Swift System")
    }
    .font(.headline)
    ```
    """#

  var body: some View {
      SwiftMarkdownDemoView {
      Markdown(self.content)
    }
  }
}

struct CodeView_Previews: PreviewProvider {
  static var previews: some View {
    CodeView()
  }
}
