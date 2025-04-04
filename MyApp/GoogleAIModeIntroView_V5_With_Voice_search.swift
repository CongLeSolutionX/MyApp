////
////  GoogleAIModeIntroView_V5_With_Voice_search.swift
////  MyApp
////
////  Created by Cong Le on 4/4/25.
////
//
//import SwiftUI
//import AVFoundation // Still needed
//
//struct GoogleAIModeIntroView: View {
//    // --- State variables ---
//    @State private var isExperimentOn = true
//    @State private var searchText = ""
//    // Add didSet observers for logging state changes
//    @State private var isListening = false {
//        didSet {
//            print("[State Change] isListening updated to: \(isListening)")
//        }
//    }
//
//    enum PermissionStatus: String { case undetermined, granted, denied }
//    @State private var micPermissionStatus: PermissionStatus = .undetermined {
//         didSet {
//             print("[State Change] micPermissionStatus updated to: \(micPermissionStatus.rawValue)")
//         }
//     }
//    @State private var showMicDeniedAlert = false {
//         didSet {
//             print("[State Change] showMicDeniedAlert updated to: \(showMicDeniedAlert)")
//         }
//     }
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
//        .onAppear {
//            print("[Lifecycle] GoogleAIModeIntroView appeared. Checking initial mic permission.")
//            checkInitialMicPermission()
//        }
//        .alert("Microphone Access Denied", isPresented: $showMicDeniedAlert) {
//            Button("Open Settings") {
//                print("[Alert Action] User tapped 'Open Settings'")
//                if let url = URL(string: UIApplication.openSettingsURLString),
//                   UIApplication.shared.canOpenURL(url) {
//                    print("Attempting to open settings URL...")
//                    UIApplication.shared.open(url)
//                } else {
//                    print("Could not open settings URL.")
//                }
//            }
//            Button("Cancel", role: .cancel) {
//                 print("[Alert Action] User tapped 'Cancel'")
//            }
//        } message: {
//            Text("To use voice input, please enable microphone access for this app in the Settings.")
//        }
//    }
//
//    // --- searchBarArea ViewBuilder ---
//     @ViewBuilder
//    private func searchBarArea() -> some View {
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
//                    print("[UI Action] Microphone button tapped.")
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
//                .disabled(micPermissionStatus == .denied || isListening) // Disable if denied OR already listening
//                .padding(.trailing, 5)
//
//
//                Image(systemName: "camera.viewfinder")
//                    .foregroundColor(micPermissionStatus == .denied ? .gray : .white)
//                    .padding(.trailing, 20)
//                    .padding(.leading, 5)
//                    .allowsHitTesting(micPermissionStatus != .denied)
//                    .onTapGesture {
//                         print("[UI Action] Camera button tapped (if enabled).")
//                         // Add camera action logic here if needed
//                     }
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
//    // --- introductoryContent ViewBuilder ---
//     @ViewBuilder
//    private func introductoryContent() -> some View {
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
//               Toggle("", isOn: $isExperimentOn.animation()) // Animate toggle
//                   .labelsHidden()
//                   .tint(buttonBlue)
//                   .onChange(of: isExperimentOn) { newValue in
//                         print("[State Change] isExperimentOn toggled to: \(newValue)")
//                   }
//           }
//           .padding()
//           .background(darkerGrayElement)
//           .cornerRadius(15)
//
//           // Try AI Mode Button
//           Button {
//               print("[UI Action] 'Try AI Mode' button tapped.")
//                // Add action for this button if needed
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
//        // Add .onAppear here if you need specific logs for this part
//        .onAppear {
//            print("[Lifecycle] introductoryContent appeared.")
//        }
//    }
//
//    // --- aiIcon ViewBuilder ---
//     @ViewBuilder
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
//    // --- Action & Permission Handling Functions (UPDATED with logging) ---
//
//    private func handleMicTap() {
//        print("[Function Call] handleMicTap() called. Current Status: \(micPermissionStatus.rawValue)")
//        switch micPermissionStatus {
//        case .granted:
//            print("  -> Permission Granted. Calling startVoiceInputSimulation().")
//            startVoiceInputSimulation()
//        case .undetermined:
//            print("  -> Permission Undetermined. Calling requestMicPermission().")
//            requestMicPermission()
//        case .denied:
//            print("  -> Permission Denied. Setting showMicDeniedAlert to true.")
//            showMicDeniedAlert = true
//        }
//    }
//
//    private func checkInitialMicPermission() {
//        print("[Function Call] checkInitialMicPermission() called.")
//        let currentPermission = AVAudioApplication.shared.recordPermission
//        print("  -> Current AVAudioApplication.recordPermission: \(currentPermission.rawValue)")
//
//        switch currentPermission {
//        case .granted:
//            self.micPermissionStatus = .granted // Use self explicitly if needed for clarity inside func
//        case .denied:
//            self.micPermissionStatus = .denied
//        case .undetermined:
//            self.micPermissionStatus = .undetermined
//        @unknown default:
//             print("  -> Encountered @unknown default case for recordPermission.")
//            self.micPermissionStatus = .undetermined
//        }
//        // State change log will be handled by didSet on micPermissionStatus
//    }
//
//    private func requestMicPermission() {
//        print("[Function Call] requestMicPermission() called. Requesting from AVAudioApplication...")
//        AVAudioApplication.requestRecordPermission { granted in
//             print("[Permission Callback] requestRecordPermission completed. Granted: \(granted)")
//            // Ensure UI updates happen on the main thread
//            DispatchQueue.main.async {
//                print("  -> Updating state on main thread.")
//                self.micPermissionStatus = granted ? .granted : .denied
//                if granted {
//                    print("    -> Permission was granted. Calling startVoiceInputSimulation().")
//                    startVoiceInputSimulation()
//                } else {
//                    print("    -> Permission was denied. Setting showMicDeniedAlert to true.")
//                    showMicDeniedAlert = true
//                }
//                 // State change logs will be handled by didSet observers
//            }
//        }
//    }
//
//    private func startVoiceInputSimulation() {
//        print("[Function Call] startVoiceInputSimulation() called.")
//        guard !isListening else {
//            print("  -> Already listening. Doing nothing.")
//            return
//        }
//        print("  -> Starting voice input simulation.")
//
//        isListening = true // Log handled by didSet
//        searchText = ""    // Resetting search text
//        print("   -> Search text cleared.")
//
//
//        let delay = 2.0
//         print("   -> Scheduling simulated result after \(delay) seconds.")
//        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//             print("[Simulation] Delay finished. Simulating voice input result.")
//            let randomQuery = mockVoiceQueries.randomElement() ?? "No result"
//             print("    -> Simulated query: '\(randomQuery)'")
//            searchText = randomQuery
//            isListening = false // Log handled by didSet
//            print("  -> Voice input simulation finished.")
//        }
//    }
//}
//
//// Ensure AVAudioSession.RecordPermission rawValue is accessible if needed for logging
//// (It usually is by default)
//extension AVAudioSession.RecordPermission: @retroactive CustomStringConvertible {
//    // Optional: Provide more descriptive names if needed
//    public var description: String {
//         switch self {
//         case .undetermined: return "undetermined"
//         case .denied: return "denied"
//         case .granted: return "granted"
//         @unknown default: return "unknown"
//         }
//     }
//}
//
//
//// Preview Provider
//struct GoogleAIModeIntroView_Previews: PreviewProvider {
//    static var previews: some View {
//        GoogleAIModeIntroView()
//            .onAppear {
//                 print("[Preview] GoogleAIModeIntroView preview appearing.")
//            }
//    }
//}
