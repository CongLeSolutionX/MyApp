//
//  WKWebContentView.swift
//  MyApp
//
//  Created by Cong Le on 3/18/25.
//
import SwiftUI
@preconcurrency import WebKit

struct WKWebContentView: View {
    @State private var showingNLR = false
    @State private var showingCBC = false
    @State private var showingAxios = false
    @State private var nlrURL = URL(string: "https://www.natlawreview.com")!
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

                    // First News Item
                    Button(action: { showingNLR = true }) {
                        VStack(alignment: .leading) {
                            Image("uscis")
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
                                Text("The National Law Review").font(.caption)
                            }
                            Text("USCIS Issues Regulation Requiring Alien Registration").font(.headline)
                            Text("Yesterday").font(.caption).foregroundColor(.secondary)
                            HStack { Spacer(); Image(systemName: "ellipsis").padding(.trailing, 8) }
                        }
                        .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingNLR) {
                        AdvancedWebView(url: nlrURL)
                    }

                    // Subsequent News Items
                    Button(action: { showingCBC = true }) {
                        WKWebViewNewsItem(logo: "cbc_logo", source: "CBC News", headline: "Canadians exempted from fingerprinting...", timeAgo: "6 days ago", image: "cbc_news_image")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingCBC) {
                        AdvancedWebView(url: cbcURL)
                    }

                    Button(action: { showingAxios = true }) {
                        WKWebViewNewsItem(logo: "axios_logo", source: "Axios", headline: "Canadian snowbirds will have to register...", timeAgo: "4 days ago", image: "axios_news_image")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingAxios) {
                        AdvancedWebView(url: axiosURL)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct WKWebViewNewsItem: View {
    let logo: String; let source: String; let headline: String; let timeAgo: String; let image: String
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack { Image(logo).resizable().scaledToFit().frame(width: 20, height: 20); Text(source).font(.caption) }
                    Text(headline).font(.headline)
                    Text(timeAgo).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Image(image).resizable().scaledToFill().frame(width: 80, height: 80).clipped().cornerRadius(10)
            }
            HStack { Spacer(); Image(systemName: "ellipsis").padding(.trailing, 8) }
        }
        .padding(.horizontal)
    }
}

// Advanced WebView (UIViewControllerRepresentable) with WKNavigationDelegate
struct AdvancedWebView: UIViewRepresentable {
    let url: URL
    @State private var isLoading: Bool = true // Track loading state
    @State private var canGoBack: Bool = false
    @State private var canGoForward: Bool = false
    @State private var estimatedProgress: Double = 0.0
    @State private var alertMessage: String? = nil
    @State private var isAlertPresented = false
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        
        // Observe loading progress
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
        
        // Set a custom user agent (optional, but good practice)
        webView.customUserAgent = "MyNewsApp/1.0 (iPad; iOS 17.0)"
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Inner Coordinator class to act as the WKNavigationDelegate
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {  // Added WKUIDelegate
        var parent: AdvancedWebView
        
        init(_ parent: AdvancedWebView) {
            self.parent = parent
        }
        
        // MARK: - WKNavigationDelegate Methods
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.alertMessage = "Navigation Error: \(error.localizedDescription)"
            parent.isAlertPresented = true // Show alert
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            // More specific error handling for provisional navigation failures
            if (error as NSError).code == NSURLErrorCancelled {
                // Ignore cancelled errors (e.g., user tapped back quickly)
                return
            }
            parent.alertMessage = "Failed to Load: \(error.localizedDescription)"
            parent.isAlertPresented = true // Show alert
            
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Example: Handle different types of navigation actions
            if navigationAction.navigationType == .linkActivated {
                // Handle links opened by the user (e.g., open in a new tab/window)
                if let url = navigationAction.request.url, url.host != parent.url.host {
                    // Open external links in SFSafariViewController (for consistency)
                    UIApplication.shared.open(url)
                    decisionHandler(.cancel) // Prevent WKWebView from loading it
                    return
                }
            }
            decisionHandler(.allow) // Allow other navigation
        }
        
        
        // MARK: - KVO Observation
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == #keyPath(WKWebView.estimatedProgress) {
                if let progress = change?[.newKey] as? Double {
                    parent.estimatedProgress = progress
                }
            } else if keyPath == #keyPath(WKWebView.canGoBack) {
                if let canGoBack = change?[.newKey] as? Bool {
                    parent.canGoBack = canGoBack
                }
            } else if keyPath == #keyPath(WKWebView.canGoForward) {
                if let canGoForward = change?[.newKey] as? Bool {
                    parent.canGoForward = canGoForward
                }
            }
        }
        
        // MARK: - WKUIDelegate Methods (for JavaScript alerts, confirms, prompts)
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            parent.alertMessage = message // Display JavaScript alert messages
            parent.isAlertPresented = true
            completionHandler() // Acknowledge the alert
            
        }
        
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            //  Basic implementation, always confirms. Ideally, show a custom alert.
            completionHandler(true)
        }
        
        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            //  Basic implementation, always returns the default text.
            completionHandler(defaultText)
        }
        
        //  Cleanup observers when deallocated
        deinit {
            if let webView = parent.makeUIView(context: .init(self)) as? WKWebView {
                webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
                webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
                webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
            }
        }
    }
    
    // MARK: - View Content
    var webViewContent: some View {
        ZStack { // Use ZStack to layer views
            WebViewRepresentable(webView: makeUIView(context: .init(self)))  // Use the underlying webView

            if isLoading { // Show loading indicator
                ProgressView(value: estimatedProgress)
                    .progressViewStyle(LinearProgressViewStyle()) // Use Linear style
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2)) // subtle background
            }

            VStack { // Navigation buttons at the bottom
                Spacer()
                HStack {
                    Button(action: {
                        if let webView = makeUIView(context: .init(self)) as? WKWebView, webView.canGoBack {
                            webView.goBack()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(!canGoBack)

                    Spacer()

                    Button(action: {
                        if let webView = makeUIView(context: .init(self)) as? WKWebView, webView.canGoForward {
                            webView.goForward()
                        }
                    }) {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(!canGoForward)
                    
                    Spacer()
                    
                    Button(action: {
                        if let webView = makeUIView(context: .init(self)) as? WKWebView{
                            webView.reload()
                        }
                    }){
                        Image(systemName: "arrow.clockwise")
                    }
                    
                }
                .padding()
                .background(Color.gray.opacity(0.1))
            }
        }
        .alert(isPresented: $isAlertPresented) {
            Alert(title: Text("Alert"), message: Text(alertMessage ?? "Unknown Error"), dismissButton: .default(Text("OK")))
        }
    }
}
// New struct for underlying WebView setup to avoid any potential conflicts
struct WebViewRepresentable: UIViewRepresentable {
    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
