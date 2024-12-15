//
//  GenAIModelsView.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//


import SwiftUI

struct GenAIModelsView: View {
    @EnvironmentObject var genAIModelListNavigation: GenAIModels
    @State var selectedGenAIModel: GenAIInformation?
    @Namespace var genAIModelNamespace
    
    var genAIModelArray: [GenAIInformation] {
        genAIModelListNavigation.genAIModelList
        
    }
    
    var genAIModelColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 150, maximum: 170))]
    }
    
    var activeGenAIModels: [GenAIInformation] {
        genAIModelArray.filter { $0.activatedGenerativeModel }
    }
    
    var inactiveGenAIModels: [GenAIInformation] {
        genAIModelArray.filter { !$0.activatedGenerativeModel }
    }
    
    var body: some View {
        ZStack {
            if let genAIModel = selectedGenAIModel {
                GenAICapabilityDetails(generativeModel: genAIModel)
                    .background(Color.white)
                    .shadow(radius: 5.0)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
                    .onTapGesture {
                        withAnimation {
                            selectedGenAIModel = nil
                        }
                    }
                    .matchedGeometryEffect(
                        id: genAIModel.hashValue,
                        in: genAIModelNamespace,
                        anchor: .topLeading
                    )
                    .navigationTitle(genAIModel.title)
            } else {
                ScrollView {
                    LazyVGrid(columns: genAIModelColumns) {
                        GenAIModelGrid(
                            title: "Activated",
                            genAIModels: activeGenAIModels,
                            selected: $selectedGenAIModel,
                            namespace: genAIModelNamespace
                        )
                    }
                    .navigationTitle("Available Gen AI Models") // TODO: Dynamically update to selected LLM provider's names
                }
            }
        }
    }
}

// MARK: - Previews
#Preview {
    NavigationStack {
        GenAIModelsView()
    }
    .environmentObject(GenAIModels())
}

