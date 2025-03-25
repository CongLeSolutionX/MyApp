//
//  CallingView.swift
//  MyApp
//
//  Created by Cong Le on 3/25/25.
//

import SwiftUI

import SwiftUI


struct CallingView: View {
    @State private var isSpeakerOn = false
    @State private var isFaceTimeOn = false
    @State private var isMuted = false
    @State private var isAddPersonPresented = false
    @State private var isEnded = false  // or can be a navigation action, to close this view
    @State private var isKeypadPresented = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0.2, blue: 0.2), .black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Top Section
                HStack {
                    Image(systemName: "waveform")
                    Spacer()
                    Image(systemName: "info.circle")
                }.padding()
                    .foregroundColor(.white)
                
                Spacer()
                    .frame(height: 20)
                
                Text("Calling home...")
                    .font(.title3)
                    .foregroundColor(.gray)
                
                Text("Mom")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 50)
                
                Spacer()
                
                // Button Grid
                VStack(spacing: 20) {
                    HStack(spacing: 40) {
                        CallButton(icon: isSpeakerOn ? "speaker.wave.3.fill" : "speaker.wave.2.fill", label: "Speaker", color: .gray, isOn: $isSpeakerOn, action: {
                            isSpeakerOn.toggle()
                            print("Speaker Toggled: \(isSpeakerOn)")
                        })
                        
                        CallButton(icon: isFaceTimeOn ? "video.fill" : "questionmark.video", label: "FaceTime", color: .gray, isOn: $isFaceTimeOn, action: {
                            isFaceTimeOn.toggle()
                            print("FaceTime Toggled: \(isFaceTimeOn)")
                        })
                        
                        CallButton(icon: isMuted ? "mic.fill" : "mic.slash.fill", label: "Mute", color: .gray, isOn: $isMuted, action: {
                            isMuted.toggle()
                            print("Mute Toggled: \(isMuted)")
                        })
                    }
                    
                    HStack(spacing: 40) {
                        CallButton(icon: "person.badge.plus", label: "Add", color: .gray, isOn: $isAddPersonPresented, action: {
                            isAddPersonPresented.toggle()
                            print("Add Person Tapped: \(isAddPersonPresented)")
                        })
                        
                        CallButton(icon: "phone.down.fill", label: "End", color: .red, isOn: $isEnded, action: {
                            isEnded.toggle()
                            print("Call Ended: \(isEnded)")
                            // Here should be action to dismiss this View or return back to root
                        })
                        
                        CallButton(icon: "square.grid.3x3.fill", label: "Keypad", color: .gray, isOn: $isKeypadPresented, action: {
                            isKeypadPresented.toggle()
                            print("Keypad Tapped: \(isKeypadPresented)")
                        })
                    }
                }
                .padding(.bottom, 50)
                
                // Bottom Bar (Home Indicator)
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 150, height: 5)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }
            .padding()
        }
    }
}

struct CallButton: View {
    let icon: String
    let label: String
    let color: Color
    @Binding var isOn: Bool
    let action: () -> Void
    
    var body: some View {
        VStack {
            Button(action: {
                action()
            }) {
                ZStack {
                    Circle()
                        .frame(width: 70, height: 70)
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                    
                    Image(systemName: icon)
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                }
            }
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}


struct CallingView_Previews: PreviewProvider {
    static var previews: some View {
        CallingView()
    }
}
