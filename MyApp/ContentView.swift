//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("showIntroView") private var showIntroView: Bool = true
    var body: some View {
        HomeView()
            .sheet(isPresented: $showIntroView) {
                IntroScreen()
                    .interactiveDismissDisabled()
            }
    }
}

// MARK: - Previews

// After iOS 17, we can use this syntax for preview:
#Preview {
    ContentView()
}


// Before iOS 17, use this syntax for preview UIKit view controller
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper()
    }
}
