//
//  MyApp.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
import SwiftUI

@main
struct MyApp: App {
    // Monitor the app's scene phase (active, inactive, background)
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        // Equivalent to application(_:didFinishLaunchingWithOptions:)
        print("App initialized (didFinishLaunchingWithOptions)")
    }
    
    var body: some Scene {
        WindowGroup {
            
            // TODO: Wrap entire functionalities of Gemini model into a card view
            NavigationStack {
                List {
                    NavigationLink {
                        SummarizeScreen()
                    } label: {
                        Label("Text", systemImage: "doc.text")
                    }
                    NavigationLink {
                        PhotoReasoningScreen()
                    } label: {
                        Label("Multi-modal", systemImage: "doc.richtext")
                    }
                    NavigationLink {
                        ConversationScreen()
                            .environmentObject(ConversationViewModel())
                    } label: {
                        Label("Chat", systemImage: "ellipsis.message.fill")
                    }
                    NavigationLink {
                        FunctionCallingScreen().environmentObject(FunctionCallingViewModel())
                    } label: {
                        Label("Function Calling", systemImage: "function")
                    }
                }
                .navigationTitle("Generative AI Samples")
            }
        }// Respond to changes in the scene phase
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                print("Scene became active")
            case .inactive:
                print("Scene became inactive")
            case .background:
                print("Scene entered background")
            @unknown default:
                print("Unknown scene phase")
            }
        }
    }
}
