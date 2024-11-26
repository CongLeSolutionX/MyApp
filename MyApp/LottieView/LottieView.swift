//
//  LottieView.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var filename: String
    var loopMode: LottieLoopMode = .loop
    
    init(filename: String, loopMode: LottieLoopMode = .loop) {
        self.filename = filename
        self.loopMode = loopMode
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let animationView = LottieAnimationView(name: filename)
        animationView.loopMode = loopMode
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundColor = .black
        
        view.addSubview(animationView)
        view.backgroundColor = .black
        
        // Constraints to cover the whole view
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let animationView = uiView.subviews.first as? LottieAnimationView {
            animationView.play()
        }
    }
}

// MARK: - Preview
#Preview {
    LottieView(filename: "LottieLego")
}
