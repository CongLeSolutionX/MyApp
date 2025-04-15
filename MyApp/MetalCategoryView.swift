//
//  MetalCategoryView.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import SwiftUI

// MARK: - Data Model for Metal Categories

struct MetalCategory: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String // SF Symbol name
    let description: String // "Why MetalKit?" summary
    let examples: [String] // Key sub-areas/examples
}

// MARK: - Data Source

let metalCategories: [MetalCategory] = [
    MetalCategory(
        name: "Games (2D & 3D)",
        iconName: "gamecontroller.fill",
        description: "High performance rendering for interactive frame rates, complex effects, and large assets.",
        examples: [
            "Sprites & Tilemaps (2D)",
            "Particle Effects (2D/3D)",
            "Model Loading & Rendering (3D)",
            "Lighting & PBR Shading (3D)",
            "Skeletal Animation (3D)",
            "Terrain Rendering (3D)"
        ]
    ),
    MetalCategory(
        name: "Data Visualization",
        iconName: "chart.bar.xaxis",
        description: "Rendering large datasets or real-time plots beyond the capabilities of standard chart frameworks.",
        examples: [
            "Large Scale Plotting (Scatter, Line)",
            "Heatmaps",
            "Graph/Network Visualization",
            "Scientific Visualization (Volume, Flow)",
            "Real-time Data Streams"
        ]
    ),
    MetalCategory(
        name: "Image & Video Processing",
        iconName: "camera.filters",
        description: "Real-time, high-performance processing, custom filters, and analysis on image/video data.",
        examples: [
            "Real-time Camera Filters",
            "Custom Video Transitions",
            "GPU-accelerated Image Analysis",
            "High-Performance Compositing",
            "Color Correction & Grading"
        ]
    ),
    MetalCategory(
        name: "Compute (GPGPU)",
        iconName: "cpu.fill", // Using CPU icon metaphorically for compute tasks
        description: "Leveraging GPU parallelism for computationally intensive tasks unsuitable for the CPU.",
        examples: [
            "Physics Simulations (Fluid, Cloth)",
            "Parallel Algorithms Acceleration",
            "Custom ML Kernels",
            "Signal Processing",
            "Procedural Generation (Noise, Textures)"
        ]
    ),
    MetalCategory(
        name: "Custom UI Rendering",
        iconName: "rectangle.3.group.fill",
        description: "Creating unique, high-performance UI elements or effects beyond standard framework capabilities.",
        examples: [
            "High-Performance Custom Controls",
            "Shader-based UI Effects/Animations",
            "Rendering to Texture for UI",
            "Interactive Backgrounds"
        ]
    ),
    MetalCategory(
        name: "Creative Tools",
        iconName: "paintbrush.pointed.fill",
        description: "Powering demanding creative applications requiring real-time feedback and complex rendering.",
        examples: [
            "Drawing/Painting Apps (Custom Brushes)",
            "3D Sculpting/Modeling Previews",
            "Visual Effects Node Editors",
            "High-Fidelity Material Rendering"
        ]
    ),
    MetalCategory(
        name: "Augmented Reality (AR)",
        iconName: "arkit",
        description: "Rendering custom visuals, objects, or shader effects into AR scenes managed by ARKit.",
        examples: [
            "Custom Rendering of Virtual Objects",
            "Shader-based AR Scene Effects",
            "Optimized Rendering for AR Content",
            "Integration with ARKit Textures"
        ]
    ),
    MetalCategory(
        name: "Scientific & Engineering",
        iconName: "flask.fill",
        description: "Visualizing complex scientific or engineering data, simulations, and models interactively.",
        examples: [
            "CAD Model Viewers",
            "Molecular Visualization",
            "Simulation Result Display (CFD, FEA)",
            "Volume Rendering"
        ]
    ),
    MetalCategory(
        name: "Specialized Rendering" ,
        iconName: "square.grid.3x3.fill",
        description: "Niche rendering tasks demanding performance and customization not met by other frameworks.",
        examples: [
            "Custom Map Tile Rendering",
            "GPU-accelerated Text Rendering",
            "High-Performance Vector Graphics"
        ]
    )
]

// MARK: - SwiftUI View Implementation

struct MetalCategoriesView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(metalCategories) { category in
                    Section {
                        // Category Description (Why MetalKit)
                        Text(category.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 5)

                        // Examples List
                        ForEach(category.examples, id: \.self) { example in
                            Label(example, systemImage: "smallcircle.filled.circle")
                                .font(.subheadline)
                        }
                    } header: {
                        // Category Header (Icon + Name)
                        Label(category.name, systemImage: category.iconName)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.primary) // Ensure header stands out
                            .padding(.vertical, 4) // Add some vertical padding to header
                    }
                }
            }
            .navigationTitle("MetalKit Use Cases")
            .listStyle(.insetGrouped) // Use inset grouped style for better visual separation
        }
    }
}

// MARK: - Preview Provider

struct MetalCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        MetalCategoriesView()
    }
}

/*
// MARK: - App Entry Point (Optional)
// If you want to run this as a standalone app:
@main
struct MetalUseCaseApp: App {
    var body: some Scene {
        WindowGroup {
            MetalCategoriesView()
        }
    }
}
*/
