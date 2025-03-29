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
        // In LTR, leading edge is minX. Guide is at minX + 0.25 * width.
        // ViewDimensions gives offsets relative to the view's origin (0,0).
        // So, 0.25 * width is the offset from the origin.
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
    /// - Parameters:
    ///   - proposal: The proposed size offered by the parent view.
    ///   - subviews: A collection of proxies for the subviews.
    ///   - cache: A storage for caching intermediate calculations (not used here).
    /// - Returns: The calculated size for the container.
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        // Use system default spacing if nil is provided.
        let verticalSpacing = spacing ?? 8 // Default spacing if nil
        // Propose width based on container proposal, height is flexible for subviews initially.
        let subviewProposal = ProposedViewSize(width: proposal.width, height: nil)

        // Calculate the total height required by summing ideal heights and spacing.
        let totalHeight = subviews.indices.reduce(0) { total, index in
            let subview = subviews[index]
            let subviewHeight = subview.sizeThatFits(subviewProposal).height
            // Only add spacing if it's not the last subview
            let spacing = (index == subviews.count - 1) ? 0 : verticalSpacing
            return total + subviewHeight + spacing
        }

        // Find the maximum width required among all subviews based on the proposal.
        let maxWidth = subviews.reduce(0) { currentMax, subview in
            return max(currentMax, subview.sizeThatFits(subviewProposal).width)
        }

        // Return the combined calculated size. The parent layout will handle clamping
        // to the final proposal if necessary.
        return CGSize(
            width: maxWidth,
            height: totalHeight
        )
        // ERROR FIX 1: Removed incorrect call to .replacingUnspecifiedDimensions on CGSize
    }

    /// Places the subviews within the given bounds.
    /// - Parameters:
    ///   - bounds: The bounds rectangle allocated to the container by its parent.
    ///   - proposal: The size proposal used to calculate the bounds.
    ///   - subviews: A collection of proxies for the subviews.
    ///   - cache: A storage for caching intermediate calculations (not used here).
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }

        let verticalSpacing = spacing ?? 8 // Use consistent spacing
        var currentY = bounds.minY

        // Determine proposal for placing subviews (allow width flexibility if container allows)
        let subviewProposal = ProposedViewSize(width: proposal.width, height: nil)

        // ERROR FIX 2: Get the container's target alignment guide offset within the bounds.
        // This *should* work based on documentation for Layout.
        // If this still errors, it might be an Xcode/Beta issue or deeper API nuance.
        let containerGuideX = bounds[alignment]

        // Iterate through subviews to place them.
        for index in subviews.indices {
            let subview = subviews[index]

            // Get dimensions using the placement proposal.
            let dimensions = subview.dimensions(in: subviewProposal)

            // Read the custom layout value (demonstration purpose).
            // We use it here to add an extra horizontal offset.
            let customXOffset = subview[MyCustomLayoutValueKey.self] ?? 0.0

            // ERROR FIX 2: Get the subview's alignment guide offset relative to its own origin.
            let subviewGuideX = dimensions[alignment]

            // Calculate the subview's origin X coordinate so its guide matches the container's guide.
            // subviewOriginX + subviewGuideX = bounds.minX + containerGuideX
            let subviewOriginX = bounds.minX + containerGuideX - subviewGuideX

            // Apply the custom offset read from the LayoutValueKey.
            let finalX = subviewOriginX + customXOffset

            // Define the placement point (top-leading corner of the subview).
            let placementPoint = CGPoint(x: finalX, y: currentY)

            // Place the subview.
            subview.place(at: placementPoint, anchor: .topLeading, proposal: subviewProposal)

            // Update the Y position for the next subview.
            currentY += dimensions.height
            if index < subviews.count - 1 {
                currentY += verticalSpacing
            }
        }
    }

    // --- Optional Layout Protocol Methods ---

    // Provide layout properties if needed (e.g., stack orientation).
    static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = .vertical // Indicate this behaves like a vertical stack
        return properties
    }

    // Provide custom spacing logic if needed. Default merges subview spacing.
    func spacing(subviews: Subviews, cache: inout ()) -> ViewSpacing {
         // Calculate container spacing based on subviews (e.g., merge outer edges)
         var spacing = ViewSpacing()
         // ERROR FIX 3: Use Edge.Set for edges parameter
         if let first = subviews.first {
             spacing.formUnion(first.spacing, edges: [.top, .leading, .trailing])
         }
         if let last = subviews.last {
             spacing.formUnion(last.spacing, edges: [.bottom, .leading, .trailing])
         }
         return spacing
    }

    // Provide explicit alignment guide values for the container itself.
    // Default merges subview guides. Let's explicitly center the container's center guide.
     func explicitAlignment(of guide: HorizontalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGFloat? {
         if guide == .center {
             return bounds.midX // Explicitly define the center guide
         }
         // Return nil to use default merging for other guides
         return nil
     }

    // Cache is not used in this simple example.
    func makeCache(subviews: Subviews) -> () { }
    func updateCache(_ cache: inout (), subviews: Subviews) { }
}

// MARK: - 4. Helper View Modifier for Custom Layout Value

extension View {
    /// Sets the custom layout value for the view.
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

            // --- Use the Custom Layout Container ---
            MyCustomVStackLayout(
                alignment: useMyAlignment ? .myAlignment : .center, // Use custom or center alignment
                spacing: 15
            ) {
                // Subview 1: Basic Text
                Text("Aligned Text 1")
                    .font(.headline)
                    .background(Color.yellow.opacity(0.3))

                // Subview 2: Rectangle with custom Layout Value Key
                Rectangle()
                    .fill(Color.blue.opacity(0.7))
                    .frame(height: 50)
                    .myCustomLayoutValue(30) // Apply custom X offset via LayoutValueKey
                    .overlay(Text("Offset by LayoutValueKey").foregroundColor(.white))

                // Subview 3: Image with overridden alignment guide
                if showThird {
                    Image(systemName: "star.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                         // Override how this specific view aligns to .myAlignment guide
                        .alignmentGuide(.myAlignment) { d in
                            // Align this view's *center* to the container's .myAlignment guide
                            d[HorizontalAlignment.center]
                        }
                        .background(Color.gray.opacity(0.2))
                }


                // Subview 4: Text aligned normally
                Text("Longer text view to show alignment clearly")
                    .multilineTextAlignment(useMyAlignment ? .leading : .center) // Text alignment *within* the view
                    .background(Color.green.opacity(0.3))


            }
            .padding()
            .border(Color.red) // Border around the custom layout container


            Spacer() // Push controls to bottom

            // --- Controls to change layout parameters ---
            Toggle("Use Custom Alignment (.myAlignment)", isOn: $useMyAlignment.animation())
            Toggle("Show Star View", isOn: $showThird.animation())

        }
        .padding()
    }
}


// MARK: - Preview
#Preview {
    ContentView()
}
