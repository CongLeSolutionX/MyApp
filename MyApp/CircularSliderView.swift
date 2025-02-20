//
//  CircularSliderView.swift
//  MyApp
//
//  Created by Cong Le on 2/18/25.
//


import SwiftUI

// MARK: - Main View
/// `CircularSliderView` is a SwiftUI `View` that displays a segmented control picker
/// and a circular image slider. The images in the slider animate based on the scroll position
/// and selected picker type.

struct CircularSliderView: View {
    // MARK: - State Variables
    /// The currently selected picker type, defaulting to `.chatWithMe`.
    @State private var pickerType: AIModelPicker = .chatWithMe
    /// The ID of the currently active image in the slider, defaulting to `0`.
    @State private var activeID: Int? = 0
    /// An array of profile image names, used as data for the circular slider.
    let profiles = (0...25).map { "Profile_\($0)" }
    
    // MARK: - Body
    var body: some View {
        VStack {
            // MARK: - Picker
            Picker("", selection: $pickerType) {
                ForEach(AIModelPicker.allCases, id: \.self) {
                    Text($0.rawValue)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Spacer(minLength: 0)
            
            // MARK: - Circular Slider
            GeometryReader { geometry in
                let size = geometry.size
                // Calculate horizontal padding to center the content.
                let padding = (size.width - 70) / 2
                
                ScrollView(.horizontal) {
                    HStack(spacing: 35) {
                        ForEach(1...25, id: \.self) { index in
                            Image("Profile_\(index)")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .clipShape(.circle)
                                .shadow(color: .black.opacity(0.15), radius: 5, x: 5, y: 5)
                            // Visual effects for offsetting and scaling the image.
                                .visualEffect { view, proxy in
                                    view
                                        .offset(y: offset(proxy))
                                    // Scale effect that is active on the`.chatWithMe`.
                                        .scaleEffect(1 + (pickerType == .chatWithMe ? 0 : (scale(proxy) / 2)))
                                    // Offset based on the scale to create depth.
                                        .offset(y: scale(proxy) * 15)
                                }
                            // Scroll transition to update the image's appearance.
                                .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                                    view
                                    // Scale effect that is active based on scroll and picker type.
                                        .scaleEffect(phase.isIdentity && activeID == index && pickerType == .talkWithMe ? 1.5 : 1, anchor: .bottom)
                                }
                        }
                    }
                    .frame(height: size.height)
                    .offset(y: -30)
                    .scrollTargetLayout()
                }
                // Background circle for .chatWithMe mode.
                .background(content: {
                    if pickerType == .chatWithMe {
                        Circle()
                            .fill(.yellow.shadow(.drop(color: .black.opacity(0.2), radius: 5)))
                            .frame(width: 85, height: 85)
                            .offset(y: -15)
                    }
                })
                .safeAreaPadding(.horizontal, padding)
                .scrollIndicators(.hidden)
                // Enable snapping to views.
                .scrollTargetBehavior(.viewAligned)
                // Update active image ID based on scroll position.
                .scrollPosition(id: $activeID)
                .frame(height: size.height)
            }
            .frame(height: 200)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        // Sets the background based on the active image or a default color.
        .background(
            Group {
                if let activeIndex = activeID, profiles.indices.contains(activeIndex) {
                    Image(profiles[activeIndex])
                        .resizable()
                        .scaledToFill()
                        .opacity(0.6)
                        .ignoresSafeArea()
                } else {
//                    Color.clear
                    Image(profiles[activeID ?? 0])
                }
            }
        )
    }
    
    // MARK: - Helper Functions
    
    /// Calculates the vertical offset of the image based on its position in the scroll view.
    /// - Parameter proxy: The `GeometryProxy` of the image view.
    /// - Returns: A `CGFloat` representing the vertical offset.
    func offset(_ proxy: GeometryProxy) -> CGFloat {
        let progress = progress(proxy)
        return progress * (progress < 0 ? -30 : 30)
    }
    
    /// Calculates the scale factor of the image based on its position in the scroll view.
    /// - Parameter proxy: The `GeometryProxy` of the image view.
    /// - Returns: A `CGFloat` representing the scale factor.
    func scale(_ proxy: GeometryProxy) -> CGFloat {
        let progress = min(max(progress(proxy), -1), 1)
        return progress < 0 ? 1 + progress : 1 - progress
    }
    
    /// Calculates the scroll progress of the image.
    /// - Parameter proxy: The `GeometryProxy` of the image view.
    /// - Returns: A `CGFloat` representing the scroll progress, normalized to the width of the view.
    func progress(_ proxy: GeometryProxy) -> CGFloat {
        let viewWidth = proxy.size.width
        let minX = proxy.bounds(of: .scrollView)?.minX ?? 0
        return minX / viewWidth
    }
}

// MARK: - Picker Enum
/// An enumeration representing the types of AI model pickers.
///
/// Conforms to `String` and `CaseIterable` for easy use in a SwiftUI `Picker`.
enum AIModelPicker: String, CaseIterable {
    /// Represents a conversational AI model that focuses on spoken interactions.
    case talkWithMe = "Talk With Me"
    /// Represents a conversational AI model that focuses on text-based interactions.
    case chatWithMe = "Chat With Me"
}

// MARK: - Preview
#Preview {
    CircularSliderView()
        .navigationTitle(Text("Circular Slider"))
}
