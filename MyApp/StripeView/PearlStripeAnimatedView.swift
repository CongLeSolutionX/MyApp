//
//  PearlStripeView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

//
//// MARK: Animated Stripes View using Timer with Pear Shape
//struct AnimatedStripesViewTimer: View {
//    @State private var phase: Int = 0
//    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo]
//    let stripeWidth: Float = 12.0
//    let timerInterval: Double = 0.1
//
//    var body: some View {
//        VStack {
//            PearShape() // Use PearShape instead of Circle
//                .fill(stripedShader())
//                .aspectRatio(0.7, contentMode: .fit) // Adjust aspect ratio
//                .onReceive(Timer.publish(every: timerInterval, on: .main, in: .common).autoconnect()) { _ in
//                    // Animate faster or slower by changing how phase increments
//                    phase = (phase + 1) % (colors.count * Int(stripeWidth)) // Make animation smoother relative to stripe width
//                }
//        }
//        .padding()
//    }
//
//    private func stripedShader() -> some ShapeStyle {
//        // Adjust the y-position input to the shader based on phase for animation
//        // We map phase to a vertical offset
//        let verticalOffset = Float(phase % (colors.count * Int(stripeWidth))) / Float(colors.count)
//        
//        return ShaderLibrary.Stripes(
//            .float(stripeWidth),
//            .colorArray(colors), // Pass original colors
//             .float(verticalOffset) // Pass the offset to the shader
//        )
//    }
//
//    // We don't need to shift colors array anymore if offset is passed to shader
//    // private func shiftedColors() -> [Color] {
//    //     var shifted = colors
//    //     shifted.rotate(to: phase / Int(stripeWidth)) // Adjust rotation speed if needed
//    //     return shifted
//    // }
//}
//
//// Keep the Array extension as it is potentially useful, although not used in the modified shader approach above
//extension Array {
//    mutating func rotate(to shift: Int) {
//        let shift = shift % count
//        if shift < 0 {
//            let newShift = count + shift
//            self.rotate(to: newShift)
//        } else if shift > 0 { // avoid unnecessary work for shift = 0
//             let rotated = self.dropFirst(shift) + self.prefix(shift)
//             self = Array(rotated)
//        }
//    }
//}
//
//// MARK: Preview for Animated Pear
//#Preview("Animated Stripes Pear View using Timer") {
//    AnimatedStripesViewTimer()
//        .preferredColorScheme(.dark)
//}
