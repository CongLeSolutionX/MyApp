//
//  ContactDetailView.swift
//  MyApp
//
//  Created by Cong Le on 3/25/25.
//

import SwiftUI

struct ContactDetailView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Set background based on color scheme
            (colorScheme == .dark ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack {
                    // Top Bar
                    HStack {
                        Button(action: {
                            print("Back button tapped")
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .padding(.leading)
                        }
                        Spacer()
                        Button(action: {
                            print("Edit button tapped")
                        }) {
                            Text("Edit")
                                .foregroundColor(.gray)
                                .padding(.trailing)
                        }

                    }
                    .padding(.top)

                    // Contact Initial
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray4))
                            .frame(width: 100, height: 100)
                        Text("M")
                            .font(.system(size: 50, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    }
                    .padding()

                    // Contact Name
                    Text("Mom")
                        .font(.system(size: 36, weight: .regular, design: .default))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.bottom)

                    // Action Buttons
                    HStack(spacing: 20) {
                        actionButton(iconName: "message.fill", text: "message", action: { print("Message tapped") }, colorScheme: colorScheme)
                        actionButton(iconName: "phone.fill", text: "call", action: { print("Call tapped") }, colorScheme: colorScheme)
                        actionButton(iconName: "video.fill", text: "video", action: { print("Video tapped") }, colorScheme: colorScheme)
                        actionButton(iconName: "envelope.fill", text: "mail", action: { print("Mail tapped") }, colorScheme: colorScheme)
                        actionButton(iconName: "dollarsign.circle.fill", text: "pay", action: { print("Pay tapped") }, colorScheme: colorScheme)
                    }
                    .padding(.bottom)

                    // Today Section
                    roundedSection(colorScheme: colorScheme) {
                        VStack(alignment: .leading) {
                            Text("Today")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.headline)
                                .padding(.bottom, 5)

                            HStack {
                                Text("3:10 PM")
                                    .foregroundColor(.gray)
                                Text("Incoming Call")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Color.green)
                            }

                            Text("29 seconds")
                                .foregroundColor(.gray)
                                .padding(.bottom, 5)

                            Text("Calls with a checkmark have been verified by the carrier.")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                        .padding()
                    }

                    // Contact Photo & Poster
                    roundedSection(colorScheme: colorScheme) {
                        Button(action: {
                            print("Contact Photo & Poster tapped")
                        }) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color(.systemGray4))
                                        .frame(width: 30, height: 30)
                                    Text("M")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                }
                                Text("Contact Photo & Poster")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            .padding()
                        }.foregroundColor(colorScheme == .dark ? .white : .black) // Ensure button text color adapts
                    }

                    // Phone Number Section
                    roundedSection(colorScheme: colorScheme) {
                        Button(action: {
                             print("Phone Number tapped")
                        }) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("home")
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                    Text("RECENT")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                        .padding(2)
                                        .background(Color.secondary.opacity(0.3))
                                        .cornerRadius(3)
                                }
                                .padding(.bottom, 2)

                                Text("(714) 660-8612")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                            }
                            .padding()
                        }
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    }

                    // FaceTime
                    roundedSection(colorScheme: colorScheme) {
                        Button(action: {
                             print("FaceTime tapped")
                        }) {
                            HStack {
                                Text("FaceTime")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Spacer()
                                Image(systemName: "video.fill")
                                    .foregroundColor(.blue)
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                        }.foregroundColor(colorScheme == .dark ? .white : .black)
                    }

                    // Ringtone
                    roundedSection(colorScheme: colorScheme) {
                        Button(action: {
                            print("Ringtone tapped")
                        }) {
                            HStack {
                                Text("Ringtone")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Spacer()
                                Text("Sound: Hey Mama")
                                    .foregroundColor(.blue)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }.foregroundColor(colorScheme == .dark ? .white : .black)

                    }

                }
                .padding(.top, 20)
                .padding(.bottom, 100) // Add padding to prevent content from being hidden by tab bar
            } // End ScrollView

            // Tab Bar (Placeholder - Replace with proper TabView)
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        print("Favorites tapped")
                    }) {
                        Image(systemName: "star.fill") // Favorites icon
                            .foregroundColor(.blue)
                    }
                    Button(action: {
                        print("Recents tapped")
                    }) {
                        Image(systemName: "clock.fill")// Recents icon
                            .foregroundColor(.blue)
                    }
                    Button(action: {
                        print("Contacts tapped")
                    }) {
                        Image(systemName: "person.fill") // Contacts icon
                            .foregroundColor(.blue)
                    }
                    Button(action: {
                        print("Keypad tapped")
                    }) {
                        Image(systemName: "circle.grid.3x3.fill")// Keypad
                            .foregroundColor(.blue)
                    }
                    Button(action: {
                        print("Voicemail tapped")
                    }) {
                        ZStack {
                            Image(systemName: "oval.portrait") //Voicemail icon
                            Circle()
                                .fill(.red)
                                .frame(width: 10, height: 10)
                                .offset(x: 8, y: -8) // Position badge using negative offset for top right
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
            }.frame(maxHeight: .infinity, alignment: .bottom)

        }
        .edgesIgnoringSafeArea(.bottom)
    }

    // Helper function for rounded sections
    func roundedSection<Content: View>(colorScheme: ColorScheme, @ViewBuilder content: () -> Content) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(.systemGray6))
            .overlay(content())
            .padding(.horizontal)
    }

    // Updated helper function for action buttons
    func actionButton(iconName: String, text: String, action: @escaping () -> Void, colorScheme: ColorScheme) -> some View {
         Button(action: action) {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                        .frame(width: 50, height: 50)
                    Image(systemName: iconName)
                        .foregroundColor(.white)
                }
                Text(text)
                    .foregroundColor( colorScheme == .dark ? .white : .gray)
                    .font(.caption)
            }
        }
    }
}

struct ContactDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContactDetailView()
            .preferredColorScheme(.dark) // Test dark mode
        ContactDetailView()
            .preferredColorScheme(.light) // Test light mode
    }
}
