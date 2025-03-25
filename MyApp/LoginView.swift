
//
//  LoginView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
//
import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var saveUsername = false

    // Rose Gold Color Definition
    let roseGold = Color(red: 189/255, green: 143/255, blue: 123/255) // Slightly muted Rose Gold

    var body: some View {
        ZStack {
            // Dark Background
            Color.black.edgesIgnoringSafeArea(.all)

            VStack {
                // Top Bar
                HStack {
                    Text("Nest Buddy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(roseGold) // Rose Gold Logo Color
                    Spacer()
                    Button("Call Us") {
                        // Action for call us
                    }
                    .foregroundColor(roseGold) // Rose Gold Button Color
                }
                .padding()

                Spacer()
                    .frame(height: 20)

                // Hello Text
                Text("Hello, Cong!")
                    .font(.system(size: 36, weight: .bold, design: .default))
                    .foregroundColor(.white)

                    .padding(.bottom, 30)

                // Username Field
                TextField("Enter Username", text: $username)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    .foregroundColor(.white)
                    .overlay(
                        HStack {
                            Spacer()
                            Button(action: {
                                //FaceID Action
                            }) {
                                Image(systemName: "faceid")
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 8)

                        }
                    )
                    .padding(.horizontal)

                // Password Field
                SecureField("Enter Password", text: $password)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    .foregroundColor(.white)
                    .overlay(
                        HStack {
                            Spacer()
                            Button(action: {
                                //toggle Password Action
                            }) {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 8)

                        }
                    )
                    .padding(.horizontal)

                // Save Username Toggle
                Toggle(isOn: $saveUsername) {
                    Text("Save Username")
                        .foregroundColor(.white)
                }
                .padding()

                // Login Button
                Button("Log In") {
                    // Login action
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(roseGold) // Rose Gold Button Background
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

                // Forgot Username/Password
                HStack {
                    Button("Forgot username or password?") {
                        // Forgot password action
                    }
                    .foregroundColor(.gray)
                }
                .padding()

                Spacer()
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
