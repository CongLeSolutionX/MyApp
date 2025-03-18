//
//  GoogleNewsListView.swift
//  MyApp
//
//  Created by Cong Le on 3/18/25.
//
import SwiftUI
import SafariServices // Import for SFSafariViewController

struct GoogleNewsListView: View {
    @State private var showingNLR = false
    @State private var showingCBC = false
    @State private var showingAxios = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // Top Bar
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                        Text("Full Coverage")
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "square.and.arrow.up")
                        Image(systemName: "ellipsis")
                    }
                    .padding(.horizontal)
                    
                    Text("News about Canadians • US")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    Text("Top news")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // First News Item (Large Image) - with Navigation
                    Button(action: {
                        showingNLR = true
                    }) {
                        VStack(alignment: .leading) {
                            Image("My-meme-red-wine-glass")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(10)
                            
                            HStack {
                                Image("nlr_logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("The National Law Review")
                                    .font(.caption)
                            }
                            
                            Text("USCIS Issues Regulation Requiring Alien Registration")
                                .font(.headline)
                            
                            Text("Yesterday")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Spacer()
                                Image(systemName: "ellipsis")
                                    .padding(.trailing, 8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle()) // Remove button highlight
                    .sheet(isPresented: $showingNLR) {
                        SafariView(url: URL(string: "https://www.yahoo.com")!) // Replace with the actual URL
                    }
                    
                    // Subsequent News Items (Smaller Image)
                    
                    Button(action: {
                        showingCBC = true
                    }){
                        NewsItem(
                            logo: "cbc_logo",
                            source: "CBC News",
                            headline: "Canadians exempted from fingerprinting for U.S. travel under new Homeland Security rules",
                            timeAgo: "6 days ago",
                            image: "cbc_news_image"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingCBC) {
                        SafariView(url: URL(string: "https://www.google.com")!) // Replace with the actual URL
                    }
                    
                    
                    Button(action: {
                        showingAxios = true
                    }){
                        NewsItem(
                            logo: "axios_logo",
                            source: "Axios",
                            headline: "Canadian snowbirds will have to register with U.S. under new Trump rule",
                            timeAgo: "4 days ago",
                            image: "axios_news_image"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingAxios) {
                        SafariView(url: URL(string: "https://www.apple.com")!) // Replace with the actual URL
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Helper View for News Items (Refactored for reusability)
struct NewsItem: View {
    let logo: String
    let source: String
    let headline: String
    let timeAgo: String
    let image: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading){
                    HStack {
                        Image(logo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text(source)
                            .font(.caption)
                    }
                    
                    Text(headline)
                        .font(.headline)
                    
                    Text(timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(10)
            }
            
            HStack{
                Spacer()
                Image(systemName: "ellipsis")
                    .padding(.trailing, 8)
            }
        }
        .padding(.horizontal)
    }
}

// SafariView (UIViewControllerRepresentable)
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct GoogleNewsListView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleNewsListView()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
