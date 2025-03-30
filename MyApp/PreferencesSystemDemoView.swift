//
//  PreferencesSystemDemoView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//
import SwiftUI

// --- 1. Define the Preference Key ---
struct BoundsPreferenceKey: PreferenceKey {
    typealias Value = [Int: CGRect]
    static var defaultValue: [Int: CGRect] = [:]

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { (_, new) in new }
    }
}

// --- 2. Create a Child View that Writes the Preference ---
struct ReportingChildView: View {
    let id: Int

    var body: some View {
        Text("Child View \(id)")
            .padding()
            .background(Color.green.opacity(0.7))
            .cornerRadius(8)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: BoundsPreferenceKey.self,
                            value: [self.id: geometry.frame(in: .global)]
                        )
                }
            )
    }
}

// --- 3. Create a Parent View that Reads and Uses the Preference ---
struct PreferenceReaderView: View {
    @State private var reportedBounds: CGRect = .zero
    @State private var showChild: Bool = true

    var body: some View {
        VStack(spacing: 20) {
            Text("Parent View")
                .font(.title)
                .padding(.bottom, 30)

            if showChild {
                ReportingChildView(id: 1)
                    .padding(40)
                    .transformPreference(BoundsPreferenceKey.self) { value in
                        if let bounds = value[1] {
                             value[1] = bounds.insetBy(dx: 5, dy: 5)
                             // Commenting out print for cleaner live previews if needed
                             // print("Transformed preference for ID 1: \(value[1]!)")
                        }
                    }
            }

            Button(showChild ? "Hide Child" : "Show Child") {
                 withAnimation { // Add animation for smooth hide/show
                     showChild.toggle()
                     if !showChild { reportedBounds = .zero }
                 }
            }
            .padding(.top)

            Text("Reported Bounds (Global):\n\(formatRect(reportedBounds))")
                .font(.caption)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true) // Prevent text layout issues
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.yellow.opacity(0.2))
        // --- Reading Method 1: .onPreferenceChange ---
        .onPreferenceChange(BoundsPreferenceKey.self) { value in
             // Use animation here if you want state changes triggered by preferences to animate other things
            withAnimation(.easeInOut) {
                self.reportedBounds = value[1] ?? .zero
                // Commenting out print for cleaner live previews if needed
                // print("Preference changed: Received bounds for ID 1: \(self.reportedBounds)")
            }
        }
        // --- Reading Method 2: .overlayPreferenceValue ---
        .overlayPreferenceValue(BoundsPreferenceKey.self) { preferences in
            GeometryReader { geometry in
                // Check if bounds for ID 1 exist
                if let globalBoundsFromPreference = preferences[1] {

                    // --- CORRECTION START ---
                    // Calculate the origin of the preference bounds relative to the GeometryReader's origin.
                    // The preference bounds are already global, so get the GeometryReader's global frame too.
                    let geometryGlobalFrame = geometry.frame(in: .global)

                    // Calculate the local origin within the GeometryReader
                    let localOriginX = globalBoundsFromPreference.origin.x - geometryGlobalFrame.origin.x
                    let localOriginY = globalBoundsFromPreference.origin.y - geometryGlobalFrame.origin.y
                    let localOrigin = CGPoint(x: localOriginX, y: localOriginY)

                    // The size doesn't need conversion (unless scaling/rotation is involved)
                    let localSize = globalBoundsFromPreference.size

                    // Create the frame in the local coordinate space of the GeometryReader
                    let localFrame = CGRect(origin: localOrigin, size: localSize)
                    // --- CORRECTION END ---


                    // Draw a red stroke around the area reported by the child view, now using the localFrame
                    Rectangle()
                        .stroke(Color.red, lineWidth: 2)
                        .frame(width: localFrame.width, height: localFrame.height)
                         // Position using the calculated local frame's center or origin
                        .position(x: localFrame.midX, y: localFrame.midY)
                        // Animate the overlay rectangle when its frame changes
                        .animation(.easeInOut, value: localFrame)

                } else {
                    // Optionally show nothing or a placeholder if the preference isn't set
                    EmptyView()
                }
            }
            // Make the overlay interactive/visible for debugging if needed
            // .allowsHitTesting(false)
        }
    }

    // Helper function to format CGRect for display
    func formatRect(_ rect: CGRect) -> String {
        guard rect != .zero else { return "N/A" }
        return String(format: "x:%.1f, y:%.1f, w:%.1f, h:%.1f",
                      rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
    }
}


// --- Preview Provider ---
#Preview {
    PreferenceReaderView()
}
