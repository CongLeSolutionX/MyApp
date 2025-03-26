//
//  GoogleNewsListView.swift
//  MyApp
//
//  Created by Cong Le on 3/18/25.

import SwiftUI
import SafariServices

struct GoogleNewsListView: View {
    @State private var showingNLR = false
    @State private var showingCBC = false
    @State private var showingAxios = false
    @State private var showingGutenberg = false
    @State private var nlrURL = URL(string: "https://www.natlawreview.com")! // Make URLs properties
    @State private var cbcURL = URL(string: "https://www.cbc.ca")!
    @State private var axiosURL = URL(string: "https://www.axios.com")!
    @State private var gutenbergURL = URL(string: "https://www.gutenberg.org/cache/epub/84/pg84.txt")!

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
                        // ... (rest of the first news item UI) ...
                        VStack(alignment: .leading) {
                            Image("My-meme-red-wine-glass")
                                .resizable()
                                .scaledToFit()
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
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingNLR) {
                        SafariView(url: nlrURL, entersReaderIfAvailable: true) // Use the URL property
                            .ignoresSafeArea() // Add this to extend to full screen
                    }

                    // Subsequent News Items (Smaller Image)
                    Button(action: {
                        showingCBC = true
                    }) {
                        NewsItem(
                            // ... (rest of NewsItem) ...
                            logo: "cbc_logo",
                            source: "CBC News",
                            headline: "Canadians exempted from fingerprinting for U.S. travel under new Homeland Security rules",
                            timeAgo: "6 days ago",
                            image: "cbc_news_image"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingCBC) {
                        SafariView(url: cbcURL, entersReaderIfAvailable: false)
                            .ignoresSafeArea()
                    }

                    Button(action: {
                        showingAxios = true
                    }) {
                        NewsItem(
                           // ... (rest of NewsItem) ...
                            logo: "axios_logo",
                            source: "Axios",
                            headline: "Canadian snowbirds will have to register with U.S. under new Trump rule",
                            timeAgo: "4 days ago",
                            image: "axios_news_image"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingAxios) {
                        SafariView(url: axiosURL, entersReaderIfAvailable: true, customBarTintColor: .blue, customControlTintColor: .white) // Customize!
                            .ignoresSafeArea()
                    }
                    
                    Button(action: {
                        showingGutenberg = true
                    }) {
                        NewsItem(
                           // ... (rest of NewsItem) ...
                            logo: "Gutenberg_logo",
                            source: "Gutenberg",
                            headline: "Gutenberg Project free ebook",
                            timeAgo: "4 days ago",
                            image: "Gutenberg_Project_image"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingGutenberg) {
                        SafariView(url: gutenbergURL, entersReaderIfAvailable: true, customBarTintColor: .systemYellow, customControlTintColor: .white) // Customize!
                            .ignoresSafeArea()
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
    var entersReaderIfAvailable: Bool = false // Reader View option
    var customBarTintColor: UIColor? = nil     // Bar tint color
    var customControlTintColor: UIColor? = nil // Control tint color
    var dismissButtonStyle: SFSafariViewController.DismissButtonStyle = .done // Dismiss button style

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = entersReaderIfAvailable
        config.barCollapsingEnabled = true // Enable bar collapsing (standard behavior)

        let safariVC = SFSafariViewController(url: url, configuration: config)
        safariVC.delegate = context.coordinator  // Set the delegate
        
        // Customization (if provided)
        if let barTintColor = customBarTintColor {
            safariVC.preferredBarTintColor = barTintColor
        }
        if let controlTintColor = customControlTintColor {
            safariVC.preferredControlTintColor = controlTintColor
        }
        safariVC.dismissButtonStyle = dismissButtonStyle

        return safariVC
    }

    func updateUIViewController(_ safariViewController: SFSafariViewController, context: Context) {
        // You can update settings here if needed, but it's less common with SFSafariViewController
        // For example, if the URL changed, you *could* reload the page:
        if safariViewController.userActivity?.webpageURL != url {
            safariViewController.loadViewIfNeeded()
            if #available(iOS 11.0, *) {
                safariViewController.reloadInputViews()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Coordinator (Delegate) - Handles events from SFSafariViewController
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var parent: SafariView

        init(_ parent: SafariView) {
            self.parent = parent
        }

        // Called when the user taps "Done"
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            // Dismiss the view (SwiftUI handles this automatically because of the sheet)
            // You could add other actions here if needed (e.g., tracking)
        }
        
        // Called when the initial load finishes.
        func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
            if didLoadSuccessfully {
                print("SafariView loaded successfully")
            } else {
                print("SafariView failed to load")
                // Handle loading errors here.  Maybe show an alert to the user.
            }
        }
        
        // Called when activity items are completed (e.g., sharing)
        func safariViewController(_ controller: SFSafariViewController, activityItemsConfigurationFor activityType: UIActivity.ActivityType?) -> UIActivityItemsConfigurationReading? {
            return nil // You can customize the activity items (sharing) here if needed
        }

        // iOS 15+; called when the user dismisses the view using a swipe gesture.
        func safariViewControllerWillOpenInBrowser(_ controller: SFSafariViewController) {
             print("SafariViewController will open in browser")
        }
    }
}

struct GoogleNewsListView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleNewsListView()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
