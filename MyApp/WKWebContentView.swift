//
//  WKWebContentView.swift
//  MyApp
//
//  Created by Cong Le on 3/18/25.
//

import SwiftUI
import WebKit

struct WKWebContentView: View {
    @State private var showingNLR = false
    @State private var showingCBC = false
    @State private var showingAxios = false
    @State private var nlrURL = URL(string: "https://www.natlawreview.com")! // Store URLs
    @State private var cbcURL = URL(string: "https://www.cbc.ca")!
    @State private var axiosURL = URL(string: "https://www.axios.com")!

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
                            // ... (rest of the first news item content)
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
                                    .padding(.trailing,8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingNLR) {
                        WebView(url: nlrURL) // Use the WebView
                    }

                    // Subsequent News Items (Smaller Image)
                    Button(action: {
                        showingCBC = true
                    }) {
                        WKWebViewNewsItem(
                            logo: "cbc_logo",
                            source: "CBC News",
                            headline: "Canadians exempted from fingerprinting for U.S. travel under new Homeland Security rules",
                            timeAgo: "6 days ago",
                            image: "cbc_news_image"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingCBC) {
                        WebView(url: cbcURL)
                    }

                    Button(action: {
                        showingAxios = true
                    }) {
                        WKWebViewNewsItem(
                            logo: "axios_logo",
                            source: "Axios",
                            headline: "Canadian snowbirds will have to register with U.S. under new Trump rule",
                            timeAgo: "4 days ago",
                            image: "axios_news_image"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingAxios) {
                        WebView(url: axiosURL)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Helper View for News Items (Refactored for reusability)
struct WKWebViewNewsItem: View {
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

// MARK: - WebView (UIViewControllerRepresentable)
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url)) // Load the URL
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        //  uiView.load(URLRequest(url: url)) // No need to reload here
    }
}

// MARK: - Preview
struct WKWebContentView_Previews: PreviewProvider {
    static var previews: some View {
        WKWebContentView()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
