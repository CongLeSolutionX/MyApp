//
//  MediumArticleContentView.swift
//  MyApp
//
//  Created by Cong Le on 11/22/24.
//


import SwiftUI

struct MediumArticleContentView: View {
    @StateObject private var viewModel = ArticleViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                if let article = viewModel.article {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(article.title)
                            .font(.largeTitle)
                            .bold()
                            .padding(.bottom, 8)

                        Text("By \(article.author)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 16)

                        ForEach(article.content, id: \.self) { paragraph in
                            Text(paragraph)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding()
                } else {
                    ProgressView("Loading article...")
                        .onAppear {
                            viewModel.fetchArticle()
                        }
                }
            }
            .navigationTitle("Medium Article")
        }
    }
}


#Preview {
    MediumArticleContentView()
}
