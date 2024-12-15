//
//  GenAIModelCardView.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//


import SwiftUI

struct GenAIModelCardView: View {
    var genAIModel: GenAIInformation
    
    var body: some View {
        VStack {
            Image(genAIModel.imageName)
                .shadow(radius: 10)
            Text(genAIModel.title)
                .font(.title3)
            Text(genAIModel.description)
                .font(.footnote)
            GenAIModelRatingStars(stars: genAIModel.ratingStars)
                .foregroundColor(.yellow)
                .shadow(color: .black, radius: 5)
                .offset(x: -5.0)
            Spacer()
        }
        .padding(10.0)
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [Color.white, Color(red: 0.0, green: 0.5, blue: 1.0)]
                ),
                startPoint: .bottomLeading,
                endPoint: .topTrailing)
        )
        .background(Color.white)
        .saturation(genAIModel.activatedGenerativeModel ? 1.0 : 0.0)
        .opacity(genAIModel.activatedGenerativeModel ? 1.0 : 0.3)
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
    }
}

// MARK: - Preview
#Preview("Gemini gen AI model 1") {
    let genAIModel = GenAIInformation(
        imageName: "Gemini_logo",
        title: "Gemini gen AI model 1",
        description: "This is a gen Ai model from Google",
        activatedGenerativeModel: true,
        ratingStars: 5
    )
    
    return GenAIModelCardView(genAIModel: genAIModel)
        .frame(width: 150, height: 220)
        .padding()
        .background(Color.black)
}
