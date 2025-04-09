//
//  V4.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//


import SwiftUI

// MARK: - Data Model

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
}

// MARK: - Chat View Model

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = [
        ChatMessage(text: "Hello, how can I help you today?", isUser: false, timestamp: Date())
    ]
    
    // Sends user message and simulates a response after a delay.
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // Append user message immediately.
        let userMessage = ChatMessage(text: text, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        // Clear the input (this will be used in the view).
        // Simulate a delayed response.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let responseText = self.generateResponse(for: text)
            let responseMessage = ChatMessage(text: responseText, isUser: false, timestamp: Date())
            self.messages.append(responseMessage)
        }
    }
    
    // In a real app this might call an API; here we return canned responses.
    private func generateResponse(for query: String) -> String {
        // For demo purposes you can expand this logic.
        if query.lowercased().contains("weather") {
            return "The current weather is sunny with a slight breeze."
        } else if query.lowercased().contains("help") {
            return "I am here to help! Could you please elaborate on your issue?"
        }
        
        return "This is a simulated response for your query: \"\(query)\""
    }
}

// MARK: - Chat Bubble Style

struct ChatBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 50)
            }
            
            Text(message.text)
                .padding(12)
                .background(message.isUser ? Color.blue.opacity(0.8) : Color.gray.opacity(0.2))
                .foregroundColor(message.isUser ? .white : .black)
                .cornerRadius(16)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer(minLength: 50)
            }
        }
        .padding(message.isUser ? .trailing : .leading, 16)
        .padding(.vertical, 4)
    }
}

// MARK: - Chat Conversation Screen

struct ChatConversationView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var composedMessage: String = ""
    @FocusState private var inputIsFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Conversation List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .background(Color(UIColor.systemBackground))
                .onChange(of: viewModel.messages.count) {
                    // Scroll to the last message when new message is added.
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Message Composition Area
            HStack {
                TextField("Type your message…", text: $composedMessage)
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(20)
                    .focused($inputIsFocused)
                    .onSubmit {
                        send()
                    }
                
                Button {
                    send()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .padding(12)
                }
                .disabled(composedMessage.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
            .background(Color(UIColor.systemBackground).ignoresSafeArea(edges: .bottom))
        }
        .navigationTitle("AI Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Optionally focus on text field or run initial setup.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                inputIsFocused = true
            }
        }
    }
    
    private func send() {
        viewModel.sendMessage(composedMessage)
        composedMessage = ""
    }
}

// MARK: - Previews

struct ChatConversationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatConversationView()
        }
        .preferredColorScheme(.light)
    }
}
