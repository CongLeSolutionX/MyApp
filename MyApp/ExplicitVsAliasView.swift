//
//  ExplicitVsAliasView.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI

// MARK: - UI Component Representing the Diagram

/// A view demonstrating the relationship between complex explicit types in SwiftUI
/// and their commonly used simpler aliases or protocol-based representations (`some View`, `some Shape`, etc.).
struct ExplicitVsAliasView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("SwiftUI: Explicit Types vs. Common Aliases")
                        .font(.title)
                        .padding(.bottom)

                Text("SwiftUI often uses complex generic types internally. However, in usage or as return types, these are frequently represented by simpler protocols or opaque types like `some View`. This diagram illustrates this concept.")
                    .font(.callout)
                    .padding(.bottom)

                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 10) {
                    // --- Header ---
                    GridRow(alignment: .firstTextBaseline) {
                        Text("Explicit Complex Type")
                            .font(.headline)
                            .gridColumnAlignment(.leading)

                        Image(systemName: "arrow.right") // Visual Separator
                            .font(.headline)
                            .foregroundColor(.gray)

                        Text("Common Alias / Usage")
                            .font(.headline)
                            .gridColumnAlignment(.leading)
                    }
                    .bold()

                    Divider()
                        .gridCellUnsizedAxes(.horizontal) // Span across grid

                    // --- Example Rows ---
                    TypeMappingRow(
                        explicitType: "ModifiedContent<Content, Modifier>",
                        aliasType: "some View",
                        description: "Modifiers wrap views, resulting in a new view type, often returned opaquely."
                    )

                    TypeMappingRow(
                        explicitType: "TupleView<T>",
                        aliasType: "some View",
                        description: "Used by ViewBuilder for multiple static views, returned opaquely."
                    )

                    TypeMappingRow(
                        explicitType: "_ShapeView<Shape, Style>",
                        aliasType: "some View",
                        description: "Internal type for styled shapes, presented as a general view."
                     )

                    TypeMappingRow(
                        explicitType: "AnimatablePair<First, Second>",
                        aliasType: "AnimatableData (Type Alias)",
                        description: "Often used as the typealias for `animatableData` in Animatable conformance."
                    )

                    TypeMappingRow(
                        explicitType: "OffsetShape<Content>",
                        aliasType: "some Shape",
                        description: "Geometric modifications result in a new shape type, returned opaquely."
                    )

                    TypeMappingRow(
                        explicitType: "RotatedShape<Content>",
                        aliasType: "some Shape",
                        description: "Geometric modifications result in a new shape type, returned opaquely."
                    )

                     TypeMappingRow(
                        explicitType: "LinearGradient",
                        aliasType: "some ShapeStyle",
                        description: "Concrete style types conform to and are often used via the ShapeStyle protocol."
                     )

                     TypeMappingRow(
                        explicitType: "TapGesture",
                        aliasType: "some Gesture",
                        description: "Concrete gestures conform to and are often used via the Gesture protocol."
                     )

                     TypeMappingRow(
                        explicitType: "MoveTransition",
                        aliasType: "some Transition",
                        description: "Concrete transitions conform to and can be returned via the Transition protocol."
                      )

                     TypeMappingRow(
                        explicitType: "HStackLayout",
                        aliasType: "some Layout",
                        description: "Concrete layout types conform to and are often used via the Layout protocol."
                     )

                     TypeMappingRow(
                        explicitType: "ExplicitTimelineSchedule<Entries>",
                        aliasType: "some TimelineSchedule",
                        description: "Concrete schedules conform to and are often used via the TimelineSchedule protocol."
                      )

                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground)) // Adaptable background
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

/// Helper View for displaying a row in the comparison grid.
struct TypeMappingRow: View {
    let explicitType: String
    let aliasType: String
    let description: String

    var body: some View {
        GridRow(alignment: .top) {
            VStack(alignment: .leading) {
                Text(explicitType)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.primary)
                    .padding(.bottom, 2)
                 Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .gridCellAnchor(.topLeading) // Align content within the cell

            Image(systemName: "arrow.right")
                .foregroundColor(.gray)
                .gridCellAnchor(.center) // Center arrow vertically

            Text(aliasType)
                .font(.system(.body, design: .monospaced).weight(.semibold))
                .foregroundStyle(.indigo) // Highlight the alias/protocol
                .gridCellAnchor(.topLeading) // Align alias within its cell
        }
        Divider()
             .gridCellUnsizedAxes(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    ExplicitVsAliasView()
}
