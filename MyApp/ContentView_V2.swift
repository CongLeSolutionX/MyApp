//
//  ContentView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//
//
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
//
//let geminiModelsData: [GeminiModel] = [
//    GeminiModel(
//        name: "Gemini 2.5 Pro Experimental", imageName: nil,
//        identifier: "gemini-2.5-pro-exp-03-25",
//        inputs: "Audio, images, videos, and text",
//        outputs: "Text",
//        optimizedFor: "Enhanced thinking and reasoning, multimodal understanding, advanced coding, and more"
//    ),
////    GeminiModel(
////        name: "Gemini 2.0 Flash", identifier: nil,
////        inputs: "gemini-2.0-flash",
////        outputs: "Audio, images, videos, and text",
////        optimizedFor: "Text, images (experimental), and audio (coming soon)",
////        imageName: "Next generation features, speed, thinking, realtime streaming, and multimodal generation"
////    ),
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
//    @Published var models: [GeminiModel] = geminiModelsData
//    @Published var changeSize = false
//
//    init() {
//        print("CardStackViewModel Initialized with \(models.count) models.")
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
//            VStack {
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
//// MARK: - Looping Stack Implementation (Generic)
//struct LoopingStack<DataModel: Identifiable & Equatable, CardContent: View>: View {
//    var data: [DataModel]
//    var visibleCardsCount = 3
//    var maxTranslationWidth: CGFloat?
//    @ViewBuilder var cardContent: (DataModel) -> CardContent
//
//    @State private var rotation = 0
//
//    var body: some View {
//        let rotatedData = rotateDataSource(data, by: rotation)
//        ZStack {
//            ForEach(rotatedData) { item in
//                let index = rotatedData.firstIndex(where: { $0.id == item.id }) ?? 0
//                let zIndex = Double(data.count - index)
//                LoopingStackCardView(
//                    id: item.id,
//                    index: index,
//                    count: data.count,
//                    visibleCardsCount: visibleCardsCount,
//                    maxTranslationWidth: maxTranslationWidth,
//                    rotation: $rotation
//                ) {
//                    cardContent(item)
//                }
//                .zIndex(zIndex)
//            }
//        }
//        .onChange(of: data) { newData, oldData in
//            if newData != oldData { rotation = 0 }
//        }
//        .onAppear {
//            print("LoopingStack appeared with \(data.count) items.")
//        }
//    }
//    
//    private func rotateDataSource(_ source: [DataModel], by rotation: Int) -> [DataModel] {
//        guard !source.isEmpty else { return [] }
//        let count = source.count
//        let normalized = (rotation % count + count) % count
//        return Array(source[normalized..<count]) + Array(source[0..<normalized])
//    }
//}
//
//// MARK: - LoopingStackCardView (Handles Gestures & Animations)
//fileprivate struct LoopingStackCardView<Content: View>: View {
//    var id: AnyHashable
//    var index, count, visibleCardsCount: Int
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
//            .frame(width: viewSize == .zero ? nil : viewSize.width,
//                   height: viewSize == .zero ? nil : viewSize.height)
//            .background(GeometryReader { proxy in
//                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
//            })
//            .onPreferenceChange(SizePreferenceKey.self) { size in
//                viewSize = size
//            }
//            .offset(x: extraOffset)
//            .scaleEffect(scale, anchor: .trailing)
//            .offset(x: offset)
//            .rotation3DEffect(.init(degrees: rotation3D),
//                              axis: (x: 0, y: 1, z: 0),
//                              anchor: .center,
//                              perspective: 0.5)
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
//    private func handleDragChange(_ value: DragGesture.Value) {
//        guard index == 0 else { return }
//        let xOffset = -max(-value.translation.width, 0)
//        if let maxWidth = maxTranslationWidth, maxWidth > 0, viewSize.width > 0 {
//            let progress = -max(min(-xOffset / maxWidth, 1), 0)
//            offset = progress * viewSize.width
//        } else {
//            offset = xOffset
//        }
//    }
//
//    private func handleDragEnd(_ value: DragGesture.Value) {
//        guard index == 0 else { return }
//        let projectedEnd = value.predictedEndTranslation.width
//        let combinedDrag = value.translation.width + (projectedEnd - value.translation.width) * 0.5
//        let isSwap = (-offset > max(viewSize.width, 1) * 0.65) || (value.velocity.width < -300)
//        if isSwap {
//            pushToNextCard()
//        } else {
//            offset = .zero
//        }
//    }
//
//    private func pushToNextCard() {
//        let safeWidth = max(viewSize.width, 1)
//        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
//            offset = -safeWidth * 1.2
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//            rotation = (rotation + 1)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                if index != 0 { offset = .zero }
//            }
//        }
//    }
//}
//
//// MARK: - Preference Key for Geometry Reading
//fileprivate struct SizePreferenceKey: PreferenceKey {
//    static var defaultValue: CGSize = .zero
//    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
//        let next = nextValue()
//        if next != .zero { value = next }
//    }
//}
//
//// MARK: - Main Content View
//struct ContentView: View {
//    @ObservedObject var viewModel: CardStackViewModel
//
//    var body: some View {
//        VStack {
//            // Usage Instructions
//            VStack(alignment: .leading, spacing: 8) {
//                /* ... Instructions content ... */
//            }
//            .padding([.horizontal, .top], 15)
//            .padding(.bottom, 15)
//
//            GeometryReader { geometry in
//                let isMinimized = viewModel.changeSize
//                LoopingStack(
//                    data: viewModel.models,
//                    visibleCardsCount: 3,
//                    maxTranslationWidth: isMinimized ? geometry.size.width : nil
//                ) { model in
//                    GeminiCardView(model: model, isMinimized: $viewModel.changeSize)
//                        .frame(width: isMinimized ? 150 : 250,
//                               height: isMinimized ? 120 : 280)
//                        .clipShape(RoundedRectangle(cornerRadius: isMinimized ? 20 : 30))
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
//            Toggle("Minimise Stack", isOn: $viewModel.changeSize)
//                .padding(15)
//        }
//        .animation(.bouncy, value: viewModel.changeSize)
//        .navigationTitle("Gemini Models")
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(.gray.opacity(0.2))
//    }
//}
//
//// MARK: - Parent View
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
//#Preview {
//    ParentView()
//}
import SwiftUI

// MARK: - Data Models (Unchanged)
struct GeminiModel: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let imageName: String?
    let identifier: String
    let inputs: String
    let outputs: String
    let optimizedFor: String
    var placeholderColor: Color {
        let hash = name.hashValue
        let hue = Double(abs(hash % 360)) / 360.0
        return Color(hue: hue, saturation: 0.7, brightness: 0.8)
    }
}

let geminiModelsData: [GeminiModel] = [
    GeminiModel(
        name: "Gemini 2.5 Pro Experimental", imageName: nil,
        identifier: "gemini-2.5-pro-exp-03-25",
        inputs: "Audio, images, videos, and text",
        outputs: "Text",
        optimizedFor: "Enhanced thinking and reasoning, multimodal understanding, advanced coding, and more"
    ),
//    GeminiModel(
//        name: "Gemini 2.0 Flash", identifier: nil,
//        inputs: "gemini-2.0-flash",
//        outputs: "Audio, images, videos, and text",
//        optimizedFor: "Text, images (experimental), and audio (coming soon)",
//        imageName: "Next generation features, speed, thinking, realtime streaming, and multimodal generation"
//    ),
    GeminiModel(
        name: "Gemini 2.0 Flash-Lite", imageName: "My-meme-original",
        identifier: "gemini-2.0-flash-lite",
        inputs: "Audio, images, videos, and text",
        outputs: "Text",
        optimizedFor: "Cost efficiency and low latency"
    ),
    GeminiModel(
        name: "Gemini 1.5 Flash", imageName: nil,
        identifier: "gemini-1.5-flash",
        inputs: "Audio, images, videos, and text",
        outputs: "Text",
        optimizedFor: "Fast and versatile performance across a diverse variety of tasks"
    ),
    GeminiModel(
        name: "Gemini 1.5 Flash-8B", imageName: nil,
        identifier: "gemini-1.5-flash-8b",
        inputs: "Audio, images, videos, and text",
        outputs: "Text",
        optimizedFor: "High volume and lower intelligence tasks"
    ),
    GeminiModel(
        name: "Gemini 1.5 Pro", imageName: nil,
        identifier: "gemini-1.5-pro",
        inputs: "Audio, images, videos, and text",
        outputs: "Text",
        optimizedFor: "Complex reasoning tasks requiring more intelligence"
    ),
    GeminiModel(
        name: "Gemini Embedding", imageName: nil,
        identifier: "gemini-embedding-exp",
        inputs: "Text",
        outputs: "Text embeddings",
        optimizedFor: "Measuring the relatedness of text strings"
    ),
    GeminiModel(
        name: "Imagen 3", imageName: nil,
        identifier: "imagen-3.0-generate-002",
        inputs: "Text",
        outputs: "Images",
        optimizedFor: "Our most advanced image generation model"
    )
]
// MARK: - View Model (Unchanged)
@MainActor
class CardStackViewModel: ObservableObject {
    @Published var models: [GeminiModel] = geminiModelsData
    @Published var changeSize = false

    init() {
        print("CardStackViewModel Initialized with \(models.count) models.")
    }
}

// MARK: - Updated GeminiCardView with Local & Remote Image Handling
struct GeminiCardView: View {
    let model: GeminiModel
    @Binding var isMinimized: Bool

    var body: some View {
        ZStack {
            // Background color as fallback
            RoundedRectangle(cornerRadius: isMinimized ? 20 : 30)
                .fill(model.placeholderColor)
            
            VStack {
                // Image handling: if available, display image (remote or local)
                if let imageName = model.imageName {
                    imageView(for: imageName)
                        .clipShape(RoundedRectangle(cornerRadius: isMinimized ? 20 : 30))
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .padding(.bottom, 5)
                }
                
                Spacer()
                Text(model.name)
                    .font(isMinimized ? .footnote : .headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .padding(.bottom, isMinimized ? 10 : 20)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
            }
        }
    }
    
    @ViewBuilder
    private func imageView(for imageName: String) -> some View {
        // Check whether the imageName is a valid URL with "http/https" scheme:
        if let url = URL(string: imageName),
           let scheme = url.scheme,
           scheme.lowercased() == "http" || scheme.lowercased() == "https" {
            // Remote image using AsyncImage
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView() // Show a progress indicator while loading
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white.opacity(0.7))
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            // Assume it's a local asset image
            Image(imageName)
                .resizable()
                .scaledToFill()
        }
    }
}

// MARK: - Looping Stack Implementation (Generic)
struct LoopingStack<DataModel: Identifiable & Equatable, CardContent: View>: View {
    var data: [DataModel]
    var visibleCardsCount = 3
    var maxTranslationWidth: CGFloat?
    @ViewBuilder var cardContent: (DataModel) -> CardContent

    @State private var rotation = 0

    var body: some View {
        let rotatedData = rotateDataSource(data, by: rotation)
        ZStack {
            ForEach(rotatedData) { item in
                let index = rotatedData.firstIndex(where: { $0.id == item.id }) ?? 0
                let zIndex = Double(data.count - index)
                LoopingStackCardView(
                    id: item.id,
                    index: index,
                    count: data.count,
                    visibleCardsCount: visibleCardsCount,
                    maxTranslationWidth: maxTranslationWidth,
                    rotation: $rotation
                ) {
                    cardContent(item)
                }
                .zIndex(zIndex)
            }
        }
        .onChange(of: data) { newData, oldData in
            if newData != oldData { rotation = 0 }
        }
        .onAppear {
            print("LoopingStack appeared with \(data.count) items.")
        }
    }
    
    private func rotateDataSource(_ source: [DataModel], by rotation: Int) -> [DataModel] {
        guard !source.isEmpty else { return [] }
        let count = source.count
        let normalized = (rotation % count + count) % count
        return Array(source[normalized..<count]) + Array(source[0..<normalized])
    }
}

// MARK: - LoopingStackCardView (Handles Gestures & Animations)
fileprivate struct LoopingStackCardView<Content: View>: View {
    var id: AnyHashable
    var index, count, visibleCardsCount: Int
    var maxTranslationWidth: CGFloat?
    @Binding var rotation: Int
    @ViewBuilder var content: Content

    @State private var offset: CGFloat = .zero
    @State private var viewSize: CGSize = .zero

    var body: some View {
        let extraOffset = min(CGFloat(index) * 20, CGFloat(visibleCardsCount) * 20)
        let scale = 1 - min(CGFloat(index) * 0.07, CGFloat(visibleCardsCount) * 0.07)
        let rotationDegree: CGFloat = -30
        let rotation3D = max(min(-offset / max(viewSize.width, 1), 1), 0) * rotationDegree

        content
            .frame(width: viewSize == .zero ? nil : viewSize.width,
                   height: viewSize == .zero ? nil : viewSize.height)
            .background(GeometryReader { proxy in
                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            })
            .onPreferenceChange(SizePreferenceKey.self) { size in
                viewSize = size
            }
            .offset(x: extraOffset)
            .scaleEffect(scale, anchor: .trailing)
            .offset(x: offset)
            .rotation3DEffect(.init(degrees: rotation3D),
                              axis: (x: 0, y: 1, z: 0),
                              anchor: .center,
                              perspective: 0.5)
            .animation(.smooth(duration: 0.25, extraBounce: 0), value: index)
            .animation(.smooth(duration: 0.3, extraBounce: 0), value: offset)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged(handleDragChange)
                    .onEnded(handleDragEnd),
                isEnabled: index == 0 && count > 1
            )
            .id(id)
    }

    private func handleDragChange(_ value: DragGesture.Value) {
        guard index == 0 else { return }
        let xOffset = -max(-value.translation.width, 0)
        if let maxWidth = maxTranslationWidth, maxWidth > 0, viewSize.width > 0 {
            let progress = -max(min(-xOffset / maxWidth, 1), 0)
            offset = progress * viewSize.width
        } else {
            offset = xOffset
        }
    }

    private func handleDragEnd(_ value: DragGesture.Value) {
        guard index == 0 else { return }
        let projectedEnd = value.predictedEndTranslation.width
        let isSwap = (-offset > max(viewSize.width, 1) * 0.65) || (value.velocity.width < -300)
        if isSwap {
            pushToNextCard()
        } else {
            offset = .zero
        }
    }

    private func pushToNextCard() {
        let safeWidth = max(viewSize.width, 1)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            offset = -safeWidth * 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            rotation = (rotation + 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if index != 0 { offset = .zero }
            }
        }
    }
}

// MARK: - Preference Key for Geometry Reading
fileprivate struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next = nextValue()
        if next != .zero { value = next }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @ObservedObject var viewModel: CardStackViewModel

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                // Usage instructions or any additional information…
            }
            .padding([.horizontal, .top], 15)
            .padding(.bottom, 15)

            GeometryReader { geometry in
                let isMinimized = viewModel.changeSize
                LoopingStack(
                    data: viewModel.models,
                    visibleCardsCount: 3,
                    maxTranslationWidth: isMinimized ? geometry.size.width : nil
                ) { model in
                    GeminiCardView(model: model, isMinimized: $viewModel.changeSize)
                        .frame(width: isMinimized ? 150 : 250,
                               height: isMinimized ? 120 : 280)
                        .clipShape(RoundedRectangle(cornerRadius: isMinimized ? 20 : 30))
                        .padding(5)
                        .background {
                            RoundedRectangle(cornerRadius: isMinimized ? 25 : 35)
                                .fill(.background)
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(maxHeight: .infinity)

            Toggle("Minimise Stack", isOn: $viewModel.changeSize)
                .padding(15)
        }
        .animation(.bouncy, value: viewModel.changeSize)
        .navigationTitle("Gemini Models")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.2))
    }
}

// MARK: - Parent View
struct ParentView: View {
    @StateObject private var cardStackViewModel = CardStackViewModel()
    var body: some View {
        NavigationStack {
            ContentView(viewModel: cardStackViewModel)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ParentView()
}

#Preview("Preview CongLeSolutionX Experimental Model") {
    let geminiModel = GeminiModel(
        name: "CongLeSolutionX Experimental",
        imageName: "My-meme-original",
        identifier: "gemini-2.5-pro-exp-03-25",
        inputs: "Audio, images, videos, and text",
        outputs: "Text",
        optimizedFor: "Enhanced thinking and reasoning, multimodal understanding, advanced coding, and more"
    )

    GeminiCardView(model: geminiModel, isMinimized: .constant(false))
}

