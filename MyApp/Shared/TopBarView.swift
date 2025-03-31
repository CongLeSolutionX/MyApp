//
//  TopBarView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI


// --- Reusable Views (Some modified, some new) ---

// Top Bar View (Unchanged conceptually)
struct TopBarView: View {
    let title: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.title2)

            Spacer()

            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            Image("profile_placeholder") // Placeholder
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
        }
        .padding(.horizontal)
        .frame(height: 44)
    }
}

