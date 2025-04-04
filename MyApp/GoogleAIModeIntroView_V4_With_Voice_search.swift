////
////  V4.swift
////  MyApp
////
////  Created by Cong Le on 4/4/25.
////
//
//import SwiftUI
//import AVFoundation // Still needed
//
//struct GoogleAIModeIntroView: View {
//    // --- State variables remain the same ---
//    @State private var isExperimentOn = true
//    @State private var searchText = ""
//    @State private var isListening = false
//
//    enum PermissionStatus { case undetermined, granted, denied }
//    @State private var micPermissionStatus: PermissionStatus = .undetermined
//    @State private var showMicDeniedAlert = false
//
//    // --- Mock data and UI Constants remain the same ---
//     let mockVoiceQueries = [
//        "What's the weather like in Tokyo?",
//        "Latest news about renewable energy",
//        "Show me pictures of golden retrievers",
//        "How to make sourdough bread",
//        "Translate 'hello' to Spanish",
//        "Fun things to do in London this weekend"
//    ]
//    let rainbowGradient = AngularGradient(
//        gradient: Gradient(colors: [
//            .yellow, .orange, .red, .purple, .blue, .green, .yellow
//        ]),
//        center: .center
//    )
//    let buttonBlue = Color(red: 0.6, green: 0.8, blue: 1.0)
//    let darkGrayBackground = Color(white: 0.1)
//    let darkerGrayElement = Color(white: 0.15)
//    let veryDarkBackground = Color(white: 0.05)
//
//
//    var body: some View {
//        ZStack {
//            // ... (background and main VStack structure remain the same)
//             darkGrayBackground.ignoresSafeArea()
//
//            VStack(spacing: 30) {
//                searchBarArea()
//                    .padding(.top, 50)
//
//                introductoryContent()
//
//                Spacer()
//            }
//        }
//        .preferredColorScheme(.dark)
//        .onAppear(perform: checkInitialMicPermission)
//        .alert("Microphone Access Denied", isPresented: $showMicDeniedAlert) {
//            Button("Open Settings") {
//                if let url = URL(string: UIApplication.openSettingsURLString),
//                   UIApplication.shared.canOpenURL(url) {
//                    UIApplication.shared.open(url)
//                }
//            }
//            Button("Cancel", role: .cancel) { }
//        } message: {
//            Text("To use voice input, please enable microphone access for this app in the Settings.")
//        }
//    }
//
//    // --- searchBarArea ViewBuilder remains the same ---
//     @ViewBuilder
//    private func searchBarArea() -> some View {
//        // No changes needed inside this ViewBuilder itself,
//        // the behavior change comes from the updated permission functions.
//         ZStack {
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
//
//            HStack {
//                TextField("Ask anything...", text: $searchText)
//                    .foregroundColor(.white)
//                    .tint(.white)
//                    .padding(.leading, 20)
//                    .disabled(isListening || micPermissionStatus == .denied)
//
//                Spacer()
//
//                Button {
//                    handleMicTap()
//                } label: {
//                    Image(systemName: micPermissionStatus == .denied
//                          ? "mic.slash.fill"
//                          : (isListening ? "waveform.circle.fill" : "mic.fill"))
//                        .font(.title2)
//                        .foregroundColor(micPermissionStatus == .denied
//                                         ? .gray
//                                         : (isListening ? buttonBlue : .white))
//                }
//                .disabled(micPermissionStatus == .denied || isListening)
//                .padding(.trailing, 5)
//
//
//                Image(systemName: "camera.viewfinder")
//                    .foregroundColor(micPermissionStatus == .denied ? .gray : .white)
//                    .padding(.trailing, 20)
//                    .padding(.leading, 5)
//                    .allowsHitTesting(micPermissionStatus != .denied)
//
//            }
//            .frame(height: 50)
//            .background(Color.black.opacity(isListening ? 0.7 : 1.0))
//            .clipShape(Capsule())
//            .padding(.horizontal, 45)
//             .opacity(micPermissionStatus == .denied ? 0.7 : 1.0)
//            .overlay(
//                Text("Listening...")
//                    .font(.caption)
//                    .foregroundColor(buttonBlue.opacity(0.8))
//                    .padding(.bottom, 40)
//                    .opacity(isListening ? 1 : 0)
//                    .animation(.easeInOut, value: isListening)
//                , alignment: .bottom
//            )
//            .overlay(
//                Text("Mic Access Denied")
//                 .font(.caption)
//                 .foregroundColor(.red.opacity(0.8))
//                 .padding(.bottom, 40)
//                 .opacity(micPermissionStatus == .denied ? 1 : 0)
//                 .animation(.easeInOut, value: micPermissionStatus)
//                , alignment: .bottom
//            )
//
//
//        }
//        .frame(height: 100)
//    }
//
//    // --- introductoryContent ViewBuilder remains the same ---
//     @ViewBuilder
//    private func introductoryContent() -> some View {
//        // No changes needed
//        VStack(alignment: .leading, spacing: 20) {
//           // Icon and Title Row
//           HStack(alignment: .center, spacing: 15) {
//               aiIcon()
//               VStack(alignment: .leading) {
//                   Text("Ask Anything with AI Mode")
//                       .font(.title2)
//                       .fontWeight(.bold)
//                   Text("New")
//                       .font(.caption)
//                       .foregroundColor(.gray)
//               }
//               Spacer()
//           }
//
//           // Description Text
//           Text("Be the first to try the new AI Mode experiment in Google Search. Get AI-powered responses and explore further with follow-up questions and links to helpful web content.")
//               .font(.subheadline)
//               .foregroundColor(.gray)
//
//           // Toggle Section
//           HStack {
//               Text("Turn this experiment on or off.")
//                   .font(.subheadline)
//               Spacer()
//               Toggle("", isOn: $isExperimentOn)
//                   .labelsHidden()
//                   .tint(buttonBlue)
//           }
//           .padding()
//           .background(darkerGrayElement)
//           .cornerRadius(15)
//
//           // Try AI Mode Button
//           Button {
//               print("Try AI Mode tapped")
//           } label: {
//               Text("Try AI Mode")
//                   .fontWeight(.semibold)
//                   .frame(maxWidth: .infinity)
//                   .padding()
//                   .background(buttonBlue)
//                   .foregroundColor(Color(white: 0.1))
//                   .cornerRadius(25)
//           }
//       }
//       .padding(.horizontal, 25)
//    }
//
//    // --- aiIcon ViewBuilder remains the same ---
//     @ViewBuilder
//    private func aiIcon() -> some View {
//      // No changes needed
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
//    // --- Action & Permission Handling Functions (UPDATED) ---
//
//    // handleMicTap remains the same structurally
//    private func handleMicTap() {
//        switch micPermissionStatus {
//        case .granted:
//            startVoiceInputSimulation()
//        case .undetermined:
//            requestMicPermission()
//        case .denied:
//            showMicDeniedAlert = true
//        }
//    }
//
//    // UPDATED: Use AVAudioApplication for checking permission
//    private func checkInitialMicPermission() {
//        // Use AVAudioApplication.shared.recordPermission instead
//        switch AVAudioApplication.shared.recordPermission {
//        case .granted:
//            micPermissionStatus = .granted
//        case .denied:
//            micPermissionStatus = .denied
//        case .undetermined:
//            micPermissionStatus = .undetermined
//        @unknown default:
//            micPermissionStatus = .undetermined
//        }
//    }
//
//    // UPDATED: Use AVAudioApplication for requesting permission
//    private func requestMicPermission() {
//        // Use AVAudioApplication.shared.requestRecordPermission instead
//        // The API signature for the closure is the same.
//        AVAudioApplication.requestRecordPermission { granted in
//            DispatchQueue.main.async {
//                self.micPermissionStatus = granted ? .granted : .denied
//                if granted {
//                    startVoiceInputSimulation()
//                } else {
//                    showMicDeniedAlert = true
//                }
//            }
//        }
//    }
//
//    // startVoiceInputSimulation remains the same
//    private func startVoiceInputSimulation() {
//        // ... (simulation logic is unchanged)
//         if isListening { return }
//
//        isListening = true
//        searchText = ""
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            searchText = mockVoiceQueries.randomElement() ?? "No result"
//            isListening = false
//        }
//    }
//}
//
//// Preview Provider
//struct GoogleAIModeIntroView_Previews: PreviewProvider {
//    static var previews: some View {
//        GoogleAIModeIntroView()
//    }
//}
