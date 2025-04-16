//
//  MyApp.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

// Step 3: Embed in main app structure
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            //ContentView()
            NavigationView {
                ContentView()
               // CardBasedGeminiChatView()
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var voiceManager = VoiceInputManager()
    @State private var inputText = ""
    @State private var isProcessing = false
    
    var body: some View {
        VStack {
            VoiceInputAreaView(
                userInput: $inputText,
                isProcessing: isProcessing,
                placeholder: "Ask Gemini...",
                sendMessageAction: {
                    guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    isProcessing = true
                    print("Send message: \(inputText)")
                    // Simulate process
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isProcessing = false
                        inputText = ""
                    }
                },
                voiceManager: voiceManager
            )
            .padding()
            
            Spacer()
        }
    }
}
