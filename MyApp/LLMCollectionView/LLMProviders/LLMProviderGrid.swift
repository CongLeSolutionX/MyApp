//
//  AwardGrid.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//


import SwiftUI

struct LLMProviderGrid: View {
  var title: String
  var providers: [LLMProviderInformation]
  @Binding var selected: LLMProviderInformation?
  var namespace: Namespace.ID

  var body: some View {
    Section(
      header: Text(title)
        .frame(maxWidth: .infinity)
        .font(.title)
        .foregroundColor(.white)
        .background(
          .ultraThinMaterial,
          in: RoundedRectangle(cornerRadius: 10)
        )
    ) {
      ForEach(providers, id: \.self) { provider in
        LLMProviderCardView(genAIProvider: provider)
          .foregroundColor(.black)
          .aspectRatio(0.67, contentMode: .fit)
          .onTapGesture {
            withAnimation {
              selected = provider
            }
          }
          .matchedGeometryEffect(
            id: provider.hashValue,
            in: namespace,
            anchor: .topLeading
          )
      }
    }
  }
}

#Preview {
  @Previewable @Namespace var namespace

  return LLMProviderGrid(
    title: "Test",
    providers: AppEnvironment().llmProviderList,
    selected: .constant(nil),
    namespace: namespace
  )
}
