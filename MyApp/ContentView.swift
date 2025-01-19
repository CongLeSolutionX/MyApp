//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

/// Sample Image Model
struct ImageModel: Identifiable {
    var id: String = UUID().uuidString
    var altText: String
    var image: String
}

let images: [ImageModel] = [
    /// https://www.pexels.com/photo/green-palm-tree-near-white-and-black-dome-building-under-blue-sky-9002742/
    .init(altText: "Mo Eid", image: "Pic 1"),
    /// https://www.pexels.com/photo/a-gradient-wallpaper-7135121/
    .init(altText: "Codioful", image: "Pic 2"),
    /// https://www.pexels.com/photo/high-speed-photography-of-colorful-ink-diffusion-in-water-9669094/
    .init(altText: "Cottonbro", image: "Pic 3"),
    /// https://www.pexels.com/photo/multicolored-abstract-painting-2868948/
    .init(altText: "Anni", image: "Pic 4")
]

struct ContentView: View {
    @State private var changeSize: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Usage:")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    
                    Text(
                """
                LoopingStack {
                    // Views
                }
                """
                    )
                    .foregroundStyle(.primary.opacity(0.7))
                    .monospaced()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(15)
                    .background(.background, in: .rect(cornerRadius: 15))
                }
                .padding([.horizontal, .top], 15)
                .padding(.bottom, 30)
                
                GeometryReader {
                    let width = $0.size.width
                    
                    LoopingStack(visibleCardsCount: 3, maxTranslationWidth: changeSize ? width : nil) {
                        ForEach(images) { image in
                            Image(image.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: changeSize ? 150 : 250, height: changeSize ? 150 : 400)
                                .clipShape(.rect(cornerRadius: 30))
                                .padding(5)
                                .background {
                                    RoundedRectangle(cornerRadius: 35)
                                        .fill(.background)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
                
                Toggle("Minimise Stack", isOn: $changeSize)
                    .padding(15)
                    .background(.background, in: .rect(cornerRadius: 15))
                    .padding(15)
            }
            .animation(.bouncy, value: changeSize)
            .navigationTitle("Looping Stack")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.gray.opacity(0.2))
        }
    }
}
// MARK: - Preview

// After iOS 17, we can use this syntax for preview:
#Preview {
    ContentView()
}


// Before iOS 17, use this syntax for preview UIKit view controller
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper()
    }
}
