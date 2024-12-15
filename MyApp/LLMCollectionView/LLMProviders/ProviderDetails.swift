//
//  AwardDetails.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//


import SwiftUI

struct ProviderDetails: View {
    var provider: LLMProviderInformation
    
    func imageSize(proxy: GeometryProxy) -> Double {
        let size = min(proxy.size.width, proxy.size.height)
        return size * 0.8
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Image(provider.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            Text(provider.title)
                .font(.title)
                .padding()
            Text(provider.description)
                .font(.body)
                .padding()
            LLMProviderRatingStars(stars: provider.ratingStars)
                .foregroundColor(.yellow)
                .shadow(color: .black, radius: 5)
            Spacer()
        }.padding()
            .opacity(provider.activatedLLMProvider ? 1.0 : 0.4)
            .saturation(provider.activatedLLMProvider ? 1 : 0)
        
        //TODO: Task 1 - Provide a list of gen AI models
        //TODO: Task 2 - Link each selected gen AI model to a corresponding `GenAICapabilityDetails` view
        VStack {
            Text("Model 1")
            Text("Model 2")
            Text("Model 1")
            Text("Model 2")
        }
    }
}

// MARK: - Previews
#Preview("Activated LLM View") {
    let genAIModel = LLMProviderInformation(
        imageName: "Gemini_logo",
        title: "Activated LLM",
        description: "Your LLM is activated and ready to serve your needs.",
        activatedLLMProvider: true,
        ratingStars: 5
    )
    
    return ProviderDetails(provider: genAIModel)
}


#Preview("Inactivated LLM View") {
    let genAIModel = LLMProviderInformation(
        imageName: "Apple_Intelligence_Logo",
        title: "Inactivated LLM",
        description: "Your LLM is not ready yet.",
        activatedLLMProvider: false,
        ratingStars: 1
    )
    
    return ProviderDetails(provider: genAIModel)
}
