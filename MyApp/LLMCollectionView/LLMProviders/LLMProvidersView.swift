//
//  LLMsView.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//


import SwiftUI

struct LLMProvidersView: View {
  @EnvironmentObject var llmProviderCollectionNavigation: LLMProviderSupplier
  @State var selectedLLMProvider: LLMProviderInformation?
  @Namespace var providerNamespace

  var llmProviderArray: [LLMProviderInformation] {
    llmProviderCollectionNavigation.llmProviderList
  }

  var llmColumns: [GridItem] {
    [GridItem(.adaptive(minimum: 150, maximum: 170))]
  }

  var activeLLMProviders: [LLMProviderInformation] {
    llmProviderArray.filter { $0.activatedLLMProvider }
  }

  var inactiveLLMProviders: [LLMProviderInformation] {
    llmProviderArray.filter { !$0.activatedLLMProvider }
  }

  var body: some View {
    ZStack {
      if let aiModelProvider = selectedLLMProvider {
        ProviderDetails(provider: aiModelProvider)
          .background(Color.white)
          .shadow(radius: 5.0)
          .clipShape(RoundedRectangle(cornerRadius: 20.0))
          .onTapGesture {
            withAnimation {
              selectedLLMProvider = nil
            }
          }
          .matchedGeometryEffect(
            id: aiModelProvider.hashValue,
            in: providerNamespace,
            anchor: .topLeading
          )
          .navigationTitle(aiModelProvider.title)
      } else {
        ScrollView {
          LazyVGrid(columns: llmColumns) {
            LLMProviderGrid(
              title: "Activated",
              providers: activeLLMProviders,
              selected: $selectedLLMProvider,
              namespace: providerNamespace
            )
            LLMProviderGrid(
              title: "Not Activated",
              providers: inactiveLLMProviders,
              selected: $selectedLLMProvider,
              namespace: providerNamespace
            )
          }
        }
        .navigationTitle("Your LLM Providers") // TODO: Dynamically update to user's name
      }
    }
    .background(
      Image("background-view")
        .resizable()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    )
  }
}

// MARK: - Previews
#Preview {
  NavigationStack {
    LLMProvidersView()
  }
  .environmentObject(LLMProviderSupplier())
}
