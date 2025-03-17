//
//  AppBarView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

// MARK: - AppBarView

struct AppBarView: View {
    @Binding var selectedArticle: Article?

    var body: some View{
        HStack {
            Button(action: {
                // Handle search action
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color("on-surface"))
            }

            Spacer()

            Text("Now in iOS")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("on-surface"))

            Spacer()

            Button(action: {
                selectedArticle = selectedArticle == nil ? placeholderArticles.first : nil
            }) {
                Image(systemName: "person.circle")
                    .foregroundColor(Color("on-surface"))
            }
        }
        .padding()
        .background(Color("surface"))
    }
}

#Preview {
    AppBarView(selectedArticle: .constant(nil))
}
