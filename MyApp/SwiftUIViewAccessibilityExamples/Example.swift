//
//  Example.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//


import SwiftUI

// MARK: Model

/// A model-level representation of an example.
struct Example {
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
    Example("Standard Controls") { StandardControlExample() },
    Example("Custom Controls") { CustomControlsExample() },
    Example("Images") { ImageExample() },
    Example("Text") { TextExample() },
    Example("Containers") { ContainerExample() },
    Example("Actions") { ActionExample() },
    Example("ViewRepresentable") { ViewRepresentableExample() },
    Example("Canvas") { CanvasExample() },
    Example("ForEach") { ForEachExample() },
    Example("Sort Priority") { SortPriorityExample() },
    Example("Composition") { CompositionExample() },
    Example("Rotors", wantsScrollView: false, wantsPadding: false) { RotorsExample() },
    Example("Focus") { FocusExample() },
    Example("Custom Content") { CustomContentExample() },
    Example("Environment") { EnvironmentExample() }
]
