////
////  ScientificEngineeringView.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//
//import SwiftUI
//
//// MARK: - Data Structures (for conceptual representation)
//
//// Simple representation of an "atom" for visualization
//struct AtomView: View {
//    let color: Color
//    let size: CGFloat = 30
//
//    var body: some View {
//        Circle()
//            .fill(color)
//            .frame(width: size, height: size)
//            .shadow(radius: 2)
//    }
//}
//
//// Simple representation of a "bond"
//struct BondView: View {
//    let length: CGFloat = 50
//    let thickness: CGFloat = 4
//
//    var body: some View {
//        Capsule()
//            .fill(.gray)
//            .frame(width: length, height: thickness)
//    }
//}
//
//// MARK: - Scientific & Engineering View
//
//struct ScientificEngineeringView: View {
//
//    // MARK: State Variables (Simulating Interactivity)
//
//    // --- Molecular Visualization State ---
//    @State private var moleculeRotationX: Double = 0
//    @State private var moleculeRotationY: Double = 30
//    @State private var moleculeScale: CGFloat = 1.0
//    @State private var selectedMolecule: String = "Water (H₂O)" // Conceptual
//
//    // --- Simulation Result State ---
//    @State private var simulationTimeStep: Double = 0.5 // 0 to 1
//    @State private var displayMode: SimDisplayMode = .heatmap
//
//    // --- CAD/Volume State (Conceptual) ---
//    @State private var showWireframe: Bool = false
//    @State private var volumeSlice: Double = 0.5 // 0 to 1
//
//    enum SimDisplayMode: String, CaseIterable, Identifiable {
//        case heatmap = "Heatmap"
//        case vectors = "Vector Field"
//        case contours = "Contours"
//        var id: String { self.rawValue }
//    }
//
//    // MARK: Body
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                // --- Header ---
//                Label("Scientific & Engineering", systemImage: "flask.fill")
//                    .font(.largeTitle.weight(.bold))
//                    .padding(.bottom, 5)
//
//                Text("Visualizing complex scientific or engineering data, simulations, and models interactively using Metal for high performance.")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//
//                Divider()
//
//                // --- Example: Molecular Visualization ---
//                GroupBox {
//                    VStack(alignment: .leading) {
//                        Text("Example: Molecular Visualization")
//                            .font(.title2.weight(.semibold))
//
//                        Text("Interactive rendering of molecules (e.g., proteins, chemicals) with custom shading and high detail.")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                            .padding(.bottom, 10)
//
//                        // Conceptual Molecule Representation
//                        ZStack {
//                            // Bonds (simple layout)
//                            BondView() // Center to Atom 1
//                                .rotationEffect(.degrees(-60))
//                                .offset(x: -25 * cos(.degrees(60) * .pi / 180), y: -25 * sin(.degrees(60) * .pi / 180)) // Convert degrees to radians for trig functions
//                             BondView() // Center to Atom 2
//                                .rotationEffect(.degrees(60))
//                                .offset(x: -25 * cos(.degrees(60) * .pi / 180), y: 25 * sin(.degrees(60) * .pi / 180))
//
//                            // Atoms (simple layout for H2O - 1 Red, 2 White)
//                            AtomView(color: .red) // Oxygen (Center)
//                            AtomView(color: .white.opacity(0.9)) // Hydrogen 1
//                                .offset(x: -50 * cos(.degrees(60) * .pi / 180), y: -50 * sin(.degrees(60) * .pi / 180))
//                             AtomView(color: .white.opacity(0.9)) // Hydrogen 2
//                                .offset(x: -50 * cos(.degrees(60) * .pi / 180), y: 50 * sin(.degrees(60) * .pi / 180))
//
//                        }
//                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 120) // Ensure ZStack expands and centers content horizontally
//                        .scaleEffect(moleculeScale)
//                        .rotation3DEffect(.degrees(moleculeRotationX), axis: (x: 1, y: 0, z: 0))
//                        .rotation3DEffect(.degrees(moleculeRotationY), axis: (x: 0, y: 1, z: 0))
//                        .animation(.interactiveSpring(), value: moleculeRotationX)
//                        .animation(.interactiveSpring(), value: moleculeRotationY)
//                        .animation(.interactiveSpring(), value: moleculeScale)
//                        .padding(.vertical)
//
//                        // Controls for Molecular Vis
//                        Text("Interaction Controls (Conceptual)").font(.caption).foregroundColor(.gray)
//                        VStack { // Wrap Sliders in VStacks for labels
//                           Text("Rotate Y (\(moleculeRotationY, specifier: "%%.0f")°)")
//                           Slider(value: $moleculeRotationY, in: -180...180, step: 5)
//                        }
//                         VStack {
//                            Text("Scale (\(moleculeScale, specifier: "%%.1f")x)")
//                            Slider(value: $moleculeScale, in: 0.5...2.0, step: 0.1)
//                         }
//                         Picker("Molecule", selection: $selectedMolecule) {
//                             Text("Water (H₂O)").tag("Water (H₂O)")
//                             Text("Methane (CH₄)").tag("Methane (CH₄)")
//                             Text("Protein XYZ").tag("Protein XYZ")
//                         }
//                         .pickerStyle(.segmented) // Just changes label - conceptual
//
//                    }
//                }
//
//                // --- Example: Simulation Result Display ---
//                GroupBox {
//                    VStack(alignment: .leading) {
//                        Text("Example: Simulation Result Display")
//                            .font(.title2.weight(.semibold))
//                        Text("Displaying outputs from simulations like CFD (fluid dynamics) or FEA (structural analysis) as heatmaps, vector fields, etc.")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                            .padding(.bottom, 10)
//
//                        // Conceptual Simulation Visualization
//                        ZStack {
//                            // Base rectangle
//                            RoundedRectangle(cornerRadius: 8)
//                                .fill(.gray.opacity(0.1))
//
//                            // Dynamic Gradient representing heatmap/flow based on timestep
//                            RoundedRectangle(cornerRadius: 8)
//                                .fill(
//                                    LinearGradient(
//                                        gradient: Gradient(colors: [
//                                            .blue.opacity(0.8),
//                                            .green.opacity(0.8 - simulationTimeStep * 0.5), // Adjusted opacity calculation
//                                            .yellow.opacity(0.5 + simulationTimeStep * 0.3),
//                                            .red.opacity(0.7 * simulationTimeStep)
//                                        ]),
//                                        startPoint: .leading,
//                                        endPoint: .trailing
//                                    )
//                                )
//                               .hueRotation(.degrees(simulationTimeStep * 90)) // Add some color change
//                        }
//                        .frame(height: 80)
//                        .clipped()
//                        .animation(.easeInOut, value: simulationTimeStep)
//                        .padding(.vertical)
//
//                        // Controls for Simulation Vis
//                        Text("Interaction Controls (Conceptual)").font(.caption).foregroundColor(.gray)
//                        VStack { // Wrap slider in VStack
//                            Text("Time Step / Parameter (\(simulationTimeStep, specifier: "%%.2f"))")
//                            Slider(value: $simulationTimeStep, in: 0...1, step: 0.05) {
//                               // Empty label here, Text used above
//                            } minimumValueLabel: {
//                                Image(systemName: "backward.end.fill")
//                            } maximumValueLabel: {
//                                 Image(systemName: "forward.end.fill")
//                            }
//                        }
//
//                        Picker("Display Mode", selection: $displayMode) {
//                            ForEach(SimDisplayMode.allCases) { mode in
//                                Text(mode.rawValue).tag(mode)
//                            }
//                        }
//                        .pickerStyle(.segmented) // Only changes state conceptually
//                    }
//                }
//
//                 // --- Other Examples (Simplified Placeholders) ---
//                 HStack(spacing: 20) {
//                     // CAD Model Viewer Placeholder
//                     GroupBox {
//                         VStack {
//                             Text("CAD Viewer").font(.headline)
//                             Image(systemName: "cube.box.fill")
//                                 .font(.system(size: 40))
//                                 .foregroundColor(showWireframe ? .blue : .gray)
//                                 .padding()
//                             Toggle("Wireframe", isOn: $showWireframe) // Conceptual toggle
//                         }
//                           .frame(maxWidth: .infinity)
//                     }
//
//                     // Volume Rendering Placeholder
//                     GroupBox {
//                         VStack {
//                             Text("Volume Render").font(.headline)
//                             Image(systemName: "square.stack.3d.up.fill")
//                                 .font(.system(size: 40))
//                                 .foregroundColor(.purple.opacity(0.7))
//                                 .overlay( // Simulate slice plane
//                                     Rectangle()
//                                        .fill(.black.opacity(0.3))
//                                        .frame(height: 2)
//                                        .offset(y: 20 * (volumeSlice - 0.5)) // Adjusted offset factor b/c font size is 40
//                                 )
//                                 .clipped()
//                                 .padding()
//                             VStack { // Wrap slider in VStack
//                                Text("Slice (\(volumeSlice, specifier: "%%.1f"))")
//                                Slider(value: $volumeSlice, in: 0...1, step: 0.1) // Conceptual slider
//                             }
//
//                         }
//                           .frame(maxWidth: .infinity)
//                     }
//                 } // End HStack
//
//            } // End Main VStack
//            .padding()
//        } // End ScrollView
//    }
//}
//
//// MARK: - Preview Provider
//
//struct ScientificEngineeringView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScientificEngineeringView()
//            .preferredColorScheme(.dark) // Example with dark mode
//        ScientificEngineeringView()
//            .preferredColorScheme(.light) // Example with dark mode
//    }
//}
