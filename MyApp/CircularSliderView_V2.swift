//
//  CircularSliderView_V2.swift
//  MyApp
//
//  Created by Cong Le on 2/19/25.
//

import SwiftUI

// MARK: - Model Picker Enum (as per Diagram 1 & Textual Explanation)

enum ModelPicker: String, CaseIterable, Identifiable {
    case normal = "Normal"
    case scaled = "Scaled"

    var id: Self { self }
}

// MARK: - CircularSliderView Implementation

struct CircularSliderView_V2: View {
    @State private var pickerType: ModelPicker = .normal
    @State private var activeID: Int? = 0 // Initialize activeID to 0
    let profiles = Array(1...15).map { "Profile_\($0)" } // Example Profile Names (local assets)

    var body: some View {
        VStack { // Root VStack - will have the background image
            Picker("Picker Type", selection: $pickerType) {
                ForEach(ModelPicker.allCases) {
                    Text(String(describing: $0)).tag($0)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Spacer()

            GeometryReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 35) {
                        ForEach(profiles.indices, id: \.self) { index in
                            Image(profiles[index]) // Load Static Local Images
                                .resizable()
                                .scaledToFit()
                                .tag(index)
                                .frame(width: 160, height: 160)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                                .visualEffect { content, geometryProxy in
                                    content
                                        .offset(y: offset(proxy: geometryProxy, index: index))
                                        .scaleEffect(scale(proxy: geometryProxy, index: index))
                                }
                                .scrollTransition { effect, phase in
                                    effect
                                        .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                        .opacity(phase.isIdentity ? 1 : 0.5)
                                }
                                .background(pickerType == .scaled ? Circle().fill(.orange.opacity(progressBackground(proxy: proxy, index: index))) : nil)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $activeID)
            }
            .frame(height: 200)
        }
        .background( // Set background of the entire VStack based on activeID
            Group { // Use Group to conditionally apply background
                if let activeIndex = activeID, activeIndex >= 0 && activeIndex < profiles.count {
                    Image(profiles[activeIndex]) // Background Image based on activeID
                        .resizable()
                        .scaledToFill()
                        .opacity(0.3) // Adjust opacity for foreground visibility
                        .ignoresSafeArea() // Make sure background extends to edges
                } else {
                    Color.clear // Default background if activeID is nil or invalid
                }
            }
        )
        .onAppear {
            // Initial Active ID is set to 0 by default
        }
    }

    // MARK: - Helper Functions (progress, offset, scale, progressBackground - no changes needed)
    private func progress(proxy: GeometryProxy) -> CGFloat {
        guard let scrollViewBounds = proxy.bounds(of: .scrollView) else { return 0 }
        let minX = scrollViewBounds.minX
        let viewWidth = proxy.size.width
        return minX / viewWidth
    }

    private func offset(proxy: GeometryProxy, index: Int) -> CGFloat {
        let progressValue = progress(proxy: proxy)
        let individualItemSpacingAndWidth: CGFloat = 160 + 35
        let itemOffsetFromCenter = CGFloat(index) * individualItemSpacingAndWidth
        let scrollOffset =  itemOffsetFromCenter + progressValue * proxy.size.width

        if scrollOffset < -50 {
            return scrollOffset * -0.3
        } else if scrollOffset > 50 {
            return scrollOffset * 0.3
        }else {
           return scrollOffset * 0.8
        }
    }

    private func scale(proxy: GeometryProxy, index: Int) -> CGFloat {
        let progressValue = progress(proxy: proxy)
        let individualItemSpacingAndWidth: CGFloat = 160 + 35
        let itemOffsetFromCenter = CGFloat(index) * individualItemSpacingAndWidth
        let scrollOffset =  itemOffsetFromCenter + progressValue * proxy.size.width
        let clippedProgress = min(max(scrollOffset / proxy.size.width , -1), 1)

        if clippedProgress < 0 {
            return 1 + clippedProgress
        } else {
            return 1 - clippedProgress
        }
    }

    private func progressBackground(proxy: GeometryProxy, index: Int) -> CGFloat {
        let progressValue = progress(proxy: proxy)
        let individualItemSpacingAndWidth: CGFloat = 160 + 35
        let itemOffsetFromCenter = CGFloat(index) * individualItemSpacingAndWidth
        let scrollOffset =  itemOffsetFromCenter + progressValue * proxy.size.width
        let clippedProgress = min(max(scrollOffset / proxy.size.width , -1), 1)
        return  1 - abs(clippedProgress)
    }
}

// MARK: - Preview

#Preview {
    CircularSliderView_V2()
}
