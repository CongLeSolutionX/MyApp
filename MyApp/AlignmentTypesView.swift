//
//  AlignmentTypesView.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//


import SwiftUI

// MARK: - Helper Views

/// A simple view to display text within a bordered box, used in demonstrations.
struct BoxView: View {
    let name: String
    let alignment: Alignment? // Optional alignment for ZStack demo

    var body: some View {
        Text(name)
            .font(.system(.caption, design: .monospaced))
            .padding(5)
            .foregroundColor(.white)
            .background(Color.blue.opacity(0.8), in: Rectangle())
            .border(Color.white.opacity(0.5)) // Subtle border for clarity
    }
}

/// Background view for the main Alignment demonstration.
private struct AlignmentDemoBackground: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Top-Leading Quadrant")
                    .font(.caption2)
                    .padding(5)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))

            Divider()

            VStack(spacing: 0) {
                Text("") // Placeholder to balance vertical space
                    .font(.caption2)
                    .padding(5)
                 Spacer()
                 Text("")
            }
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
        }
        .overlay(
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("")// Placeholder
                        .frame(maxWidth: .infinity)
                     Divider()
                     Text("")
                        .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: .infinity)
                Divider()
                HStack(spacing: 0) {
                    Text("")// Placeholder
                        .frame(maxWidth: .infinity)
                     Divider()
                     VStack(alignment: .trailing, spacing: 0) {
                         Spacer()
                        Text("Bottom-Trailing Quadrant")
                            .font(.caption2)
                            .padding(5)
                            .multilineTextAlignment(.trailing)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                }
                .frame(maxHeight: .infinity)
            }
        )
        .aspectRatio(1, contentMode: .fit)
        .foregroundColor(.secondary)
        .border(Color.primary.opacity(0.5))
    }
}

// MARK: - Alignment Demonstration View

/// Demonstrates various built-in `Alignment` values within a ZStack.
struct AlignmentDemoView: View {
    var body: some View {
        VStack {
            Text("Alignment Demo (in ZStack)")
                .font(.headline)
                .padding(.bottom)

            AlignmentDemoBackground()
                .overlay(alignment: .topLeading) { BoxView(name: ".topLeading", alignment: .topLeading) }
                .overlay(alignment: .top) { BoxView(name: ".top", alignment: .top) }
                .overlay(alignment: .topTrailing) { BoxView(name: ".topTrailing", alignment: .topTrailing) }
                .overlay(alignment: .leading) { BoxView(name: ".leading", alignment: .leading) }
                .overlay(alignment: .center) { BoxView(name: ".center", alignment: .center) }
                .overlay(alignment: .trailing) { BoxView(name: ".trailing", alignment: .trailing) }
                .overlay(alignment: .bottomLeading) { BoxView(name: ".bottomLeading", alignment: .bottomLeading) }
                .overlay(alignment: .bottom) { BoxView(name: ".bottom", alignment: .bottom) }
                .overlay(alignment: .bottomTrailing) { BoxView(name: ".bottomTrailing", alignment: .bottomTrailing) }
                // Note: Text baseline alignments are less intuitive in ZStack without text content.
                // They are better demonstrated in HStack/VStack.
        }
        .padding()
    }
}

// MARK: - HorizontalAlignment Demonstration View

/// Demonstrates various built-in `HorizontalAlignment` values within a VStack.
struct HorizontalAlignmentDemoView: View {
    var body: some View {
        VStack {
            Text("HorizontalAlignment Demo (in VStack)")
                .font(.headline)
                .padding(.bottom)

            HStack(spacing: 30) {
                column(alignment: .leading, text: "Leading")
                column(alignment: .center, text: "Center")
                column(alignment: .trailing, text: "Trailing")
            }
            .frame(height: 150)
        }
        .padding()
    }

    private func column(alignment: HorizontalAlignment, text: String) -> some View {
        VStack(alignment: alignment, spacing: 0) {
            Color.red.frame(width: 1, height: 50) // Alignment guide visualizer
            BoxView(name: text, alignment: nil) // Text box
                .border(Color.gray.opacity(0.8))
            Color.red.frame(width: 1, height: 50) // Alignment guide visualizer

            Text("(\(alignment.description))") // Display alignment name
              .font(.caption)
              .padding(.top, 5)
        }
        .background(Color.gray.opacity(0.1)) // Background for column clarity

    }
}

// Extend HorizontalAlignment for description (internal detail, not usually needed)
extension HorizontalAlignment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .leading: return ".leading"
        case .center: return ".center"
        case .trailing: return ".trailing"
        default: return "custom" // Simplified for demo
        }
    }
}

// MARK: - VerticalAlignment Demonstration View

/// Demonstrates various built-in `VerticalAlignment` values within an HStack.
struct VerticalAlignmentDemoView: View {
    var body: some View {
        VStack {
            Text("VerticalAlignment Demo (in HStack)")
                .font(.headline)
                .padding(.bottom)

            VStack(spacing: 30) {
                row(alignment: .top, text: "Top")
                row(alignment: .center, text: "Center")
                row(alignment: .bottom, text: "Bottom")
                row(alignment: .firstTextBaseline, text: "fghijkl") // Use text with descenders
                row(alignment: .lastTextBaseline, text: "NOPQR")
            }
            .frame(width: 250)
        }
        .padding()
    }

     private func row(alignment: VerticalAlignment, text: String) -> some View {
        HStack(alignment: alignment, spacing: 0) {
            Color.red.frame(width: 50, height: 1) // Alignment guide visualizer
             VStack { // Wrap Text for baseline demo
                Text(text)
                    .font(alignment == .firstTextBaseline || alignment == .lastTextBaseline ? .title : .body)
                    .border(Color.gray.opacity(0.8))
                    .background(alignment == .firstTextBaseline ? Color.yellow.opacity(0.1) : Color.clear) // Highlight baseline rows
                    .background(alignment == .lastTextBaseline ? Color.orange.opacity(0.1) : Color.clear)
                if (alignment == .firstTextBaseline || alignment == .lastTextBaseline) {
                     Text("(Baseline Demo)")
                        .font(.caption2)
                 }
             }
            Color.red.frame(width: 50, height: 1) // Alignment guide visualizer

//            Text("(\(alignment.id.description))") // Display alignment name
//                .font(.caption)
//                .frame(minWidth: 120, alignment: .leading) // Ensure space for label
         }
         .background(Color.gray.opacity(0.1)) // Background for row clarity
     }
}

// Extend VerticalAlignment.ID for description (internal detail, not usually needed)
extension AlignmentID {
     // Simple description based on known types for demo purposes
    var description: String {
       let typeName = String(describing: Self.self)
        switch typeName {
            case "_TopAlignment": return ".top"
            case "_CenterAlignment": return ".center"
            case "_BottomAlignment": return ".bottom"
            case "_FirstBaselineAlignment": return ".firstTextBaseline"
            case "_LastBaselineAlignment": return ".lastTextBaseline"
            default: return "custom (\(typeName))"
        }
   }
}

// MARK: - Custom AlignmentID Demonstration

// 1. Define a custom AlignmentID
private struct FirstThirdAlignmentID: AlignmentID {
    // 4. Use ViewDimensions in defaultValue
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        // Place the guide one-third down the view's height
        return context.height / 3
    }
}

// 2. Extend VerticalAlignment with a static property for the custom guide
extension VerticalAlignment {
    static let firstThird = VerticalAlignment(FirstThirdAlignmentID.self)
}

/// View demonstrating the use of a custom VerticalAlignment.
struct CustomAlignmentDemoView: View {
    var body: some View {
        VStack {
            Text("Custom AlignmentID (Vertical: .firstThird)")
                .font(.headline)
                .padding(.bottom)

             Text("HStack uses `.firstThird` alignment.")
                 .font(.caption)
                 .padding(.bottom, 5)

            // 3. Use the custom alignment in a layout container
            HStack(alignment: .firstThird, spacing: 10) {
                stripeGroup(height: 60, color: .blue)
                stripeGroup(height: 120, color: .green)
                stripeGroup(height: 90, color: .orange)

                 // Example of overriding the guide for one view
                 stripeGroup(height: 90, color: .purple)
                     .alignmentGuide(.firstThird) { context in
                         // Align this view's guide at two-thirds instead
                         return 2 * context.height / 3
                     }
                     .overlay(Text("Overridden").font(.caption2).foregroundColor(.white).padding(2), alignment: .top)
            }
            .frame(height: 150) // Ensure enough height for demonstration
            .background(Color.gray.opacity(0.1))
            .border(Color.primary.opacity(0.5))
         }
        .padding()
    }

    private func stripeGroup(height: CGFloat, color: Color) -> some View {
        VStack(spacing: 1) {
            ForEach(0..<3) { i in
                color
                    .overlay(Text("\(i+1)/3rds").font(.caption2).foregroundColor(.white))
            }
        }
        .frame(width: 40, height: height)
//        .overlay( // Visualize the alignment guide position
//            GeometryReader { geometry in
//                let guideY = FirstThirdAlignmentID.defaultValue(in: geometry)
//                Path { path in
//                    path.move(to: CGPoint(x: 0, y: guideY))
//                    path.addLine(to: CGPoint(x: geometry.size.width, y: guideY))
//                }
//                .stroke(Color.red, style: StrokeStyle(lineWidth: 1, dash: [2]))
//            }
//        )
    }
}

// MARK: - Main ContentView

/// Combines all demonstration views.
struct AlignmentTypesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                AlignmentDemoView()
                Divider()
                HorizontalAlignmentDemoView()
                Divider()
                VerticalAlignmentDemoView()
                Divider()
                CustomAlignmentDemoView()
            }
            .padding()
        }
        .navigationTitle("Alignment Types") // Use in NavigationView for title
    }
}

// MARK: - Preview

#Preview {
    NavigationView { // Wrap in NavigationView for better title display
        AlignmentTypesView()
    }
}
