////
////  ChatRoomsListView.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//
//// MARK: - Data Model
//
//struct ChatRoom: Identifiable {
//    let id = UUID()
//    let title: String           // e.g. Contact name or group title.
//    let lastMessage: String     // A snippet of the most recent message.
//    let timestamp: Date         // Time of the last message.
//    let unreadCount: Int        // Unread message count.
//}
//
//// MARK: - Chat Rooms List View
//
//import SwiftUI
//
//struct ChatRoomsListView: View {
//    
//    // Sample ChatRoom mock data.
//    let chatRooms: [ChatRoom] = [
//        ChatRoom(title: "Alice", lastMessage: "Hey, are you free tomorrow?", timestamp: Date().addingTimeInterval(-3600), unreadCount: 2),
//        ChatRoom(title: "Bob", lastMessage: "Let's meet up later this week.", timestamp: Date().addingTimeInterval(-7200), unreadCount: 0),
//        ChatRoom(title: "Work Chat", lastMessage: "Please review the report I sent.", timestamp: Date().addingTimeInterval(-9800), unreadCount: 5),
//        ChatRoom(title: "Family", lastMessage: "Dinner is at 7 tonight!", timestamp: Date().addingTimeInterval(-84600), unreadCount: 0)
//    ]
//    
//    var body: some View {
//        NavigationView {
//            List(chatRooms) { room in
//                NavigationLink(
//                    destination: ChatConversationView()  // Reusing our conversation view.
//                ) {
//                    HStack(spacing: 12) {
//                        // Profile or group image using SF Symbols as placeholder.
//                        Image(systemName: "person.crop.circle.fill")
//                            .resizable()
//                            .frame(width: 48, height: 48)
//                            .foregroundColor(.blue)
//                        
//                        // Conversation summary (title and last message).
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text(room.title)
//                                .font(.headline)
//                            Text(room.lastMessage)
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                                .lineLimit(1)
//                        }
//                        
//                        Spacer()
//                        
//                        // Timestamp and unread count
//                        VStack(alignment: .trailing, spacing: 4) {
//                            Text(timeAgoSince(room.timestamp))
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                            
//                            if room.unreadCount > 0 {
//                                Text("\(room.unreadCount)")
//                                    .font(.caption2)
//                                    .padding(6)
//                                    .background(Color.red)
//                                    .foregroundColor(.white)
//                                    .clipShape(Circle())
//                            }
//                        }
//                    }
//                    .padding(.vertical, 8)
//                }
//            }
//            .listStyle(InsetGroupedListStyle())
//            .navigationTitle("Chats")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//    
//    // Helper method to display a relative time string.
//    private func timeAgoSince(_ date: Date) -> String {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.unitsStyle = .short
//        return formatter.localizedString(for: date, relativeTo: Date())
//    }
//}
//
//// MARK: - Preview
//
//struct ChatRoomsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatRoomsListView()
//            .preferredColorScheme(.light)
//    }
//}
