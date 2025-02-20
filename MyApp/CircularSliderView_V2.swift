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
    @State private var pickerType: ModelPicker = .normal // State Variable (Diagram 1 - A1)
    @State private var activeID: Int? = 0 // State Variable to track active Image (Diagram 1 - A2 & Diagram 5)
    let profiles = Array(1...15).map { "Profile_\($0)" } // Example Profile Array - Replace with actual URLs in a real app

    var body: some View {
        VStack { // UI Composition - VStack (Diagram 1 - B1)
            Picker("Picker Type", selection: $pickerType) { // Picker (Diagram 1 - B2)
                ForEach(ModelPicker.allCases) { // ModelPicker.allCases (Diagram 1 - B3)
                    Text(String(describing: $0)).tag($0)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Spacer() // Spacer (Diagram 1 - B4)

            GeometryReader { proxy in // GeometryReader (Diagram 1 - B5 & Diagram 2)
                ScrollView(.horizontal, showsIndicators: false) { // ScrollView (.horizontal)  (Diagram 1 - B6 & Diagram 2)
                    HStack(spacing: 35) { // HStack (spacing: 35) (Diagram 1 - B7 & Diagram 2)
                        ForEach(profiles.indices, id: \.self) { index in // ForEach(profiles) & indices for ID (Diagram 1 - B8)
                            // Asynchronous Image Loading with Error Handling (Diagram 6)
                            AsyncImage(url: URL(string: "https://example.com/\(profiles[index]).png")) { phase in // Replace with your actual URL base
                                switch phase {
                                case .empty:
                                    ProgressView() // Placeholder while loading
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .tag(index) // Tag for identification in ScrollView & activeID (Diagram 5)
                                        .frame(width: 160, height: 160)
                                        .clipShape(Circle()) // Modifier (Diagram 1 - B11)
                                        .shadow(radius: 5)   // Modifier (Diagram 1 - B12)
                                        .visualEffect { content, geometryProxy in // Modifier: visualEffect & GeometryProxy (Diagram 1 - B13 & Diagram 2)
                                            content
                                                .offset(y: offset(proxy: geometryProxy, index: index)) // Offset Animation (Diagram 3 & Text Explanation)
                                                .scaleEffect(scale(proxy: geometryProxy, index: index)) // Scale Animation (Diagram 3 & Text Explanation)
                                        }
                                    // `.scrollTransition` for potential custom transitions (Diagram 4 & Text Explanation)
                                        .scrollTransition { effect, phase in
                                            effect
                                                .scaleEffect(phase.isIdentity ? 1 : 0.9) // Example transition effect, can be customized further based on Diagram 4
                                                .opacity(phase.isIdentity ? 1 : 0.5) // Example transition effect, can be customized further based on Diagram 4
                                        }

                                case .failure(let error):
                                    // Error Handling - Display Placeholder + Log Error (Diagram 6 & Text Explanation)
                                    
                                    Circle() // Placeholder Circle (Diagram 6 - G)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 160, height: 160)
                                        .overlay(Image(systemName: "photo.fill.on.rectangle.fill").foregroundColor(.white)) // Placeholder Icon
                                        .tag(index)
                                        .shadow(radius: 5)
                                        .visualEffect { content, geometryProxy in
                                            content
                                                .offset(y: offset(proxy: geometryProxy, index: index))
                                                .scaleEffect(scale(proxy: geometryProxy, index: index))
                                        }
                                        .scrollTransition { effect, phase in // Apply same `scrollTransition` even for placeholders for consistency
                                            effect
                                                .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                                .opacity(phase.isIdentity ? 1 : 0.5)
                                        }

                                @unknown default:
                                    // Fallback for future cases
                                    Image(systemName: "exclamationmark.triangle.fill") // Another placeholder
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.orange)
                                        .tag(index)
                                        .frame(width: 160, height: 160)
                                        .shadow(radius: 5)
                                        .visualEffect { content, geometryProxy in
                                            content
                                                .offset(y: offset(proxy: geometryProxy, index: index))
                                                .scaleEffect(scale(proxy: geometryProxy, index: index))
                                        }
                                        .scrollTransition { effect, phase in // Consistent `scrollTransition` for fallback as well
                                            effect
                                                .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                                .opacity(phase.isIdentity ? 1 : 0.5)
                                        }
                                }
                            }
                            .background(pickerType == .scaled ? Circle().fill(.orange.opacity(progressBackground(proxy: proxy, index: index))) : nil) // Background (conditional) - Diagram 1 - B14 & 'circle'

                        } // End ForEach profiles
                    } // End HStack
                    .scrollTargetLayout() // Enable ScrollView snapping (Diagram 5 - Calculate Snapped Position)
                } // End ScrollView
                .scrollTargetBehavior(.viewAligned) //  ScrollView snapping behavior (Diagram 5 - Calculate Snapped Position)
                .scrollPosition(id: $activeID) // Programmatic Scroll Control & Snapping (Diagram 5 - Programmatic Scroll Animation & activeID Update)
            } // End GeometryReader
            .frame(height: 200) // Fixed height for GeometryReader for illustration
        } // End VStack
        .onAppear {
            // Initial Active ID can be set here if needed, default is already 0
        }
    }

    // MARK: - Helper Functions (Diagram 1 - C & Diagram 3 & Diagram 2)
    
    func logErrorMessage(error: Any) {
//        print("Image failed to load for \(profiles[index]) with error: \(error)") // Diagram 6 - H: Log Error
        print("Image failed to load for with error: \(error)") // Diagram 6 - H: Log Error
    }

    /// Calculates the scroll progress based on the GeometryProxy of the GeometryReader and ScrollView's bounds.
    /// - Parameter proxy: GeometryProxy of the GeometryReader.
    /// - Returns: Normalized scroll progress, where 0 is centered, negative is scrolled right, positive is scrolled left (Diagram 3 - B & Diagram 2 - minX).
    private func progress(proxy: GeometryProxy) -> CGFloat {
        guard let scrollViewBounds = proxy.bounds(of: .scrollView) else { return 0 } // Diagram 2 - ScrollView bounds

        let minX = scrollViewBounds.minX // Diagram 2 - minX derivation
        let viewWidth = proxy.size.width // Diagram 2 - viewWidth

        return minX / viewWidth // Diagram 3 - B: Calculate Progress & Diagram 2 - minX in GeometryReader's Space
    }


    /// Calculates vertical offset for each image based on its position and scroll progress.
    /// - Parameters:
    ///   - proxy: GeometryProxy of the GeometryReader.
    ///   - index: Index of the image in the profiles array.
    /// - Returns: Vertical offset for the image (Diagram 3 - offset(proxy) Logic).
    private func offset(proxy: GeometryProxy, index: Int) -> CGFloat {
        let progressValue = progress(proxy: proxy) // Diagram 3 - B: Calculate Progress
       // Simplified logic for offset based on index position relative to scroll progress
        let individualItemSpacingAndWidth: CGFloat = 160 + 35 // imageWidth + spacing
        let itemOffsetFromCenter = CGFloat(index) * individualItemSpacingAndWidth

        let scrollOffset =  itemOffsetFromCenter + progressValue * proxy.size.width

        if scrollOffset < -50 { // Threshold can be tuned based on visual preference
            return scrollOffset * -0.3 // Damping factor for further items
        } else if scrollOffset > 50 {
            return scrollOffset * 0.3  // Damping factor for further items
        }else {
           return scrollOffset * 0.8 // Different damping for closer items
        }
    }

    /// Calculates scale factor for each image to create depth effect, based on scroll progress.
    /// - Parameters:
    ///   - proxy: GeometryProxy.
    ///   - index: Index of the image.
    /// - Returns: Scale factor for the image (Diagram 3 - scale(proxy) Logic).
    private func scale(proxy: GeometryProxy, index: Int) -> CGFloat {
        let progressValue = progress(proxy: proxy) // Diagram 3 - B: Calculate Progress
        let individualItemSpacingAndWidth: CGFloat = 160 + 35 // imageWidth + spacing
        let itemOffsetFromCenter = CGFloat(index) * individualItemSpacingAndWidth

        let scrollOffset =  itemOffsetFromCenter + progressValue * proxy.size.width

        let clippedProgress = min(max(scrollOffset / proxy.size.width , -1), 1) // Diagram 3 - G: Clip Progress

        if clippedProgress < 0 { // Diagram 3 - H & I: Conditional Scaling - clippedProgress < 0? Yes -> scale = 1 + clippedProgress
            return 1 + clippedProgress
        } else {        // Diagram 3 - H & J: Conditional Scaling - clippedProgress < 0? No  -> scale = 1 - clippedProgress
            return 1 - clippedProgress
        }
    }

    /// Calculates the background circle's opacity based on position and scroll progress.
    /// - Parameters:
    ///   - proxy: GeometryProxy.
    ///   - index: Index of the image.
    /// - Returns: Opacity value for the background circle.
    private func progressBackground(proxy: GeometryProxy, index: Int) -> CGFloat {
        let progressValue = progress(proxy: proxy)
        let individualItemSpacingAndWidth: CGFloat = 160 + 35 // imageWidth + spacing
        let itemOffsetFromCenter = CGFloat(index) * individualItemSpacingAndWidth

        let scrollOffset =  itemOffsetFromCenter + progressValue * proxy.size.width

        let clippedProgress = min(max(scrollOffset / proxy.size.width , -1), 1)

        return  1 - abs(clippedProgress) // Opacity decreases as clippedProgress moves away from 0
    }
}

// MARK: - Preview

#Preview {
    CircularSliderView_V2()
        .background(Color.gray.opacity(0.2))
}
