//
//  ContactDetailView.swift
//  MyApp
//
//  Created by Cong Le on 3/25/25.
//
import SwiftUI

struct ContactDetailView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack {
                // Top Bar
                HStack {
                    Button(action: {
                        print("Back button tapped")
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
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
                    .foregroundColor(.white)
                    .padding(.bottom)

                // Action Buttons
                HStack(spacing: 20) {
                    actionButton(iconName: "message.fill", text: "message", action: { print("Message tapped") })
                    actionButton(iconName: "phone.fill", text: "call", action: { print("Call tapped") })
                    actionButton(iconName: "video.fill", text: "video", action: { print("Video tapped") })
                    actionButton(iconName: "envelope.fill", text: "mail", action: { print("Mail tapped") })
                    actionButton(iconName: "dollarsign.circle.fill", text: "pay", action: { print("Pay tapped") })
                }
                .padding(.bottom)

                // Today Section
                roundedSection {
                    VStack(alignment: .leading) {
                        Text("Today")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(.bottom, 5)

                        HStack {
                            Text("3:10 PM")
                                .foregroundColor(.gray)
                            Text("Incoming Call")
                                .foregroundColor(.white)
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
                roundedSection {
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
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                }

                // Phone Number Section
                roundedSection {
                    Button(action: {
                         print("Phone Number tapped")
                    }) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("home")
                                    .foregroundColor(.white)
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
                }

                // FaceTime
                roundedSection {
                    Button(action: {
                         print("FaceTime tapped")
                    }) {
                        HStack {
                            Text("FaceTime")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "video.fill")
                                .foregroundColor(.blue)
                            Image(systemName: "phone.fill")
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                }

                // Ringtone
                roundedSection {
                    Button(action: {
                        print("Ringtone tapped")
                    }) {
                        HStack {
                            Text("Ringtone")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Sound: Hey Mama")
                                .foregroundColor(.blue)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                }

                Spacer()
            }
            .padding(.top, 20)

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
            }.frame(maxHeight: .infinity)

        }
        .edgesIgnoringSafeArea(.bottom)
    }

    // Helper function for rounded sections
    func roundedSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(.systemGray6))
            .overlay(content())
            .padding(.horizontal)
    }

    // Updated helper function for action buttons
    func actionButton(iconName: String, text: String, action: @escaping () -> Void) -> some View {
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
                    .foregroundColor(.white)
                    .font(.caption)
            }
        }
    }
}

struct ContactDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContactDetailView()
    }
}
