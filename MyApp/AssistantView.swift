//
//  AssistantView.swift
//  MyApp
//
//  Created by Cong Le on 10/7/24.
//

import SwiftUICore
import SwiftUI

struct AssistantView: View {
    @ObservedObject var viewModel: AssistantViewModel
    @StateObject var speechRecognizer = SpeechRecognizer()

    @State private var isRecording = false

    init(viewModel: AssistantViewModel) { // Inject the view model
      self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Button {
                if isRecording {
                    Task {
                        await endRecording()
                    }
                }
            } label: {
                VStack { // Center content better
                    if isRecording {
                        RoundAnimation()
                    }
                    Image(systemName: "mic.circle")
                        .font(.system(size: 70))
                        .foregroundColor(.blue)
                }
                .frame(height: 100) // Set the frame for the container
                .padding()

            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.1)
                    .onEnded { _ in
                        Task { // Use a Task to handle the async operation
                            await startRecording()
                        }
                    })
        }
        .padding()
    }

    @MainActor private func startRecording() async {
        isRecording = true // Set isRecording to true immediately
        print("Debug: Start transcription")
        await speechRecognizer.resetTranscript()
        await speechRecognizer.startTranscribing()
    }


    @MainActor private func endRecording() async {
        await speechRecognizer.stopTranscribing()
        isRecording = false
        await viewModel.sendMessage(message: speechRecognizer.transcript)
        print("Debug: Stopped transcription", speechRecognizer.transcript)

        Task { // Reset the transcript after sending for the next recording
            await speechRecognizer.resetTranscript()
        }
    }
}


struct RoundAnimation: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(AngularGradient(gradient: Gradient(colors: [.blue, .purple]), center: .center), style: StrokeStyle(lineWidth: 8, lineCap: .round))
            .frame(width: 100, height: 100)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Preview
#Preview {
    RoundAnimation()
    AssistantView(viewModel: AssistantViewModel())
}