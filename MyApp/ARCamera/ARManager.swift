//
//  ARManager.swift
//  MyApp
//
//  Created by Cong Le on 11/17/24.
//

import Foundation
import ARKit
import SwiftUI

actor ARManager: NSObject, ARSessionDelegate, ObservableObject {
    
    @MainActor let sceneView = ARSCNView()
    @MainActor private var isProcessing = false
    @MainActor @Published var isCapturing = false
    let pointCloud = PointCloud() // Instantiate PointCloud actor

    @MainActor
    override init() {
        super.init()
        sceneView.session.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        configuration.frameSemantics = .sceneDepth
        sceneView.session.run(configuration)
    }
    
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        Task { await process(frame: frame) }
    }
    
    @MainActor
    private func process(frame: ARFrame) async {
        guard !isProcessing else { return }
        isProcessing = true
        await pointCloud.process(frame: frame) // Process frame with PointCloud actor
        isProcessing = false
    }
}
