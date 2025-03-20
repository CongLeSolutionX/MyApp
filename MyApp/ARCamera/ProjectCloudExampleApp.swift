//
//  ProjectCloudExampleApp.swift
//  MyApp
//
//  Created by Cong Le on 3/20/25.
//


import SwiftUI

struct UIViewWrapper<V: UIView>: UIViewRepresentable {
    let view: V
    func makeUIView(context: Context) -> V { view }
    func updateUIView(_ uiView: V, context: Context) { }
}

@main
struct PointCloudExampleApp: App {
    @StateObject var arManager = ARManager()
    
    var body: some Scene {
        WindowGroup {
            UIViewWrapper(view: arManager.sceneView).ignoresSafeArea()
        }
    }
}

