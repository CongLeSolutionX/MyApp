//
//  SkeletonView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

struct Skeleton_ContentView: View {
    @State private var card: Card?
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                SomeCardView(card: card)
                SomeContactCard()
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .navigationTitle("Skeleton Effect")
            .toolbar {
                ToolbarItem {
                    Button("Tap", systemImage: "arrow.trianglehead.2.counterclockwise", action: toggleCard)
                }
            }
        }
    }
    
    @ViewBuilder
    func SomeContactCard() -> some View {
        let isLoading = card == nil
        
        VStack(alignment: .leading, spacing: 15) {
             HStack(spacing: 12) {
                 Group {
                     if isLoading {
                         SkeletonView(.circle)
                     } else {
                         Circle()
                             .fill(.indigo.gradient)
                             .overlay {
                                 Text("C")
                                     .font(.title.bold())
                                     .foregroundStyle(.white)
                             }
                     }
                 }
                 .frame(width: 60, height: 60)
                 
                 VStack(alignment: .leading, spacing: 6) {
                     ZStack {
                         if isLoading {
                             SkeletonView(.rect(cornerRadius: 5))
                                 .frame(height: 15)
                         } else {
                             Text("CongLeSolutionX")
                                 .font(.title3.bold())
                         }
                     }
                     
                     ZStack {
                         if isLoading {
                             SkeletonView(.rect(cornerRadius: 5))
                                 .frame(height: 15)
                         } else {
                             Text("Hello </> from SwiftUI!")
                                 .font(.callout)
                                 .foregroundStyle(.gray)
                         }
                     }
                     .padding(.trailing, 50)
                 }
                 .frame(maxWidth: .infinity, alignment: .leading)
             }
         }
         .padding(15)
         .background(.background)
         .clipShape(.rect(cornerRadius: 15))
         .shadow(color: .black.opacity(0.1), radius: 15)
    }
    
    func toggleCard() {
        withAnimation(.smooth) {
            if card == nil {
                card = .init(
                    image: "My-meme-orange",
                    title: "World Wide Developer Conference 2025",
                    subTitle: "From June 9th 2025",
                    description: "Be there for the reveal of the latest Apple tools, frameworks, and features. Learn to elevate your apps and games through video sessions hosted by Apple engineers and designers."
                )
            } else {
                card = nil
            }
        }
    }
}

struct Card: Identifiable {
    var id: String = UUID().uuidString
    var image: String
    var title: String
    var subTitle: String
    var description: String
}

struct SomeCardView: View {
    var card: Card?
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Rectangle()
                .foregroundStyle(.clear)
                .overlay {
                    if let card {
                        Image(card.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        SkeletonView(.rect)
                    }
                }
                .frame(height: 220)
                .clipped()
            
            VStack(alignment: .leading, spacing: 10) {
                if let card {
                    Text(card.title)
                        .fontWeight(.semibold)
                } else {
                    SkeletonView(.rect(cornerRadius: 5))
                        .frame(height: 20)
                }
                
                Group {
                    if let card {
                        Text(card.subTitle)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    } else {
                        SkeletonView(.rect(cornerRadius: 5))
                            .frame(height: 15)
                    }
                }
                .padding(.trailing, 30)
                
                ZStack {
                    if let card {
                        Text(card.description)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    } else {
                        SkeletonView(.rect(cornerRadius: 5))
                    }
                }
                .frame(height: 50)
                .lineLimit(3)
            }
            .padding([.horizontal, .top], 15)
            .padding(.bottom, 25)
        }
        .background(.background)
        .clipShape(.rect(cornerRadius: 15))
        .shadow(color: .black.opacity(0.1), radius: 10)
    }
}

// MARK: - Preview
#Preview {
    Skeleton_ContentView()
}
