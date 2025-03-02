//
//  AppleBookView.swift
//  MyApp
//
//  Created by Cong Le on 3/1/25.
//

import SwiftUI

struct AppleBookView: View {
    @State private var selection: Int = 0
    var body: some View {
        TabView(selection: $selection) {
            Tab.init("Home", systemImage: "house", value: 0) {
                Text("Home")
            }
            Tab.init("Library", systemImage: "books.vertical.fill", value: 1) {
                Text("Library")
            }
            Tab.init("Book Store", systemImage: "bag.fill", value: 2) {
                Text("Book Store")
            }
            Tab.init("Search", systemImage: "magnifyingglass", value: 3) {
                SearchView()
                    .toolbarBackground(.visible, for: .tabBar)
            }
            
        }
    }
}

// MARK: - Preview
#Preview {
    AppleBookView()
}
