//
//  CanvasDrawingDemoView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//
import SwiftUI

// MARK: - Demo View Structure

/// A view demonstrating various drawing capabilities using Canvas and GraphicsContext.
struct CanvasDrawingDemoView: View {

    // Enum to uniquely identify symbols passed to the Canvas
    enum SymbolIdentifier: Int {
        case yellowStar = 1
        case swiftLogo = 2
    }

    var body: some View {
        ScrollView { // Wrap in ScrollView in case content overflows
            VStack(alignment: .leading, spacing: 20) {
                Text("SwiftUI Canvas Demo")
                    .font(.largeTitle)
                    .padding(.bottom)

                // --- Canvas Start ---
                Canvas { context, size in
                    // The 'context' (GraphicsContext) is the drawing environment.
                    // The 'size' (CGSize) is the available drawing area for the Canvas.

                    // MARK: 1. Basic Path Drawing (Fill & Stroke)
                    drawBasicShapes(context: context, size: size)

                    // MARK: 2. Image Drawing
                    drawImage(context: context, size: size)

                    // MARK: 3. Text Drawing
                    drawText(context: context, size: size)

                    // MARK: 4. Symbol Drawing (Resolving Tagged Views)
                    drawSymbols(context: context, size: size)

                    // MARK: 5. Transformations (Translate, Rotate, Scale)
                    drawTransformedContent(context: context, size: size)

                    // MARK: 6. Clipping
                    drawClippedContent(context: context, size: size)

                    // MARK: 7. Filters (Shadow)
                    drawFilteredContent(context: context, size: size)

                    // MARK: 8. State Management (Opacity & BlendMode)
                    drawWithStateChanges(context: context, size: size)

                    // MARK: 9. Using the Size Parameter
                    drawSizeInfo(context: context, size: size)

                    // MARK: 10. Core Graphics Interoperability (Optional Demo)
                    // drawWithCGContext(context: context, size: size) // Uncomment to see CGContext usage

                } symbols: {
                    // Define views that can be resolved and drawn inside the Canvas renderer.
                    // Each symbol needs a unique tag.
                    Image(systemName: "star.fill")
                        .resizable()
                        .foregroundStyle(.yellow) // Foreground style is applied before resolving
                        .tag(SymbolIdentifier.yellowStar) // Tag for resolving

                    Image(systemName: "swift")
                        .resizable()
                        .foregroundStyle(.orange) // Foreground style is applied before resolving
                        .tag(SymbolIdentifier.swiftLogo)  // Tag for resolving
                }
                .frame(width: 350, height: 700) // Define Canvas frame
                .border(Color.gray, width: 1) // Border to see canvas bounds
                .padding() // Add padding around the canvas
            }
            .padding() // Padding for the VStack content
        }
        .navigationTitle("Canvas Demo")
        #if !os(watchOS) // Navigation Bar Title Display Mode not available on watchOS
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    // MARK: - Drawing Helper Functions

    /// Draws basic filled and stroked paths.
    func drawBasicShapes(context: GraphicsContext, size: CGSize) {
        let rectPath = Path(CGRect(x: 20, y: 20, width: 100, height: 60))
        // Fill with a solid color (Shading.color)
        context.fill(rectPath, with: .color(.cyan))

        let circlePath = Path(ellipseIn: CGRect(x: 150, y: 20, width: 60, height: 60))
        // Stroke with a linear gradient (Shading.linearGradient)
        let gradient = Gradient(colors: [.green, .mint])
        context.stroke(
            circlePath,
            with: .linearGradient(gradient, startPoint: CGPoint(x: 150, y: 20), endPoint: CGPoint(x: 210, y: 80)),
            style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [5, 5]) // Example StrokeStyle
        )

        // Draw another path using conic gradient
         let conicPath = Path(ellipseIn: CGRect(x: 230, y: 20, width: 60, height: 60))
         context.fill(
             conicPath,
             with: .conicGradient(gradient, center: CGPoint(x: 260, y: 50), angle: .degrees(90)),
             style: FillStyle(eoFill: true) // Example FillStyle
         )
    }

    /// Draws system images.
    func drawImage(context: GraphicsContext, size: CGSize) {
        // Resolve an image first (gives more control).
        // The context.resolve method returns a non-optional ResolvedImage.
        let resolvedWalkingFigure = context.resolve(Image(systemName: "figure.walk.circle.fill"))
        context.draw(resolvedWalkingFigure, at: CGPoint(x: 50, y: 120), anchor: .center)

        // Draw directly (simpler for basic cases).
        // Apply foreground style *within* the draw call using shading on the resolved image.
        // GraphicsContext.draw doesn't directly take SwiftUI modifiers like foregroundStyle.
        var resolvedPaintBrush = context.resolve(Image(systemName: "paintbrush.fill"))
        resolvedPaintBrush.shading = .color(.red) // Set the shading on the resolved image
        context.draw(resolvedPaintBrush, in: CGRect(x: 100, y: 100, width: 40, height: 40))
        // Note: Alternatively, you could set context.environment before drawing, but
        // manipulating the resolved image's shading is often clearer inside Canvas.
    }


    /// Draws formatted text.
    func drawText(context: GraphicsContext, size: CGSize) {
        // Resolve text first
        var resolvedText = context.resolve(Text("Resolved Text").font(.headline).italic())
        resolvedText.shading = .color(.purple) // Change text color via shading
        context.draw(resolvedText, at: CGPoint(x: 180, y: 110))

        // Draw directly
        context.draw(Text("Direct Draw").font(.caption), at: CGPoint(x: 180, y: 135))
    }

    /// Resolves and draws symbols defined in the `symbols` closure.
    func drawSymbols(context: GraphicsContext, size: CGSize) {
        // resolveSymbol returns an Optional, so use if let here.
        if let starSymbol = context.resolveSymbol(id: SymbolIdentifier.yellowStar) {
            // Draw the star symbol at its resolved size
            context.draw(starSymbol, at: CGPoint(x: 50, y: 180))
            // Draw it again, scaled and positioned
            context.draw(starSymbol, in: CGRect(x: 100, y: 165, width: 40, height: 40))
        }

        if let swiftSymbol = context.resolveSymbol(id: SymbolIdentifier.swiftLogo) {
            context.draw(swiftSymbol, in: CGRect(x: 160, y: 165, width: 40, height: 40))
        }
    }

    /// Demonstrates applying transformations.
    func drawTransformedContent(context: GraphicsContext, size: CGSize) {
        // Create a copy of the context to apply transformations without affecting others.
        // Alternatively, use saveGState/restoreGState with withCGContext.
        var transformedContext = context

        // Translate
        transformedContext.translateBy(x: 50, y: 240)

        // Rotate
        transformedContext.rotate(by: .degrees(15))

        // Scale
        transformedContext.scaleBy(x: 1.2, y: 0.8)

        // Draw something in the transformed context
        let transformedPath = Path(roundedRect: CGRect(origin: .zero, size: CGSize(width: 100, height: 50)), cornerRadius: 8)
        transformedContext.fill(transformedPath, with: .color(.orange))

        // Draw Coordinate Axes for reference (using original context's transform)
         drawAxes(context: context, point: CGPoint(x: 50, y: 240), label: "Transformed Origin")
    }

    /// Helper to draw axes
    func drawAxes(context: GraphicsContext, point: CGPoint, label: String) {
        let axisLength: CGFloat = 30
        var xAxisPath = Path()
        xAxisPath.move(to: point)
        xAxisPath.addLine(to: CGPoint(x: point.x + axisLength, y: point.y))
        context.stroke(xAxisPath, with: .color(.red), lineWidth: 1)

        var yAxisPath = Path()
        yAxisPath.move(to: point)
        yAxisPath.addLine(to: CGPoint(x: point.x, y: point.y + axisLength))
        context.stroke(yAxisPath, with: .color(.green), lineWidth: 1)
        context.draw(Text(label).font(.caption2), at: CGPoint(x: point.x, y: point.y - 10), anchor: .bottomLeading)
    }


    /// Demonstrates clipping drawing operations.
    func drawClippedContent(context: GraphicsContext, size: CGSize) {
        // Draw the original shape lightly for reference
        let originalClipShapeBounds = CGRect(x: 200, y: 220, width: 120, height: 80)
        context.stroke(Path(originalClipShapeBounds), with: .color(.gray.opacity(0.3)), lineWidth: 1)

        // Use a copy of the context for clipping to avoid affecting subsequent drawings
        var clipContext = context
        let clipPath = Path(ellipseIn: originalClipShapeBounds.insetBy(dx: 10, dy: 10))
        clipContext.clip(to: clipPath, style: FillStyle(), options: []) // ClipOptions example: .inverse

        // Draw something that will be clipped by the ellipse
        clipContext.fill(Path(originalClipShapeBounds), with: .color(.purple))
        // Only the part within the ellipse clipPath will be visible.
    }

    /// Demonstrates adding filters like shadows.
    func drawFilteredContent(context: GraphicsContext, size: CGSize) {
        // Use drawLayer to apply filter to specific content
        context.drawLayer { layerContext in
            // Add a shadow filter to the layer
            let shadowFilter = GraphicsContext.Filter.shadow(
                color: .black.opacity(0.6),
                radius: 5,
                x: 4, y: 4
            )
            layerContext.addFilter(shadowFilter) // Add filter options here if needed

            // Draw the content that needs the shadow
            let filterRectPath = Path(CGRect(x: 30, y: 330, width: 100, height: 50))
            layerContext.fill(filterRectPath, with: .color(.yellow))
        } // Shadow is applied only to the content drawn within this layer closure
    }

    /// Demonstrates changing context state like opacity and blend mode.
    func drawWithStateChanges(context: GraphicsContext, size: CGSize) {
        var stateContext = context // Use a copy

        stateContext.opacity = 0.7
        stateContext.blendMode = .multiply // Change blend mode

        let rect1 = CGRect(x: 160, y: 330, width: 60, height: 60)
        let rect2 = CGRect(x: 190, y: 360, width: 60, height: 60)

        stateContext.fill(Path(rect1), with: .color(.red))
        stateContext.fill(Path(rect2), with: .color(.blue)) // Blue multiplies with Red where they overlap

        // Opacity and blend mode are reset when stateContext goes out of scope
    }

    /// Demonstrates using the `size` parameter passed into the renderer.
    func drawSizeInfo(context: GraphicsContext, size: CGSize) {
        let sizeText = Text("Canvas Size: \(Int(size.width)) x \(Int(size.height))")
            .font(.caption)
            .bold()
        let textPoint = CGPoint(x: size.width / 2, y: size.height - 15) // Position near bottom-center
        context.draw(sizeText, at: textPoint, anchor: .center)

        // Draw a border just inside the canvas bounds using the size
        var borderPath = Path()
        borderPath.addRect(CGRect(origin: .zero, size: size).insetBy(dx: 1, dy: 1))
        context.stroke(borderPath, with: .color(.blue.opacity(0.5)), lineWidth: 1)
    }

    /// Optional: Demonstrates drawing using Core Graphics context interoperability.
    func drawWithCGContext(context: GraphicsContext, size: CGSize) {
         context.withCGContext { cgContext in
             // Now you can use standard Core Graphics drawing functions
             let cgRect = CGRect(x: 20, y: 450, width: 100, height: 40)
             #if canImport(UIKit)
             cgContext.setFillColor(UIColor.magenta.cgColor)
             cgContext.setStrokeColor(UIColor.black.cgColor)
             #elseif canImport(AppKit)
             cgContext.setFillColor(NSColor.magenta.cgColor)
             cgContext.setStrokeColor(NSColor.black.cgColor)
             #endif
             cgContext.fill(cgRect)
             cgContext.stroke(cgRect, width: 2)

             // Note: CGContext has a different coordinate system (origin bottom-left)
             // SwiftUI's GraphicsContext abstracts this away, but be mindful here.
             // Text drawing in CGContext is more complex than context.draw(Text(...))
         }
    }
}

// MARK: - Preview

// Provides a preview of the CanvasDrawingDemoView in Xcode.
#Preview {
    // Use NavigationView for better title presentation in preview
    NavigationView {
        CanvasDrawingDemoView()
    }
}
