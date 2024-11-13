//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
        UIKitViewControllerWrapper()
            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
    }
}

// Before iOS 17, use this syntax for preview UIKit view controller
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper()
    }
}

struct ContactContentView: View {
    @State private var storeManager = ContactStoreManager()
    
    var body: some View {
        MainView()
            .environment(storeManager)
    }
}

#Preview {
    ContactContentView()
        .environment(ContactStoreManager())
}

#Preview {
    ContentView()
}
