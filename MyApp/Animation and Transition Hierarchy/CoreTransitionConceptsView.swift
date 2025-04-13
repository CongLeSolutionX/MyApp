//
//  CoreTransitionConceptsView.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//


import SwiftUI

// MARK: - Demo Content View

/// A simple view to be animated in and out using transitions.
struct DemoView: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(radius: 3)
            .padding(.horizontal)
    }
}

// MARK: - Core Transition Concepts Demonstration View

struct CoreTransitionConceptsView: View {
    @State private var showIdentity = false
    @State private var showOpacity = false
    @State private var showSlide = false
    @State private var showMove = false
    @State private var showOffset = false
    @State private var showScale = false
    @State private var showAsymmetric = false
    @State private var showCombined = false
    @State private var showAnimated = false
    @State private var showPush = false // iOS 16+
    @State private var showBlurReplace = false // iOS 17+
    @State private var showCustom = false // iOS 17+

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Core Transition Concepts")
                    .font(.largeTitle)
                    .padding(.bottom)

                // --- Standard AnyTransitions ---

                Section("Standard AnyTransitions") {
                    // .identity (No visible animation)
                    VStack {
                        Toggle("Show with .identity", isOn: $showIdentity.animation())
                        if showIdentity {
                            DemoView(title: ".identity", color: .gray)
                                .transition(.identity)
                        }
                    }

                    // .opacity
                    VStack {
                        Toggle("Show with .opacity", isOn: $showOpacity.animation())
                        if showOpacity {
                            DemoView(title: ".opacity", color: .blue)
                                .transition(.opacity)
                        }
                    }

                    // .slide
                    VStack {
                        Toggle("Show with .slide", isOn: $showSlide.animation())
                        if showSlide {
                            DemoView(title: ".slide", color: .green)
                                .transition(.slide)
                        }
                    }

                    // .move(edge:)
                    VStack {
                        Toggle("Show with .move(edge: .bottom)", isOn: $showMove.animation())
                        if showMove {
                            DemoView(title: ".move(edge: .bottom)", color: .orange)
                                .transition(.move(edge: .bottom))
                        }
                    }

                    // .offset()
                    VStack {
                        Toggle("Show with .offset()", isOn: $showOffset.animation())
                        if showOffset {
                            DemoView(title: ".offset(x: 100, y: 50)", color: .purple)
                                .transition(.offset(x: 100, y: 50))
                        }
                    }

                    // .scale()
                    VStack {
                        Toggle("Show with .scale()", isOn: $showScale.animation())
                        if showScale {
                            DemoView(title: ".scale(scale: 0.1, anchor: .bottom)", color: .pink)
                                .transition(.scale(scale: 0.1, anchor: .bottom))
                        }
                    }
                }

                Divider()

                // --- Combined/Modified Transitions ---

                Section("Combined/Modified Transitions") {
                    // .combined(with:)
                    VStack {
                        Toggle("Show with .combined(.opacity, .move)", isOn: $showCombined.animation())
                        if showCombined {
                            DemoView(title: ".combined(.opacity, .move)", color: .indigo)
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                        }
                    }

                    // .animation() attached to transition
                    VStack {
                        Toggle("Show with .slide.animation(.spring)", isOn: $showAnimated.animation()) // Animation on toggle for structure change
                        if showAnimated {
                            DemoView(title: ".slide with custom animation", color: .cyan)
                                .transition(.slide.animation(.interpolatingSpring(stiffness: 50, damping: 5)))
                        }
                    }

                    // .asymmetric(insertion:removal:)
                    VStack {
                        Toggle("Show with .asymmetric", isOn: $showAsymmetric.animation())
                        if showAsymmetric {
                            DemoView(title: ".asymmetric", color: .teal)
                                .transition(.asymmetric(insertion: .scale, removal: .opacity.combined(with: .move(edge: .top))))
                        }
                    }
                }

                Divider()

                // --- Newer Transitions (Check Availability) ---

                Section("Newer Transitions") {
                    // .push(from:) (iOS 16+)
                    if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                        VStack {
                            Toggle("Show with .push(from:)", isOn: $showPush.animation())
                            if showPush {
                                DemoView(title: ".push(from: .leading)", color: .brown)
                                    .transition(.push(from: .leading))
                            }
                        }
                    } else {
                        Text(".push requires iOS 16+").font(.caption).foregroundColor(.gray)
                    }

                    // .blurReplace() (iOS 17+)
                    if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                        VStack {
                             Toggle("Toggle .blurReplace Content", isOn: $showBlurReplace.animation())
                             Group {
                                 if showBlurReplace {
                                     DemoView(title: "Visible (Blur Replace)", color: .mint)
                                 } else {
                                     DemoView(title: "Hidden (Blur Replace)", color: .gray)
                                 }
                             }
                             .id(showBlurReplace) // Ensure replacement triggers transition
                             .transition(.blurReplace)
                        }
                    } else {
                        Text(".blurReplace requires iOS 17+").font(.caption).foregroundColor(.gray)
                    }
                }

                Divider()

                // --- Custom Transition (iOS 17+) ---

                Section("Custom Transition (iOS 17+)") {
                    if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                        VStack {
                            Toggle("Show with Custom Transition", isOn: $showCustom.animation())
                            if showCustom {
                                DemoView(title: "Custom Rotating Fade", color: .yellow)
                                    .transition(RotatingFadeTransition(rotationAmount: .degrees(90)))
                            }
                        }
                    } else {
                         Text("Custom Transition requires iOS 17+").font(.caption).foregroundColor(.gray)
                    }

                }
                 Spacer() // Push content up

            } // End Main VStack
            .padding()
        } // End ScrollView
        .navigationTitle("Transitions Demo")
    }
}

// MARK: - Custom Transition (iOS 17+)

/// A custom transition that fades and rotates the view.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct RotatingFadeTransition: Transition {
    var rotationAmount: Angle = .degrees(45) // Customizable rotation

    // Define the properties of this transition
    static var properties: TransitionProperties {
        // Indicate that this transition involves motion.
        // Set to false if you want it to ignore the reduce motion setting.
        TransitionProperties(hasMotion: true)
    }

    // Define how the view looks at different phases
    func body(content: Content, phase: TransitionPhase) -> some View {
        // Use phase.isIdentity to determine if the view is fully visible
        // Use phase.value (-1 for willAppear, 0 for identity, 1 for didDisappear) for interpolation
        content
            .opacity(phase.isIdentity ? 1.0 : 0.0) // Fade in/out
            .rotationEffect(Angle.degrees(phase.value * rotationAmount.degrees)) // Rotate based on phase value
            .scaleEffect(phase.isIdentity ? 1.0 : 0.7) // Optional scale effect
    }
}

// MARK: - Preview

#Preview {
    NavigationView { // Use NavigationView for title display
         CoreTransitionConceptsView()
    }
}
