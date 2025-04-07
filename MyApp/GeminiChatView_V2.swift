//
//  GeminiChatView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

// Data structure for AI Models
struct AIModel: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let isLocked: Bool
    // Add other properties if needed, e.g., identifier for API calls
}

// Main View mimicking the screenshot structure
struct GeminiChatView: View {
    @State private var inputText: String = ""
    @State private var selectedTab: Int = 0 // 0 for Discover, 1 for Chats

    // --- New State Variables ---
    @State private var availableModels: [AIModel] = [
        AIModel(name: "GPT-4o mini", description: "Great for everyday tasks", isLocked: false),
        AIModel(name: "Grok AI", description: "Great for discussions", isLocked: true),
        AIModel(name: "R1", description: "For deep thinking", isLocked: true),
        AIModel(name: "Sonnet 3.5", description: "Best for essays & code", isLocked: true),
        AIModel(name: "GPT-4o", description: "Most advanced model", isLocked: true),
        AIModel(name: "Llama 1B", description: "Meta's advanced model", isLocked: true),
        AIModel(name: "Qwen 32B", description: "#1 for coding and maths", isLocked: true)
    ]
    @State private var selectedModel: AIModel? = AIModel(name: "GPT-4o mini", description: "Great for everyday tasks", isLocked: false) // Initialize with default
    @State private var isModelSelectorPresented: Bool = false
    // --- End New State Variables ---

    var body: some View {
        ZStack {
            // Background Color
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // --- Pass state down to HeaderView ---
                HeaderView(
                    selectedModel: $selectedModel,
                    isModelSelectorPresented: $isModelSelectorPresented
                )
                .zIndex(1) // Ensure header is above the overlay dismiss area if needed
                // --- End Pass state ---

                ScrollView {
                    ChatPlaceholderView()
                        .padding(.top, 50)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                QuickShortcutsView()
                    .padding(.vertical)

                InputAreaView(inputText: $inputText)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
            // --- Conditional Overlay for Model Selector ---
             .overlay(alignment: .top) {
                 if isModelSelectorPresented {
                     // Dimming background to dismiss on tap
                     Color.black.opacity(0.3)
                         .ignoresSafeArea()
                         .onTapGesture {
                             withAnimation(.easeInOut(duration: 0.2)) {
                                 isModelSelectorPresented = false
                             }
                         }
                         .zIndex(0.5) // Below header but above content

                     ModelSelectorView(
                         availableModels: availableModels,
                         selectedModel: $selectedModel,
                         isPresented: $isModelSelectorPresented
                     )
                     .padding(.top, 90) // Adjust padding to position below the trigger button
                     .zIndex(1) // Ensure selector is on top
                     .transition(.opacity.combined(with: .offset(y: -20))) // Add transition
                 }
             }
             // --- End Conditional Overlay ---
        }
         .overlay(alignment: .bottom) {
             SimulatedTabView(selectedTab: $selectedTab)
         }
         .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Header Components
struct HeaderView: View {
    // --- Bindings for state ---
    @Binding var selectedModel: AIModel?
    @Binding var isModelSelectorPresented: Bool
    // --- End Bindings ---

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button { /* Back action */ } label: {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                Spacer()

                Text("Chat")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Spacer()

                HStack(spacing: 16) {
                     Button { /* Text size action */ } label: {
                        Text("AA")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }

                    Button { /* Feedback/History action */ } label: {
                        Image(systemName: "bubble.left.and.bubble.right")
                             .font(.title2)
                             .foregroundColor(.white)
                           .overlay(
                                Circle()
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(-5)
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // --- Updated Model Selector Button ---
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isModelSelectorPresented.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                    // Display the selected model name, default if nil
                    Text(selectedModel?.name ?? "Select Model")
                   Image(systemName: "chevron.down")
                        .font(.caption)
                        .rotationEffect(.degrees(isModelSelectorPresented ? 180 : 0)) // Animate chevron
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.15))
                .clipShape(Capsule())
            }
            // --- End Updated Button ---
        }
         .padding(.bottom, 10)
         .background(Color.black.opacity(0.9))
    }
}

// MARK: - Model Selector Components
struct ModelSelectorView: View {
    let availableModels: [AIModel]
    @Binding var selectedModel: AIModel?
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(availableModels) { model in
                ModelRowView(
                    model: model,
                    isSelected: model == selectedModel
                ) {
                    // Action on tap
                    if !model.isLocked { // Only allow selecting non-locked models
                        selectedModel = model
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPresented = false
                        }
                    } else {
                        // Handle tap on locked model (e.g., show upgrade prompt)
                        print("Tapped locked model: \(model.name)")
                    }
                }
                if model.id != availableModels.last?.id { // Don't add divider after last item
                    Divider()
                       .background(Color.gray.opacity(0.3))
                       .padding(.leading, 40) // Indent divider
                }
            }
        }
        .padding(.vertical, 5) // Add some padding inside the card
        .background(Color(UIColor.systemGray6).opacity(0.95)) // Use a system dark gray
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 5)
        .frame(width: UIScreen.main.bounds.width * 0.85) // Adjust width as needed
        .fixedSize(horizontal: false, vertical: true) // Allow vertical growth
    }
}

struct ModelRowView: View {
    let model: AIModel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                // Checkmark (visible only if selected)
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(isSelected ? 1 : 0)
                    .frame(width: 20) // Allocate space even when hidden

                VStack(alignment: .leading, spacing: 2) {
                    Text(model.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    Text(model.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer() // Push lock icon to the right

                // Lock icon (visible only if locked)
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.8))
                    .opacity(model.isLocked ? 1 : 0)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .contentShape(Rectangle()) // Ensure entire row area is tappable
        }
        .buttonStyle(.plain) // Use plain style to avoid default button styling interfering
    }
}

// MARK: - Chat Area Placeholder
struct ChatPlaceholderView: View {
    // ... (Keep existing code)
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "hexagon.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))

            Text("Hello! How can I assist\nyou today?")
                .font(.title3)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

// MARK: - Quick Shortcuts Components
struct QuickShortcutsView: View {
    // ... (Keep existing code, including ShortcutItem struct)
    struct ShortcutItem: Identifiable {
        let id = UUID()
        let imageName: String
        let title: String
        let isSystemImage: Bool = true
    }

    let shortcutItems: [ShortcutItem] = [
        ShortcutItem(imageName: "person.crop.rectangle.stack.fill", title: "Image Maker"),
        ShortcutItem(imageName: "paintbrush.pointed.fill", title: "Logo Studio"),
        ShortcutItem(imageName: "person.fill.viewfinder", title: "Profile Pic"),
        ShortcutItem(imageName: "doc.text.image.fill", title: "Edit Image")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 5) {
                Image(systemName: "bolt.fill")
                Text("Quick Shortcuts")
            }
            .font(.footnote)
            .foregroundColor(.gray)
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(shortcutItems) { item in
                        ShortcutButtonView(item: item)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ShortcutButtonView: View {
    // ... (Keep existing code)
    let item: QuickShortcutsView.ShortcutItem

    var body: some View {
        Button { /* Action for shortcut */ } label: {
            HStack(spacing: 8) {
                Image(systemName: item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(5)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text(item.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "arrow.up.forward.app")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Input Area Components
struct InputAreaView: View {
    // ... (Keep existing code)
    @Binding var inputText: String

    var body: some View {
        HStack(spacing: 10) {
            Button { /* Add attachment action */ } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
            }

            HStack(spacing: 0) {
                TextField("How can I help?", text: $inputText)
                    .foregroundColor(.white.opacity(0.8))
                     .accentColor(.blue)
                     .padding(.leading, 15)
                     .padding(.vertical, 12)

                Spacer()

                Button { /* Send action */ } label: {
                    Image(systemName: "arrow.up")
                       .font(.system(size: 16, weight: .semibold))
                       .foregroundColor(inputText.isEmpty ? .gray.opacity(0.6) : .white)
                       .padding(8)
                       .background(inputText.isEmpty ? Color.gray.opacity(0.4) : Color.blue)
                       .clipShape(Circle())
                       .padding(.trailing, 8)
                }
                .disabled(inputText.isEmpty)
            }
            .background(Color.white.opacity(0.1))
            .clipShape(Capsule())
        }
    }
}

// MARK: - Simulated Tab Bar (for layout context)
struct SimulatedTabView: View {
    // ... (Keep existing code)
     @Binding var selectedTab: Int

     var body: some View {
         HStack {
             Spacer()
             TabBarItem(iconName: "sparkles", title: "Discover", isSelected: selectedTab == 0) {
                 selectedTab = 0
             }
             Spacer()
             TabBarItem(iconName: "message", title: "Chats", isSelected: selectedTab == 1) {
                  selectedTab = 1
             }
             Spacer()
         }
         .padding(.top, 8)
         .padding(.bottom, 5)
         .background(Color.black.opacity(0.9))
     }
 }

struct TabBarItem: View {
    // ... (Keep existing code)
     let iconName: String
     let title: String
     let isSelected: Bool
     let action: () -> Void

     var body: some View {
         Button(action: action) {
             VStack(spacing: 3) {
                 Image(systemName: iconName)
                     .font(.system(size: 22))
                 Text(title)
                     .font(.caption2)
             }
             .foregroundColor(isSelected ? .white : .gray)
         }
     }
 }

// MARK: - Preview
struct GeminiChatView_Previews: PreviewProvider {
    static var previews: some View {
        GeminiChatView()
            .preferredColorScheme(.dark) // Ensure preview uses dark mode
    }
}
