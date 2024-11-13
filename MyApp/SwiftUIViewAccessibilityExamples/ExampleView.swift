//
//  Example.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//


import SwiftUI

// MARK: Model

/// A model-level representation of an example.
struct ExampleView {
    var name: String
    var view: AnyView
    var wantsScrollView: Bool
    var wantsPadding: Bool

    init<Content: View>(
        _ name: String,
        wantsScrollView: Bool = true,
        wantsPadding: Bool = true,
        @ViewBuilder content: @escaping (() -> Content)
    ) {
        self.name = name
        self.wantsScrollView = wantsScrollView
        self.wantsPadding = wantsPadding
        self.view = AnyView(content())
    }
}


/// The list of examples to show.
let examples = [
    ExampleView("Standard Controls") { StandardControlExample() },
    ExampleView("Custom Controls") { CustomControlsExample() },
    ExampleView("Images") { ImageExample() },
    ExampleView("Text") { TextExample() },
    ExampleView("Containers") { ContainerExample() },
    ExampleView("Actions") { ActionExample() },
    ExampleView("ViewRepresentable") { ViewRepresentableExample() },
    ExampleView("Canvas") { CanvasExample() },
    ExampleView("ForEach") { ForEachExample() },
    ExampleView("Sort Priority") { SortPriorityExample() },
    ExampleView("Composition") { CompositionExample() },
    ExampleView("Rotors", wantsScrollView: false, wantsPadding: false) { RotorsExample() },
    ExampleView("Focus") { FocusExample() },
    ExampleView("Custom Content") { CustomContentExample() },
    ExampleView("Environment") { EnvironmentExample() }
]
