//
//  MessageBubble.swift
//  MyApp
//
//  Created by Cong Le on 10/4/24.
//
//
import OpenAI
import SwiftUI

struct MessageBubble: View {
    var message: Item.Message
    
    var body: some View {
        VStack {
            ForEach(message.content, id: \.text) { content in
                // Note: Ideally, use a more robust ID if your content
                // can have duplicate text values.
                if let text = content.text {
                    Text(text)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .accessibilityElement()
                        .accessibilityLabel(Text("Message bubble"))
                }
            }
        }
    }
}

struct MessageBubble_ContentView: View {
    var body: some View {
        VStack {
            MessageBubble(message: Item.Message(
                id: "1",
                from: .user,
                content: [.text("Hello, World!")]
            ))
            MessageBubble(message: Item.Message(
                id: "2",
                from: .assistant,
                content: [.text("How are you?")]
            ))
        }
    }
}

// MARK: - Preview

// Before iOS 17, use this syntax for preview UIKit view controller
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble_ContentView()
    }
}

// After iOS 17, we can use this syntax for preview:
#Preview {
    MessageBubble_ContentView()
}


