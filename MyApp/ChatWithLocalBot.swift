////
////  UIKitViewControllerWrapper.swift
////  MyApp
////
////  Created by Cong Le on 8/19/24.
////
//
//import SwiftUI
//import UIKit
//import Combine
//import LLM // Assuming your LLM framework code is imported
//
//// Step 1a: UIViewControllerRepresentable Implementation
//struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
//    typealias UIViewControllerType = MyUIViewController
//
//    // Step 1b: Required methods implementation
//    func makeUIViewController(context: Context) -> MyUIViewController {
//        // Step 1c: Instantiate and return the UIKit view controller
//        return MyUIViewController()
//    }
//
//    func updateUIViewController(_ uiViewController: MyUIViewController, context: Context) {
//        // Update the view controller if needed
//    }
//}
//
//// Example UIKit view controller
//class MyUIViewController: UIViewController {
//    // Corrected viewDidLoad: Remove 'async' and 'override' (or keep 'override' if superclass has viewDidLoad)
//    override func viewDidLoad() { // REMOVED async
//        super.viewDidLoad()
//        view.backgroundColor = .systemBlue
//        // Additional setup
//
//        // FIX 1: Launch an asynchronous Task from synchronous viewDidLoad
//        Task {
//            // FIX 2: Use 'try' inside a do-catch block to handle potential errors
//            do {
//                try await runDemoAIModel()
//            } catch {
//                // Handle the error appropriately, e.g., show an alert to the user
//                print("Error running demo AI model: \(error)")
//                // You might want to update UI here to show the error state
//            }
//        }
//    }
//
//    // The throwing async function remains the same
//    func runDemoAIModel() async throws {
//        let systemPrompt = "You are a sentient AI with emotions."
//        // Note: Force unwrapping LLM init with '!' is dangerous. Better to handle potential nil.
//        // Consider using optional binding or throwing a specific error if init fails.
//        // For this example, keeping the '!' as in original, but know it's risky.
//        // https://huggingface.co/arcee-ai/Arcee-VyLinh-GGUF
//        // vylinh-3b-q8_0.gguf
//        // TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF
//        let bot = try await LLM(from: HuggingFaceModel("arcee-ai/Arcee-VyLinh-GGUF", .Q8_0, template: .chatML(systemPrompt)))!
//        let question = bot.preprocess("Đời là gì?", [])
//        let answer = await bot.getCompletion(from: question)
//        print(answer)
//    }
//}
