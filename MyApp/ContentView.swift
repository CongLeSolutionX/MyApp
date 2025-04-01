//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}
import SwiftUI
import AVFoundation // Import AVFoundation for speech synthesis

// MARK: - Main Content View
struct ContentView: View {
    // State for the Pizza Control
    @State private var sliceCount: Int = 4
    let maxSlices = 8

    // State for the Modal Presentation
    @State private var isShowingScore: Bool = false
    let correctAnswers = 6 // Example score

    // Speech Synthesizer instance
    // Note: In a real app, manage its lifecycle more carefully (e.g., StateObject)
    let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {

                    // --- Section 1: Custom Adjustable Control (Pizza Slices) ---
                    GroupBox("Custom Adjustable Control") {
                        VStack(alignment: .leading) {
                            Text("Mimicking the custom pizza slice selector using native accessibility.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 5)

                            PizzaControlView(sliceCount: $sliceCount, maxSlices: maxSlices)
                        }
                        .padding(.vertical, 5)
                    }

                    // --- Section 2: Speech Synthesis (Bilingual Question) ---
                    GroupBox("Speech Synthesis (like SSML)") {
                        VStack(alignment: .leading) {
                            Text("Using AVSpeechSynthesizer to read text with different languages and rates, similar to SSML effects.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 5)

                            Button {
                                speakBilingualQuestion()
                            } label: {
                                Label("Read Bilingual Question", systemImage: "speaker.wave.2.fill")
                            }
                            // Accessibility for the button itself
                            .accessibilityLabel("Read bilingual question aloud")
                            .accessibilityHint("Plays the sample question using text-to-speech.")
                        }
                        .padding(.vertical, 5)
                    }

                    // --- Section 3: Modal Presentation (Quiz Score) ---
                    GroupBox("Modal Presentation (like <dialog>)") {
                         VStack(alignment: .leading) {
                            Text("Using a SwiftUI Sheet to present modal results, similar to the HTML dialog element.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 5)

                            Button("Show Score") {
                                isShowingScore = true
                            }
                            // Accessibility for the button
                            .accessibilityHint("Opens a modal view displaying your quiz score.")
                        }
                        .padding(.vertical, 5)
                    }

                    Spacer() // Pushes content to the top
                }
                .padding()
            }
            .navigationTitle("Web Accessibility Concepts")
            // Modal Sheet Presentation
            .sheet(isPresented: $isShowingScore) {
                // This is the view content presented modally
                ScoreSheetView(score: correctAnswers, totalQuestions: correctAnswers)
            }
        }
    }

    // MARK: - Speech Synthesis Logic
    func speakBilingualQuestion() {
        // Stop any previous speech
        synthesizer.stopSpeaking(at: .immediate)

        let questionPart1 = AVSpeechUtterance(string: "How do you say")
        questionPart1.voice = AVSpeechSynthesisVoice(language: "en-US")
        questionPart1.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9 // Slightly slower like prosody rate
        questionPart1.postUtteranceDelay = 0.1 // Short pause like <break>

        let phraseToTranslate = AVSpeechUtterance(string: "the water")
        phraseToTranslate.voice = AVSpeechSynthesisVoice(language: "en-US")
        phraseToTranslate.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8 // Slower emphasis
        phraseToTranslate.postUtteranceDelay = 0.1

        let questionPart2 = AVSpeechUtterance(string: "in Spanish?")
        questionPart2.voice = AVSpeechSynthesisVoice(language: "en-US")
        questionPart2.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        questionPart2.postUtteranceDelay = 0.2 // Longer pause before answers

        // Speak introduction
        synthesizer.speak(questionPart1)
        synthesizer.speak(phraseToTranslate)
        synthesizer.speak(questionPart2)

        // Speak Spanish answers
        let answers = ["El agua", "La abuela", "La abeja", "El árbol"]
        for answer in answers {
            let answerUtterance = AVSpeechUtterance(string: answer)
            // Use Spanish voice
            answerUtterance.voice = AVSpeechSynthesisVoice(language: "es-MX") // Explicitly Spanish (Mexico)
            answerUtterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8 // Consistent slower rate for answers
            answerUtterance.postUtteranceDelay = 0.15 // Pause between answers
            synthesizer.speak(answerUtterance)
        }
    }
}

// MARK: - Pizza Control View
struct PizzaControlView: View {
    @Binding var sliceCount: Int
    let maxSlices: Int
    let minSlices: Int = 0

    var body: some View {
        HStack {
            // Simple visual representation
            Image(systemName: "chart.pie.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
                .overlay(
                   // Crude slice indicator - more complex drawing possible
                   Text("\(sliceCount)")
                     .font(.caption)
                     .foregroundColor(.white)
                     .padding(2)
                     .background(Color.black.opacity(0.5))
                     .clipShape(Circle())
                )

            // Display text
            Text("\(sliceCount) \(sliceCount == 1 ? "slice" : "slices")")
                .font(.headline)

            Spacer() // Pushes content to the left

        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        // --- Accessibility Modifiers ---
        // Make the whole HStack the accessible element
        .accessibilityElement(children: .combine) // Combines text for reading
        .accessibilityLabel("Pizza Slices Selector") // What it is (like aria-label)
        .accessibilityValue(Text("\(sliceCount) \(sliceCount == 1 ? "slice" : "slices")")) // Current value (like aria-valuetext)
        .accessibilityAdjustableAction { direction in // Handles swipes (like keydown listener + role="slider")
            switch direction {
            case .increment:
                if sliceCount < maxSlices {
                    sliceCount += 1
                }
            case .decrement:
                if sliceCount > minSlices {
                    sliceCount -= 1
                }
            @unknown default:
                break // Handle future cases
            }
        }
        .accessibilityHint("Swipe up to add a slice, swipe down to remove a slice.") // User guidance
    }
}

// MARK: - Score Sheet View (Modal Content)
struct ScoreSheetView: View {
    let score: Int
    let totalQuestions: Int
    @Environment(\.dismiss) var dismiss // Environment value to dismiss the sheet

    var body: some View {
        NavigationView { // Provides a title bar and structure
            VStack(spacing: 20) {
                Image(systemName: score == totalQuestions ? "star.fill" : "xmark.octagon.fill")
                    .font(.system(size: 50))
                    .foregroundColor(score == totalQuestions ? .yellow : .red)

                // This Text often gets read first by VoiceOver because of structure.
                // Similar role to aria-labelledby pointing to the main content.
                Text("You got \(score) out of \(totalQuestions) questions correct.")
                    .font(.title2)
                    .multilineTextAlignment(.center)

                Text(score == totalQuestions ? "Great work!" : "Keep practicing!")
                    .font(.body)

                Button("Close") {
                    dismiss() // Action to close the sheet
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)
                // No specific autofocus needed here, SwiftUI usually focuses the first interactive element or reads content well.
                // The button's accessibility is automatically handled.
            }
            .padding()
            .navigationTitle("Quiz Results") // Title for the modal sheet
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { // Add explicit close button in toolbar as well (good practice)
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button("Done") {
                         dismiss()
                     }
                 }
            }
        }
        // The sheet itself handles modal behavior (trapping focus, dismissal gestures)
        // Accessibility announcement usually includes the Navigation Title first.
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
