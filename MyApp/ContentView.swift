//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

// Step 2: Use in SwiftUI view
struct RootContentView: View {
    var body: some View {
        Text("Hello World from SwiftUI View!")
            .onAppear {
                print("View.onAppear()")
            }
            .onDisappear {
                print("View.onDisappear()")
            }
    }
}

// After iOS 17, we can use this syntax for preview:
#Preview {
    RootContentView()
}
