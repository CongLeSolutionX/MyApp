//
//  GestureExamplesView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI

// MARK: - Main ContentView to Host Examples
struct GestureExamplesView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Basic Gestures") {
                    NavigationLink("Tap Gesture", destination: TapGestureExample())
                    NavigationLink("Long Press Gesture", destination: LongPressGestureExample())
                    NavigationLink("Drag Gesture", destination: DragGestureExample())
                    NavigationLink("Magnification Gesture", destination: MagnificationGestureExample())
                    NavigationLink("Rotation Gesture", destination: RotationGestureExample())
                }

                Section("Gesture Callbacks & State") {
                    NavigationLink("Gesture State (Drag)", destination: GestureStateExample())
                }

                Section("Gesture Combinators") {
                    NavigationLink("Simultaneous Gestures", destination: SimultaneousGestureExample())
                    NavigationLink("Exclusive Gestures", destination: ExclusiveGestureExample())
                    // SequenceGesture example can be complex, omitting for brevity unless requested
                }

                Section("Gesture Modifiers") {
                    NavigationLink("High Priority Gesture", destination: HighPriorityGestureExample())
                    NavigationLink("Simultaneous Gesture (Modifier)", destination: SimultaneousGestureModifierExample())
                }
            }
            .navigationTitle("SwiftUI Gestures")
        }
    }
}

// MARK: - Example Views

// --- Basic Gestures ---

struct TapGestureExample: View {
    @State private var isTapped = false
    @State private var tapCount = 0

    var body: some View {
        VStack(spacing: 30) {
            Circle()
                .fill(isTapped ? Color.blue : Color.red)
                .frame(width: 100, height: 100)
                .onTapGesture { // Simple tap action modifier
                    isTapped.toggle()
                    print("Simple tap performed!")
                }
            
            Text("Tapped \(tapCount) times (double tap)")
                .padding()
                .background(Color.yellow)
                .gesture( // Explicit TapGesture
                    TapGesture(count: 2) // Require 2 taps
                        .onEnded { _ in // Use '_' as value is Void
                            tapCount += 1
                            print("Explicit Double Tap gesture ended!")
                        }
                )
            
            Text("Tap Count: \(tapCount)") // Display tap count
        }
        .navigationTitle("TapGesture")
    }
}

struct LongPressGestureExample: View {
    @State private var isPressed = false
    @State private var pressCount = 0
    let minimumDuration = 1.0 // seconds

    var body: some View {
        VStack {
            Rectangle()
                .fill(isPressed ? Color.green : Color.orange)
                .frame(width: 150, height: 150)
                .overlay(Text(isPressed ? "Pressed (\(pressCount))" : "Press Me")
                            .foregroundColor(.white))
                .gesture(
                    LongPressGesture(minimumDuration: minimumDuration)
                        .onEnded { finished in // finished is Bool (true if duration met)
                            if finished {
                                print("Long press completed!")
                                pressCount += 1
                                // Keep it green briefly after release
                                isPressed = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                     isPressed = false
                                }
                            } else {
                                print("Long press cancelled before minimum duration.")
                            }
                       }
                       .onChanged { pressing in // Callback during the press
                           // Note: onChanged for LongPress fires *once* when minimum duration is met
                           // while still pressing. For continuous feedback *during* the press,
                           // combine with DragGesture or use @GestureState.
                           if pressing {
                                print("Long press minimum duration met, still holding...")
                                // You could trigger a different visual state here if needed
                           }
                       }
                )
            
            Text("Minimum Duration: \(String(format: "%.1f", minimumDuration))s")
            Text("Successful Presses: \(pressCount)")
        }
        .navigationTitle("LongPressGesture")
    }
}

struct DragGestureExample: View {
    @State private var currentOffset: CGSize = .zero
    @State private var finalOffset: CGSize = .zero
    @State private var dragInfo: String = "Drag the circle"

    var body: some View {
        VStack {
            Circle()
                .fill(Color.purple)
                .frame(width: 100, height: 100)
                .offset(CGSize(width: finalOffset.width + currentOffset.width, height: finalOffset.height + currentOffset.height))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            currentOffset = value.translation // How much dragged *from start*
                            dragInfo = """
                            Location: \(value.location)
                            Translation: \(value.translation)
                            Start Location: \(value.startLocation)
                            """
                            // print("Dragging: \(value.translation)")
                        }
                        .onEnded { value in
                            // Add the current drag offset to the final position
                            finalOffset.width += value.translation.width
                            finalOffset.height += value.translation.height
                            // Reset the temporary drag offset
                            currentOffset = .zero
                            dragInfo = "Drag ended.\nPredicted End: \(value.predictedEndTranslation)"
                            // print("Drag ended. Final offset: \(finalOffset)")
                        }
                )
            
            Text(dragInfo)
                .padding()
                .frame(height: 150) // Reserve space for info text
        }
        .navigationTitle("DragGesture")
    }
}


struct MagnificationGestureExample: View {
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0

    var body: some View {
        VStack {
            Image(systemName: "star.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100 * currentScale * finalScale, height: 100 * currentScale * finalScale)
                .foregroundColor(.yellow)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in // value is CGFloat magnification factor *from start*
                            currentScale = value
                             print("Magnifying: \(value)")
                        }
                        .onEnded { value in
                            finalScale *= value // Apply the last magnification change
                            currentScale = 1.0 // Reset temporary scale factor
                            print("Magnification ended. Final scale: \(finalScale)")
                        }
                )
            Text("Current Scale: \(String(format: "%.2f", currentScale * finalScale))")
        }
        .navigationTitle("MagnificationGesture")
    }
}

struct RotationGestureExample: View {
    @State private var currentAngle: Angle = .zero
    @State private var finalAngle: Angle = .zero

    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.teal)
                .frame(width: 150, height: 150)
                .rotationEffect(finalAngle + currentAngle)
                .gesture(
                    RotationGesture()
                        .onChanged { value in // value is Angle *from start*
                            currentAngle = value
                            // print("Rotating: \(value.degrees)")
                        }
                        .onEnded { value in
                            finalAngle += value // Add rotation change to final angle
                            currentAngle = .zero // Reset temporary rotation
                            print("Rotation ended. Final Angle: \(finalAngle.degrees)")
                        }
                 )
            Text("Rotation: \(String(format: "%.1f", (finalAngle + currentAngle).degrees))°")
        }
        .navigationTitle("RotationGesture")
    }
}


// --- Gesture State ---

struct GestureStateExample: View {
    @GestureState private var dragOffset: CGSize = .zero // Resets automatically onEnded
    @State private var finalOffset: CGSize = .zero
     @GestureState private var isDragging: Bool = false // Track drag state

    var body: some View {
        VStack {
             Text("Using @GestureState")
                .font(.headline)
                .padding(.bottom, 20)

            Circle()
                .fill(isDragging ? Color.blue.opacity(0.6) : Color.blue) // Change appearance during drag
                .frame(width: 100, height: 100)
                .scaleEffect(isDragging ? 1.2 : 1.0) // Scale up during drag
                .offset(CGSize(width: finalOffset.width + dragOffset.width, height: finalOffset.height + dragOffset.height))
                .gesture(
                    DragGesture()
                         // Update the @GestureState variable
                        .updating($dragOffset) { value, state, transaction in
                           state = value.translation // Update GestureState - reflects current drag *from start*
                           // transaction.animation = .spring() // Optionally animate updates
                           print("Updating GestureState offset: \(state)")
                        }
                         // Update a second @GestureState for boolean state
                         .updating($isDragging) { value, state, transaction in
                           state = true // Set to true while dragging
                            // print("Updating isDragging state: \(state)")
                         }
                        .onEnded { value in
                            // Manually update the @State variable
                            finalOffset.width += value.translation.width
                            finalOffset.height += value.translation.height
                            // No need to reset dragOffset - @GestureState does this
                            print("Drag ended (GestureState resets). Final @State offset: \(finalOffset)")
                         }
                )
             Text("@GestureState automatically resets when the gesture ends.")
                .padding()
                .multilineTextAlignment(.center)
             Text("Current @State offset: \(finalOffset)")
             Text("Current @GestureState offset: \(dragOffset)") // Shows temporary drag
        }
        .navigationTitle("GestureState (Drag)")
        .animation(.spring(), value: isDragging) // Animate scale/opacity changes
        .animation(.spring(), value: dragOffset) // Animate offset changes smoothly
    }
}

// --- Gesture Combinators ---

struct SimultaneousGestureExample: View {
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    @State private var currentAngle: Angle = .zero
    @State private var finalAngle: Angle = .zero

    var body: some View {
        let magnification = MagnificationGesture()
            .onChanged { value in currentScale = value }
            .onEnded { value in
                finalScale *= value
                currentScale = 1.0
            }

        let rotation = RotationGesture()
            .onChanged { value in currentAngle = value }
            .onEnded { value in
                finalAngle += value
                currentAngle = .zero
            }

        // Combine both gestures to run simultaneously
        let combined = SimultaneousGesture(magnification, rotation)

        return VStack {
            Image(systemName: "photo.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 150 * currentScale * finalScale, height: 150 * currentScale * finalScale)
                .rotationEffect(finalAngle + currentAngle)
                .foregroundColor(.indigo)
                .gesture(combined) // Attach the combined gesture

             Text("Pinch to Scale & Rotate Simultaneously")
                .padding(.top)
             Text("Scale: \(String(format: "%.2f", currentScale * finalScale))")
             Text("Angle: \(String(format: "%.1f", (finalAngle + currentAngle).degrees))°")
        }
        .navigationTitle("SimultaneousGesture")
    }
}


struct ExclusiveGestureExample: View {
    @State private var message = "Tap or Long Press the Circle"

    var body: some View {
        // Long press has higher precedence
        let longPress = LongPressGesture(minimumDuration: 0.8)
            .onEnded { _ in
                message = "Long Press Detected!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { message = "Tap or Long Press" }
            }

        // Tap only triggers if long press doesn't
        let tap = TapGesture()
            .onEnded {
                message = "Tap Detected!"
                 DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { message = "Tap or Long Press" }
            }
            
        // Give long press priority
        let combined = ExclusiveGesture(longPress, tap)
//        let combined = ExclusiveGesture(tap, longPress) // Tap would always win if first

        return VStack {
            Circle()
                .fill(Color.orange)
                .frame(width: 150, height: 150)
                .overlay(Text(message).foregroundColor(.white).multilineTextAlignment(.center))
                .gesture(combined) // Attach the exclusive gesture
        }
        .navigationTitle("ExclusiveGesture")

    }
}

// --- Gesture Modifiers ---

struct HighPriorityGestureExample: View {
     @State private var vstackTapped = false

    var body: some View {
         let tapVStack = TapGesture().onEnded {
            vstackTapped = true
            print("VStack High Priority Tap Detected!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { vstackTapped = false } // Reset visual feedback
         }

         return VStack {
            Text("High Priority Example")
                .font(.headline)
            
            Text(vstackTapped ? "VStack Tapped" : "Tap the VStack or the Button")
                 .padding()
                 .background(vstackTapped ? Color.yellow : Color.clear)

             Button("Tap Me Button") {
                 print("Button Action Fired!") // This won't fire if VStack gesture consumes tap
             }
            .padding()
            .buttonStyle(.borderedProminent)

         }
         .frame(width: 300, height: 200)
         .border(Color.gray)
         .contentShape(Rectangle()) // Make the whole VStack tappable
         .highPriorityGesture(tapVStack) // Give the VStack's gesture priority
         .navigationTitle("High Priority")
    }
}

struct SimultaneousGestureModifierExample: View {
    @State private var vstackTapped = false

    var body: some View {
        let tapVStack = TapGesture().onEnded {
           vstackTapped = true
           print("VStack Simultaneous Tap Detected!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { vstackTapped = false }
        }

        return VStack {
           Text("Simultaneous Modifier Example")
               .font(.headline)
           
           Text(vstackTapped ? "VStack Tapped" : "Tap the VStack or the Button")
                .padding()
                .background(vstackTapped ? Color.green : Color.clear)

            Button("Tap Me Button") {
                print("Button Action Fired Simultaneously!") // This WILL fire
            }
            .padding()
            .buttonStyle(.bordered)

        }
        .frame(width: 300, height: 200)
        .border(Color.gray)
        .contentShape(Rectangle())
        .simultaneousGesture(tapVStack) // Attach VStack's gesture simultaneously
        .navigationTitle("Simultaneous Modifier")
    }
}


// MARK: - Preview Provider
#Preview {
    GestureExamplesView()
}
