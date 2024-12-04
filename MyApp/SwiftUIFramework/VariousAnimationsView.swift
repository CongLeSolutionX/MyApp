//
//  VariousAnimationsView.swift
//  MyApp
//
//  Created by Cong Le on 12/4/24.
//

import SwiftUI

/**
    A customizable and animated progress bar.

    - Parameters:
        - progress: A binding to a `Double` value representing the progress level (0.0 to 1.0). Updates to this value will trigger the animation.
        - color: The color of the progress bar. Defaults to blue.

    The progress bar animates linearly over a duration of 1 second whenever the `progress` value changes. It uses `GeometryReader` to dynamically adjust to the width of its container.
*/
struct AnimatedProgressBar: View {
    @Binding var progress: Double
    var color: Color = .blue
    @State private var isAnimating = false  // Controls animation state

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background rectangle
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.gray)

                // Foreground rectangle representing progress
                Rectangle()
                    .frame(width: min(CGFloat(self.progress) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(color)
                    // Explicit animation trigger, ensuring animation only occurs when progress changes and during onAppear
                    .animation(isAnimating ? .linear(duration: 1.0) : .none, value: isAnimating ? progress : nil)
                    .onAppear {
                        // Enable animation when the view appears
                        isAnimating = true
                    }
            }
            .cornerRadius(geometry.size.height / 2.0)
        }
    }
}

/**
    A view that displays a glowing circle.

    - Parameters:
        - color: The color of the circle and its glow. Defaults to yellow.

    The circle's glow animates with a continuous ease-in-ease-out effect, repeating indefinitely and auto-reversing.
*/
struct GlowingCircle: View {
    @State private var isGlowing = false
    var color: Color = .yellow

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 100, height: 100)
            // Conditional shadow based on isGlowing, with dynamic radius
            .shadow(color: isGlowing ? color : .clear, radius: isGlowing ? 30 : 0)
            .onAppear {
                // Starts the glowing animation loop as soon as the view appears
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isGlowing = true
                }
            }
    }
}

/**
 Various Animations View that switches between a summary view and a detail view.

 This view manages a progress bar, a glowing circle, and transitions between two states: a summary view and a detail view. It uses animations to enhance the user experience during transitions.

 - Properties:
   - showDetail: A state variable that controls whether to show the detail view.
   - progress: A state variable that represents the progress of the progress bar.

 - Views:
   - GlowingCircle: An animated glowing circle.
   - AnimatedProgressBar: A progress bar that animates its fill level.
   - DetailView: A view shown when `showDetail` is true.

 - Transitions:
   - The transition to the detail view uses a slide animation, entering from the trailing edge and fading out on removal.
   - The return to the main view employs an ease-in-out animation.
 */
struct VariousAnimationsView: View {
    @State private var showDetail = false
    @State private var progress: Double = 0.0

    var body: some View {
        VStack {
            if !showDetail {
                // Summary Content
                VStack {
                    GlowingCircle()
                        .padding()

                    AnimatedProgressBar(progress: $progress)
                        .frame(height: 20)
                        .padding()

                    // Button to start progress animation
                    Button("Start Progress") {
                        withAnimation(.spring()) {
                            progress = 1.0
                        }
                    }
                    .padding()

                    // Button to show detail view
                    Button("Show Detail") {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            showDetail = true
                        }
                    }
                    .padding()
                    // Transition for the content when appearing
                    .transition(.slide)
                }
            } else {
                // Detail Content
                DetailView(showDetail: $showDetail)
                    // Asymmetric transition for showing and hiding the detail view
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
            }
        }
        .padding()
    }
}

/**
    A detailed view that displays additional content.

    - Parameters:
        - showDetail: A binding to a Boolean value that controls the visibility of the detail view. When set to `false`, the view transitions out.

    The view features a rotating text label that animates upon appearance and a button to hide the detail view.
*/
struct DetailView: View {
    @Binding var showDetail: Bool
    @State private var rotationAngle: Double = 0

    var body: some View {
        VStack {
            Text("Detail View")
                .font(.largeTitle)
                .rotationEffect(.degrees(rotationAngle))
               // Explicitly animates rotation angle changes with a linear effect, repeating three times
                .onAppear {
               withAnimation(.linear(duration: 2).repeatCount(3, autoreverses: true)){
                   rotationAngle = 90
               }
                     
                        }

                // Button to hide detail view
            Button("Hide Detail") {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showDetail = false
                }
            }
            .padding()
         }
    }
}

// MARK: - Preview

#Preview {
    VariousAnimationsView()
}
