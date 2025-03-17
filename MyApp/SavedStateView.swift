//
//  SavedStateView.swift
//  MyApp
//
//  Created by Cong Le on 3/16/25.
//

import SwiftUI

struct SavedStateView: View {
    // State to manage the selected tab.  Start with "Saved".
    @State private var selectedTab = "Saved"

    var body: some View {
        NavigationView {
            VStack { // Use VStack to arrange top bar, content, and tab bar vertically
                // Top Bar (Customized within the NavigationView)
                HStack {
                    Image(systemName: "magnifyingglass")
                    Spacer()
                    Text("Saved")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "ellipsis.circle")
                }
                .padding(.horizontal)

                // Main Content Area
                Spacer() // Push content to the center vertically
                
                // Empty State View (Conditional based on saved items - Placeholder here)
                EmptySavedView()
                
                Spacer() // Push content to the center vertically

                // Bottom Tab Bar (using TabView)
                Divider() // Add a visual divider
                
                //Custom TabView
                HStack{
                    Spacer()
                    
                    Button {
                        selectedTab = "For you"
                    } label: {
                        VStack{
                            Image(systemName: "person.crop.circle.fill")
                            Text("For you")
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(selectedTab == "For you" ? .purple : .gray)
                    
                    Spacer()
                    
                    Button {
                        selectedTab = "Episodes"
                    } label: {
                        VStack{
                            Image(systemName: "book.closed.fill")
                            Text("Episodes")
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(selectedTab == "Episodes" ? .purple : .gray)
                    
                    Spacer()
                    
                    Button {
                        selectedTab = "Saved"
                    } label: {
                        VStack{
                            Image(systemName: "bookmark.fill")
                            Text("Saved")
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(selectedTab == "Saved" ? .purple : .gray)
                    
                    Spacer()
                    
                    Button {
                        selectedTab = "Interests"
                    } label: {
                        VStack{
                            Image(systemName: "tag.fill")
                            Text("Interests")
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(selectedTab == "Interests" ? .purple : .gray)
                    
                    Spacer()
                }
                .padding(.bottom)
            }
            .navigationBarHidden(true) // Hide default navigation bar
        }
    }
}

// Separate view for the "empty saved" state.  Good for reusability.
struct EmptySavedView: View {
    var body: some View {
        VStack {
            Image(systemName: "bookmark.slash.fill") // Larger, filled bookmark
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.purple)

            Text("No saved updates")
                .font(.title2)
                .foregroundColor(.black)

            Text("Updates you save will be stored here\nto read later")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding() // Add some padding around the content
    }
}
// Preview
struct SavedStateView_Previews: PreviewProvider {
    static var previews: some View {
        SavedStateView()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
