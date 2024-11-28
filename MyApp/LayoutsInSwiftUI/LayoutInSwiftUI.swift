//
//  LayoutInSwiftUI.swift
//  MyApp
//
//  Created by Cong Le on 11/28/24.
//

import SwiftUI

// MARK: - Adaptive LazyVGrid
#Preview("Adaptive LazyVGrid") {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
        ForEach(0 ..< 20) { item in
            Rectangle()
                .frame(height: 100)
        }
    }
    
}
// MARK: - Grid and Item Spacing
#Preview("Grid and Item Spacing") {
    LazyVGrid(
        columns: [GridItem(.adaptive(minimum: 80), spacing: 16)],
        spacing: 16) {
            
            ForEach(0 ..< 12) { item in
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
                    .frame(height: 100)
            }
        }
        .padding()
}

// MARK: - LazyHGrid
#Preview("LazyHGrid") {
    LazyHGrid(
        rows: [GridItem(.adaptive(minimum: 80), spacing: 16)],
        spacing: 12) {
            
            ForEach(0 ..< 20) { item in
                Rectangle().frame(width: 100)
            }
        }
}

// MARK: - Fixed Columns
#Preview("Fixed Column") {
    LazyVGrid(
        columns: [
            GridItem(.fixed(100), spacing: 8),
            GridItem(.fixed(160), spacing: 8),
            GridItem(.fixed(80), spacing: 8)
        ], spacing: 12) {
            
            ForEach(0 ..< 20) { item in
                Rectangle()
                    .frame(height: 80)
            }
        }
}

// MARK: - LazyVStack
#Preview("LazyVStack") {
    ScrollView {
        LazyVStack(spacing: 16) {
            ForEach(0 ..< 10000) { item in
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(height: 100)
                    .shadow(radius: 100)
            }
        }
        .padding()
    }
}

// MARK: - LazyVGrid
#Preview("LazyVGrid") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
            ForEach(0 ..< 10000) { item in
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(height: 100)
                    .shadow(radius: 100)
            }
        }
        .padding()
    }
}

