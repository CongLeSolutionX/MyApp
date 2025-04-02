//
//  LyricsView.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

import SwiftUI

// MARK: - Custom Text Renderer Definition

/// A custom text renderer that draws text with a blurred glow effect behind it.
struct KaraokeGlowRenderer: TextRenderer {
    /// The color of the glow effect.
    let glowColor: Color
    /// The radius of the blur applied to the glow.
    let blurRadius: CGFloat

    /// The core drawing function required by the TextRenderer protocol.
    ///
    /// SwiftUI calls this function to draw the text associated with the renderer.
    /// - Parameters:
    ///   - layout: Provides access to the laid-out text lines and runs.
    ///   - context: The graphics context used for drawing.
    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        // Iterate through each line of text provided by the layout engine.
        for line in layout {
            // Iterate through each run within the line. A run represents a contiguous
            // piece of text with consistent styling (font, color, etc.).
            for run in line {
                // 1. Prepare the Glow Effect Context:
                // Create a copy of the current graphics context. Modifications
                // to this copy (like applying filters) won't affect the original
                // context used for drawing the main text.
                var glowContext = context

                // Apply the filters to the copied context to create the glow:
                // a) Add a blur filter.
                glowContext.addFilter(.blur(radius: blurRadius))
                // b) Apply a color tint using colorMultiply. This tints the blurred text.
                glowContext.addFilter(.colorMultiply(glowColor))

                // 2. Draw the Glow Layer:
                // Draw the text run using the modified 'glowContext'.
                // This renders the blurred, colored text first, placing it
                // underneath the sharp text layer.
                glowContext.draw(run)

                // 3. Draw the Original Text Layer:
                // Draw the same text run again, but this time using the original,
                // unmodified 'context'. This renders the sharp text directly
                // on top of the previously drawn glow layer.
                context.draw(run)
            }
        }
    }
}

// MARK: - Convenience View Modifier (Optional but Recommended)

/// An extension on View to provide a cleaner way to apply the KaraokeGlowRenderer.
extension View {
    /// Applies a karaoke-style glow effect to the text within this view.
    /// - Parameters:
    ///   - color: The color of the glow. Defaults to purple.
    ///   - radius: The blur radius of the glow. Defaults to 8.
    /// - Returns: A view with the text glow effect applied.
    func karaokeGlow(color: Color = .purple, radius: CGFloat = 8) -> some View {
        // Apply the custom TextRenderer using the .textRenderer modifier.
        // Note: This works because Text conforms to View, and modifiers applied
        // to Text often get passed down appropriately. For complex views,
        // you might need a more specific Text extension.
        self.modifier(KaraokeGlowTextModifier(glowColor: color, blurRadius: radius))
    }
}

// Helper modifier to ensure textRenderer is applied correctly
struct KaraokeGlowTextModifier: ViewModifier {
    let glowColor: Color
    let blurRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *) {
             // Apply the renderer - Works directly on Text views.
             // If 'content' might not be just Text, this could be less reliable.
             // A pure Text extension might be safer if only Text is targeted.
            content.textRenderer(KaraokeGlowRenderer(glowColor: glowColor, blurRadius: blurRadius))
        } else {
            // Fallback for older OS versions if needed
            content
        }
    }
}

// MARK: - Example Usage in a SwiftUI View

struct LyricsView: View {
    var body: some View {
        // Use a dark background for better visibility of the glow effect
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 30) {
                Text("A Whole View World")
                    .font(.system(size: 50, weight: .heavy))
                    .foregroundColor(.white) // Set base text color
                    // Apply the effect using the convenience modifier
                    .karaokeGlow(color: .cyan, radius: 10)

                Text("SwiftUI makes it shine!")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.yellow) // Different base color
                    .karaokeGlow(color: .orange, radius: 8)

                Text("With custom renderers,\nmy text looks divine.")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .karaokeGlow(color: .pink, radius: 6)

                // Example without the convenience modifier:
                // Text("Direct Renderer Use")
                //     .font(.system(size: 20))
                //     .foregroundColor(.green)
                //     .textRenderer(KaraokeGlowRenderer(glowColor: .lime, blurRadius: 5))

            }
            .padding()
        }
    }
}

// MARK: - Preview

#Preview {
    LyricsView()
}
