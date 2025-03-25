//
//  DialingView.swift
//  MyApp
//
//  Created by Cong Le on 3/25/25.
//

import SwiftUI

 struct DialingView: View {
     var body: some View {
         ZStack {
             Color.black.edgesIgnoringSafeArea(.all) // Background color

             VStack {
                 Spacer()
                 // Top status bar (time, signal, battery) - simplified for this example
                 HStack {
                     Text("4:01").foregroundColor(.green).padding(.leading)
                     Spacer()
                     Text("5G+ 71").foregroundColor(.white).padding(.trailing)
                 }
                 .padding(.top)

                 Spacer() // Push dial pad to the lower part of the screen

                 // Dial Pad
                 LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                     DialButton(number: "1", letters: "")
                     DialButton(number: "2", letters: "ABC")
                     DialButton(number: "3", letters: "DEF")
                     DialButton(number: "4", letters: "GHI")
                     DialButton(number: "5", letters: "JKL")
                     DialButton(number: "6", letters: "MNO")
                     DialButton(number: "7", letters: "PQRS")
                     DialButton(number: "8", letters: "TUV")
                     DialButton(number: "9", letters: "WXYZ")
                     DialButton(number: "*", letters: "")
                     DialButton(number: "0", letters: "+")
                     DialButton(number: "#", letters: "")
                 }
                 .padding(.horizontal, 30)

                 Spacer()

                 // Call Button
                 Button(action: {
                     // Call action
                     print("Call button tapped")
                 }) {
                     Image(systemName: "phone.fill")
                         .font(.system(size: 36, weight: .regular))
                         .foregroundColor(.white)
                         .padding()
                         .background(Color.green)
                         .clipShape(Circle())
                 }
                 .padding(.bottom)

                 Spacer()
                 // Bottom Tab Bar
                 HStack {
                     TabBarItem(icon: "star", label: "Favorites")
                     TabBarItem(icon: "clock", label: "Recents")
                     TabBarItem(icon: "person", label: "Contacts")
                     TabBarItem(icon: "square.grid.2x2.fill", label: "Keypad", isSelected: true) // Highlighted
                     ZStack(alignment: .topTrailing){
                         TabBarItem(icon: "mail.stack", label: "Voicemail")
                         Circle()
                             .fill(.red)
                             .frame(width: 18)
                             .overlay(Text("37").font(.system(size: 10, weight: .bold)).foregroundColor(.white))
                             .offset(x: 8, y: -5)
                        
                     }
                 }
                 .padding(.horizontal)
                 .padding(.bottom, 10)
             }
         }
     }
 }

 struct DialButton: View {
     let number: String
     let letters: String

     var body: some View {
         Button(action: {
             // Dial number action
             print("\(number) button tapped")
         }) {
             ZStack {
                 Circle()
                     .fill(Color(UIColor.darkGray)) // Dark gray color
                     .frame(width: 80, height: 80)

                 VStack {
                     Text(number)
                         .font(.title)
                         .foregroundColor(.white)
                     if !letters.isEmpty {
                         Text(letters)
                             .font(.system(size: 10))
                             .foregroundColor(.white)
                     }
                 }
             }
         }
     }
 }

 struct TabBarItem: View {
     let icon: String
     let label: String
     var isSelected: Bool = false

     var body: some View {
         VStack {
             Image(systemName: icon)
                 .font(.system(size: 24))
                 .foregroundColor(isSelected ? .blue : .gray)
             Text(label)
                 .font(.system(size: 12))
                 .foregroundColor(isSelected ? .blue : .gray)
         }
         .frame(maxWidth: .infinity)
     }
 }

 struct DialingView_Previews: PreviewProvider {
     static var previews: some View {
         DialingView()
     }
 }
