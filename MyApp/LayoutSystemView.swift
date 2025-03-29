//
//  LayoutSystemView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//
import SwiftUI

// MARK: - 1. Custom Alignment Guide

/// Define a custom AlignmentID for our horizontal alignment.
private struct MyHorizontalAlignmentID: AlignmentID {
    /// Provides the default value for the custom alignment guide.
    /// In this case, we position it at 25% of the view's width from the leading edge.
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        return context.width * 0.25
    }
}

/// Extend HorizontalAlignment to include our custom alignment guide.
extension HorizontalAlignment {
    static let myAlignment = HorizontalAlignment(MyHorizontalAlignmentID.self)
}

// MARK: - 2. Custom Layout Value Key

/// Define a custom LayoutValueKey to pass data from subviews to the layout container.
/// This key will hold an optional CGFloat value, defaulting to nil.
private struct MyCustomLayoutValueKey: LayoutValueKey {
    static let defaultValue: CGFloat? = nil
}

// MARK: - 3. Custom Layout Container (Similar to VStack)

/// A custom layout container that arranges its subviews vertically,
/// respecting horizontal alignment and custom layout values.
struct MyCustomVStackLayout: Layout {
    /// The horizontal alignment guide for positioning subviews. Defaults to center.
    var alignment: HorizontalAlignment = .center
    /// The spacing between subviews. Defaults to a system-standard value (nil).
    var spacing: CGFloat? = nil

    /// Calculates the size needed by the layout container.
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let verticalSpacing = spacing ?? 8
        let subviewProposal = ProposedViewSize(width: proposal.width, height: nil)

        let totalHeight = subviews.indices.reduce(0) { total, index in
            let subview = subviews[index]
            let subviewHeight = subview.sizeThatFits(subviewProposal).height
            let spacing = (index == subviews.count - 1) ? 0 : verticalSpacing
            return total + subviewHeight + spacing
        }

        let maxWidth = subviews.reduce(0) { currentMax, subview in
            return max(currentMax, subview.sizeThatFits(subviewProposal).width)
        }

        return CGSize(
            width: maxWidth,
            height: totalHeight
        )
    }

    /// Places the subviews within the given bounds.
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }

        let verticalSpacing = spacing ?? 8
        var currentY = bounds.minY

        // Proposal for placing subviews
        let subviewProposal = ProposedViewSize(width: proposal.width, height: nil)

        // --- ERROR FIX ---
        // Calculate the target X coordinate within the bounds based on the container's alignment.
        // We cannot use bounds[alignment]. We must calculate it manually for known types.
        let containerGuideXAnchorOffset: CGFloat
        if alignment == .leading {
            containerGuideXAnchorOffset = bounds.minX
        } else if alignment == .trailing {
            containerGuideXAnchorOffset = bounds.maxX
        } else if alignment == .center {
            containerGuideXAnchorOffset = bounds.midX
        // } else if alignment == .myAlignment {
            // Handling custom alignments for the *container's* guide within placeSubviews
            // is tricky without ViewDimensions for the container itself.
            // A robust way often involves calculating based on the subviews' desired positions,
            // but for simplicity here, we might fallback or use a known proxy like center.
            // Let's fallback to center for this example's custom alignment positioning
            // *within the container*. This means .myAlignment on the container
            // will behave like .center *for positioning subviews*.
            // A better approach might involve implementing explicitAlignment for the container
            // and reading that value if needed, though that's more complex.
            // containerGuideXAnchorOffset = bounds.width * 0.25 // This assumes minX is 0, incorrect.
            // Fallback to center:
            // containerGuideXAnchorOffset = bounds.midX
        } else {
             // For truly custom alignments passed to the *container*, we need a default value.
             // SwiftUI's mechanism for this isn't fully exposed. The AlignmentID.defaultValue
             // needs ViewDimensions *of the view setting the default*.
             // Here, we only have the container's bounds. Let's use the origin + default value calculated on *some* dimension.
             // This is imperfect. The default behavior likely involves more complex internal merging.
             // Using center as a fallback is often the most reasonable approach without more info.
              containerGuideXAnchorOffset = bounds.midX // Fallback to center
        }
        // --- END ERROR FIX ---


        // Iterate through subviews to place them.
        for index in subviews.indices {
            let subview = subviews[index]
            let dimensions = subview.dimensions(in: subviewProposal)
            let customXOffset = subview[MyCustomLayoutValueKey.self] ?? 0.0

            // Get the subview's alignment guide offset relative to its own origin (0, 0)
            let subviewGuideXOffset = dimensions[alignment]

            // Calculate the subview's origin X so its guide aligns with the container's guide anchor point
            // subviewOriginX + subviewGuideXOffset = containerGuideXAnchorOffset
            let subviewOriginX = containerGuideXAnchorOffset - subviewGuideXOffset

            let finalX = subviewOriginX + customXOffset

            let placementPoint = CGPoint(x: finalX, y: currentY)

            subview.place(at: placementPoint, anchor: .topLeading, proposal: subviewProposal)

            currentY += dimensions.height
            if index < subviews.count - 1 {
                currentY += verticalSpacing
            }
        }
    }

    // Optional methods remain the same
    static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = .vertical
        return properties
    }

    func spacing(subviews: Subviews, cache: inout ()) -> ViewSpacing {
         var spacing = ViewSpacing()
         if let first = subviews.first {
             spacing.formUnion(first.spacing, edges: [.top, .leading, .trailing])
         }
         if let last = subviews.last {
             spacing.formUnion(last.spacing, edges: [.bottom, .leading, .trailing])
         }
         return spacing
    }

     func explicitAlignment(of guide: HorizontalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGFloat? {
         if guide == .center {
             return bounds.midX
         }
         return nil
     }

    func makeCache(subviews: Subviews) -> () { }
    func updateCache(_ cache: inout (), subviews: Subviews) { }
}

// MARK: - 4. Helper View Modifier for Custom Layout Value

extension View {
    func myCustomLayoutValue(_ value: CGFloat?) -> some View {
        layoutValue(key: MyCustomLayoutValueKey.self, value: value)
    }
}

// MARK: - 5. ContentView: Demonstrating the Layout System

struct ContentView: View {
    @State private var useMyAlignment = true
    @State private var showThird = true

    var body: some View {
        VStack {
            Text("SwiftUI Custom Layout Demo")
                .font(.title)
                .padding(.bottom)

            MyCustomVStackLayout(
                alignment: useMyAlignment ? .myAlignment : .center,
                spacing: 15
            ) {
                Text("Aligned Text 1")
                    .font(.headline)
                    .background(Color.yellow.opacity(0.3))

                Rectangle()
                    .fill(Color.blue.opacity(0.7))
                    .frame(height: 50)
                    .myCustomLayoutValue(30)
                    .overlay(Text("Offset by LayoutValueKey").foregroundColor(.white))

                if showThird {
                    Image(systemName: "star.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                        .alignmentGuide(.myAlignment) { d in
                            d[HorizontalAlignment.center]
                        }
                        .background(Color.gray.opacity(0.2))
                }

                Text("Longer text view to show alignment clearly")
                    .multilineTextAlignment(textAlignmentForContainerAlignment(alignment: useMyAlignment ? .myAlignment : .center)) // Align text *within* the view based on container alignment
                    .background(Color.green.opacity(0.3))
            }
            .padding()
            .border(Color.red)


            Spacer()

            Toggle("Use Custom Alignment (.myAlignment)", isOn: $useMyAlignment.animation())
            Toggle("Show Star View", isOn: $showThird.animation())
        }
        .padding()
    }

    // Helper to map container alignment to TextAlignment
    private func textAlignmentForContainerAlignment(alignment: HorizontalAlignment) -> TextAlignment {
        if alignment == .leading {
            return .leading
        } else if alignment == .trailing {
            return .trailing
        } else {
            return .center // Default for .center and custom alignments in this example
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
