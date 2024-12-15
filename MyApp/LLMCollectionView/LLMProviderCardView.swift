//
//  AwardCardView.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//


import SwiftUI

struct LLMProviderCardView: View {
  var genAIProvider: LLMProviderInformation

  var body: some View {
    VStack {
      Image(genAIProvider.imageName)
        .shadow(radius: 10)
      Text(genAIProvider.title)
        .font(.title3)
      Text(genAIProvider.description)
        .font(.footnote)
      LLMProviderRatingStars(stars: genAIProvider.ratingStars)
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
    .saturation(genAIProvider.activatedLLMProvider ? 1.0 : 0.0)
    .opacity(genAIProvider.activatedLLMProvider ? 1.0 : 0.3)
    .clipShape(RoundedRectangle(cornerRadius: 25.0))
  }
}

// MARK: - Preview
#Preview("Gemini logo") {
  let genAIProvider = LLMProviderInformation(
    imageName: "Gemini_logo",
    title: "Gemini models",
    description: "Awarded the first time you open the app while at the airport.",
    activatedLLMProvider: true,
    ratingStars: 5
  )

  return LLMProviderCardView(genAIProvider: genAIProvider)
    .frame(width: 150, height: 220)
    .padding()
    .background(Color.black)
}
