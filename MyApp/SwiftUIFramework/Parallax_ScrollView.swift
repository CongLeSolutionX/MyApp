//
//  Parallax_ScrollView.swift
//  MyApp
//
//  Created by Cong Le on 11/28/24.
//


import SwiftUI

struct Parallax_ScrollView: View {
    let imageNames = [
        "My-meme-original",
        "My-meme-microphone",
        "My-meme-heineken",
        "My-meme-red-wine-glass",
        "My-meme-cordyceps"
    ]

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 16) {
                ForEach(imageNames, id: \.self) { imageName in
                    VStack {
                        ZStack {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .scrollTransition(axis: .horizontal) { content, phase in
                                    content
                                        .offset(x: phase.isIdentity ? 0 : phase.value * -200)
                                }
                        }
                        .containerRelativeFrame(.horizontal)
                        .clipShape(RoundedRectangle(cornerRadius: 36))
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 5, y:10)
                        .scrollTransition(axis: .horizontal) { content, phase in
                            content.scaleEffect(phase.isIdentity ? 1 : 0.95)
                        }

                        Text(imageName)
                            .scrollTransition(axis: .horizontal) { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .offset(x: phase.value * 100)
                            }
                    }
                }
            }
        }
        .contentMargins(32)
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
    }
}

// MARK: - Preview
#Preview {
    Parallax_ScrollView()
}
