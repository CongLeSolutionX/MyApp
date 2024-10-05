//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//

//#Preview {
//    ContentView()
//}

import OpenAI
import SwiftUI


struct ContentView: View {
    @State private var newMessage: String = ""
    @State private var conversation = Conversation(authToken: "OPENAI_KEY")

    var messages: [Item.Message] {
        conversation.entries.compactMap { switch $0 {
            case let .message(message): return message
            default: return nil
        } }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(messages, id: \.id) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }

            HStack(spacing: 12) {
                HStack {
                    TextField("Chat", text: $newMessage, onCommit: { sendMessage() })
                        .frame(height: 40)
                        .submitLabel(.send)

                    if newMessage != "" {
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 28, height: 28)
                                .foregroundStyle(.white, .blue)
                        }
                    }
                }
                .padding(.leading)
                .padding(.trailing, 6)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(.quaternary, lineWidth: 1))
            }
            .padding()
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }

    func sendMessage() {
        guard newMessage != "" else { return }

        Task {
            try await conversation.send(from: .user, text: newMessage)
            newMessage = ""
        }
    }
}
