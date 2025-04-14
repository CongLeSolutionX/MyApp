////
////  ArticleView.swift
////  MyApp
////
////  Created by Cong Le on 4/13/25.
////
//
//import SwiftUI
//
//struct ArticleView: View {
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 24) {
//
//                // Introduction Label
//                Text("Charting a clear path: From disruption to smooth skies — an illustration created by the author using DALL-E 3 and GPT-4o assistance.")
//                    .font(.footnote)
//                    .foregroundStyle(.gray.opacity(0.9))
//                
//                // Main Title
//                Text("The SwiftUI Navigation Airspace: Calm or Chaos?")
//                    .font(.title)
//                    .bold()
//                    .padding(.bottom, 8)
//                
//                // Article Content
//                VStack(alignment: .leading, spacing: 16) {
//                    // First Paragraph
//                    Text("Building a new feature in your app often feels like scheduling a flight at a small regional airport. With only a handful of runways and a few planes to manage, everything runs like clockwork.")
//                        .font(.body)
//                    
//                    // Second Paragraph with inline code example
//                    Text("Navigation in SwiftUI mirrors this simplicity when building lightweight apps: just a few ") +
//                    Text("NavigationDestination")
//                        .font(.system(.body, design: .monospaced))
//                        .foregroundColor(.white)
//                        .padding(4)
//                        .background(RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.3))) +
//                    Text(" closures, and all the \"flights\" (views) land safely where they're supposed to.")
//                    
//                    // Third Paragraph
//                    Text("But as your app expands, so does your “airsp...")
//                        .font(.body)
//                        .foregroundStyle(.secondary)
//                }
//
//                // Interaction Bar
//                interactionBar()
//                    .padding(.top, 20)
//                
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 24)
//        }
//        .background(Color.black.edgesIgnoringSafeArea(.all))
//        .foregroundColor(.white)
//    }
//
//    // Interaction Bar View
//    @ViewBuilder
//    private func interactionBar() -> some View {
//        HStack(spacing: 40) {
//            interactionIcon(systemIcon: "hands.clap.fill", count: "48")
//            interactionIcon(systemIcon: "bubble.left", count: "2")
//            interactionIcon(systemIcon: "bookmark", count: nil)
//            interactionIcon(systemIcon: "square.and.arrow.up", count: nil)
//        }
//        .padding(12)
//        .frame(maxWidth: .infinity)
//        .foregroundColor(.white)
//        .background(
//            Capsule()
//                .fill(Color.gray.opacity(0.15))
//        )
//    }
//
//    @ViewBuilder
//    private func interactionIcon(systemIcon: String, count: String?) -> some View {
//        VStack {
//            Image(systemName: systemIcon)
//                .font(.headline)
//            if let count = count {
//                Text(count)
//                    .font(.caption)
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    ArticleView()
//}
