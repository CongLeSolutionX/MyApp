//
//  AssistantViewModel.swift
//  MyApp
//
//  Created by Cong Le on 10/7/24.
//

import Foundation
import Combine
import AVFAudio
import AVFoundation

class AssistantViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    var player: AVAudioPlayer?
    
    let openAIService: OpenAIService

    init(openAIService: OpenAIService = OpenAIService()) {
        self.openAIService = openAIService
    }
    
    func sendMessage (message: String) async {
        guard message != "" else {return}

        openAIService.makeRequest(message: OpenAIMessage(role: "user", content: message))
            .sink { completion in
                /// - Handle Error here
                switch completion {
                //TODO: update to better handling methods
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { response in
                self.handleResponse(response: response)
            }
            .store(in: &cancellables)
    }

    func handleResponse(response: OpenAIResponse) {
        guard let message = response.choices.first?.message else { return }

        if let functionCall = message.function_call {
            handleFunctionCall(functionCall: functionCall)
        } else if let textResponse = message.content?.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\""))) {
            print("Response", textResponse)
            saveAndPlayAudio(text: textResponse)
            
        }
    }

    func handleFunctionCall(functionCall: FunctionCall) {
        self.openAIService.handleFunctionCall(functionCall: functionCall) { result in
            switch result {
            case .success(let functionResponse):
                self.openAIService.makeRequest(
                    message: OpenAIMessage(
                        role: "function",
                        content: functionResponse,
                        name: functionCall.name
                    )
                )
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error): print("error", error)
                    case .finished: break
                    }
                }, receiveValue: { response in
                    guard let responseMessage = response.choices.first?.message else {
                        return
                    }
                    guard let textResponse = responseMessage.content?
                        .trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\""))) else {return}

                    print("Function Call Response", textResponse)
                })
                .store(in: &self.cancellables)

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func saveAndPlayAudio(text: String) {
        openAIService.tts(text: text)
            .sink { completion in
                /// - Handle Error here
                switch completion {
                //TODO: update to better handling methods
                case .failure(let error): print(error.localizedDescription)
                case .finished: break
                }
            } receiveValue: { data in
                let tempDirectory = FileManager.default.temporaryDirectory
                let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("wav")
                do {
                    try data.write(to: tempFileURL)
                    self.playAudio(url: tempFileURL)
                } catch {
                    print("Error saving audio", error)
                }
            }
            .store(in: &cancellables)
    }

    func playAudio(url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}
