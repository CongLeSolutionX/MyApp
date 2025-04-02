//
//  SwiftUIFoundationsCoreImprovements.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//
import SwiftUI
// Import AVKit for VideoPlayer placeholder if needed
 import AVKit

// --- Reacting to Scroll Geometry ---

struct ScrollGeometryExample: View {
    @State private var showBackButton = false

    var body: some View {
        ScrollView {
            VStack {
                Image(systemName: "music.mic.fill") // Placeholder content
                    .font(.system(size: 100))
                    .padding(50)
                ForEach(0..<30) { i in
                    Text("Scroll Content Line \(i)")
                        .padding(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .overlay(alignment: .topLeading) {
            // Button appears when scrolled down
            if showBackButton {
                Button {
                    // Action to scroll back up (see next example)
                } label: {
                    Label("Back to Top", systemImage: "arrow.up.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
         // Monitor scroll offset changes
        .onScrollGeometryChange(for: Bool.self) { geometry in
             // Condition: Is content offset below the top inset?
             geometry.contentOffset.y > geometry.contentInsets.top
         } action: { wasScrolledDown, isScrolledDown in
             // Animate button visibility based on state change
             withAnimation(.easeInOut) {
                 showBackButton = isScrolledDown
             }
         }
    }
}

#Preview("Scroll Geometry") {
    ScrollGeometryExample()
}

// --- Reacting to Scroll Visibility ---

// Placeholder for AVPlayer
// class MockPlayer { func play() { print("Mock Play") }; func pause() { print("Mock Pause") } }

struct AutoPlayingVideoPlaceholder: View {
    // @State private var player = MockPlayer() // Use mock or real AVPlayer
    @State private var isPlaying = false
    var id: Int

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.blue.opacity(0.3))
            .frame(height: 200)
            .overlay(
                VStack {
                    Text("Video Placeholder \(id)")
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                }
            )
            .padding()
             // Trigger action when visibility crosses 50% threshold
            .onScrollVisibilityChange(threshold: 0.5) { isVisible in
                 print("Video \(id) visibility changed: \(isVisible)")
                 // Simulate play/pause based on visibility
                 // if isVisible { player.play() } else { player.pause() }
                 isPlaying = isVisible
             }
             // Optional: Add animation
             .animation(.easeInOut, value: isPlaying)
    }
}

struct ScrollVisibilityExample: View {
    var body: some View {
        ScrollView {
            ForEach(0..<10) { i in
                AutoPlayingVideoPlaceholder(id: i)
                    .id(i) // Ensure views have unique IDs for tracking
            }
        }
    }
}

#Preview("Scroll Visibility") {
    ScrollVisibilityExample()
}

// --- New Scroll Positions (`scrollTo(edge:)`) ---

struct ScrollToEdgeExample: View {
    // State to hold the scroll position binding
    @State private var position = ScrollPosition(idType: Int.self)

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(0..<50) { i in
                        Text("Item \(i)")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.2))
                            .id(i) // Make items identifiable
                    }
                }
            }
            // Bind the scroll position
            .scrollPosition($position)

            HStack {
                Button("Scroll to Top") {
                    withAnimation {
                        // Use the bound position to scroll
                        position.scrollTo(edge: .top)
                    }
                }
                Button("Scroll to Item 25") {
                     withAnimation {
                        position.scrollTo(id: 25, anchor: .center) // Example scroll to ID
                     }
                }
                Button("Scroll to Bottom") {
                    withAnimation {
                        position.scrollTo(edge: .bottom)
                    }
                }
            }
            .padding()
            .buttonStyle(.bordered)
        }
        // Optional: report current position
//        .onChange(of: position) { newValue in
//           print("Scroll position changed to \(newValue.rect)")
//        }
    }
}

#Preview("Scroll To Edge") {
    ScrollToEdgeExample()
}

// --- Scroll Fine Control (Comments) ---
/*
 Other ScrollView modifiers for fine-grained control include:

 .scrollBounceBehavior(.basedOnSize) // Or .always, .automatic
 .scrollTargetBehavior(.paging) // Or .viewAligned, .contentDerived, etc.
 .scrollIndicators(.hidden) // Or .visible, .automatic
 .scrollDisabled(true) // Disable scrolling
 .contentMargins(.horizontal, 20) // Add margins inside scroll view, around content
 .scrollDismissesKeyboard(.interactively) // Or .immediately, .never

 Example:
 ScrollView { ... }
    .scrollBounceBehavior(.basedOnSize, axes: .vertical) // Only affect vertical bounce
    .scrollIndicators(.hidden)
*/
