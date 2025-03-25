//
//  ContactListView.swift
//  MyApp
//
//  Created by Cong Le on 3/25/25.
//

import SwiftUI

struct ContactListView: View {
    @State private var searchText = ""
    @State private var isListActive = false
    @State private var isFavoritesSelected = false
    @State private var isRecentsSelected = false
    @State private var isContactsSelected = true
    @State private var isKeypadSelected = false
    @State private var isVoicemailSelected = false
    @State private var contacts: [String] = ["Huy 📺☎️🎲 - A Hai", "A Anh VN", "A Ba", "A Duc Nail", "A Duc Sua Xe", "A Dung Nha", "A Dung-ban nhau", "A Duong", "A Duy", "A Duy - Chi Nghi", "A Hai"]

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all) // Background color

                VStack {
                    // Top Bar
                    HStack {
                        Button(action: {
                            isListActive = true
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.blue)
                                Text("Lists")
                                    .foregroundColor(.blue)
                            }
                        }
                        .background(
                            NavigationLink(destination: Text("Lists View"), isActive: $isListActive) {
                                EmptyView()
                            }
                            .hidden()
                        )
                        Spacer()
                        Text("Contacts")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            // TODO: Add action to add a new contact
                            print("Add new contact button pressed")
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()

                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search", text: $searchText)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "mic")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    ScrollView {
                        VStack(alignment: .leading) {
                            // "My Card" Section
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                VStack(alignment: .leading) {
                                    Text("Cong Le")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                    Text("My Card")
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)

                            // Contact List
                            Text("A")
                                .foregroundColor(.gray)
                                .padding(.leading)

                            ForEach(contacts.filter { $0.lowercased().starts(with: "a") }, id: \.self) { contact in
                                ContactRow(name: contact)
                            }
                        }
                    }

                    Spacer() // Push content to top

                    // Bottom Tab Bar
                    HStack {
                        TabBarIcon(icon: "star", text: "Favorites", badgeCount: nil, isSelected: isFavoritesSelected) {
                            isFavoritesSelected = true
                            isRecentsSelected = false
                            isContactsSelected = false
                            isKeypadSelected = false
                            isVoicemailSelected = false
                            print("Favorite button pressed")
                        }
                        TabBarIcon(icon: "clock", text: "Recents", badgeCount: nil, isSelected: isRecentsSelected) {
                            isFavoritesSelected = false
                            isRecentsSelected = true
                            isContactsSelected = false
                            isKeypadSelected = false
                            isVoicemailSelected = false
                            print("Recents button pressed")

                        }
                        TabBarIcon(icon: "person.fill", text: "Contacts", badgeCount: nil, isSelected: isContactsSelected) {
                            isFavoritesSelected = false
                            isRecentsSelected = false
                            isContactsSelected = true
                            isKeypadSelected = false
                            isVoicemailSelected = false
                           print("Contacts button pressed")
                        }
                        TabBarIcon(icon: "dialpad", text: "Keypad", badgeCount: nil, isSelected: isKeypadSelected) {
                            isFavoritesSelected = false
                            isRecentsSelected = false
                            isContactsSelected = false
                            isKeypadSelected = true
                            isVoicemailSelected = false
                            print("Keypad button pressed")
                        }
                        TabBarIcon(icon: "voicemail", text: "Voicemail", badgeCount: 37, isSelected: isVoicemailSelected) {
                            isFavoritesSelected = false
                            isRecentsSelected = false
                            isContactsSelected = false
                            isKeypadSelected = false
                            isVoicemailSelected = true
                            print("Voicemail button pressed")
                        }
                    }
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                }
                 .edgesIgnoringSafeArea(.bottom)
            }
            .navigationBarHidden(true)
        }
    }
}

struct ContactRow: View {
    let name: String

    var body: some View {
        VStack {
            HStack {
                Text(name)
                    .foregroundColor(.white)
                    .padding(.leading)
                Spacer()
            }
            Divider().background(Color(.systemGray6))
        }
    }
}

struct TabBarIcon: View {
    let icon: String
    let text: String
    let badgeCount: Int?
    @State var isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: {
            action() // Execute the button's action
        }) {
            VStack {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .blue : .gray) // change to variable isSelected

                    if let count = badgeCount, count > 0 {
                         Circle()
                            .fill(.red)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Text("\(count)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                            )
                    }
                }
                Text(text)
                    .font(.caption)
                   .foregroundColor(isSelected ? .blue : .gray) // change to variable isSelected
            }
           .frame(maxWidth: .infinity)
        }
    }
    init(icon: String, text: String, badgeCount: Int? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.icon = icon
        self.text = text
        self.badgeCount = badgeCount
        self._isSelected = State(initialValue: isSelected)
        self.action = action
    }
}

struct ContactListView_Previews: PreviewProvider {
    static var previews: some View {
        ContactListView()
    }
}
