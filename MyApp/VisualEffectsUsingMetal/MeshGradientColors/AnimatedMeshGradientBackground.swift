//
//  AnimatedMeshGradientBackground.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import SwiftUI

//struct AnimatedMeshGradientBackground: View {
//    @State private var phase: CGFloat = 0.0
//    
//    var body: some View {
//        if #available(iOS 18, *) {
//            MeshGradient(width: 10, height: 10,
//                         points: (0..<100).map { index in
//                let x = CGFloat(index % 10)
//                let y = CGFloat(index / 10)
//                
//                //TODO: Fix this math
//                return [
//                    x / 10.0 + sin(phase + CGFloat(index)) * 0.05,
//                    y / 10.0 + cos(phase - CGFloat(index)) * 0.05
//                ]
//            },
//                         colors: (0..<100).map { index in
//                Color(hue: Double(index) / 100.0, saturation: 1.0, brightness: 1.0)
//            })
//            .onAppear {
//                withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
//                    phase = .pi * 2
//                }
//            }
//            .edgesIgnoringSafeArea(.all)
//            
//        } else {
//            // Fallback content for older iOS versions
//            ContainerRelativeShape()
//                .fill(.linearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
//                .onAppear{
//                    print("MeshGradient is available since iOS 18")
//                }
//                .edgesIgnoringSafeArea(.all)
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    AnimatedMeshGradientBackground()
//}
