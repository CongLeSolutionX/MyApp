//
//  GenAICapabilityDetails.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//


import SwiftUI

struct GenAICapabilityDetails: View {
    var generativeModel: GenAIInformation
    
    func imageSize(proxy: GeometryProxy) -> Double {
        let size = min(proxy.size.width, proxy.size.height)
        return size * 0.8
    }
    
    var body: some View {
        // TODO: Provide some description and information about the selected gen AI model, dynamically
        VStack(alignment: .center) {
            Image(generativeModel.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            Text(generativeModel.title)
                .font(.title)
                .padding()
            Text(generativeModel.description)
                .font(.body)
                .padding()
            LLMProviderRatingStars(stars: generativeModel.ratingStars)
                .foregroundColor(.yellow)
                .shadow(color: .black, radius: 5)
            Spacer()
        }.padding()
            .opacity(generativeModel.activatedGenerativeModel ? 1.0 : 0.4)
            .saturation(generativeModel.activatedGenerativeModel ? 1 : 0)
        
        // TODO: This list of capabilities should bve dynamically updated basedon selected gen AI model by name
        HStack {
            NavigationStack {
                List {
                    NavigationLink {
                        SummarizeScreen()
                    } label: {
                        Label("Text", systemImage: "doc.text")
                    }
                    NavigationLink {
                        PhotoReasoningScreen()
                    } label: {
                        Label("Multi-modal", systemImage: "doc.richtext")
                    }
                    NavigationLink {
                        ConversationScreen()
                            .environmentObject(ConversationViewModel())
                    } label: {
                        Label("Chat", systemImage: "ellipsis.message.fill")
                    }
                    NavigationLink {
                        FunctionCallingScreen().environmentObject(FunctionCallingViewModel())
                    } label: {
                        Label("Function Calling", systemImage: "function")
                    }
                }
                .navigationTitle("Available Capabilities")
            }
        }
    }
}

// MARK: - Previews
#Preview {
    let genAIModel = GenAIInformation(
        imageName: "Apple_Intelligence_Logo",
        title: "Apple",
        description: "This is anactived gen AI model",
        activatedGenerativeModel: true
    )
    
    return GenAICapabilityDetails(generativeModel: genAIModel)
}


//#Preview("Inactivated LLM View") {
//    let genAIModel = LLMProviderInformation(
//        imageName: "Apple_Intelligence_Logo",
//        title: "Inactivated LLM",
//        description: "Your LLM is not ready yet.",
//        activatedLLMProvider: false,
//        ratingStars: 1
//    )
//    
//    return GenAICapabilityDetails(generativeModel: genAIModel)
//}
