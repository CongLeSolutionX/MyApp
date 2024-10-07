//
//  AssistantView.swift
//  MyApp
//
//  Created by Cong Le on 10/7/24.
//

import SwiftUICore
import SwiftUI

struct AssistantView: View {
    @ObservedObject var viewModel: AssistantViewModel = AssistantViewModel()
    @StateObject var speechRecognizer = SpeechRecognizer()

    @State private var isRecording = false

    var body: some View {
        VStack {
            Button {
                endRecording()
            } label: {
                if isRecording {
                    RoundAnimation()
                }

                Image(systemName: "mic.circle")
                    .frame(height: 100)
                    .foregroundColor(.blue)
                    .font(.system(size: 70))
                    .padding()
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.1).onEnded { _ in
                    startRecording()
                })
        }
        .padding()
    }

    @MainActor private func startRecording() {
        print("Debug: Start transcription")
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        isRecording = true
    }

    @MainActor private func endRecording() {
        speechRecognizer.stopTranscribing()
        isRecording = false
        print("Stopped", speechRecognizer.transcript)
        viewModel.sendMessage(message: speechRecognizer.transcript)

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
    AssistantView()
}
