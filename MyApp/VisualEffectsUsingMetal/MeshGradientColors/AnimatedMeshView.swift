//
//  AnimatedMeshView.swift
//  MyApp
//
//  Created by Cong Le on 11/28/24.
//
//
import SwiftUI
//
// MARK: - The original solution
struct AnimatedMeshView: View {
    @State var time: Float = 0.0
    @State var animationTimer: Timer?
    
    var body: some View {
        if #available(iOS 18.0, *) {
            meshGradientView
                .onAppear {
                    startTimer()
                }
                .background(.black)
                .ignoresSafeArea()
                .onDisappear {
                    stopTimer()
                }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @available(iOS 18.0, *)
    private var meshGradientView: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [.init(0, 0), .init(0.5, 0), .init(1, 0),
                     [sinInRange(-0.8...(-0.2), offset: 0.439, timeScale: 0.342, t: time), sinInRange(0.3...0.7, offset: 3.42, timeScale: 0.984, t: time)],
                     [sinInRange(0.1...0.8, offset: 0.239, timeScale: 0.084, t: time), sinInRange(0.2...0.8, offset: 5.21, timeScale: 0.242, t: time)],
                     [sinInRange(1.0...1.5, offset: 0.939, timeScale: 0.084, t: time), sinInRange(0.4...0.8, offset: 0.25, timeScale: 0.642, t: time)],
                     [sinInRange(-0.8...0.0, offset: 1.439, timeScale: 0.442, t: time), sinInRange(1.4...1.9, offset: 3.42, timeScale: 0.984, t: time)],
                     [sinInRange(0.3...0.6, offset: 0.339, timeScale: 0.784, t: time), sinInRange(1.0...1.2, offset: 1.22, timeScale: 0.772, t: time)],
                     [sinInRange(1.0...1.5, offset: 0.939, timeScale: 0.056, t: time), sinInRange(1.3...1.7, offset: 0.47, timeScale: 0.342, t: time)]],
            colors: [.red, .purple, .indigo,
                     .orange, .white, .blue,
                     .yellow, .black, .mint
            ]
        )
    }
    
    func sinInRange(_ range: ClosedRange<Float>, offset: Float, timeScale: Float, t: Float) -> Float {
        let amplitude = (range.upperBound - range.lowerBound) / 2
        let midPoint = (range.upperBound + range.lowerBound) / 2
        return midPoint + amplitude * sin(timeScale * t + offset)
    }
    
    private func startTimer() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            time += 0.02
        }
    }
    
    private func stopTimer() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

// MARK: - Preview
#Preview {
    AnimatedMeshView()
}

//
//import SwiftUI
//
//struct AnimatedMeshView: View {
//    @State private var t: Float = 0.0
//    @State private var timer: Timer?
//
//    var body: some View {
//        if #available(iOS 18.0, *) {
//            meshGradientView
//                .onAppear { startTimer() }
//                .onDisappear { stopTimer() }
//                .background(.black)
//                .ignoresSafeArea()
//
//        } else {
//            // Fallback for earlier versions
//            Text("MeshGradient not supported on this iOS version.")
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(.gray)
//        }
//    }
//
//    @available(iOS 18.0, *)
//    private var meshGradientView: some View {
//        MeshGradient(
//            width: 3,
//            height: 3,
//            points: [
//                [.init(signOf: 0, magnitudeOf: 0), .init(signOf: 0.5, magnitudeOf: 0), .init(signOf: 1, magnitudeOf: 0)],
//                generateDynamicPointsRow(offset: 0.439, timeScale: 0.342),
//                generateDynamicPointsRow(offset: 0.239, timeScale: 0.084),
//                generateDynamicPointsRow(offset: 0.939, timeScale: 0.084),
//                generateDynamicPointsRow(offset: 1.439, timeScale: 0.442),
//                generateDynamicPointsRow(offset: 0.339, timeScale: 0.784),
//                generateDynamicPointsRow(offset: 0.939, timeScale: 0.056)
//            ],
//            colors: [.red, .purple, .indigo,
//                     .orange, .white, .blue,
//                     .yellow, .black, .mint]
//        )
//    }
//
//    @available(iOS 18.0, *)
//    private func generateDynamicPointsRow(offset: Float, timeScale: Float) -> SIMD2<Float>{
//        // TODO: Need to appy Float type to the dynamic point valaues here
//        let xRanges = Float(
//            [
//                -0.8...(-0.2),
//                0.3...0.7,
//                0.1...0.8,
//                1.0...1.5,
//                -0.8...0.0,
//                0.3...0.6,
//                1.0...1.5
//            ]
//        )
//
//        let yRanges = Float (
//            [
//                0.3...0.7,
//                0.2...0.8,
//                0.4...0.8,
//                1.4...1.9,
//                1.0...1.2,
//                1.3...1.7
//            ]
//        )
//
//        return [
//            SIMD2<Float>(x: Float(sinInRange(xRanges[0], offset: offset, timeScale: timeScale, t: t)),
//                      y: Float(sinInRange(yRanges[0], offset: 3.42, timeScale: 0.984, t: t))),
//            SIMD2<Float>(x: Float(sinInRange(xRanges[1], offset: offset, timeScale: timeScale, t: t)),
//                      y: Float(sinInRange(yRanges[1], offset: 5.21, timeScale: 0.242, t: t))),
//        ]
//    }
//
//    func sinInRange(_ range: ClosedRange<Float>, offset: Float, timeScale: Float, t: Float) -> Float {
//        let amplitude = (range.upperBound - range.lowerBound) / 2
//        let midPoint = (range.upperBound + range.lowerBound) / 2
//        return midPoint + amplitude * sin(timeScale * t + offset)
//    }
//
//    private func startTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
//            t += 0.02
//        }
//    }
//
//    private func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    AnimatedMeshView()
//}
