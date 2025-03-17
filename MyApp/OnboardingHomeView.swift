//
//  OnboardingHomeView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct OnboardingHomeView: View {
    // State variable to manage selected interests
    @State private var selectedInterests: [String] = []
    
    // Sample data for interests and people (replace with real data)
    let interests = ["Accessibility", "Android TV", "Android Auto", "Architecture", "Android Studio", "Compose"]
    let people = ["Fernando", "Alex", "Sam", "Lee"]
    
    // Function to toggle interest selection
    func toggleInterest(interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.removeAll(where: { $0 == interest })
        } else {
            selectedInterests.append(interest)
        }
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 0.1, green: 0.1, blue: 0.1).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading) {
                    // Top Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Spacer()
                        Text("Now in iOS").font(.title)
                        Spacer()
                        Image(systemName: "person.circle")
                    }
                    .padding()
                    
                    // Title
                    Text("What are you interested in?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    // Subtitle
                    Text("Updates from interests you follow will appear here. Follow some things to get started.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom)
                    
                    // People List (Horizontal Scroll)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(people, id: \.self) { person in
                                VStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 0.2, green: 0.2, blue: 0.2))
                                            .frame(width: 50, height: 50)
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.white)
                                    }
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .font(.system(size: 12))
                                        .padding(4)
                                        .background(Circle().fill(Color.gray))
                                }
                                .overlay(
                                   RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .padding(.trailing, 8)
                                Text(person).font(.caption).foregroundColor(.white)

                            }
                        }
                        .padding(.bottom)
                    }
                    
                    
                    // Interest List
                    VStack(spacing: 16) {
                        ForEach(interests, id: \.self) { interest in
                            Button(action: {
                                toggleInterest(interest: interest)
                            }) {
                                HStack {
                                    // SF Symbol based on the interest
                                    switch interest {
                                    case "Accessibility":
                                        Image(systemName: "figure.walk")
                                    case "Android TV":
                                        Image(systemName: "tv")
                                    case "Android Auto":
                                        Image(systemName: "car.fill")
                                    case "Architecture":
                                        Image(systemName: "building.columns")
                                    case "Android Studio":
                                        Image(systemName: "hammer.fill") // Placeholder, find a better one
                                    case "Compose":
                                        Image(systemName: "square.stack.3d.up.fill") // Placeholder
                                    default:
                                        Image(systemName: "questionmark")
                                    }
                                    
                                    Text(interest)
                                    Spacer()
                                    
                                    if selectedInterests.contains(interest) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.pink)
                                    } else {
                                        Image(systemName: "plus")
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity) // Make the button fill the width
                                .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            
                        }
                    }
                    .padding(.vertical)
                    
                    // Done Button
                    Button(action: {
                        // Handle done action
                    }) {
                        Text("Done")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                    .padding(.vertical)
                    
                    // Browse Topics Button
                    Button(action: {
                        // Handle browse topics
                    }) {
                        Text("Browse topics")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                    
                    // Dummy image (Replace with actual image/view)
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.5))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo") // Replace with your actual image
                                .resizable()
                                .scaledToFit()
                        )
                        .padding(.bottom)
                }
                .padding()
                
                
                // Tab Bar (Bottom)
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "star.fill").foregroundColor(.pink)
                        Text("For you").font(.caption).foregroundColor(.white)
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "book").foregroundColor(.white)
                        Text("Episodes").font(.caption).foregroundColor(.white)
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "bookmark").foregroundColor(.white)
                        Text("Saved").font(.caption).foregroundColor(.white)
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "number").foregroundColor(.white)
                        Text("Interests").font(.caption).foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.top)
                .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                
            }
            
            
        }
        
    }
}

struct OnboardingHomeView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingHomeView()
    }
}
