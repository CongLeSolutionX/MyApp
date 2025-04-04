//
//  V3.swift
//  MyApp
//
//  Created by Cong Le on 4/4/25.
//

import SwiftUI
import AVFoundation // Import the framework for audio session

struct GoogleAIModeIntroView: View {
    // --- Existing State ---
    @State private var isExperimentOn = true
    @State private var searchText = ""
    @State private var isListening = false // For simulation UI state

    // --- NEW State for Permissions ---
    enum PermissionStatus { case undetermined, granted, denied }
    @State private var micPermissionStatus: PermissionStatus = .undetermined
    @State private var showMicDeniedAlert = false // To trigger the alert

    // Mock data for voice search results
    let mockVoiceQueries = [
        // ... (same as before)
        "What's the weather like in Tokyo?",
        "Latest news about renewable energy",
        "Show me pictures of golden retrievers",
        "How to make sourdough bread",
        "Translate 'hello' to Spanish",
        "Fun things to do in London this weekend"
    ]

    // --- Existing UI Constants ---
   
    // Define the gradient for the glow and icon
    let rainbowGradient = AngularGradient(
        gradient: Gradient(colors: [
            .yellow, .orange, .red, .purple, .blue, .green, .yellow
        ]),
        center: .center
    )
    let buttonBlue = Color(red: 0.6, green: 0.8, blue: 1.0)
    let darkGrayBackground = Color(white: 0.1)
    let darkerGrayElement = Color(white: 0.15)
    let veryDarkBackground = Color(white: 0.05)


    var body: some View {
        ZStack {
            darkGrayBackground.ignoresSafeArea()

            VStack(spacing: 30) {
                searchBarArea()
                    .padding(.top, 50)

                introductoryContent()

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        // --- NEW: Check permission status when the view appears ---
        .onAppear(perform: checkInitialMicPermission)
        // --- NEW: Alert to guide user if permission was denied ---
        .alert("Microphone Access Denied", isPresented: $showMicDeniedAlert) {
            Button("Open Settings") {
                // Direct user to the app's settings screen
                if let url = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To use voice input, please enable microphone access for this app in the Settings.")
        }
    }

    // --- Search Bar Area (Updated Mic Button Logic) ---
    @ViewBuilder
    private func searchBarArea() -> some View {
        ZStack {
            // ... (background and glow layers remain the same)
              veryDarkBackground
                .cornerRadius(20)
                .padding(.horizontal, 20)

            Capsule()
                .strokeBorder(rainbowGradient, lineWidth: 4)
                .blur(radius: 8)
                .opacity(0.8)
                .frame(height: 55)
                .padding(.horizontal, 40)


            HStack {
                TextField("Ask anything...", text: $searchText)
                    .foregroundColor(.white)
                    .tint(.white)
                    .padding(.leading, 20)
                    .disabled(isListening || micPermissionStatus == .denied) // Also disable if denied

                Spacer()

                // --- Microphone Button (UPDATED with Permission Logic) ---
                Button {
                    // Renamed function for clarity
                    handleMicTap()
                } label: {
                    // Icon changes based on permission and listening state
                    Image(systemName: micPermissionStatus == .denied
                          ? "mic.slash.fill" // Icon for denied state
                          : (isListening ? "waveform.circle.fill" : "mic.fill"))
                        .font(.title2)
                        // Color changes based on permission and listening state
                        .foregroundColor(micPermissionStatus == .denied
                                         ? .gray // Dim color if denied
                                         : (isListening ? buttonBlue : .white))
                }
                // Disable button if permission denied OR currently listening
                .disabled(micPermissionStatus == .denied || isListening)
                .padding(.trailing, 5)

                // --- Camera Icon (Remains the same) ---
                Image(systemName: "camera.viewfinder")
                    .foregroundColor(micPermissionStatus == .denied ? .gray : .white) // Also dim if denied
                    .padding(.trailing, 20)
                    .padding(.leading, 5)
                    .allowsHitTesting(micPermissionStatus != .denied) // Prevent interaction if denied

            }
            .frame(height: 50)
            .background(Color.black.opacity(isListening ? 0.7 : 1.0))
            .clipShape(Capsule())
            .padding(.horizontal, 45)
            // Dim the whole bar slightly if permission is denied
             .opacity(micPermissionStatus == .denied ? 0.7 : 1.0)
            // Overlay for "Listening..." (remains the same logic)
            .overlay(
                Text("Listening...")
                    .font(.caption)
                    .foregroundColor(buttonBlue.opacity(0.8))
                    .padding(.bottom, 40)
                    .opacity(isListening ? 1 : 0)
                    .animation(.easeInOut, value: isListening)
                , alignment: .bottom
            )
             // NEW: Overlay to show message if permission denied (optional)
            .overlay(
                Text("Mic Access Denied")
                 .font(.caption)
                 .foregroundColor(.red.opacity(0.8))
                 .padding(.bottom, 40)
                 .opacity(micPermissionStatus == .denied ? 1 : 0) // Only show if denied
                 .animation(.easeInOut, value: micPermissionStatus)
                , alignment: .bottom
            )


        }
        .frame(height: 100)
    }

    // --- Introductory Content (No changes needed here) ---
    @ViewBuilder
    private func introductoryContent() -> some View {
       // ... (same as before)
        VStack(alignment: .leading, spacing: 20) {
                   // Icon and Title Row
                   HStack(alignment: .center, spacing: 15) {
                       aiIcon()
                       VStack(alignment: .leading) {
                           Text("Ask Anything with AI Mode")
                               .font(.title2)
                               .fontWeight(.bold)
                           Text("New")
                               .font(.caption)
                               .foregroundColor(.gray)
                       }
                       Spacer()
                   }

                   // Description Text
                   Text("Be the first to try the new AI Mode experiment in Google Search. Get AI-powered responses and explore further with follow-up questions and links to helpful web content.")
                       .font(.subheadline)
                       .foregroundColor(.gray)

                   // Toggle Section
                   HStack {
                       Text("Turn this experiment on or off.")
                           .font(.subheadline)
                       Spacer()
                       Toggle("", isOn: $isExperimentOn)
                           .labelsHidden()
                           .tint(buttonBlue)
                   }
                   .padding()
                   .background(darkerGrayElement)
                   .cornerRadius(15)

                   // Try AI Mode Button
                   Button {
                       print("Try AI Mode tapped")
                   } label: {
                       Text("Try AI Mode")
                           .fontWeight(.semibold)
                           .frame(maxWidth: .infinity)
                           .padding()
                           .background(buttonBlue)
                           .foregroundColor(Color(white: 0.1))
                           .cornerRadius(25)
                   }
               }
               .padding(.horizontal, 25)

    }

    // --- AI Icon (No changes needed here) ---
    @ViewBuilder
    private func aiIcon() -> some View {
       // ... (same as before)
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
                .frame(width: 55, height: 55)
            Circle()
                 .fill(rainbowGradient)
                 .frame(width: 45, height: 45)
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }

    // --- Action & Permission Handling Functions ---

    // NEW: Renamed function that handles the tap and checks permissions
    private func handleMicTap() {
        switch micPermissionStatus {
        case .granted:
            // Permission already granted, proceed with action
            startVoiceInputSimulation() // (Will be replaced with real speech recognition)
        case .undetermined:
            // Permission not yet requested, ask for it
            requestMicPermission()
        case .denied:
            // Permission was denied, show alert to guide user
            showMicDeniedAlert = true
        }
    }

    // NEW: Function to check the initial microphone permission status
    private func checkInitialMicPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            micPermissionStatus = .granted
        case .denied:
            micPermissionStatus = .denied
        case .undetermined:
            micPermissionStatus = .undetermined
        @unknown default:
            // Handle future cases gracefully
            micPermissionStatus = .undetermined
        }
    }

    // NEW: Function to explicitly request microphone permission
    private func requestMicPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            // IMPORTANT: Update state on the main thread
            DispatchQueue.main.async {
                self.micPermissionStatus = granted ? .granted : .denied
                if granted {
                    // If permission was just granted, proceed immediately
                    startVoiceInputSimulation()
                } else {
                    // If permission was just denied, show the alert
                    showMicDeniedAlert = true
                }
            }
        }
    }

    // Renamed: Contains the simulation logic (will be replaced later)
    private func startVoiceInputSimulation() {
        if isListening { return } // Prevent starting again if already listening

        isListening = true
        searchText = "" // Clear text field when starting voice input

        // Simulate listening duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            searchText = mockVoiceQueries.randomElement() ?? "No result"
            isListening = false // Stop listening state
        }
    }
}

// Preview Provider
struct GoogleAIModeIntroView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleAIModeIntroView()
    }
}
