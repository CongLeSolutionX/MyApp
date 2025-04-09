////
////  Chat Conversation.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//
// MARK: - Data Model for Chat Message

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isCurrentUser: Bool
    let timestamp: Date
}

// MARK: - Chat Conversation View

import SwiftUI

struct ChatConversationView: View {
    
    // Sample mock messages for demonstration.
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi there!", isCurrentUser: false, timestamp: Date().addingTimeInterval(-3600)),
        ChatMessage(text: "Hello! How can I help you today?", isCurrentUser: true, timestamp: Date().addingTimeInterval(-3500)),
        ChatMessage(text: "I was wondering about the status of my order.", isCurrentUser: false, timestamp: Date().addingTimeInterval(-3400)),
        ChatMessage(text: "Let me check that for you.", isCurrentUser: true, timestamp: Date().addingTimeInterval(-3300)),
        ChatMessage(text: "Thanks!", isCurrentUser: false, timestamp: Date().addingTimeInterval(-3200))
    ]
    
    // Input state for new message text.
    @State private var newMessage: String = ""
    
    var body: some View {
        VStack {
            // Messages Scroll View
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .onChange(of: messages.count) { 
                    // Auto-scroll to the latest message when a new one is added.
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Message Input Toolbar
            HStack(spacing: 8) {
                TextField("Type a message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                }
                .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Send Message Action
    private func sendMessage() {
        let trimmed = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Append new message simulating a sent message.
        let message = ChatMessage(text: trimmed, isCurrentUser: true, timestamp: Date())
        messages.append(message)
        newMessage = ""
    }
}

// MARK: - Chat Bubble View

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isCurrentUser { Spacer() }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message.text)
                    .padding(10)
                    .background(message.isCurrentUser ? Color.blue.opacity(0.85) : Color.gray.opacity(0.2))
                    .foregroundColor(message.isCurrentUser ? .white : .black)
                    .cornerRadius(16)
                
                Text(relativeTime(for: message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(message.isCurrentUser ? .trailing : .leading, 8)
            }
            
            if !message.isCurrentUser { Spacer() }
        }
        .id(message.id)
        .padding(message.isCurrentUser ? .leading : .trailing, 60)
    }
    
    // Helper to display a relative timestamp.
    private func relativeTime(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

//// MARK: - Preview
//
//struct ChatConversationView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ChatConversationView()
//                .preferredColorScheme(.light)
//        }
//    }
//}
