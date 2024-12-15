//
//  AppEnvironment.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//


import SwiftUI

class AppEnvironment: ObservableObject {
    @Published var lastAppLaunchId: Int?
    @Published var llmProviderList: [LLMProviderInformation] = []
    
    init() {
        loadActivatedLLMProviders()
        loadInactivatedLLMProviders()
    }
    
    func loadActivatedLLMProviders() {
        llmProviderList.append(
            LLMProviderInformation(
                imageName: "OpenAI_logo",
                title: "OpenAI",
                description: "Generative AI Model from OpenAI.",
                activatedLLMProvider: true,
                ratingStars: 5
            )
        )
        
        llmProviderList.append(
            LLMProviderInformation(
                imageName: "Gemini_logo",
                title: "Gemini",
                description: "Gemini AI models from Google",
                activatedLLMProvider: true,
                ratingStars: 5
            )
        )
    }
    
    func loadInactivatedLLMProviders() {
        llmProviderList.append(
            LLMProviderInformation(
                imageName: "Perplexity_logo",
                title: "Perplexity",
                description: "Perplexity AI Model",
                activatedLLMProvider: false,
                ratingStars: 2
            )
        )
        llmProviderList.append(
            LLMProviderInformation(
                imageName: "Midjourney_logo",
                title: "Midjourney",
                description: "Midjourney AI Model",
                activatedLLMProvider: false,
                ratingStars: 2
            )
        )
        llmProviderList.append(
            LLMProviderInformation(
                imageName: "Grok_logo",
                title: "Grok",
                description: "Grok AI models",
                activatedLLMProvider: false,
                ratingStars: 3
            )
        )
        llmProviderList.append(
            LLMProviderInformation(
                imageName: "Copilot_logo",
                title: "Copilot",
                description: "Copilot AI models",
                activatedLLMProvider: false,
                ratingStars: 3
            )
        )
        llmProviderList.append(
            LLMProviderInformation(
                imageName: "Claude_logo",
                title: "Claude",
                description: "Gen AI models from Claude",
                activatedLLMProvider: false,
                ratingStars: 2
            )
        )
        llmProviderList.append(
            LLMProviderInformation(
                imageName: "Arc_logo",
                title: "Arc",
                description: "Gen AI Models from Arc",
                activatedLLMProvider: false,
                ratingStars: 3
            )
        )
        llmProviderList.append(
            LLMProviderInformation(
                imageName: "Apple_Intelligence_logo_3",
                title: "Appple",
                description: "Gen AI from Apple",
                activatedLLMProvider: false,
                ratingStars: 2
            )
        )
    }
}
