//
//  GenAIModels.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//


import SwiftUI

class GenAIModels: ObservableObject {
    @Published var genAIModelList: [GenAIInformation] = []
    
    init() {
        loadActivatedGenAIModels()
    }
    
    func loadActivatedGenAIModels() {
        genAIModelList.append(
            GenAIInformation(
                imageName: "Gemini_logo",
                title: "Gemini AI model 1",
                description: "Name of selected Gemini AI Model",
                activatedGenerativeModel: true,
                ratingStars: 5
            )
        )
        
        genAIModelList.append(
            GenAIInformation(
                imageName: "Gemini_logo",
                title: "Gemini AI model 2",
                description: "Name of selected Gemini AI Model",
                activatedGenerativeModel: true,
                ratingStars: 5
            )
        )
        
        genAIModelList.append(
            GenAIInformation(
                imageName: "Gemini_logo",
                title: "Gemini AI model 3",
                description: "Name of selected Gemini AI Model",
                activatedGenerativeModel: true,
                ratingStars: 5
            )
        )
        
        genAIModelList.append(
            GenAIInformation(
                imageName: "Gemini_logo",
                title: "Gemini AI model 4",
                description: "Name of selected Gemini AI Model",
                activatedGenerativeModel: true,
                ratingStars: 5
            )
        )
    }
}
