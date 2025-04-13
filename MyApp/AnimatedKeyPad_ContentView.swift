//
//  AnimatedKeyPad_ContentView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

struct AnimatedKeyPad_ContentView: View {
    /// View Properties
    @State private var value: KeyPadValue = .init()
    var body: some View {
        VStack(spacing: 20) {
            Text("Send Money")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 5)
            
            VStack(spacing: 6) {
                Image(.myMemeOrange)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(.circle)
                
                Text("CongLeSolutionX.tech")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .frame(maxHeight: .infinity)
            
            /// Animated Text View
            TextView()
                .frame(height: 50)
                .overlay(alignment: .bottom) {
                    if value.isExceedingMaxLength {
                        Text("😅 Max Length Reached!")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.red)
                            .offset(y: 30)
                    }
                }
                .padding(.bottom, 30)
            
            /// Custom Keypad View
            CustomKeypad()
            
            Button {
                print(value.intValue)
            } label: {
                Text("Continue")
                    .fontWeight(.semibold)
                    .foregroundStyle(.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.primary, in: .capsule)
            }
            .padding(.horizontal, 15)
        }
        .fontDesign(.rounded)
        .padding(15)
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    func TextView() -> some View {
        HStack(spacing: 2) {
            Text("$")
            
            AnimatedTextView(value: $value)
        }
        /// You can even adjust the font size based on the length, but for the video tutorial, I’m using a fixed size of 40
        .font(.system(size: 40, weight: .black))
    }
    
    @ViewBuilder
    func CustomKeypad() -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
            /// 1-9 Buttons
            ForEach(1...9, id: \.self) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        value.append(index)
                    }
                } label: {
                    Text("\(index)")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .contentShape(.rect)
                }
            }
            
            Spacer()
            
            /// 0 & Back Button
            ForEach(["0", "delete.backward.fill"], id: \.self) { string in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if string == "0" {
                            value.append(0)
                        } else {
                            value.removeLast()
                        }
                    }
                } label: {
                    Group {
                        if string == "0" {
                            Text("0")
                        } else {
                            Image(systemName: string)
                        }
                    }
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .contentShape(.rect)
                }
                /// Repeating behaviour for back button to erase all digits if long pressed!
                .buttonRepeatBehavior(string == "0" ? .disabled : .enabled)
            }
        }
        .buttonStyle(KeypadButtonStyle())
        .foregroundStyle(.white)
    }
}

#Preview {
    AnimatedKeyPad_ContentView()
}

/// Custom Button Style for Keypad Buttons
struct KeypadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.gray.opacity(0.2))
                    .opacity(configuration.isPressed ? 1 : 0)
                    .padding(.horizontal, 5)
            }
            .animation(.easeInOut(duration: 0.25), value: configuration.isPressed)
    }
}
