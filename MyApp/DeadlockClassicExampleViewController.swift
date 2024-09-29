//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

struct DeadlockClassicViewController: View {
    
    var body: some View {
        Text("Deadlock Classic View Controller")
        UIKitViewControllerWrapper()
            .edgesIgnoringSafeArea(.all)
    }
}

struct DeadlockBySemaphoresView: View {
    var body: some View {
        Text("Deadlock By Sepaphores View")
        UIKitViewWrapper()
            .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Previews

// Before iOS 17, use this syntax for preview UIKit view controller
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        Text("Deadlock Classic View Controller - Before iOS 17 preview - Using wrapper")
        UIKitViewControllerWrapper()
    }
}

#Preview {
    Text("Deadlock Classic View Controller - After iOS 17 preview - Using macro")
    DeadlockClassicViewController()
}

#Preview {
    Text("Deadlock by Semaphores View - After iOS 17 preview - Using macro")
    DeadlockBySemaphoresView()
}
