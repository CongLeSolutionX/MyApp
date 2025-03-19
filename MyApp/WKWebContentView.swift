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
                        Image(systemName: "chevron.left").font(.title2)
                        Text("Full Coverage").font(.subheadline)
                        Spacer()
                        Image(systemName: "square.and.arrow.up")
                        Image(systemName: "ellipsis")
                    }
                    .padding(.horizontal)

                    Text("News about Canadians • US").font(.title2).fontWeight(.bold).padding(.horizontal)
                    Text("Top news").font(.title).fontWeight(.bold).padding(.horizontal).padding(.top)

                    // First News Item
                    Button(action: { showingNLR = true }) {
                        VStack(alignment: .leading) {
                            Image("My-meme-red-wine-glass").resizable().scaledToFill().frame(height: 200).clipped().cornerRadius(10)
                            HStack { Image("nlr_logo").resizable().scaledToFit().frame(width: 20, height: 20); Text("The National Law Review").font(.caption) }
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
                        WKWebViewNewsItem(logo: "cbc_logo", source: "CBC News", headline: "Canadians exempted...", timeAgo: "6 days ago", image: "My-meme-red-wine-glass")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingCBC) {
                        AdvancedWebView(url: cbcURL)
                    }

                    Button(action: { showingAxios = true }) {
                        WKWebViewNewsItem(logo: "axios_logo", source: "Axios", headline: "Canadian snowbirds will have to register...", timeAgo: "4 days ago", image: "My-meme-red-wine-glass")
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

struct AdvancedWebView: UIViewRepresentable {
    let url: URL
    @State private var isLoading: Bool = true
    @State private var canGoBack: Bool = false
    @State private var canGoForward: Bool = false
    @State private var estimatedProgress: Double = 0.0
    @State private var alertMessage: String? = nil
    @State private var isAlertPresented = false
    @State private var webView: WKWebView = WKWebView() // Store the WKWebView

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator  // Set uiDelegate
        webView.load(URLRequest(url: url))
        webView.customUserAgent = "MyNewsApp/1.0 (iPad; iOS 17.0)"

        // Add observers *here*, on the stored webView instance
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No need to reload here; we handle navigation in the Coordinator
    }

      func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: AdvancedWebView

        init(_ parent: AdvancedWebView) {
            self.parent = parent
        }
        
        // Correct deinit: Remove observers from the *stored* webView
        deinit {
            parent.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
            parent.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
            parent.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
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
            parent.isAlertPresented = true
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            if (error as NSError).code == NSURLErrorCancelled { return }
            parent.alertMessage = "Failed to Load: \(error.localizedDescription)"
            parent.isAlertPresented = true
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
             if navigationAction.navigationType == .linkActivated {
                if let url = navigationAction.request.url, url.host != parent.url.host {
                    UIApplication.shared.open(url) // Open external links in Safari
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }

        // MARK: - KVO Observation

        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == #keyPath(WKWebView.estimatedProgress) {
                parent.estimatedProgress = change?[.newKey] as? Double ?? 0.0
            } else if keyPath == #keyPath(WKWebView.canGoBack) {
                parent.canGoBack = change?[.newKey] as? Bool ?? false
            } else if keyPath == #keyPath(WKWebView.canGoForward) {
                parent.canGoForward = change?[.newKey] as? Bool ?? false
            }
        }

        // MARK: - WKUIDelegate Methods

        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            parent.alertMessage = message
            parent.isAlertPresented = true
            completionHandler()
        }

        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
             let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            })
            alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(true)
            })
            // Present from the root view controller
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(alertController, animated: true, completion: nil)
            } else {
                completionHandler(false) // Fallback if no root view controller
            }
        }

        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.text = defaultText
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(nil)
            })
            alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                let text = alertController.textFields?.first?.text
                completionHandler(text)
            })

             if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                 rootViewController.present(alertController, animated: true, completion: nil)
            } else {
                 completionHandler(nil)
            }
        }
    }
    
    // MARK: - View Content
    var webViewContent: some View {
        ZStack {
             WebViewRepresentable(webView: webView) // Use the stored webView

            if isLoading {
                ProgressView(value: estimatedProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
            }

            VStack {
                Spacer()
                HStack {
                    Button(action: { if webView.canGoBack { webView.goBack() } }) {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(!canGoBack)
                    Spacer()
                    Button(action: { if webView.canGoForward { webView.goForward() } }) {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(!canGoForward)
                    Spacer()
                    Button(action: { webView.reload() }) {
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

struct WKWebContentView_Previews: PreviewProvider {
    static var previews: some View {
        WKWebContentView()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
