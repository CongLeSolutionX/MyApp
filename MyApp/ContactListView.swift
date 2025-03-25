//
//  ContactListView.swift
//  MyApp
//
//  Created by Cong Le on 3/25/25.
//


import SwiftUI

struct ContactListView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all) // Background color

                VStack {
                    // Top Bar
                    HStack {
                        NavigationLink(destination: Text("Lists")) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                            Text("Lists")
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        Text("Contacts")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            // Action
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
                        TextField("Search", text: .constant(""))
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

                            ContactRow(name: "Huy 📺☎️🎲 - A Hai")// example how to add emojis in text field
                            ContactRow(name: "A Anh VN")
                            ContactRow(name: "A Ba")
                            ContactRow(name: "A Duc Nail")
                            ContactRow(name: "A Duc Sua Xe")
                            ContactRow(name: "A Dung Nha")
                            ContactRow(name: "A Dung-ban nhau")
                            ContactRow(name: "A Duong")
                            ContactRow(name: "A Duy")
                            ContactRow(name: "A Duy - Chi Nghi")
                            ContactRow(name: "A Hai")

                        }
                    }

                    Spacer() // Push content to top

                    // Bottom Tab Bar
                    HStack {
                        TabBarIcon(icon: "star", text: "Favorites", isSelected: false) // Set the initial selection
                        TabBarIcon(icon: "clock", text: "Recents", isSelected: false)
                        TabBarIcon(icon: "person.fill", text: "Contacts", isSelected: true)
                        TabBarIcon(icon: "dialpad", text: "Keypad", isSelected: false)
                        TabBarIcon(icon: "voicemail", text: "Voicemail", badgeCount: 37, isSelected: false)
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
    var isSelected: Bool

    init(icon: String, text: String, badgeCount: Int? = nil, isSelected: Bool) {
        self.icon = icon
        self.text = text
        self.badgeCount = badgeCount
        self.isSelected = isSelected
    }

    var body: some View {
        Button(action: {
            // TODO: Add tab selection logic
        }) {
            VStack {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .blue : .gray)

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
                   .foregroundColor(isSelected ? .blue : .gray)
            }
           .frame(maxWidth: .infinity)
        }
    }
}

struct ContactListView_Previews: PreviewProvider {
    static var previews: some View {
        ContactListView()
    }
}
