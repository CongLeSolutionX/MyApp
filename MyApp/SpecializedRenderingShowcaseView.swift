//
//  SpecializedRenderingShowcaseView.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import SwiftUI

// MARK: - Data Structures for Mock Map

struct MapTile: Identifiable {
    let id = UUID()
    let color: Color
    let variation: Double // 0.0 to 1.0 for subtle visual difference
}

// MARK: - Mock Map Tile Grid View

struct MapTileGridView: View {
    let tiles: [MapTile]
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 1), count: 10) // 10 columns

    var body: some View {
        LazyVGrid(columns: columns, spacing: 1) {
            ForEach(tiles) { tile in
                RoundedRectangle(cornerRadius: 2)
                    .fill(tile.color)
                    .brightness(tile.variation * 0.1 - 0.05) // Apply subtle brightness variation
                    .aspectRatio(1.0, contentMode: .fit) // Ensure square tiles
            }
        }
    }
}

// MARK: - Mock Vector & Text Overlay Views (Conceptual)

struct VectorOverlayView: View {
    var body: some View {
        Canvas { context, size in
            // Conceptual: Draw vector-like lines (e.g., roads)
            var roadPath = Path()
            roadPath.move(to: CGPoint(x: size.width * 0.1, y: size.height * 0.2))
            roadPath.addLine(to: CGPoint(x: size.width * 0.8, y: size.height * 0.3))
            roadPath.addLine(to: CGPoint(x: size.width * 0.7, y: size.height * 0.9))
            context.stroke(roadPath, with: .color(.gray.opacity(0.6)), lineWidth: 3)

            // Conceptual: Draw points of interest
            let poiRect = CGRect(x: size.width * 0.2 - 5, y: size.height * 0.7 - 5, width: 10, height: 10)
            context.fill(Path(ellipseIn: poiRect), with: .color(.red.opacity(0.8)))
            let poiRect2 = CGRect(x: size.width * 0.6 - 5, y: size.height * 0.5 - 5, width: 10, height: 10)
            context.fill(Path(ellipseIn: poiRect2), with: .color(.blue.opacity(0.8)))

        }
    }
}

struct TextLabelsOverlayView: View {
     var body: some View {
        GeometryReader { geometry in
            ZStack {
                 // Conceptual: Place text labels - positions relative to parent size
                Text("Region A")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.black.opacity(0.7))
                    .padding(2)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(3)
                    .position(x: geometry.size.width * 0.3, y: geometry.size.height * 0.4)

                Text("Main St")
                    .font(.system(size: 9, weight: .light, design: .monospaced))
                    .foregroundColor(.black.opacity(0.6))
                    .rotationEffect(.degrees(-10)) // Align text with a road visually
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.7)

                 Text("POI 1")
                     .font(.caption2)
                     .foregroundColor(.white)
                     .shadow(radius: 1)
                     .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.7 + 12) // Below red dot

                 Text("POI 2")
                     .font(.caption2)
                     .foregroundColor(.white)
                     .shadow(radius: 1)
                     .position(x: geometry.size.width * 0.6, y: geometry.size.height * 0.5 - 12) // Above blue dot
            }
        }
    }
}

// MARK: - Main Showcase View

struct SpecializedRenderingShowcaseView: View {

    // Generate some mock tile data
    let mapTiles: [MapTile] = (0..<100).map { _ in
        let type = Double.random(in: 0...1)
        let color: Color
        if type < 0.6 { // Land majority
            color = .green.opacity(Double.random(in: 0.5...0.9))
        } else if type < 0.85 { // Water
            color = .blue.opacity(Double.random(in: 0.4...0.8))
        } else { // Urban/Gray
            color = .gray.opacity(Double.random(in: 0.3...0.7))
        }
        return MapTile(color: color, variation: Double.random(in: 0...1))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {

                // 1. Header
                Label("Specialized Rendering", systemImage: "square.grid.3x3.fill")
                    .font(.title.weight(.semibold))
                    .foregroundColor(.purple)
                    .padding(.bottom, 5)

                // 2. Description
                Text("Niche rendering tasks demanding performance and customization not met by other frameworks.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Divider()

                // 3. Concrete Example Section: Custom Map Rendering
                Text("Example: Custom Map Tile Rendering")
                    .font(.title3.weight(.medium))

                // 4. Visual Mock-up of the Map
                ZStack {
                    // Background tiles
                    MapTileGridView(tiles: mapTiles)
                        .padding(2)
                        .background(Color.black.opacity(0.8)) // Frame the grid
                        .clipShape(RoundedRectangle(cornerRadius: 5))

                    // Vector overlay (conceptual roads, POIs)
                    VectorOverlayView()

                    // Text labels overlay (conceptual place names)
                    TextLabelsOverlayView()
                }
                .aspectRatio(1.5, contentMode: .fit) // Maintain aspect ratio for the map area
                .padding(.vertical)

                // 5. Characteristics Explanation linked to visuals
                 VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.orange)
                            .frame(width: 20)
                        VStack(alignment: .leading) {
                             Text("Performance").bold()
                             Text("Handling many tiles/elements smoothly, often requires bypassing standard UI layers for direct GPU control (Metal).")
                        }
                    }

                    HStack(alignment: .top) {
                         Image(systemName: "paintbrush.pointed.fill")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        VStack(alignment: .leading) {
                             Text("Customization").bold()
                             Text("Unique tile appearances (colors, shaders), custom vector styles (roads), and specific text rendering details (GPU-accelerated glyphs).")
                        }
                    }

                    HStack(alignment: .top) {
                         Image(systemName: "puzzlepiece.extension.fill")
                            .foregroundColor(.green)
                            .frame(width: 20)
                         VStack(alignment: .leading) {
                             Text("Niche Task").bold()
                             Text("Building a map system from scratch is specialized; standard map views might not offer the needed control or visual style.")
                        }
                   }
                }
                 .font(.footnote)
                 .padding(.horizontal)

            }
            .padding()
        }
    }
}

// MARK: - Preview Provider

struct SpecializedRenderingShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        SpecializedRenderingShowcaseView()
    }
}

/*
// MARK: - App Entry Point (Optional)
@main
struct SpecializedApp: App {
    var body: some Scene {
        WindowGroup {
            SpecializedRenderingShowcaseView()
        }
    }
}
*/
