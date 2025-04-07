////
////  DialogView.swift
////  MyApp
////
////  Created by Cong Le on 4/6/25.
////
//
//import SwiftUI
//
//// Define custom colors to match the screenshot's palette
//extension Color {
//    static let dialogBackground = Color(red: 0.96, green: 0.95, blue: 0.98) // Light Lavender
//    static let accentPurple = Color(red: 0.4, green: 0.3, blue: 0.7)      // Purple for Checkbox/Buttons
//    static let avatarBackground = Color(red: 0.9, green: 0.88, blue: 0.95) // Lighter Lavender for Avatar
//    static let primaryText = Color.black.opacity(0.85)
//    static let secondaryText = Color.black.opacity(0.6)
//    static let dividerColor = Color.black.opacity(0.1)
//}
//
//// Data structure for list items
//struct ListItem_V2: Identifiable {
//    let id = UUID()
//    let initial: String
//    let text: String
//    let detail: String
//    var isSelected: Bool
//}
//
//// Reusable View for each list item row
//struct DialogListItemView: View {
//    @Binding var item: ListItem_V2
//
//    var body: some View {
//        HStack(spacing: 15) {
//            // Avatar Circle
//            ZStack {
//                Circle()
//                    .fill(Color.avatarBackground)
//                    .frame(width: 40, height: 40)
//                Text(item.initial)
//                    .font(.headline)
//                    .foregroundColor(Color.accentPurple)
//            }
//
//            // Main Text
//            Text(item.text)
//                .font(.body)
//                .foregroundColor(Color.primaryText)
//
//            Spacer() // Pushes detail and checkbox to the right
//
//            // Detail Text
//            Text(item.detail)
//                .font(.callout)
//                .foregroundColor(Color.secondaryText)
//                .padding(.trailing, 5) // Space before checkbox
//
//            // Checkbox
//            Image(systemName: item.isSelected ? "checkmark.square.fill" : "square")
//                .resizable()
//                .frame(width: 24, height: 24)
//                .foregroundColor(Color.accentPurple)
//                .onTapGesture {
//                    item.isSelected.toggle() // Allow toggling
//                }
//        }
//        .padding(.vertical, 8) // Padding within the list item row
//    }
//}
//
//// Main Dialog View
//struct DialogView: View {
//    // State for the list items - allows interaction
//    @State private var listItems = [
//        ListItem_V2(initial: "A", text: "List item", detail: "100+", isSelected: true),
//        ListItem_V2(initial: "A", text: "List item", detail: "100+", isSelected: true),
//        ListItem_V2(initial: "A", text: "List item", detail: "100+", isSelected: true)
//    ]
//
//    var body: some View {
//        // Main container mimicking the modal appearance
//        VStack(alignment: .leading, spacing: 16) {
//            // Dialog Title
//            Text("Dialog title")
//                .font(.largeTitle)
//                .fontWeight(.semibold) // Slightly less bold than .bold
//                .foregroundColor(Color.primaryText)
//
//            // Dialog Description
//            Text("A dialog is a type of modal window that appears in front of app content to provide critical information, or ask for a decision.")
//                .font(.body)
//                .foregroundColor(Color.secondaryText)
//                .lineSpacing(4) // Improve readability
//
//            // List Items Section
//            VStack(spacing: 0) {
//                // Use ForEach with indices to access bindings
//                ForEach($listItems) { $item in
//                    VStack(spacing: 0) {
//                         DialogListItemView(item: $item)
//                         Divider().background(Color.dividerColor) // Divider below each item
//                    }
//                }
//            }
//            .padding(.top, 8) // Space above the list
//
//            // Action Buttons
//            HStack {
//                Spacer() // Push buttons to the right
//
//                Button("Action 2") {
//                    // Action for button 2
//                    print("Action 2 Tapped")
//                }
//                .font(.body.weight(.medium))
//                .foregroundColor(Color.accentPurple)
//                .padding(.horizontal)
//
//                Button("Action 1") {
//                    // Action for button 1
//                    print("Action 1 Tapped")
//                }
//                .font(.body.weight(.medium))
//                .foregroundColor(Color.accentPurple)
//            }
//            .padding(.top, 8) // Space above the buttons
//
//        }
//        .padding(24) // Overall padding inside the dialog card
//        .background(Color.dialogBackground)
//        .cornerRadius(20) // Rounded corners for the dialog card
//        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5) // Subtle shadow
//        .padding(30) // Padding around the dialog to simulate modal presentation
//        .frame(maxWidth: 400) // Constrain width typically seen in dialogs
//        .background(Color.black.opacity(0.6)) // Dark background behind the dialog
//        .edgesIgnoringSafeArea(.all)
//    }
//}
//
//// Preview Provider
//struct DialogView_Previews: PreviewProvider {
//    static var previews: some View {
//        DialogView()
//    }
//}
