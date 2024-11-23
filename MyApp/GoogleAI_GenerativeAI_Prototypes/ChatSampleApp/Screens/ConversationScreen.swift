//
//  ConversationScreen.swift
//  MyApp
//
//  Created by Cong Le on 11/23/24.
//


// TODO: Rewrite custom UI components
/// I will add this static GenerativeAIUIComponents framework later,
/// I'm using direct implementation from the original source code for now
// import GenerativeAIUIComponents


import GoogleGenerativeAI
import SwiftUI

struct ConversationScreen: View {
    @EnvironmentObject
    var viewModel: ConversationViewModel
    
    @State
    private var userPrompt = ""
    
    enum FocusedField: Hashable {
        case message
    }
    
    @FocusState
    var focusedField: FocusedField?
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                List {
                    ForEach(viewModel.messages) { message in
                        MessageView(message: message)
                    }
                    if let error = viewModel.error {
                        ErrorView(error: error)
                            .tag("errorView")
                    }
                }
                .listStyle(.plain)
                .onChange(of: viewModel.messages) { oldValue, newValue in
                    if viewModel.hasError {
                        // wait for a short moment to make sure we can actually scroll to the bottom
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation {
                                scrollViewProxy.scrollTo("errorView", anchor: .bottom)
                            }
                            focusedField = .message
                        }
                    } else {
                        guard let lastMessage = viewModel.messages.last else { return }
                        
                        // wait for a short moment to make sure we can actually scroll to the bottom
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                            focusedField = .message
                        }
                    }
                }
            }
            InputField("Message...", text: $userPrompt) {
                Image(systemName: viewModel.busy ? "stop.circle.fill" : "arrow.up.circle.fill")
                    .font(.title)
            }
            .focused($focusedField, equals: .message)
            .onSubmit { sendOrStop() }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: newChat) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .navigationTitle("Chat sample")
        .onAppear {
            focusedField = .message
        }
    }
    
    private func sendMessage() {
        Task {
            let prompt = userPrompt
            userPrompt = ""
            await viewModel.sendMessage(prompt, streaming: true)
        }
    }
    
    private func sendOrStop() {
        focusedField = nil
        
        if viewModel.busy {
            viewModel.stop()
        } else {
            sendMessage()
        }
    }
    
    private func newChat() {
        viewModel.startNewChat()
    }
}

// MARK: - Previews
// TODO: Need better and reusable navigation to preview the views
// This is workaround setup for now for this preview
struct ConversationScreen_Previews: PreviewProvider {
    struct ContainerView: View {
        @StateObject var viewModel = ConversationViewModel()
        
        var body: some View {
            ConversationScreen()
                .onAppear {
                    viewModel.messages = ChatMessage.samples
                }
        }
    }
    
    static var previews: some View {
        @StateObject var viewModel = ConversationViewModel()
        
        NavigationStack {
            ConversationScreen()
                .environmentObject(viewModel)
        }
    }
}
