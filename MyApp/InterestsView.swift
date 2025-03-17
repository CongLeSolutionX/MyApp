//
//  InterestsView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct InterestsView: View {
    // State variables for tab selection and segmented control
    @State private var selectedTab: Tab = .interests
    @State private var selectedSegment = 0

    // Enum for Tab Bar Items
    enum Tab: String, CaseIterable {
        case forYou = "For you"
        case episodes = "Episodes"
        case saved = "Saved"
        case interests = "Interests"

        var iconName: String {
            switch self {
            case .forYou: return "sparkles"
            case .episodes: return "book"
            case .saved: return "bookmark"
            case .interests: return "number"
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Background
                Color(UIColor(red: 0.95, green: 0.9, blue: 0.95, alpha: 1.0)) // Light grayish-purple
                    .edgesIgnoringSafeArea(.all)

                // Main Content Area
                VStack {
                    // Top Navigation Bar (Hidden in NavigationView, but we'll create the content)
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Spacer()
                        Text("Interests")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()

                        // Conditional rendering of buttons
                        if selectedSegment == 0 { // Topics tab
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                        } else {                   // People Tab
                            Image(systemName: "person.circle")
                        }
                    }
                    .padding(.horizontal)

                    // Segmented Control (Topics/People)
                    Picker(selection: $selectedSegment, label: Text("")) {
                        Text("Topics").tag(0)
                        Text("People").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Content based on segment selection
                    if selectedSegment == 0 {
                        topicsView // Show topics view
                    } else {
                        peopleView // show people view
                    }

                    Spacer() // Push content to the top
                }
                .padding(.top, 10) // Add padding to separate content and navigation bar
                 // Custom Tab Bar
                createCustomTabBar()

            }

            .navigationBarHidden(true) // Hide the default navigation bar
        }
    }

    // Custom Tab Bar (Re-usable component)
    func createCustomTabBar() -> some View {
           HStack {
               ForEach(Tab.allCases, id: \.self) { tab in
                   Button(action: {
                       selectedTab = tab
                   }) {
                       VStack {
                           Image(systemName: tab.iconName)
                               .resizable()
                               .scaledToFit()
                               .frame(width: 24, height: 24)
                           Text(tab.rawValue)
                               .font(.caption)
                       }
                       .foregroundColor(selectedTab == tab ? .purple : .gray) // Highlight selected tab
                   }
                   .frame(maxWidth: .infinity) // Equal spacing
               }
           }
           .padding(.vertical, 8)
           .background(Color(UIColor.systemBackground)) // Adapts to light/dark mode
           .overlay( // Top border
               Rectangle()
                   .frame(height: 1)
                   .foregroundColor(Color.gray.opacity(0.3)),
               alignment: .top
           )
       }

    // Topics View (Placeholder content)
    var topicsView: some View {
        ScrollView {
            VStack {
                // Placeholder for loading indicator (spinning)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                    .scaleEffect(1.5)
                    .padding(.top, 20)

                // Placeholder content (repeating blocks)
                ForEach(0..<5) { _ in
                    topicPlaceholder
                }
            }
            .padding(.horizontal)
        }
    }

    // Single Topic Placeholder
    var topicPlaceholder: some View {
        VStack(alignment: .leading) {
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 10)
                    .padding(.leading, 8)
            }
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 10)
                .padding(.top, 4)
        }
        .padding(.bottom, 16)
    }

     // People View (Placeholder Content + Description)
    var peopleView: some View {
          ScrollView {
              VStack {
                  // Description Text
                  Text("What are you interested in?")
                      .font(.title2)
                      .fontWeight(.bold)
                      .padding(.top, 10)
                  Text("Updates from topics you follow will appear here. Follow some things to get started.")
                      .font(.subheadline)
                      .foregroundColor(.gray)
                      .multilineTextAlignment(.center)
                      .padding(.horizontal)
                      .padding(.bottom)

                  // Placeholder for loading indicator
                  ProgressView()
                      .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                      .scaleEffect(1.5)
                      .padding()

                // Placeholder Content - Repeating "Person" items
                ForEach(0..<4) { _ in
                    personPlaceholder
                }
                
                  // "Done" Button
                  Button(action: {}) { // Replace with actual action later
                      Text("Done")
                          .fontWeight(.bold)
                          .foregroundColor(.white)
                          .padding()
                          .frame(maxWidth: .infinity)
                          .background(Color.purple)
                          .cornerRadius(10)
                  }
                  .padding(.horizontal)
                  .padding(.bottom, 20)  // Add padding to avoid overlap with tab bar
                  
              }
          }
      }

      // Single Person Placeholder
      var personPlaceholder: some View {
          HStack {
              ZStack { // For the "+" overlay
                  Circle()
                      .fill(Color.gray.opacity(0.3))
                      .frame(width: 50, height: 50)
                  Image(systemName: "plus.circle.fill")
                      .foregroundColor(.white)
                      .background(Color.gray.opacity(0.3))
                      .clipShape(Circle()) // Clip the background to a circle as well
              }

              Rectangle()
                  .fill(Color.gray.opacity(0.3))
                  .frame(height: 12)
                  .padding(.leading, 8)

              Spacer()  // Push to the right
              Image(systemName: "plus") // Add button
                  .foregroundColor(.gray)
          }
          .padding(.vertical, 8)
      }
}

// MARK: - Preview
struct InterestsView_Previews: PreviewProvider {
    static var previews: some View {
        InterestsView()
    }
}
