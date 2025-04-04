////
////  GoogleAIModeIntroView_V2_With_Voice_search.swift
////  MyApp
////
////  Created by Cong Le on 4/4/25.
////
//
//import SwiftUI
//
//struct GoogleAIModeIntroView: View {
//    // State for the toggle switch
//    @State private var isExperimentOn = true
//    // State for the text input in the search bar
//    @State private var searchText = ""
//    // State for voice input status (NEW)
//    @State private var isListening = false
//
//    // Mock data for voice search results (NEW)
//    let mockVoiceQueries = [
//        "What's the weather like in Tokyo?",
//        "Latest news about renewable energy",
//        "Show me pictures of golden retrievers",
//        "How to make sourdough bread",
//        "Translate 'hello' to Spanish",
//        "Fun things to do in London this weekend"
//    ]
//
//    // Define the gradient for the glow and icon
//    let rainbowGradient = AngularGradient(
//        gradient: Gradient(colors: [
//            .yellow, .orange, .red, .purple, .blue, .green, .yellow
//        ]),
//        center: .center
//    )
//
//    let buttonBlue = Color(red: 0.6, green: 0.8, blue: 1.0) // Approximate blue
//    let darkGrayBackground = Color(white: 0.1)
//    let darkerGrayElement = Color(white: 0.15)
//    let veryDarkBackground = Color(white: 0.05) // Even darker for top section
//
//    var body: some View {
//        ZStack {
//            // Main Background
//            darkGrayBackground.ignoresSafeArea()
//
//            VStack(spacing: 30) {
//                // --- Top Search Bar Area ---
//                searchBarArea()
//                    .padding(.top, 50)
//
//                // --- Bottom Introductory Content ---
//                introductoryContent()
//
//                Spacer() // Pushes content up
//            }
//        }
//        .preferredColorScheme(.dark) // Enforce dark mode appearance
//    }
//
//    // Extracted function for the Search Bar Area - Updated for Voice Input
//    @ViewBuilder
//    private func searchBarArea() -> some View {
//        ZStack {
//            veryDarkBackground
//                .cornerRadius(20)
//                .padding(.horizontal, 20)
//
//            Capsule()
//                .strokeBorder(rainbowGradient, lineWidth: 4)
//                .blur(radius: 8)
//                .opacity(0.8)
//                .frame(height: 55)
//                .padding(.horizontal, 40)
//
//            HStack {
//                TextField("Ask anything...", text: $searchText)
//                    .foregroundColor(.white)
//                    .tint(.white)
//                    .padding(.leading, 20)
//                    .disabled(isListening) // Disable text field while "listening"
//
//                Spacer()
//
//                // --- Microphone Button (UPDATED) ---
//                Button {
//                    simulateVoiceInput() // Trigger voice input simulation
//                } label: {
//                    Image(systemName: isListening ? "waveform.circle.fill" : "mic.fill") // Change icon when listening
//                        .font(.title2) // Slightly larger icon
//                        .foregroundColor(isListening ? buttonBlue : .white) // Change color when listening
//                }
//                .padding(.trailing, 5) // Adjust spacing
//
//                // --- Camera Icon ---
//                Image(systemName: "camera.viewfinder")
//                    .foregroundColor(.white)
//                    .padding(.trailing, 20)
//                    .padding(.leading, 5) // Adjust spacing
//            }
//            .frame(height: 50)
//            .background(Color.black.opacity(isListening ? 0.7 : 1.0)) // Slightly dim background when listening
//            .clipShape(Capsule())
//            .padding(.horizontal, 45)
//            // Add an overlay for a more prominent listening indicator (Optional)
//            .overlay(
//                Text("Listening...")
//                    .font(.caption)
//                    .foregroundColor(buttonBlue.opacity(0.8))
//                    .padding(.bottom, 40) // Position below the search bar
//                    .opacity(isListening ? 1 : 0) // Show only when listening
//                    .animation(.easeInOut, value: isListening)
//                , alignment: .bottom // Align overlay below
//            )
//        }
//        .frame(height: 100)
//    }
//
//    // Extracted function for the Introductory Content (Remains the same)
//    @ViewBuilder
//    private func introductoryContent() -> some View {
//        VStack(alignment: .leading, spacing: 20) {
//            // Icon and Title Row
//            HStack(alignment: .center, spacing: 15) {
//                aiIcon()
//                VStack(alignment: .leading) {
//                    Text("Ask Anything with AI Mode")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                    Text("New")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//                Spacer()
//            }
//
//            // Description Text
//            Text("Be the first to try the new AI Mode experiment in Google Search. Get AI-powered responses and explore further with follow-up questions and links to helpful web content.")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//
//            // Toggle Section
//            HStack {
//                Text("Turn this experiment on or off.")
//                    .font(.subheadline)
//                Spacer()
//                Toggle("", isOn: $isExperimentOn)
//                    .labelsHidden()
//                    .tint(buttonBlue)
//            }
//            .padding()
//            .background(darkerGrayElement)
//            .cornerRadius(15)
//
//            // Try AI Mode Button
//            Button {
//                print("Try AI Mode tapped")
//            } label: {
//                Text("Try AI Mode")
//                    .fontWeight(.semibold)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(buttonBlue)
//                    .foregroundColor(Color(white: 0.1))
//                    .cornerRadius(25)
//            }
//        }
//        .padding(.horizontal, 25)
//    }
//
//    // Extracted function for the AI Icon (Remains the same)
//    @ViewBuilder
//    private func aiIcon() -> some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.black.opacity(0.8))
//                .frame(width: 55, height: 55)
//            Circle()
//                 .fill(rainbowGradient)
//                 .frame(width: 45, height: 45)
//            Image(systemName: "magnifyingglass")
//                .font(.title2)
//                .fontWeight(.bold)
//                .foregroundColor(.white)
//        }
//    }
//
//    // --- Function to Simulate Voice Input (NEW) ---
//    private func simulateVoiceInput() {
//        if isListening { return } // Prevent starting again if already listening
//
//        isListening = true
//        searchText = "" // Clear text field when starting voice input
//
//        // Simulate listening duration (e.g., 2 seconds)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            // Select a random mock query after "listening"
//            searchText = mockVoiceQueries.randomElement() ?? "No result" // Use mock data
//            isListening = false // Stop listening state
//        }
//    }
//}
//
//// Preview Provider for Canvas
//struct GoogleAIModeIntroView_Previews: PreviewProvider {
//    static var previews: some View {
//        GoogleAIModeIntroView()
//    }
//}
