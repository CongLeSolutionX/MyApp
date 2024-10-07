//
//  AssistantViewModel.swift
//  MyApp
//
//  Created by Cong Le on 10/7/24.
//

import Foundation
import Combine

class AssistantViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    let openAIService: OpenAIService

    init(openAIService: OpenAIService = OpenAIService()) {
        self.openAIService = openAIService
    }

    func sendMessage (message: String) {
        guard message != "" else {return}

        openAIService.makeRequest(message: OpenAIMessage(role: "user", content: message))
            .sink { completion in
                /// - Handle Error here
                switch completion {
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
}
