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

            ScrollView {
                VStack {
                    // Top Bar
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(.leading)
                        Spacer()
                        Text("Edit")
                            .foregroundColor(.gray)
                            .padding(.trailing)
                    }
                    .padding(.top)

                    // Circle Avatar
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                        Text("M")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    .padding()

                    // Name
                    Text("Mom")
                        .font(.system(size: 36, weight: .regular,design: .default))
                        .foregroundColor(.white)
                        .padding(.bottom)

                    // Action Buttons
                    HStack(spacing: 20) {
                        ActionButton(imageName: "message.fill", text: "message")
                        ActionButton(imageName: "phone.fill", text: "call")
                        ActionButton(imageName: "video.fill", text: "video")
                        ActionButton(imageName: "envelope.fill", text: "mail")
                        ActionButton(imageName: "dollarsign.circle.fill", text: "pay")
                    }
                    .padding(.bottom)

                    // Today Section
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.2))
                        .padding(.horizontal)
                        .overlay(
                            VStack(alignment: .leading) {
                                Text("Today")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding(.top)
                                Text("3:10 PM Incoming Call \u{2705}")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                Text("29 seconds")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                Text("Calls with a checkmark have been verified by the carrier.")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                    .padding(.bottom)
                            }
                            .padding()
                            ,alignment: .topLeading
                        )

                    // Contact Photo & Poster
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.2))
                        .padding(.horizontal)
                        .overlay(
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.5))
                                        .frame(width: 30, height: 30)
                                    Text("M")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                }
                                Text("Contact Photo & Poster")
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            ,alignment: .topLeading
                        )

                    // Home Section
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.2))
                        .padding(.horizontal)
                        .overlay(
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("home")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                    Text("RECENT")
                                        .foregroundColor(.gray)
                                        .font(.caption)

                                }
                                Text("(714) 660-8612")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 20, weight: .regular,design: .default))
                            }
                            .padding()
                            ,alignment: .topLeading
                      )
                      
                    //FaceTime Section
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.2))
                        .padding(.horizontal)
                        .overlay(
                            HStack {
                                Text("FaceTime")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "video.fill")
                                    .foregroundColor(.blue)
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            ,alignment: .topLeading
                      )

                     //Ringtone Section
                     RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.2))
                        .padding(.horizontal)
                        .overlay(
                            HStack {
                                VStack(alignment: .leading){
                                    Text("Ringtone")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                    Text("Sound: Hey Mama")
                                        .foregroundColor(.blue)
                                        .font(.subheadline)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            ,alignment: .topLeading
                      )
                    Spacer()
                }
            }

            VStack {
                Spacer()
                // Bottom Tab Bar
                HStack {
                    BottomBarButton(imageName: "star.fill", text: "Favorites", badgeCount: nil)
                    BottomBarButton(imageName: "clock.fill", text: "Recents", badgeCount: nil)
                    BottomBarButton(imageName: "person.fill", text: "Contacts", badgeCount: nil)
                    BottomBarButton(imageName: "keypad", text: "Keypad", badgeCount: nil)
                    BottomBarButton(imageName: "voicemail.fill", text: "Voicemail", badgeCount: 37)
                }
                .padding(.top, 8)
                .padding(.bottom, 30)
                .background(Color.secondary.opacity(0.2))
            }
        }
    }
}

struct ActionButton: View {
    let imageName: String
    let text: String

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 60, height: 60)
                Image(systemName: imageName)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            Text(text)
                .foregroundColor(.white)
                .font(.caption)
        }
    }
}

struct BottomBarButton: View {
    let imageName: String
    let text: String
    let badgeCount: Int?

    var body: some View {
        ZStack {
            VStack {
                Image(systemName: imageName)
                    .font(.title3)
                    .foregroundColor(.white)
                Text(text)
                    .foregroundColor(.white)
                    .font(.system(size: 10))
            }

            if let count = badgeCount {
                Circle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Text("\(count)")
                            .foregroundColor(.white)
                            .font(.system(size: 12))
                    )
                    .offset(x: 15, y: -10)
            }
        }
    }
}

struct ContactDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContactDetailView()
    }
}
