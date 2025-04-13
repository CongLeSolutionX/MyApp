//
//  DarkModeAnimationView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

struct DarkModeAnimationView: View {
    var body: some View {
        DarkModeWrapper {
            Home()
        }
    }
}

// MARK: - Preview
#Preview {
    DarkModeAnimationView()
}
