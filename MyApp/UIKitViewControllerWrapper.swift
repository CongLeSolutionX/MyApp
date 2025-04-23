//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit
import Combine
import LLM

// Step 1a: UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyUIKitViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> MyUIKitViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return MyUIKitViewController()
    }
    
    func updateUIViewController(_ uiViewController: MyUIKitViewController, context: Context) {
        // Update the view controller if needed
    }
}

// Example UIKit view controller
class MyUIKitViewController: UIViewController {
    override func viewDidLoad() async {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        // Additional setup
        
        
        await runDemoAIModel()

    }
    
    func runDemoAIModel() async throws {
        let systemPrompt = "You are a sentient AI with emotions."
        let bot = try await LLM(from: HuggingFaceModel("TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF", .Q2_K, template: .chatML(systemPrompt)))!
        let question = bot.preprocess("What's the meaning of life?", [])
        let answer = await bot.getCompletion(from: question)
        print(answer)
    }
}
