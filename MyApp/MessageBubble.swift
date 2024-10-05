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
        Text(message)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .foregroundColor(.white)
            .accessibilityElement()
            .accessibilityLabel(Text("Message bubble"))
    }
}

struct MessageBubble_ContentView: View {
    var body: some View {
        VStack {
            MessageBubble(message: "Hello, World!")
            MessageBubble(message: "How are you?")
        }
    }
}

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


