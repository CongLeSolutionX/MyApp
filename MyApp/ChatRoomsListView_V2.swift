//
//  NewView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//


// MARK: - Data Models

import SwiftUI

/// Represents a single chat room or conversation.
struct ChatRoom: Identifiable {
    let id = UUID()
    let roomName: String
    let lastMessage: String
    let timestamp: Date
    let isRead: Bool
}

/// Sample Data: Mock chat rooms
let sampleChatRooms = [
    ChatRoom(roomName: "Alice Johnson", lastMessage: "Can you send me the document?", timestamp: Date().addingTimeInterval(-600), isRead: false),
    ChatRoom(roomName: "Marketing Group", lastMessage: "The campaign starts next week.", timestamp: Date().addingTimeInterval(-3600), isRead: true),
    ChatRoom(roomName: "Bob Smith", lastMessage: "Sounds great, thanks!", timestamp: Date().addingTimeInterval(-7200), isRead: true),
    ChatRoom(roomName: "Work", lastMessage: "Meeting rescheduled to 2 PM.", timestamp: Date().addingTimeInterval(-10800), isRead: false)
]

// MARK: - Chat Room Row View

/// A single row representing a chat room in the list.
struct ChatRoomRow: View {
    let room: ChatRoom
    
    var body: some View {
        HStack {
            // Placeholder for an avatar or room image
            Circle()
                .fill(Color.blue)
                .frame(width: 48, height: 48)
                .overlay(
                    Text(room.roomName.prefix(1))
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(room.roomName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(room.lastMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(relativeTime(for: room.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !room.isRead {
                    // Small dot indicating unread messages
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // A helper function to display timestamps as relative time.
    private func relativeTime(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Chat Rooms List View

/// The main view for displaying the list of chat rooms.
struct ChatRoomsListView_V2: View {
    // In a real scenario, you might use a ViewModel or Combine for dynamic data.
    @State private var chatRooms: [ChatRoom] = sampleChatRooms
    
    var body: some View {
        NavigationView {
            List(chatRooms) { room in
                NavigationLink(destination: ChatConversationView()) {
                    ChatRoomRow(room: room)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Chats")
            .navigationBarItems(
                trailing:
                    Button(action: composeNewChat) {
                        Image(systemName: "square.and.pencil")
                            .imageScale(.large)
                    }
            )
        }
    }
    
    /// Action triggered when the user taps the compose button.
    private func composeNewChat() {
        // In production, present a new chat composition view.
        print("Compose new chat")
    }
}

// MARK: - Preview

struct ChatRoomsListView_V2_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomsListView_V2()
            .preferredColorScheme(.light)
    }
}
