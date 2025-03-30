//
//  GeometryCoordinatesAndAnchorsDemoView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//
import SwiftUI

// MARK: - Data Structures (for demonstration)

struct ItemData: Identifiable {
    let id = UUID()
    let color: Color
}

// MARK: - Preference Key for Anchors

/// Preference key to store the center anchor of a view.
struct CenterAnchorKey: PreferenceKey {
    // Store an optional Anchor<CGPoint>. Default is nil.
    static var defaultValue: Anchor<CGPoint>? = nil

    // Combine values: We only care about one anchor, so keep the first non-nil value found.
    // In a real app, you might need a dictionary or array if tracking multiple anchors.
    static func reduce(value: inout Anchor<CGPoint>?, nextValue: () -> Anchor<CGPoint>?) {
        value = value ?? nextValue()
    }
}

// MARK: - Main Demo View

struct GeometryCoordinatesAnchorsDemoView: View {
    // State to display geometry information dynamically
    @State private var geometryInfo: String = "Tap a shape to see its geometry info."
    // Name for our custom coordinate space
    private let customSpaceName = "CustomVStackSpace"

    // Sample data for demonstration
    private let items = [ItemData(color: .red), ItemData(color: .green)]

    var body: some View {
        VStack(spacing: 20) {
            // Display area for geometry info
            Text(geometryInfo)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(8)
                .lineLimit(nil) // Allow multiple lines
                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion

            Divider()

            // Outer GeometryReader to get the context for resolving coordinates/anchors
            GeometryReader { fullViewGeometryProxy in
                VStack(spacing: 15) {
                    Text("Tap Shapes Below")
                        .font(.headline)

                    // Inner container with its own coordinate space
                    VStack {
                        Rectangle()
                            .fill(Color.blue.opacity(0.3))
                             .frame(height: 200)
                             .overlay(GeometryReader { rectProxy in // <- FIX: Removed '-> some View'
                                 // Use overlay with GeometryReader to capture proxy for tap gesture
                                 let tapAction = TapGesture().onEnded {
                                     updateGeometryInfo(description: "Blue Rectangle", proxy: rectProxy)
                                 }
                                 // Return the view with the gesture attached
                                 return Color.clear.contentShape(Rectangle()).gesture(tapAction)
                            })


                        Circle()
                             .fill(Color.orange.opacity(0.7))
                             .frame(width: 100, height: 100)
                             .anchorPreference(key: CenterAnchorKey.self, value: .center) { $0 } // Export center anchor
                             .overlay(GeometryReader { circleProxy in // <- FIX: Removed '-> some View'
                                 let tapAction = TapGesture().onEnded {
                                     updateGeometryInfo(description: "Orange Circle", proxy: circleProxy)
                                 }
                                 // Return the view with the gesture attached
                                 return Color.clear.contentShape(Circle()).gesture(tapAction) // Use Circle content shape
                             })
                    }
                    .coordinateSpace(name: customSpaceName) // Define the named coordinate space
                    // Read the anchor preference and use the outer GeometryReader to resolve it
                    .overlayPreferenceValue(CenterAnchorKey.self) { centerAnchor in
                         // Use GeometryReader *inside* the preference overlay to resolve
                        GeometryReader { geometry in
                            // Ensure anchor exists before trying to resolve
                            if let anchor = centerAnchor {
                                let resolvedCenter = geometry[anchor] // Resolve anchor relative to the view applying the overlayPreferenceValue
                                // Mark the resolved center visually
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 8, height: 8)
                                    .position(resolvedCenter) // Position the marker

                                Text("Anchor: (\(resolvedCenter.x, specifier: "%.0f"), \(resolvedCenter.y, specifier: "%.0f"))")
                                    .font(.caption)
                                    .padding(2)
                                    .background(Color.white.opacity(0.7))
                                    .offset(x: resolvedCenter.x + 20, y: resolvedCenter.y) // Position text near anchor
                            }
                        }
                    }
                }
                 // Example of accessing GeometryProxy info directly if needed elsewhere
                 // Text("Full View Size: \(fullViewGeometryProxy.size.width, specifier: "%.0f") x \(fullViewGeometryProxy.size.height, specifier: "%.0f")")
                 //    .font(.caption)
            }
            .padding() // Padding for the outer VStack
        }
        .navigationTitle("Geometry Demo")
        .padding() // Padding for the root VStack
    }

    // MARK: - Helper Function

    /// Updates the state variable `geometryInfo` with formatted details from the GeometryProxy.
    private func updateGeometryInfo(description: String, proxy: GeometryProxy) {
        let size = proxy.size
        let safeArea = proxy.safeAreaInsets
        let globalFrame = proxy.frame(in: .global)
        let localFrame = proxy.frame(in: .local)
        // Get frame in custom space
        let customFrame = proxy.frame(in: .named(customSpaceName))

        // Build the string with formatted values
        geometryInfo = """
        \(description) Tapped:
          Size: \(String(format: "%.1f", size.width))w x \(String(format: "%.1f", size.height))h
          Global Origin: (\(String(format: "%.1f", globalFrame.origin.x)), \(String(format: "%.1f", globalFrame.origin.y)))
          Local Origin: (\(String(format: "%.1f", localFrame.origin.x)), \(String(format: "%.1f", localFrame.origin.y)))
          '\(customSpaceName)' Origin: (\(String(format: "%.1f", customFrame.origin.x)), \(String(format: "%.1f", customFrame.origin.y)))
          Safe Insets (T,L,B,R): (\(String(format: "%.1f", safeArea.top)), \(String(format: "%.1f", safeArea.leading)), \(String(format: "%.1f", safeArea.bottom)), \(String(format: "%.1f", safeArea.trailing)))
        """
    }
}

// MARK: - Preview

#Preview {
    // Wrap in NavigationView for better preview display and title
    NavigationView {
        GeometryCoordinatesAnchorsDemoView()
    }
}
