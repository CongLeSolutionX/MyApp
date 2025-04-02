////
////  ContentView.swift
////  MyApp
////
////  Created by Cong Le on 8/19/24.
////
////
////import SwiftUI
////
////// Step 2: Use in SwiftUI view
////struct ContentView: View {
////    var body: some View {
////        UIKitViewControllerWrapper()
////            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
////    }
////}
////
////// Before iOS 17, use this syntax for preview UIKit view controller
////struct UIKitViewControllerWrapper_Previews: PreviewProvider {
////    static var previews: some View {
////        UIKitViewControllerWrapper()
////    }
////}
////
////// After iOS 17, we can use this syntax for preview:
////#Preview {
////    ContentView()
////}
//import SwiftUI
//
//// MARK: - Data Models (Unchanged)
//struct GeminiModel: Identifiable, Equatable {
//    let id = UUID()
//    let name: String
//    let imageName: String?
//    let identifier: String
//    let inputs: String
//    let outputs: String
//    let optimizedFor: String
//    var placeholderColor: Color {
//        let hash = name.hashValue
//        let hue = Double(abs(hash % 360)) / 360.0
//        return Color(hue: hue, saturation: 0.7, brightness: 0.8)
//    }
//}
//let geminiModelsData: [GeminiModel] = [
//    GeminiModel(
//        name: "Gemini 2.5 Pro Experimental", imageName: nil,
//        identifier: "gemini-2.5-pro-exp-03-25",
//        inputs: "Audio, images, videos, and text",
//        outputs: "Text",
//        optimizedFor: "Enhanced thinking and reasoning, multimodal understanding, advanced coding, and more"
//    ),
//    GeminiModel(
//        name: "Gemini 2.0 Flash", imageName: nil,
//        identifier: "gemini-2.0-flash",
//        inputs: "Audio, images, videos, and text",
//        outputs: "Text, images (experimental), and audio (coming soon)",
//        optimizedFor: "Next generation features, speed, thinking, realtime streaming, and multimodal generation"
//    ),
//    GeminiModel(
//        name: "Gemini 2.0 Flash-Lite", imageName: nil,
//        identifier: "gemini-2.0-flash-lite",
//        inputs: "Audio, images, videos, and text",
//        outputs: "Text",
//        optimizedFor: "Cost efficiency and low latency"
//    ),
//    GeminiModel(
//        name: "Gemini 1.5 Flash", imageName: nil,
//        identifier: "gemini-1.5-flash",
//        inputs: "Audio, images, videos, and text",
//        outputs: "Text",
//        optimizedFor: "Fast and versatile performance across a diverse variety of tasks"
//    ),
//    GeminiModel(
//        name: "Gemini 1.5 Flash-8B", imageName: nil,
//        identifier: "gemini-1.5-flash-8b",
//        inputs: "Audio, images, videos, and text",
//        outputs: "Text",
//        optimizedFor: "High volume and lower intelligence tasks"
//    ),
//    GeminiModel(
//        name: "Gemini 1.5 Pro", imageName: nil,
//        identifier: "gemini-1.5-pro",
//        inputs: "Audio, images, videos, and text",
//        outputs: "Text",
//        optimizedFor: "Complex reasoning tasks requiring more intelligence"
//    ),
//    GeminiModel(
//        name: "Gemini Embedding", imageName: nil,
//        identifier: "gemini-embedding-exp",
//        inputs: "Text",
//        outputs: "Text embeddings",
//        optimizedFor: "Measuring the relatedness of text strings"
//    ),
//    GeminiModel(
//        name: "Imagen 3", imageName: nil,
//        identifier: "imagen-3.0-generate-002",
//        inputs: "Text",
//        outputs: "Images",
//        optimizedFor: "Our most advanced image generation model"
//    )
//]
//// MARK: - View Model (Unchanged)
//@MainActor
//class CardStackViewModel: ObservableObject {
//    @Published var models: [GeminiModel] = [] // Initialize empty temporarily? NO - Use initial value.
//    @Published var changeSize: Bool = false
//
//    init(initialModels: [GeminiModel] = geminiModelsData) { // Default parameter uses the data
//        print("CardStackViewModel Initialized on Main Actor")
//        self.models = initialModels // Assign data SYNCHRONOUSLY
//        print("ViewModel Init: Assigned \(self.models.count) models.") // Add confirmation log
//    }
//}
//
//// MARK: - Placeholder Card View (Unchanged)
//struct GeminiCardView: View {
//    let model: GeminiModel
//    @Binding var isMinimized: Bool
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: isMinimized ? 20 : 30)
//                .fill(model.placeholderColor)
//            VStack { /* ... Placeholder content ... */
//                Spacer()
//                Text(model.name)
//                    .font(isMinimized ? .footnote : .headline)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 10)
//                    .padding(.bottom, isMinimized ? 10 : 20)
//                    .lineLimit(2)
//                    .minimumScaleFactor(0.8)
//                    .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
//            }
//        }
//    }
//}
//
//#Preview("Preview CongLeSolutionX Experimental Model") {
//    let geminiModel = GeminiModel(
//        name: "CongLeSolutionX Experimental",
//        imageName: nil,
//        identifier: "gemini-2.5-pro-exp-03-25",
//        inputs: "Audio, images, videos, and text",
//        outputs: "Text",
//        optimizedFor: "Enhanced thinking and reasoning, multimodal understanding, advanced coding, and more"
//    )
//    
//    GeminiCardView(model: geminiModel, isMinimized: .constant(false))
//}
//
//// MARK: - Looping Stack Implementation (REVISED)
//
//// Now generic over DataModel and CardContent view
//struct LoopingStack<DataModel: Identifiable & Equatable, CardContent: View>: View {
//    // Input Properties
//    var data: [DataModel] // Accept data directly
//    var visibleCardsCount: Int = 3
//    var maxTranslationWidth: CGFloat?
//    // Closure to build the card view for each data item
//    @ViewBuilder var cardContent: (DataModel) -> CardContent
//
//    // Internal State
//    @State private var rotation: Int = 0
//
//    var body: some View {
//        // Rotate the actual data array for display order
//        let rotatedData = rotateDataSource(data, by: rotation)
//
//        ZStack {
//            // Iterate directly over the rotated data
//            ForEach(rotatedData) { item in
//                // Find the current display index after rotation
//                let index = rotatedData.firstIndex(where: { $0.id == item.id }) ?? 0
//                let count = data.count // Use original data count for total
//                let zIndex = Double(count - index)
//
//                // Use the existing LoopingStackCardView for interaction/layout
//                LoopingStackCardView(
//                    id: item.id, // Pass the item's ID
//                    index: index,
//                    count: count,
//                    visibleCardsCount: visibleCardsCount,
//                    maxTranslationWidth: maxTranslationWidth,
//                    rotation: $rotation // Pass binding for rotation updates
//                ) {
//                    // Build the actual card content using the provided closure
//                    cardContent(item)
//                }
//                .zIndex(zIndex) // Apply zIndex for stacking order
//            }
//        }
//        // Now .onChange can reliably observe the data array
//        .onChange(of: data) { newData, oldData in // Use new iOS 17+ onChange signature
//             print("LoopingStack data changed. Count: \(newData.count)")
//             // Decide how to handle data changes. Resetting rotation is common.
//             if newData.count != oldData.count || newData != oldData {
//                // Reset rotation if data fundamentally changes
//                 rotation = 0
//             }
//        }
//        .onAppear {
//             // Ensure initial state is correct if needed
//             print("LoopingStack appeared with \(data.count) items.")
//         }
//    }
//
//    // Helper function to rotate the actual data source array
//    private func rotateDataSource(_ source: [DataModel], by: Int) -> [DataModel] {
//       guard !source.isEmpty else { return [] }
//       let count = source.count
//       // Ensure rotation index is always positive and within bounds
//       let normalizedRotation = (by % count + count) % count
//       guard normalizedRotation >= 0 else { return source } // Should not happen
//       // Perform array rotation
//       return Array(source[normalizedRotation..<count]) + Array(source[0..<normalizedRotation])
//   }
//}
//
//// MARK: - Looping Stack Card View (Interaction Logic - Unchanged)
//// This view remains the same as it handles the individual card's geometry,
//// offset, scale, rotation, and drag gestures.
//
//fileprivate struct LoopingStackCardView<Content: View>: View {
//    var id: AnyHashable
//    var index: Int
//    var count: Int
//    var visibleCardsCount: Int
//    var maxTranslationWidth: CGFloat?
//    @Binding var rotation: Int
//    @ViewBuilder var content: Content
//
//    @State private var offset: CGFloat = .zero
//    @State private var viewSize: CGSize = .zero
//
//    var body: some View {
//        let extraOffset = min(CGFloat(index) * 20, CGFloat(visibleCardsCount) * 20)
//        let scale = 1 - min(CGFloat(index) * 0.07, CGFloat(visibleCardsCount) * 0.07)
//        let rotationDegree: CGFloat = -30
//        let rotation3D = max(min(-offset / max(viewSize.width, 1), 1), 0) * rotationDegree
//
//        content
//            .frame(width: viewSize == .zero ? nil : viewSize.width, height: viewSize == .zero ? nil : viewSize.height)
//            .background( GeometryReader { proxy in
//                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
//            })
//            .onPreferenceChange(SizePreferenceKey.self) { size in
//                 viewSize = size
//            }
//            .offset(x: extraOffset)
//            .scaleEffect(scale, anchor: .trailing)
//            .offset(x: offset)
//            .rotation3DEffect(.init(degrees: rotation3D), axis: (x: 0, y: 1, z: 0), anchor: .center, perspective: 0.5)
//            .animation(.smooth(duration: 0.25, extraBounce: 0), value: index)
//            .animation(.smooth(duration: 0.3, extraBounce: 0), value: offset)
//            .gesture(
//                DragGesture(minimumDistance: 10)
//                    .onChanged(handleDragChange)
//                    .onEnded(handleDragEnd),
//                isEnabled: index == 0 && count > 1
//            )
//            .id(id)
//    }
//
//    private func handleDragChange(_ value: DragGesture.Value) { /* ... Same logic ... */
//        guard index == 0 else { return }
//        let xOffset = -max(-value.translation.width, 0)
//        if let maxTranslationWidth, maxTranslationWidth > 0, viewSize.width > 0 {
//           let progress = -max(min(-xOffset / maxTranslationWidth, 1), 0)
//           offset = progress * viewSize.width
//        } else {
//           offset = xOffset
//        }
//    }
//    private func handleDragEnd(_ value: DragGesture.Value) { /* ... Same logic ... */
//        guard index == 0 else { return }
//        let projectedEndTranslation = value.predictedEndTranslation.width
//        let currentTranslation = value.translation.width
//        let combinedDrag = currentTranslation + (projectedEndTranslation - currentTranslation) * 0.5
//        let safeViewWidth = max(viewSize.width, 1)
//        let isSignificantSwipe = (-offset > safeViewWidth * 0.65) || (value.velocity.width < -300)
//
//        if isSignificantSwipe {
//           pushToNextCard()
//        } else {
//           offset = .zero
//        }
//    }
//    private func pushToNextCard() { /* ... Same logic ... */
//        let safeViewWidth = max(viewSize.width, 1)
//        let pushAmount = -safeViewWidth * 1.2
//        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
//           offset = pushAmount
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//           rotation = (rotation + 1)
//             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                if index != 0 { offset = .zero }
//             }
//        }
//    }
//}
//
//// MARK: - Preference Key for Geometry Reading (Unchanged)
//fileprivate struct SizePreferenceKey: PreferenceKey { /* ... Same ... */
//    static var defaultValue: CGSize = .zero
//    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
//        let next = nextValue()
//        if next != .zero { value = next }
//    }
//}
//
//// MARK: - Main Content View (REVISED Call Site)
//
//struct ContentView: View {
//    @ObservedObject var viewModel: CardStackViewModel
//
//    init(viewModel: CardStackViewModel) {
//        self.viewModel = viewModel
//    }
//
//    var body: some View {
//        VStack {
//            // Usage Instruction Block (Unchanged)
//            VStack(alignment: .leading, spacing: 8) { /* ... */ }
//                .padding([.horizontal, .top], 15)
//                .padding(.bottom, 15)
//
//            GeometryReader { geometry in
//                let size = geometry.size
//                let isMinimized = viewModel.changeSize
//
//                // REVISED: Call the redesigned LoopingStack
//                LoopingStack(
//                    data: viewModel.models, // Pass the data array
//                    visibleCardsCount: 3,   // Pass parameters
//                    maxTranslationWidth: isMinimized ? size.width : nil
//                ) { model in
//                    // Provide the closure to build each card
//                    GeminiCardView(model: model, isMinimized: $viewModel.changeSize)
//                        .frame(width: isMinimized ? 150 : 250, height: isMinimized ? 120 : 280)
//                        .clipShape(.rect(cornerRadius: isMinimized ? 20 : 30))
//                        .padding(5)
//                        .background {
//                            RoundedRectangle(cornerRadius: isMinimized ? 25 : 35)
//                                .fill(.background)
//                        }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//            }
//            .frame(maxHeight: .infinity)
//
//            // Toggle (Unchanged)
//            Toggle("Minimise Stack", isOn: $viewModel.changeSize)
//                .padding(15) /* ... */
//
//        }
//        .animation(.bouncy, value: viewModel.changeSize)
//        .navigationTitle("Gemini Models")
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(.gray.opacity(0.2))
//    }
//}
//
//// MARK: - Parent View (Owns and Injects ViewModel - Unchanged)
//struct ParentView: View {
//    @StateObject private var cardStackViewModel = CardStackViewModel()
//    var body: some View {
//        NavigationStack {
//            ContentView(viewModel: cardStackViewModel)
//                .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//
//// MARK: - Preview (Unchanged)
//#Preview {
//    ParentView()
//}
