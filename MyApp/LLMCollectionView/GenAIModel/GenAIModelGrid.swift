//
//  GenAIModelGrid.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//


import SwiftUI

struct GenAIModelGrid: View {
    var title: String
    var genAIModels: [GenAIInformation]
    @Binding var selected: GenAIInformation?
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
            ForEach(genAIModels, id: \.self) { genAIModel in
                GenAIModelCardView(genAIModel: genAIModel)
                    .foregroundColor(.black)
                    .aspectRatio(0.67, contentMode: .fit)
                    .onTapGesture {
                        withAnimation {
                            selected = genAIModel
                        }
                    }
                    .matchedGeometryEffect(
                        id: genAIModel.hashValue,
                        in: namespace,
                        anchor: .topLeading
                    )
            }
        }
    }
}

// MARK: - Previews
#Preview {
    @Previewable @Namespace var namespace
    
    return GenAIModelGrid(
        title: "Testing Gen AI model",
        genAIModels: GenAIModels().genAIModelList,
        selected: .constant(nil),
        namespace: namespace
    )
}
