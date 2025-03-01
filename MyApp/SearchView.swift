//
//  SearchView.swift
//  MyApp
//
//  Created by Cong Le on 3/1/25.
//

import SwiftUI

struct SearchView: View {
    @State private var activeID: String? = books.first?.id
    @State private var scrollPosition: ScrollPosition = .init(idType: String.self)
    @State private var isAnyBookCardScrolled: Bool = false
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(.gray.opacity(0.15))
                .ignoresSafeArea()
            
            ScrollView(.horizontal) {
                HStack(spacing: 4) {
                    ForEach(books) { book in
                        BookCardView(book: book, size: geometry.size) { isScrolled in
                            isAnyBookCardScrolled = isScrolled
                        }
                        .frame(width: geometry.size.width - 30)
                        /// Let's Make currently active card to the top of the stack
                        .zIndex(activeID == book.id ? 1000 : 1)
                    }
                }
                .scrollTargetLayout()
            }
            /// This is the parent Padding!
            .safeAreaPadding(15)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollPosition($scrollPosition)
            .scrollDisabled(isAnyBookCardScrolled)
            .onChange(of: scrollPosition.viewID(type: String.self)) { oldValue, newValue in
                activeID = newValue
            }
            .scrollIndicators(.hidden)
        }
    }
}

// MARK: - Preview 
#Preview {
    SearchView()
}
