//
//  GeminiChatView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

// Main View mimicking the screenshot structure
struct GeminiChatView_V1: View {
    @State private var inputText: String = ""
    @State private var selectedTab: Int = 0 // 0 for Discover, 1 for Chats

    var body: some View {
        ZStack {
            // Background Color
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderView()
                
                ScrollView {
                    // Add chat messages here eventually
                    ChatPlaceholderView()
                        .padding(.top, 50) // Add some top padding for centering
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Occupy available space

                QuickShortcutsView()
                    .padding(.vertical)

                InputAreaView(title: nil, placeholder: inputText)
                    .padding(.horizontal)
                    .padding(.bottom, 8) // Padding above TabView
            }
             // Apply dark theme preference explicitly if needed
             // .preferredColorScheme(.dark)
             // The TabView would typically wrap this entire VStack
             // For this example, we focus on the Chat screen's content
        }
        // If this view is meant to be *inside* a TabView, the TabView definition
        // would be outside this ZStack, and this view would be one of the tabs.
        // The screenshot implies this *is* the "Chats" tab content, with a common Tab bar below.
        // Let's simulate the Tab Bar appearance *below* the main content for structural context.
         .overlay(alignment: .bottom) {
             SimulatedTabView(selectedTab: $selectedTab)
         }
         .ignoresSafeArea(.keyboard, edges: .bottom) // Prevent keyboard overlap issues
    }
}

// MARK: - Header Components
struct HeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button { /* Back action */ } label: {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Title - Placed using Spacer, could be more complex if centering is exact
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
                        Image(systemName: "bubble.left.and.bubble.right") // Placeholder icon
                             .font(.title2)
                             .foregroundColor(.white)
                            // Dashed circle effect requires more complex drawing or an image asset
                           .overlay(
                                Circle()
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(-5) // Adjust padding to fit around icon
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8) // Adjust based on status bar height avoidance
            
            Button { /* Model selection action */ } label: {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                    Text("GPT-4o mini")
                   Image(systemName: "chevron.down")
                       .font(.caption)
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.15))
                .clipShape(Capsule())
            }
        }
         .padding(.bottom, 10)
         .background(Color.black.opacity(0.9)) // Slightly different from pure black maybe
    }
}

// MARK: - Chat Area Placeholder
struct ChatPlaceholderView: View {
    var body: some View {
        VStack(spacing: 15) {
            // Placeholder for the custom geometric icon
            Image(systemName: "hexagon.fill") // Using a simple placeholder
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
                
            Text("Hello! How can I assist\nyou today?")
                .font(.title3)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Center vertically too
    }
}

// MARK: - Quick Shortcuts Components
struct QuickShortcutsView: View {
    // Sample Data - Replace with actual data model
    struct ShortcutItem: Identifiable {
        let id = UUID()
        let imageName: String // Use system name or asset name
        let title: String
        let isSystemImage: Bool = true // Flag for placeholder logic
    }

    let shortcutItems: [ShortcutItem] = [
        ShortcutItem(imageName: "person.crop.rectangle.stack.fill", title: "Image Maker"), // Placeholder
        ShortcutItem(imageName: "paintbrush.pointed.fill", title: "Logo Studio"),
        ShortcutItem(imageName: "person.fill.viewfinder", title: "Profile Pic"), // Placeholder
        ShortcutItem(imageName: "doc.text.image.fill", title: "Edit Image") // Placeholder
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
    let item: QuickShortcutsView.ShortcutItem

    var body: some View {
        Button { /* Action for shortcut */ } label: {
            HStack(spacing: 8) {
                // Placeholder Image - Use item.imageName
                Image(systemName: item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(5)
                    .background(Color.gray.opacity(0.3)) // BG color for the image square
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text(item.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer() // Push arrow to the right

                Image(systemName: "arrow.up.forward.app")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.1)) // Button background
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Input Area Components
struct InputAreaView_V2: View {
    @Binding var inputText: String

    var body: some View {
        HStack(spacing: 10) {
            Button { /* Add attachment action */ } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.black) // Icon color
                    .padding(10)
                    .background(Color.white.opacity(0.9)) // Button background
                    .clipShape(Circle())
            }

            HStack(spacing: 0) {
                TextField("How can I help?", text: $inputText)
                    .foregroundColor(.white.opacity(0.8))
                     .accentColor(.blue) // Cursor color
                     .padding(.leading, 15)
                     .padding(.vertical, 12)

                Spacer() // Push send button to the right

                Button { /* Send action */ } label: {
                    Image(systemName: "arrow.up")
                       .font(.system(size: 16, weight: .semibold))
                       .foregroundColor(inputText.isEmpty ? .gray.opacity(0.6) : .white) // Conditional color
                       .padding(8)
                       .background(inputText.isEmpty ? Color.gray.opacity(0.4) : Color.blue) // Conditional BG
                       .clipShape(Circle())
                       .padding(.trailing, 8)
                }
                .disabled(inputText.isEmpty) // Disable if no text
            }
            .background(Color.white.opacity(0.1)) // Text field background
            .clipShape(Capsule())
        }
    }
}

// MARK: - Simulated Tab Bar (for layout context)
struct SimulatedTabView: View {
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
         .padding(.bottom, 5)  // Minimal bottom padding
         .background(Color.black.opacity(0.9)) // Tab bar background
     }
 }

struct TabBarItem: View {
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
        GeminiChatView_V1()
            .preferredColorScheme(.dark) // Ensure preview uses dark mode
    }
}
