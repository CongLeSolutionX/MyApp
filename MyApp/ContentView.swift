//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}

import SwiftUI

// MARK: - Data Models

// Gemini Model Data Structure
struct GeminiModel: Identifiable, Equatable { // Added Equatable for potential ForEach optimizations
    let id = UUID() // Conformance to Identifiable for ForEach
    let name: String
    let identifier: String
    // Inputs, Outputs, OptimizedFor are kept in the model but won't be displayed directly
    let inputs: String
    let outputs: String
    let optimizedFor: String

    // Placeholder color for the card based on name hash (simple example)
    var placeholderColor: Color {
        let hash = name.hashValue
        let hue = Double(abs(hash % 360)) / 360.0
        return Color(hue: hue, saturation: 0.7, brightness: 0.8)
    }
}

// Gemini Model Data Source
let geminiModelsData: [GeminiModel] = [
    GeminiModel(name: "Gemini 2.5 Pro Exp.", identifier: "gemini-2.5-pro-exp-03-25", inputs: "Audio, images, videos, and text", outputs: "Text", optimizedFor: "Enhanced thinking and reasoning, multimodal understanding, advanced coding, and more"),
    GeminiModel(name: "Gemini 2.0 Flash", identifier: "gemini-2.0-flash", inputs: "Audio, images, videos, and text", outputs: "Text, images (experimental), and audio (coming soon)", optimizedFor: "Next generation features, speed, thinking, realtime streaming, and multimodal generation"),
    GeminiModel(name: "Gemini 2.0 Flash-Lite", identifier: "gemini-2.0-flash-lite", inputs: "Audio, images, videos, and text", outputs: "Text", optimizedFor: "Cost efficiency and low latency"),
    GeminiModel(name: "Gemini 1.5 Flash", identifier: "gemini-1.5-flash", inputs: "Audio, images, videos, and text", outputs: "Text", optimizedFor: "Fast and versatile performance across a diverse variety of tasks"),
    GeminiModel(name: "Gemini 1.5 Flash-8B", identifier: "gemini-1.5-flash-8b", inputs: "Audio, images, videos, and text", outputs: "Text", optimizedFor: "High volume and lower intelligence tasks"),
    GeminiModel(name: "Gemini 1.5 Pro", identifier: "gemini-1.5-pro", inputs: "Audio, images, videos, and text", outputs: "Text", optimizedFor: "Complex reasoning tasks requiring more intelligence"),
    GeminiModel(name: "Gemini Embedding", identifier: "gemini-embedding-exp", inputs: "Text", outputs: "Text embeddings", optimizedFor: "Measuring the relatedness of text strings"),
    GeminiModel(name: "Imagen 3", identifier: "imagen-3.0-generate-002", inputs: "Text", outputs: "Images", optimizedFor: "Our most advanced image generation model")
]

// MARK: - View Model (Using @MainActor)

@MainActor // Ensure UI updates happen on the main thread
class CardStackViewModel: ObservableObject {
    @Published var models: [GeminiModel] = []
    @Published var changeSize: Bool = false // State moved to ViewModel

    // You can add logic here to fetch or manage models asynchronously if needed
    init(initialModels: [GeminiModel] = geminiModelsData) {
        print("CardStackViewModel Initialized on Main Actor")
        self.models = initialModels
        // Example: Simulate loading more models after a delay
        // loadMoreModels()
    }

    // func loadMoreModels() { ... }
    // func toggleSize() { changeSize.toggle() } // Example action
}

// MARK: - Placeholder Card View for Gemini Model

struct GeminiCardView: View {
    let model: GeminiModel
    @Binding var isMinimized: Bool // Use for frame/layout adjustments

    var body: some View {
        ZStack {
            // Placeholder Background
            RoundedRectangle(cornerRadius: isMinimized ? 20 : 30)
                .fill(model.placeholderColor) // Use the placeholder color

            // Placeholder Content (e.g., Model Name)
            VStack {
                Spacer() // Pushes content down
                Text(model.name)
                    .font(isMinimized ? .footnote : .headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white) // Ensure contrast with placeholder color
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .padding(.bottom, isMinimized ? 10 : 20) // Adjust padding
                    .lineLimit(2)
                    .minimumScaleFactor(0.8) // Allow text to shrink slightly
                     .shadow(color: .black.opacity(0.3), radius: 3, y: 2) // Add shadow for readability
            }
        }
        // Keep animation internal if layout changes drastically
        // .animation(.bouncy, value: isMinimized) // Animation applied by parent frame change
        // .clipped() // Clipping is handled by the parent's clipShape
    }
}

// MARK: - Main Content View (Using @ObservedObject)

struct ContentView: View {
    // Observe the ViewModel provided by the parent
    @ObservedObject var viewModel: CardStackViewModel

    // State for interaction specific to this view instance, if any.
    // @State private var someLocalState: Bool = false

    // Initializer requires the ViewModel instance
    init(viewModel: CardStackViewModel) {
        self.viewModel = viewModel
        print("ContentView initialized with injected ViewModel")
    }

    var body: some View {
        VStack {
            // Usage instruction block can remain if desired
            VStack(alignment: .leading, spacing: 8) {
                Text("Usage: Swipe Cards Left")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                Text("Data managed by injected ViewModel.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding([.horizontal, .top], 15)
            .padding(.bottom, 15)

            GeometryReader { geometry in
                let size = geometry.size
                let isMinimized = viewModel.changeSize // Use ViewModel's state

                LoopingStack(
                    visibleCardsCount: 3,
                    maxTranslationWidth: isMinimized ? size.width : nil
                ) {
                    // Iterate over Models from the ViewModel
                    ForEach(viewModel.models) { model in
                        GeminiCardView(model: model, isMinimized: $viewModel.changeSize) // Pass binding
                            // Apply frame, clipping, padding, and background *outside*
                            .frame(width: isMinimized ? 150 : 250, height: isMinimized ? 120 : 280) // Adjusted height for placeholder
                            .clipShape(.rect(cornerRadius: isMinimized ? 20 : 30))
                            .padding(5) // Padding creates the border effect
                            .background {
                                RoundedRectangle(cornerRadius: isMinimized ? 25 : 35) // Slightly larger for border
                                    .fill(.background) // Use view's background for border color
                            }
                            // Apply transition/animation specifically for the card appearance/disappearance if needed
                            // .transition(.slide)
                    }
                }
                // Center the stack or align as needed
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            // Take up remaining space
            .frame(maxHeight: .infinity)

            Toggle("Minimise Stack", isOn: $viewModel.changeSize) // Bind Toggle to ViewModel's state
                .padding(15)
                .background(.background, in: .rect(cornerRadius: 15))
                .padding(15)
        }
        // Animate changes triggered by viewModel.changeSize
        .animation(.bouncy, value: viewModel.changeSize)
        .navigationTitle("Gemini Models") // Set title in Parent or here
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.2)) // Background for the whole content area
    }
}

// MARK: - Parent View (Owns and Injects the ViewModel)

struct ParentView: View {
    // Parent owns the ViewModel using @StateObject
    @StateObject private var cardStackViewModel = CardStackViewModel()

    var body: some View {
        NavigationStack {
            // Inject the ViewModel into the ContentView
            ContentView(viewModel: cardStackViewModel)
                .navigationBarTitleDisplayMode(.inline) // Example nav bar style
        }
    }
}

// MARK: - Looping Stack Implementation (Adapted)
// Includes the _LoopingStackContent helper structure for broader compatibility
// if Group(subviews:) is not available/desired.

struct LoopingStack<Content: View>: View {
    var visibleCardsCount: Int = 2
    var maxTranslationWidth: CGFloat?
    @ViewBuilder var content: Content
    @State private var rotation: Int = 0

    var body: some View {
        _LoopingStackContent(
            visibleCardsCount: visibleCardsCount,
            maxTranslationWidth: maxTranslationWidth,
            rotation: $rotation, // Pass the binding
            content: content // Pass the content closure
        )
    }
}
fileprivate struct _LoopingStackContent<Content: View>: View {
    var visibleCardsCount: Int
    var maxTranslationWidth: CGFloat?
    @Binding var rotation: Int
    let content: Content // Accepts the ViewBuilder content directly

    // Helper struct to wrap views and give them IDs for rotation/indexing
    struct ViewWrapper: Identifiable {
        let id: AnyHashable // Use the original model's ID
        let view: AnyView
    }

    @State private var viewWrappers: [ViewWrapper] = []

    var body: some View {
        ZStack {
            // Use the state wrappers for rendering
            let rotatedViews = rotateViews(viewWrappers, by: rotation)

            ForEach(rotatedViews) { viewWrapper in
                 let index = rotatedViews.firstIndex(where: { $0.id == viewWrapper.id }) ?? 0
                 let count = rotatedViews.count
                 let zIndex = Double(count - index)

                LoopingStackCardView(
                    id: viewWrapper.id, // Pass the ID
                    index: index,
                    count: count,
                    visibleCardsCount: visibleCardsCount,
                    maxTranslationWidth: maxTranslationWidth,
                    rotation: $rotation // Pass binding
                ) {
                    viewWrapper.view
                }
                .zIndex(zIndex)
            }
        }
        // Update wrappers only when the view appears
        .onAppear(perform: updateViewWrappers)
        // REMOVED: .onChange(of: content) { ... } // <-- This line caused the error

         // Consider adding onChange for the 'rotation' or other relevant STATE changes if needed
         // .onChange(of: rotation) { newValue in ... } // Example
    }

     // Function to build wrappers from the content closure (still has limitations)
    private func updateViewWrappers() {
        // --- Same logic as before ---
        // This part still relies on assumptions about 'content' structure
        // or needs to be adapted based on how data is passed.
         if let forEachView = content as? ForEach<[GeminiModel], UUID, GeminiCardView> {
             self.viewWrappers = forEachView.data.map { model in
                 // Simplified: Assumes GeminiCardView does NOT need the external binding here
                 ViewWrapper(id: model.id, view: AnyView(forEachView.content(model)))
            }
         } else {
              print("Warning: LoopingStack couldn't automatically extract views. Update logic needed.")
              self.viewWrappers = [] // Fallback
         }
        print("Updated View Wrappers: \(viewWrappers.count)")
    }

    func rotateViews(_ views: [ViewWrapper], by: Int) -> [ViewWrapper] {
         // --- Same logic as before ---
         guard !views.isEmpty else { return [] }
         let count = views.count
         let normalizedRotation = (by % count + count) % count
         guard normalizedRotation >= 0 else { return views }
         return Array(views[normalizedRotation..<count]) + Array(views[0..<normalizedRotation])
   }
}

// Include the rest of your code (Models, ViewModel, CardView, ContentView, ParentView, LoopingStackCardView, etc.)
// ... ensure the GeminiCardView used within updateViewWrappers doesn't require the problematic binding ...
// ... or implement the more robust data-passing approach mentioned above.
//
//fileprivate struct _LoopingStackContent<Content: View>: View {
//    var visibleCardsCount: Int
//    var maxTranslationWidth: CGFloat?
//    @Binding var rotation: Int
//    let content: Content // Accepts the ViewBuilder content directly
//
//    // Helper struct to wrap views and give them IDs for rotation/indexing
//    struct ViewWrapper: Identifiable {
//        let id: AnyHashable // Use the original model's ID
//        let view: AnyView
//    }
//
//    @State private var viewWrappers: [ViewWrapper] = []
//
//    var body: some View {
//        ZStack {
//            // Use the state wrappers for rendering
//            let rotatedViews = rotateViews(viewWrappers, by: rotation)
//
//            ForEach(rotatedViews) { viewWrapper in
//                 let index = rotatedViews.firstIndex(where: { $0.id == viewWrapper.id }) ?? 0
//                 let count = rotatedViews.count
//                 let zIndex = Double(count - index)
//
//                LoopingStackCardView(
//                    id: viewWrapper.id, // Pass the ID
//                    index: index,
//                    count: count,
//                    visibleCardsCount: visibleCardsCount,
//                    maxTranslationWidth: maxTranslationWidth,
//                    rotation: $rotation // Pass binding
//                ) {
//                    viewWrapper.view
//                }
//                .zIndex(zIndex)
//            }
//        }
//        // This approach relies on identifiable data within the ForEach passed as content
//        // It observes the content and tries to build wrappers. Best used with ForEach.
//        .onAppear(perform: updateViewWrappers)
//        .onChange(of: content) { // Requires Content to be Equatable or use a trick
//             // This onChange might not work reliably depending on how Content is structured.
//             // A direct `Group(subviews:)` approach (iOS 18+) is more robust.
//             // Or pass the data array directly to LoopingStack.
//             // updateViewWrappers()
//             print("Warning: LoopingStack content changed, manual update might be needed if not using ForEach data directly.")
//        }
//         // A more reliable approach if Content IS a ForEach might be to extract the data source
//         // inside LoopingStack, but that breaks the generic @ViewBuilder pattern slightly.
//    }
//
//    // Function to build wrappers from the content closure
//    // This is complex and works best if Content IS specifically a ForEach
//    private func updateViewWrappers() {
//        // This is a simplified example assuming content is ForEach<[Identifiable], ID, View>
//        // In reality, parsing generic @ViewBuilder content is non-trivial without specific APIs.
//        // For THIS specific case with ForEach(viewModel.models), we can potentially inject the models.
//        // Let's assume for now 'content' directly renders the views we need.
//        // A cleaner way: Pass the DATA to LoopingStack, not just the @ViewBuilder content.
//
//        // === Workaround: Rebuild based on known data source (less generic) ===
//        // This breaks the pure @ViewBuilder concept slightly but is pragmatic if Group(subviews:) isn't used.
//        // It requires knowing the Content structure or data source.
//        if let forEachView = content as? ForEach<[GeminiModel], UUID, GeminiCardView> {
//             self.viewWrappers = forEachView.data.map { model in
//                 // We need the BINDING to isMinimized here... this is tricky.
//                 // This simulation won't have the live binding from the parent.
//                 // Solution: The CardView itself should *not* take the binding,
//                 // or LoopingStack needs access to the parent's state.
//                 // --> Let's simplify GeminiCardView to NOT depend on external binding for this example.
//                  ViewWrapper(id: model.id, view: AnyView(forEachView.content(model)))
//            }
//         } else {
//              print("Warning: LoopingStack couldn't automatically extract views. Update logic needed.")
//              // Attempt basic extraction (highly experimental)
//              // let views = Mirror(reflecting: content).children.compactMap { $0.value as? View }
//              // self.viewWrappers = views.map { ViewWrapper(id: UUID(), view: AnyView($0)) } // Problem: No stable IDs
//              self.viewWrappers = [] // Fallback
//         }
//
//        print("Updated View Wrappers: \(viewWrappers.count)")
//
//    }
//
//    func rotateViews(_ views: [ViewWrapper], by: Int) -> [ViewWrapper] {
//       guard !views.isEmpty else { return [] }
//       let count = views.count
//       // Ensure rotation index is always positive and within bounds
//       let normalizedRotation = (by % count + count) % count
//       guard normalizedRotation >= 0 else { return views } // Should not happen with modulo arithmetic
//       return Array(views[normalizedRotation..<count]) + Array(views[0..<normalizedRotation])
//   }
//
//}

// MARK: - Looping Stack Card View (Interaction Logic)

fileprivate struct LoopingStackCardView<Content: View>: View {
    // Use AnyHashable for ID flexibility
    var id: AnyHashable
    var index: Int
    var count: Int
    var visibleCardsCount: Int
    var maxTranslationWidth: CGFloat?
    @Binding var rotation: Int
    @ViewBuilder var content: Content

    /// Interaction Properties
    @State private var offset: CGFloat = .zero
    @State private var viewSize: CGSize = .zero

    var body: some View {
        let extraOffset = min(CGFloat(index) * 20, CGFloat(visibleCardsCount) * 20)
        let scale = 1 - min(CGFloat(index) * 0.07, CGFloat(visibleCardsCount) * 0.07)
        let rotationDegree: CGFloat = -30
        let rotation3D = max(min(-offset / max(viewSize.width, 1), 1), 0) * rotationDegree // Avoid division by zero

        content
            .frame(width: viewSize == .zero ? nil : viewSize.width, height: viewSize == .zero ? nil : viewSize.height) // Apply measured size
            .background( GeometryReader { proxy in // Use background for geometry reading
                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            })
            .onPreferenceChange(SizePreferenceKey.self) { size in
                 viewSize = size // Update viewSize based on preference key
            }
            .offset(x: extraOffset)
            .scaleEffect(scale, anchor: .trailing)
            .offset(x: offset) // Apply drag offset
            .rotation3DEffect(.init(degrees: rotation3D), axis: (x: 0, y: 1, z: 0), anchor: .center, perspective: 0.5)
            .animation(.smooth(duration: 0.25, extraBounce: 0), value: index) // Animate index-based effects
            .animation(.smooth(duration: 0.3, extraBounce: 0), value: offset) // Animate offset changes
            .gesture(
                DragGesture(minimumDistance: 10) // Require some movement to start drag
                    .onChanged(handleDragChange)
                    .onEnded(handleDragEnd),
                /// Only Activating Gesture for the top most card
                isEnabled: index == 0 && count > 1
            )
            .id(id) // Ensure the card view itself is identifiable
    }

    // Extracted gesture handlers for clarity
    private func handleDragChange(_ value: DragGesture.Value) {
         guard index == 0 else { return }
         let xOffset = -max(-value.translation.width, 0) // Only allow leftward drag accumulate

         if let maxTranslationWidth, maxTranslationWidth > 0, viewSize.width > 0 {
            // Calculate progress based on defined max translation width
             let progress = -max(min(-xOffset / maxTranslationWidth, 1), 0)
             offset = progress * viewSize.width // Apply offset based on progress and view width
         } else {
            // If no max width, apply direct offset
             offset = xOffset
         }
    }

    private func handleDragEnd(_ value: DragGesture.Value) {
        guard index == 0 else { return }
        // Use projected velocity for a more natural feel
        let projectedEndTranslation = value.predictedEndTranslation.width
        let currentTranslation = value.translation.width
        let combinedDrag = currentTranslation + (projectedEndTranslation - currentTranslation) * 0.5 // Factor in some velocity

        let safeViewWidth = max(viewSize.width, 1) // Avoid division by zero

        // Determine if swipe is significant enough to push card
        // Threshold: Moved more than 65% of the width OR a fast swipe left
        let isSignificantSwipe = (-offset > safeViewWidth * 0.65) || (value.velocity.width < -300) // Fast swipe velocity threshold

        if isSignificantSwipe {
            pushToNextCard()
        } else {
           // Resetting offset uses the .animation modifier
            offset = .zero
        }
    }

    private func pushToNextCard() {
        let safeViewWidth = max(viewSize.width, 1)
        let pushAmount = -safeViewWidth * 1.2 // Push significantly off-screen

        // Use a slightly longer animation for the push-off
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            offset = pushAmount
        }

        // Update rotation after a delay to let animation start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            rotation = (rotation + 1) // Increment rotation
            // Reset offset after rotation ensures the card is ready for its new position if it cycles back
            // The card that *was* at index 0 will get a new index, and its offset will be recalculated
            // based on the extraOffset/scale effects in its next render pass.
            // Explicitly resetting might interfere if not timed perfectly.
             // Let the standard update cycle handle the reset based on new index.
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                  if index != 0 { // Only reset if it's no longer the top card
                    offset = .zero
                 }
              }
        }
    }
}

// MARK: - Preference Key for Geometry Reading

fileprivate struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        // Use the last reported non-zero size
        let next = nextValue()
        if next != .zero {
             value = next
        }
    }
}

// MARK: - Preview

#Preview {
    // Preview the ParentView, which creates and injects the ViewModel
    ParentView()
}
