//
//  HomeView.swift
//  MyApp
//
//  Created by Cong Le on 1/19/25.
//


import SwiftUI

struct HomeView: View {
    /// View Properties
    @State private var items: [Item] = []
    @State private var isSelectionEnabled: Bool = false
    @State private var panGesture: UIPanGestureRecognizer?
    @State private var properties: SelectionProperties = .init()
    @State private var scrollProperties: ScrollProperties = .init()
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 20) {
                Text("Grid View")
                    .font(.title.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .trailing) {
                        Button {
                            isSelectionEnabled.toggle()
                            
                            if !isSelectionEnabled {
                                properties = .init()
                            }
                        } label: {
                            Text(isSelectionEnabled ? "Cancel" : "Select")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .foregroundStyle(Color.primary)
                                .background(Color.primary.opacity(0.1), in: .capsule)
                                .contentShape(.capsule)
                        }
                    }
                
                LazyVGrid(columns: Array(repeating: GridItem(), count: 4)) {
                    ForEach($items) { $item in
                        ItemCardView($item)
                    }
                }
            }
            .scrollTargetLayout()
        }
        .safeAreaPadding(15)
        .scrollPosition($scrollProperties.position)
        .overlay(alignment: .top) {
            ScrollDetectionRegion()
        }
        .overlay(alignment: .bottom) {
            ScrollDetectionRegion(false)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomBar()
        }
        .onScrollGeometryChange(for: CGFloat.self, of: {
            $0.contentOffset.y + $0.contentInsets.top
        }, action: { oldValue, newValue in
            scrollProperties.currentScrollOffset = newValue
        })
        .onChange(of: scrollProperties.direction, { oldValue, newValue in
            if newValue != .none {
                guard scrollProperties.timer == nil else { return }
                scrollProperties.manualScrollOffset = scrollProperties.currentScrollOffset
                
                scrollProperties.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
                    if newValue == .up {
                        scrollProperties.manualScrollOffset += 3
                    }
                    
                    if newValue == .down {
                        scrollProperties.manualScrollOffset -= 3
                    }
                    
                    scrollProperties.position.scrollTo(y: scrollProperties.manualScrollOffset)
                })
                
                scrollProperties.timer?.fire()
            } else {
                resetTimer()
            }
        })
        .onChange(of: isSelectionEnabled, { oldValue, newValue in
            panGesture?.isEnabled = newValue
        })
        .gesture(
            PanGesture { gesture in
                if panGesture == nil {
                    panGesture = gesture
                    gesture.isEnabled = isSelectionEnabled
                }
                let state = gesture.state
                
                if state == .began || state == .changed {
                    onGestureChange(gesture)
                } else {
                    onGestureEnded(gesture)
                }
            }
        )
        .onAppear(perform: createSampleData)
    }
    
    /// Item Card View
    @ViewBuilder
    func ItemCardView(_ binding: Binding<Item>) -> some View {
        let item = binding.wrappedValue
        
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            RoundedRectangle(cornerRadius: 18)
                .fill(item.color.gradient)
                .frame(height: 80)
                .onGeometryChange(for: CGRect.self) {
                    $0.frame(in: .global)
                } action: { newValue in
                    binding.wrappedValue.location = newValue
                }
                .overlay(alignment: .topLeading) {
                    ZStack {
                        if properties.selectedIndices.contains(index) && !properties.toBeDeletedIndices.contains(index) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.black, .white)
                                .padding(5)
                                .transition(.blurReplace)
                        }
                    }
                    .animation(.snappy(duration: 0.25, extraBounce: 0), value: properties.selectedIndices)
                    .animation(.snappy(duration: 0.25, extraBounce: 0), value: properties.toBeDeletedIndices)
                }
                .overlay {
                    if isSelectionEnabled {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .contentShape(.rect)
                            .onTapGesture {
                                if properties.selectedIndices.contains(index) {
                                    properties.selectedIndices.removeAll(where: { $0 == index })
                                } else {
                                    properties.selectedIndices.append(index)
                                }
                                
                                properties.previousIndices = properties.selectedIndices
                            }
                            .transition(.identity)
                    }
                }
        }
    }
    
    /// Scroll Detection Region View
    @ViewBuilder
    func ScrollDetectionRegion(_ isTop: Bool = true) -> some View {
        Rectangle()
            .foregroundStyle(.clear)
            .frame(height: 60)
            .ignoresSafeArea()
            .onGeometryChange(for: CGRect.self) {
                $0.frame(in: .global)
            } action: { newValue in
                if isTop {
                    scrollProperties.topRegion = newValue
                } else {
                    scrollProperties.bottomRegion = newValue
                }
            }
    }
    
    /// Customized Bottom Bar
    @ViewBuilder
    func BottomBar() -> some View {
        ZStack {
            if isSelectionEnabled {
                HStack {
                    Button("", systemImage: "square.and.arrow.up.fill") {
                        
                    }
                    
                    Spacer(minLength: 0)
                    
                    Button("", systemImage: "trash.fill") {
                        
                    }
                    .foregroundStyle(.red)
                }
                .font(.title3)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(Material.thin)
                .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
            }
        }
        .animation(.snappy(duration: 0.25, extraBounce: 0), value: isSelectionEnabled)
    }
    
    /// Gesture OnChanged
    private func onGestureChange(_ gesture: UIPanGestureRecognizer) {
        let positon = gesture.location(in: gesture.view)
        if let fallingIndex = items.firstIndex(where: { $0.location.contains(positon) }) {
            if properties.start == nil {
                properties.start = fallingIndex
                properties.isDeleteDrag = properties.previousIndices.contains(fallingIndex)
            }
            
            properties.end = fallingIndex
            
            if let start = properties.start, let end = properties.end {
                if properties.isDeleteDrag {
                    let indices = (start > end ? end...start : start...end).compactMap({ $0 })
                    properties.toBeDeletedIndices = Set(properties.previousIndices).intersection(indices).compactMap({ $0 })
                } else {
                    let indices = (start > end ? end...start : start...end).compactMap({ $0 })
                    properties.selectedIndices = Set(properties.previousIndices).union(indices).compactMap({ $0 })
                }
            }
            
            scrollProperties.direction = scrollProperties.topRegion.contains(positon) ? .down : scrollProperties.bottomRegion.contains(positon) ? .up : .none
        }
    }
    
    /// Gesture OnEnded
    private func onGestureEnded(_ gesture: UIPanGestureRecognizer) {
        /// Deleting Indices that must be deleted
        for index in properties.toBeDeletedIndices {
            properties.selectedIndices.removeAll(where: { $0 == index })
        }
        properties.toBeDeletedIndices = []
        
        properties.previousIndices = properties.selectedIndices
        properties.start = nil
        properties.end = nil
        properties.isDeleteDrag = false
        
        resetTimer()
    }
    
    /// Reset Timer
    private func resetTimer() {
        scrollProperties.manualScrollOffset = 0
        scrollProperties.timer?.invalidate()
        scrollProperties.timer = nil
        scrollProperties.direction = .none
    }
    
    /// Creating Sample Item Data
    private func createSampleData() {
        guard items.isEmpty else { return }
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .cyan, .brown, .orange, .pink]
        
        for _ in 0...4 {
            let sampleItems = colors.shuffled().compactMap({ Item(color: $0) })
            items.append(contentsOf: sampleItems)
        }
    }
    
    /// Drag Selection Properties
    private struct SelectionProperties {
        var start: Int?
        var end: Int?
        /// This property holds the actual selected indices
        var selectedIndices: [Int] = []
        var previousIndices: [Int] = []
        var toBeDeletedIndices: [Int] = []
        var isDeleteDrag: Bool = false
    }
    
    /// Auto Scroll Properties
    private struct ScrollProperties {
        var position: ScrollPosition = .init()
        var currentScrollOffset: CGFloat = 0
        var manualScrollOffset: CGFloat = 0
        var timer: Timer?
        var direction: ScrollDirection = .none
        /// Regions
        var topRegion: CGRect = .zero
        var bottomRegion: CGRect = .zero
    }
    
    private enum ScrollDirection {
        case up
        case down
        case none
    }
}

/// Custom UIKit Gesture
struct PanGesture: UIGestureRecognizerRepresentable {
    var handle: (UIPanGestureRecognizer) -> ()
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        return UIPanGestureRecognizer()
    }
    
    func updateUIGestureRecognizer(_ recognizer: UIPanGestureRecognizer, context: Context) {
        
    }
    
    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        handle(recognizer)
    }
}

// MARK: - Preview 
#Preview {
    HomeView()
}
