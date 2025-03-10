//
//  OnboardingFlow.swift
//  MyApp
//  SceneReconstructionApp
//
//  Created by Cong Le on 3/10/25.
//

import SwiftUI
import AVFoundation // For handling camera permissions (if needed)
// import CoreLocation  // Uncomment if using location features
//
//@main
//struct SceneReconstructionApp: App {
//    var body: some Scene {
//        WindowGroup {
//            SceneReconstructionView()
//        }
//    }
//}

/// The root view that determines whether to show the onboarding or the main app screen.
struct SceneReconstructionView: View {
    // This flag is used to decide if the onboarding flow should be shown.
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some View {
        NavigationView {
            if hasSeenOnboarding {
                MainAppView()
            } else {
                OnboardingContainerView(hasSeenOnboarding: $hasSeenOnboarding)
            }
        }
    }
}

/// Container view that manages the onboarding steps.
struct OnboardingContainerView: View {
    // Binding to update onboarding completion state in the parent view.
    @Binding var hasSeenOnboarding: Bool
    /// Tracks the current onboarding step.
    @State private var currentStep: Int = 1

    var body: some View {
        VStack(spacing: 30) {
            // Display different content based on the current step.
            Group {
                if currentStep == 1 {
                    OnboardingStepView(
                        title: "Welcome!",
                        description: "Welcome to Scene Reconstruction. Discover how you can bring your surroundings to life!"
                    )
                } else if currentStep == 2 {
                    OnboardingStepView(
                        title: "Discover the Feature",
                        description: "Our app uses innovative scene reconstruction techniques to rebuild 3D scenes from your environment. Explore key features and benefits."
                    )
                } else if currentStep == 3 {
                    OnboardingStepView(
                        title: "Permissions Request",
                        description: "To get started, we require access to your camera. Optionally, access to your location can help with geotagging features."
                    )
                    // Optionally, you can add buttons to request camera/location permissions here.
                }
            }
            .transition(.slide)
            .padding()

            // Navigation button changes based on the current step.
            Button(action: {
                withAnimation {
                    if currentStep < 3 {
                        currentStep += 1
                    } else {
                        // On final step, mark onboarding as complete.
                        hasSeenOnboarding = true
                    }
                }
            }) {
                Text(currentStep < 3 ? "Next" : "Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .navigationBarHidden(true)
    }
}

/// A reusable view for an individual onboarding screen.
struct OnboardingStepView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Text(title)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

/// The main app screen that users see after completing onboarding.
struct MainAppView: View {
    var body: some View {
        VStack {
            Text("Main App Screen")
                .font(.largeTitle)
                .bold()
            // Your main app content and navigation goes here.
            Text("Capture your scene, choose your capture mode, and get started!")
                .padding()
        }
        .navigationBarTitle("Scene Reconstruction", displayMode: .inline)
    }
}

// MARK: - Preview
#Preview {
    SceneReconstructionView()
//    MainAppView()
}
