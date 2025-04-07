//
//  MenuOptionView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

// MARK: - Reusable Menu Item View

struct MenuItemView: View {
    let text: String
    let leadingIcon: String?
    let trailingIcon: String?
    let isSelected: Bool
    let densityPadding: CGFloat // Simulate density adjustments

    init(text: String,
         leadingIcon: String? = nil,
         trailingIcon: String? = nil,
         isSelected: Bool = false,
         density: Int = 0) { // 0 = default, negative values for denser
        self.text = text
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.isSelected = isSelected
        // Adjust vertical padding based on density. Higher negative numbers mean less padding.
        self.densityPadding = 12 + CGFloat(density * 2) // Example density adjustment
    }

    var body: some View {
        HStack(spacing: 12) {
            // Leading Icon
            if let iconName = leadingIcon {
                Image(systemName: iconName)
                    .foregroundColor(isSelected ? .accentColor : .primary.opacity(0.7))
                    .frame(width: 24, height: 24) // Consistent icon size
            } else {
                Spacer().frame(width: 24) // Maintain alignment if no icon
            }

            // Text Label
            Text(text)
                .font(.body)
                .foregroundColor(isSelected ? .accentColor : .primary)

            Spacer() // Push trailing icon to the end

            // Trailing Icon
            if let iconName = trailingIcon {
                 Image(systemName: iconName)
                    .foregroundColor(isSelected ? .accentColor : .primary.opacity(0.7))
                    .frame(width: 24, height: 24) // Consistent icon size
            } else {
                 Spacer().frame(width: 24) // Maintain alignment if no icon
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, densityPadding) // Use calculated padding
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear) // Subtle selection background
        .contentShape(Rectangle()) // Ensure the whole row is tappable
    }
}

// MARK: - Menu Container View

struct MenuView<Header: View>: View {
    let header: Header
    let items: [AnyView] // Use AnyView to allow heterogeneous items if needed

    init(@ViewBuilder header: () -> Header = { EmptyView() }, items: [AnyView]) {
        self.header = header()
        self.items = items
    }

    // Convenience initializer for simple text items
     init(@ViewBuilder header: () -> Header = { EmptyView() }, itemTexts: [String]) {
        self.header = header()
        self.items = itemTexts.map { AnyView(MenuItemView(text: $0)) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Optional Header
            if !(header is EmptyView) {
                header
                    .padding(.horizontal, 16).padding(.vertical, 8) // Padding for header content
                Divider().padding(.bottom, 4) // Divider below header
            }

            // Menu Items
            ForEach(0..<items.count, id: \.self) { index in
                items[index]
            }
        }
        .background(Color(.systemGray6)) // Typical light background for menus
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2) // Subtle shadow
        .frame(minWidth: 150, maxWidth: 280) // Typical menu width constraints
        .padding(20) // Padding around the menu for demonstration
    }
}

// MARK: - Example Text Field Header

struct MenuTextFieldHeader: View {
    @Binding var text: String
    let label: String
    let leadingIcon: String?
    let placeholder: String

    var body: some View {
         VStack(alignment: .leading, spacing: 2) {
             // Optional Label (Material style floating label simulation)
             if !label.isEmpty {
                 Text(label)
                     .font(.caption)
                     .foregroundColor(.gray)
                     .padding(.leading, leadingIcon != nil ? 40 : 12) // Adjust based on icon presence
             }

             HStack {
                 if let iconName = leadingIcon {
                     Image(systemName: iconName)
                         .foregroundColor(.gray)
                 }
                 TextField(placeholder, text: $text)
                 if !text.isEmpty {
                     Button {
                         text = ""
                     } label: {
                         Image(systemName: "xmark.circle.fill")
                             .foregroundColor(.gray)
                     }
                 }
             }
             .padding(.horizontal, 12)
             .padding(.vertical, 8)
             .background(Color(.systemGray5))
             .clipShape(RoundedRectangle(cornerRadius: 6)) // Using clipShape instead of cornerRadius for background
         }
    }
}

// MARK: - Demonstration Content View

struct MenuOptionView: View {
    @State private var searchText1: String = ""
    @State private var searchText2: String = "Input" // Pre-filled example

    let menuItems = ["Menu Item", "Menu Item", "Menu Item", "Menu Item"]
    let detailedMenuItems = [
        AnyView(MenuItemView(text: "Menu Item", leadingIcon: "scissors", trailingIcon: "chevron.right")),
        AnyView(MenuItemView(text: "Menu Item", leadingIcon: "scissors", trailingIcon: "chevron.right", density: -2)), // Denser
        AnyView(MenuItemView(text: "Menu Item", leadingIcon: "scissors", trailingIcon: "chevron.right", density: -4)), // Even Denser
        AnyView(MenuItemView(text: "Selected Item", leadingIcon: "scissors", trailingIcon: "play.fill", isSelected: true)), // Selected state example
         AnyView(MenuItemView(text: "Leading Only", leadingIcon: "scissors")),
         AnyView(MenuItemView(text: "Trailing Only", trailingIcon: "play.fill")),
         AnyView(MenuItemView(text: "Trailing Selected", trailingIcon: "play.fill", isSelected: true)),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {

                Text("Basic Menu").font(.title2)
                MenuView(itemTexts: menuItems)
                    .frame(maxWidth: .infinity, alignment: .leading) // Align left for demo

                Text("Menu with Icon Button Trigger (Visual Only)").font(.title2)
                HStack {
                     Button {} label: { Image(systemName: "gearshape").padding(5).background(Circle().fill(Color.purple.opacity(0.2)))}
                     MenuView(itemTexts: ["Menu Item", "Menu Item", "Menu Item"])
                 }

                Text("Menu with Text Field (Empty)").font(.title2)
                MenuView(
                    header: {
                        MenuTextFieldHeader(text: $searchText1, label: "Label", leadingIcon: "magnifyingglass", placeholder: "Input")
                    },
                    items: menuItems.map { AnyView(MenuItemView(text: $0)) }
                )
                 .frame(maxWidth: .infinity, alignment: .leading)

                 Text("Menu with Text Field (Filled)").font(.title2)
                 MenuView(
                     header: {
                         MenuTextFieldHeader(text: $searchText2, label: "Label", leadingIcon: "magnifyingglass", placeholder: "Input")
                     },
                     items: menuItems.map { AnyView(MenuItemView(text: $0)) }
                 )
                 .frame(maxWidth: .infinity, alignment: .leading)

                Text("Detailed Menu Items").font(.title2)
                 MenuView(items: detailedMenuItems)
                 .frame(maxWidth: .infinity, alignment: .leading)

                // Standalone Elements for Clarity
                Text("Leading Element Example").font(.title2)
                Image(systemName: "scissors").padding()

                Text("Trailing Element Example").font(.title2)
                Image(systemName: "chevron.right").padding()

                Text("Trailing Element Selected Example").font(.title2)
                 Image(systemName: "play.fill").foregroundColor(.accentColor).padding()

            }
            .padding()
        }
    }
}

// MARK: - Preview

#Preview {
    MenuOptionView()
}
