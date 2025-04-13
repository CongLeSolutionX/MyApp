//
//  AnchorAndGeometryProxyView.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//


import SwiftUI

// MARK: - Core Concepts Documentation Review

// Anchor<Value>: Represents an opaque value derived from an anchor source
// and a specific view. It allows converting this value (like a CGPoint or CGRect)
// into the coordinate space of another target view using GeometryProxy.
//
// Anchor.Source: A type-erased value used to create specific Anchors.
// It provides static methods (.point, .unitPoint, .bounds, .topLeading, etc.)
// to define the anchor relative to a view's bounds or specific points.
//
// GeometryProxy: Provides access to the geometry information (size, coordinate space)
// of a container view. Crucially, it has a subscript `proxy[anchor]` that
// resolves an Anchor<Value> into a concrete Value (e.g., CGPoint, CGRect)
// within the proxy's coordinate space. It also allows converting frames
// between different coordinate spaces using `frame(in:)`.

// MARK: - SwiftUI Anchor and GeometryProxy Demonstration

struct AnchorPointPreferenceKey: PreferenceKey {
    typealias Value = Anchor<CGPoint>?

    static var defaultValue: Value = nil

    // Use the first non-nil anchor found.
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value ?? nextValue()
    }
}

struct AnchorRectPreferenceKey: PreferenceKey {
    typealias Value = Anchor<CGRect>?

    static var defaultValue: Value = nil

    // Use the first non-nil anchor found.
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value ?? nextValue()
    }
}

// MARK: - Example Views

/// A view that provides an anchor (its center point) via PreferenceKey.
struct AnchoredView: View {
    let id: Int
    let color: Color

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 50, height: 50)
            // Set an anchor preference for the center of this view
            .anchorPreference(key: AnchorPointPreferenceKey.self, value: .center) { anchor in
                anchor // Pass the anchor itself as the preference value
            }
            .overlay(Text("\(id)"))
    }
}

/// A view that demonstrates reading an anchor from a child view and resolving it.
struct AnchorReaderView: View {
    @State private var childAnchor: Anchor<CGPoint>? = nil
    @State private var resolvedChildCenter: CGPoint? = nil
    @State private var childFrameInGlobal: CGRect? = nil
    @State private var childFrameInLocal: CGRect? = nil
    @State private var childFrameInNamed: CGRect? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Anchor Demonstration")
                .font(.title)

            Text("The blue square below provides its center anchor via a PreferenceKey.")

            GeometryReader { geometryProxy in
                ZStack(alignment: .topLeading) {
                    // Display the blue square
                    AnchoredView(id: 1, color: .blue)
                        .position(x: geometryProxy.size.width / 2, y: 50) // Position it for demo

                    // Draw a marker at the resolved anchor point if available
                    if let resolvedCenter = resolvedChildCenter {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .position(resolvedCenter)
                        Text("Resolved Center: \(Int(resolvedCenter.x)), \(Int(resolvedCenter.y))")
                            .font(.caption)
                            .position(x: resolvedCenter.x, y: resolvedCenter.y + 20)
                    }

                    // Display frame information
                    VStack(alignment: .leading) {
                        if let globalFrame = childFrameInGlobal {
                            Text("Frame (Global): \(frameToString(globalFrame))")
                        }
                        if let localFrame = childFrameInLocal {
                            Text("Frame (Local): \(frameToString(localFrame))")
                        }
                         if let namedFrame = childFrameInNamed {
                             Text("Frame (Named 'Reader'): \(frameToString(namedFrame))")
                         }
                    }
                    .font(.caption)
                    .position(x: geometryProxy.size.width / 2, y: 150)

                }
                .coordinateSpace(.named("Reader")) // Define a named coordinate space
                .onPreferenceChange(AnchorPointPreferenceKey.self) { anchor in
                    self.childAnchor = anchor
                    resolveAnchor(in: geometryProxy)
                }
                // Use background task to get geometry updates for frame calculations
                .background(
                     GeometryReader { backgroundProxy in
                         Color.clear
                             .task(id: childAnchor) { // Rerun when anchor changes (view appears/updates)
                                 await MainActor.run { // Ensure UI updates on main thread
                                     guard childAnchor != nil else { return }
                                    // Just use the anchor to get frame, it doesn't need to be point specific
                                   // self.childFrameInGlobal = backgroundProxy[anchor].bounds // Use bounds from resolved CGPoint anchor
                                    self.childFrameInLocal = backgroundProxy.frame(in: .local)
                                    self.childFrameInNamed = backgroundProxy.frame(in: .named("Reader"))
                                 }
                             }
                     }
                )
            }
            .frame(height: 250)
            .border(Color.gray)

            Text("GeometryProxy allows resolving the child's anchor point (red dot) into this parent's coordinate space.")
            Text("It also converts frames between coordinate spaces (local, global, named).")
                .font(.footnote)
        }
        .padding()
    }

    // Helper function to resolve the anchor using the GeometryProxy
    private func resolveAnchor(in geometryProxy: GeometryProxy) {
        guard let anchor = childAnchor else {
            resolvedChildCenter = nil
            return
        }
        // Resolve the anchor using the geometryProxy's subscript
        resolvedChildCenter = geometryProxy[anchor]
    }

     // Helper function to format CGRect for display
     private func frameToString(_ frame: CGRect) -> String {
         return "(\(Int(frame.origin.x)), \(Int(frame.origin.y))), (\(Int(frame.size.width)), \(Int(frame.size.height)))"
     }

    // Helper struct to get bounds from an anchor - normally you'd pass CGRect anchors
     struct BoundsAnchorProvider: View {
         var body: some View {
              Color.clear
                 .anchorPreference(key: AnchorRectPreferenceKey.self, value: .bounds) { $0 }
         }
     }
}

// MARK: - Main ContentView
struct ContentView_AnchorGeoDemo: View {
    var body: some View {
        NavigationView {
            AnchorReaderView()
                .navigationTitle("Anchor & GeometryProxy")
        }
    }
}

// MARK: - Preview
struct ContentView_AnchorGeoDemo_Previews: PreviewProvider {
    static var previews: some View {
        ContentView_AnchorGeoDemo()
    }
}

// MARK: - Included Struct Definitions (for completeness, normally implicit)

/*
 // Basic structure of Anchor and GeometryProxy for conceptual understanding
 // These are placeholder definitions and do not replicate the full internal implementation.

 @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
 @frozen public struct Anchor<Value> {
     /// A type-erased geometry value that produces an anchored value of a given type.
     @frozen public struct Source { }

     // Internal representation, not directly accessible
     internal var box: Any

     // Note: Anchor cannot be initialized directly by users.
     // It's obtained via Anchor.Source and preference keys.
 }

 @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
 extension Anchor.Source {
      /// Creates an anchor source representing a specific point within the view.
      public static func point(_ p: CGPoint) -> Anchor<CGPoint>.Source { /* Internal details */ fatalError() }
      /// Creates an anchor source representing a unit point within the view.
      public static func unitPoint(_ p: UnitPoint) -> Anchor<CGPoint>.Source { /* Internal details */ fatalError() }
       /// Creates an anchor source representing a specific rectangle within the view.
       public static func rect(_ r: CGRect) -> Anchor<CGRect>.Source { /* Internal details */ fatalError() }
      /// Creates an anchor source representing the view's bounds rectangle.
      public static var bounds: Anchor<CGRect>.Source { /* Internal details */ fatalError() }

     // Other static points like .center, .topLeading etc. are convenience wrappers
     public static var center: Anchor<CGPoint>.Source { unitPoint(.center) }
     // ... other static UnitPoint based anchors ...
 }

 @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
 public struct GeometryProxy {
     /// The size of the container view.
     public var size: CGSize { get }

     /// The safe area inset of the container view.
     public var safeAreaInsets: EdgeInsets { get }

     /// Returns the container view's bounds rectangle, converted to a defined coordinate space.
     public func frame(in coordinateSpace: CoordinateSpace) -> CGRect { /* Internal details */ fatalError() }

     /// Resolves the value of an anchor within the container view's coordinate space.
     public subscript<T>(anchor: Anchor<T>) -> T { /* Internal details */ fatalError() }

     // Internal representation, not directly accessible
     // let ...
 }

 @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
 extension GeometryProxy {
     /// Returns the container view's bounds rectangle, converted to a defined coordinate space protocol.
     public func frame(in coordinateSpace: some CoordinateSpaceProtocol) -> CGRect { self.frame(in: coordinateSpace.coordinateSpace) }
    // public func bounds(of coordinateSpace: NamedCoordinateSpace) -> CGRect? { /*...*/ }
 }
 */
