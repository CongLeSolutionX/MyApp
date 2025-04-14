////
////  ArticleView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/13/25.
////
//
//import Foundation
//
//struct NewArticle: Identifiable, Codable {
//    let id: UUID
//    let category: String
//    let title: String
//    let body: [String]
//    let highlightedWords: [String]
//    var claps: Int
//    var comments: [Comment]
//    var saved: Bool
//    
//    static func sampleArticle() -> NewArticle {
//        NewArticle(
//            id: UUID(),
//            category: "Design & UX",
//            title: "The SwiftUI Navigation Airspace: Calm or Chaos?",
//            body: [
//                "Building a new feature often feels like scheduling a flight at a small regional airport...",
//                "Navigation in SwiftUI mirrors this simplicity when building lightweight apps: just a few NavigationDestination closures...",
//                "But as your app expands, so does your airspace complexity..."
//            ],
//            highlightedWords: ["NavigationDestination"],
//            claps: 48,
//            comments: Comment.sampleComments(),
//            saved: false
//        )
//    }
//}
//
//struct Comment: Identifiable, Codable {
//    let id: UUID
//    let user: String
//    let message: String
//    let date: Date
//    
//    static func sampleComments() -> [Comment] {
//        [
//            Comment(id: UUID(), user: "Sarah Green", message: "Great insights! Helped me a lot!", date: Date()),
//            Comment(id: UUID(), user: "John Appleseed", message: "Loved the analogy!", date: Date())
//        ]
//    }
//}
//
//import SwiftUI
//import Combine
//
//class ArticleViewModel: ObservableObject {
//    @Published var article: NewArticle
//    
//    init(article: NewArticle) {
//        self.article = article
//    }
//    
//    func toggleSave() {
//        article.saved.toggle()
//    }
//    
//    func addClap() {
//        article.claps += 1
//    }
//    
//    func addComment(user: String, message: String) {
//        article.comments.append(Comment(id: UUID(), user: user, message: message, date: Date()))
//    }
//}
//
//import SwiftUI
//
//struct ArticleView: View {
//    @StateObject private var viewModel = ArticleViewModel(article: .sampleArticle())
//    @State private var showingComments = false
//    @State private var showingShareSheet = false
//    @State private var newCommentText = ""
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 24) {
//
//                introSection
//                
//                contentSection
//                
//                interactionSection
//                
//                if showingComments {
//                    commentSection
//                }
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 24)
//        }
//        .background(Color(.systemBackground))
//        .sheet(isPresented: $showingShareSheet) {
//            shareSheet
//        }
//    }
//}
//
//// MARK: - UI Sections
//
//extension ArticleView {
//    
//    private var introSection: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(viewModel.article.category)
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//            
//            Text(viewModel.article.title)
//                .font(.largeTitle)
//                .bold()
//        }
//    }
//    
//    private var contentSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            ForEach(viewModel.article.body, id: \.self) { paragraph in
//                highlightedText(paragraph)
//            }
//        }
//        .font(.body)
//        .foregroundStyle(.primary)
//    }
//    
//    private func highlightedText(_ paragraph: String) -> some View {
//        viewModel.article.highlightedWords.reduce(Text(paragraph)) { accum, word in
//            accum.replace(word, with: Text(word).bold().foregroundColor(.blue))
//        }
//    }
//    
//    private var interactionSection: some View {
//        HStack(spacing: 32) {
//
//            VStack {
//                Button {
//                    viewModel.addClap()
//                } label: {
//                    Image(systemName: "hands.clap.fill")
//                }
//                Text("\(viewModel.article.claps)")
//            }
//
//            VStack {
//                Button {
//                    withAnimation {
//                        showingComments.toggle()
//                    }
//                } label: {
//                    Image(systemName: "bubble.left")
//                }
//                Text("\(viewModel.article.comments.count)")
//            }
//
//            VStack {
//                Button {
//                    viewModel.toggleSave()
//                } label: {
//                    Image(systemName: viewModel.article.saved ? "bookmark.fill" : "bookmark")
//                }
//            }
//
//            VStack {
//                Button {
//                    showingShareSheet = true
//                } label: {
//                    Image(systemName: "square.and.arrow.up")
//                }
//            }
//        }
//        .font(.headline)
//        .padding()
//        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemFill)))
//    }
//    
//    private var commentSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Comments")
//                .font(.headline)
//
//            ForEach(viewModel.article.comments) { comment in
//                VStack(alignment: .leading) {
//                    Text(comment.user)
//                        .bold()
//                    Text(comment.message)
//                        .foregroundStyle(.secondary)
//                    Text(comment.date, style: .date)
//                        .font(.caption2)
//                }
//                .padding(8)
//                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.tertiarySystemFill)))
//            }
//
//            newCommentField
//        }
//    }
//    
//    private var newCommentField: some View {
//        HStack {
//            TextField("Add your comment...", text: $newCommentText)
//                .textFieldStyle(.roundedBorder)
//            
//            Button("Send") {
//                guard !newCommentText.isEmpty else { return }
//                viewModel.addComment(user: "You", message: newCommentText)
//                newCommentText = ""
//            }
//        }
//    }
//    
//    private var shareSheet: some View {
//        NavigationStack {
//            ShareLink(item: viewModel.article.title)
//                .navigationTitle("Share Article")
//                .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//
//// Replace helper
//extension Text {
//    func replace(_ target: String, with replacement: Text) -> Text {
//        guard let range = self.storage.range(of: target) else { return self }
//        let before = String(self.storage[..<range.lowerBound])
//        let after = String(self.storage[range.upperBound...])
//        return Text(before) + replacement + Text(after)
//    }
//
//    private var storage: String {
//        Mirror(reflecting: self).children.first(where: { $0.label == "storage" })?.value as? String ?? ""
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    NavigationStack {
//        ArticleView()
//    }
//}
