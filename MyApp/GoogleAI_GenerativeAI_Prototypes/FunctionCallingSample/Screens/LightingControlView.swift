//
//  LightingControlView.swift
//  MyApp
//
//  Created by Cong Le on 11/23/24.
//
import SwiftUI

struct LightingControlView: View {
    @State private var modelResponse: String = "Loading..."

    var body: some View {
        Text(modelResponse)
            .padding()
            .task {
                await demoLightingControl()
            }
    }
    
    func demoLightingControl() async {
        let controlLightFunctionDeclaration = FunctionDeclaration(
            name: "controlLight",
            description: "Set the brightness and color temperature of a room light.",
            parameters: [
                "brightness": Schema(
                    type: .string,
                    description: "Light level from 0 to 100. Zero is off and 100 is full brightness."
                ),
                "colorTemperature": Schema(
                    type: .string,
                    description: "Color temperature of the light fixture which can be `daylight`, `cool`, or `warm`."
                ),
            ],
            requiredParameters: ["brightness", "colorTemperature"]
        )

        // Initialize the generative model with the specified function declaration
        let generativeModel = GenerativeModel(
            name: "gemini-1.5-flash",
            apiKey: APIKey.default,
            tools: [Tool(functionDeclarations: [controlLightFunctionDeclaration])]
        )

        let chat = generativeModel.startChat()

        let prompt = "Dim the lights so the room feels cozy and warm."

        do {
            // Send the message to the generative model
            let response1 = try await chat.sendMessage(prompt)
            
            // Check if the model responded with a function call
            guard let functionCall = response1.functionCalls.first else {
                await MainActor.run {
                    self.modelResponse = "Model did not respond with a function call."
                }
                return
            }
            
            // Verify that the correct function was called
            guard functionCall.name == "controlLight" else {
                await MainActor.run {
                    self.modelResponse = "Unexpected function called: \(functionCall.name)"
                }
                return
            }
            
            // Extract and validate the function arguments
            guard case let .string(brightness) = functionCall.args["brightness"] else {
                await MainActor.run {
                    self.modelResponse = "Missing or invalid argument: brightness"
                }
                return
            }
            guard case let .string(colorTemp) = functionCall.args["colorTemperature"] else {
                await MainActor.run {
                    self.modelResponse = "Missing or invalid argument: colorTemperature"
                }
                return
            }
            
            // Call the hypothetical API with the extracted parameters
            let apiResponse = setLightValues(brightness: brightness, colorTemp: colorTemp)
            
            // Send the API response back to the model to generate user-friendly text
            let functionResponse = FunctionResponse(
                name: functionCall.name,
                response: apiResponse
            )
            let response = try await chat.sendMessage([
                ModelContent(
                    role: "function",
                    parts: [.functionResponse(functionResponse)]
                )
            ])
            
            // Update the UI with the model's response
            if let modelResponseText = response.text {
                await MainActor.run {
                    self.modelResponse = modelResponseText
                }
            } else {
                await MainActor.run {
                    self.modelResponse = "Model did not respond with text."
                }
            }
            
        } catch {
            // Handle errors appropriately
            await MainActor.run {
                self.modelResponse = "Error occurred: \(error.localizedDescription)"
            }
        }
    }
    
    func setLightValues(brightness: String, colorTemp: String) -> JSONObject {
        // Mock API response with the requested lighting values
        return [
            "brightness": .string(brightness),
            "colorTemperature": .string(colorTemp)
        ]
    }
}

// MARK: - Preview
#Preview {
    LightingControlView()
}
