//
//  FacebookWebview.swift
//  MyApp
//
//  Created by Cong Le on 3/20/25.
//

//import SwiftUI
//@preconcurrency import WebKit
//
//struct FacebookWebview: View {
//    var body: some View {
//        WebView(url: URL(string: "https://www.quantamagazine.org")!)
//            .overlay(alignment: .top) {
//                CustomNavigationBar()
//            }
//    }
//}
//
//struct CustomNavigationBar: View {
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        ZStack {
//            Color.orange
//                .opacity(0.8)
//                .ignoresSafeArea(edges: .top)
//
//            HStack {
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Image(systemName: "xmark")
//                        .foregroundColor(.white)
//                        .padding()
//                }
//
//                Spacer()
//
//                VStack(alignment: .center) {
//                    Text("Facebook")
//                        .font(.caption)
//                        .foregroundColor(.white)
//                    Text("arxiv.org")
//                        .font(.caption)
//                        .foregroundColor(.white)
//                }
//                .frame(maxWidth: .infinity) // Ensure the title uses max width
//
//                Spacer()
//
//                Button(action: {
//                    // Handle the "more" action (e.g., present a menu)
//                }) {
//                    Image(systemName: "ellipsis")
//                        .foregroundColor(.white)
//                        .padding()
//                }
//            }
//            .padding(.horizontal)
//
//        }
//        .frame(height: 44) // Standard navigation bar height
//
//    }
//}
//
//
//struct WebView: UIViewRepresentable {
//    let url: URL
//
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.navigationDelegate = context.coordinator // Set the navigation delegate
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        let request = URLRequest(url: url)
//        uiView.load(request)
//    }
//    
//    // MARK: - Coordinator for handling navigation events
//    func makeCoordinator() -> Coordinator {
//          Coordinator(self)
//      }
//
//      class Coordinator: NSObject, WKNavigationDelegate {
//          var parent: WebView
//
//          init(_ parent: WebView) {
//              self.parent = parent
//          }
//
//          // Implement WKNavigationDelegate methods here (optional, for custom behavior)
//          func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//              print("Navigation started")
//          }
//
//          func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//              print("Navigation finished")
//
//              // Inject JavaScript to customize appearance (if needed).
//              // Example: Hide specific elements, change fonts/colors, etc.
//              // Be VERY careful with this to avoid breaking the page layout.
//              let js = """
//              // Example: Hide the header (replace with appropriate selector)
//              // document.querySelector('header').style.display = 'none';
//
//              // Another Example: Change body background color (careful!)
//              // document.body.style.backgroundColor = 'lightgray';
//              """
//              webView.evaluateJavaScript(js, completionHandler: nil)
//          }
//          
//          func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//                  // Custom navigation handling (optional)
//                 
//                 // Allow all navigation
//                 decisionHandler(.allow)
//          }
//
//          func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//              print("Navigation failed: \(error.localizedDescription)")
//              // Handle navigation errors appropriately
//          }
//          
//          func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//                print("Provisional navigation failed: \(error.localizedDescription)")
//                // Handle provisional navigation errors appropriately
//            }
//          
//      }
//}
//
//#Preview {
//    FacebookWebview()
//}

import SwiftUI
@preconcurrency import WebKit
import Combine

struct FacebookWebview: View {
    @StateObject var webViewModel = WebViewModel(url: URL(string: "https://www.quantamagazine.org/the-beautiful-mathematical-explorations-of-maryam-mirzakhani-20170228/")!)

    var body: some View {
        ZStack {
            WebView(viewModel: webViewModel)
                .overlay(alignment: .top) {
                    CustomNavigationBar(viewModel: webViewModel)
                }
                .overlay(alignment: .bottom) {
                    WebViewToolbar(viewModel: webViewModel)
                }
                .alert(item: $webViewModel.alertItem) { alertItem in
                    if let alert = alertItem.alert {
                        alert  // Use pre-built alert if available
                    } else {
                        Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
                    }
                }
                .sheet(isPresented: $webViewModel.isFindInPageActive) { // Sheet for Find in Page
                    FindInPageView(viewModel: webViewModel)
                }
        }
        .environmentObject(webViewModel)
    }
}

struct CustomNavigationBar: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: WebViewModel

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.8)
                .ignoresSafeArea(edges: .top)

            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding()
                }

                Spacer()

                VStack(alignment: .center) {
                    Text(viewModel.title ?? "Loading...")
                        .font(.caption)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(viewModel.url?.host() ?? "")
                        .font(.caption)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)

                Spacer()

                Menu {
                    Button(action: { viewModel.reload() }) {
                        Label("Reload", systemImage: "arrow.clockwise")
                    }
                    Button(action: { viewModel.takeSnapshot() }) {
                         Label("Take Snapshot", systemImage: "camera")
                     }
                    if let image = viewModel.snapshotImage {
                        ShareLink(item: Image(uiImage: image), preview: SharePreview("Snapshot", image: Image(uiImage: image)))
                    }

                    Divider()

                    Button(action: { viewModel.findInPage() }) {
                        Label("Find in Page", systemImage: "magnifyingglass")
                    }

                    Divider()

                    Button(action: { viewModel.openInSafari() }) {
                        Label("Open in Safari", systemImage: "safari")
                    }
                    
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                        .padding()
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 44)
    }
}

struct WebViewToolbar: View {
    @ObservedObject var viewModel: WebViewModel
    @State private var isSharing = false

    var body: some View {
        if viewModel.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .padding()
                .background(Color.black.opacity(0.7))
        } else {
            HStack {
                Button(action: { viewModel.goBack() }) {
                    Image(systemName: "chevron.left")
                }
                .disabled(!viewModel.canGoBack)

                Spacer()

                Button(action: { viewModel.goForward() }) {
                    Image(systemName: "chevron.right")
                }
                .disabled(!viewModel.canGoForward)
                
                Spacer()
                
                if let url = viewModel.url {
                    ShareLink(item: url, preview: SharePreview(viewModel.title ?? "Webpage", image: Image(systemName: "globe")))
                }
                
                Spacer()
                
                Button(action: { viewModel.reload() }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .padding()
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
        }
    }
}

struct WebView: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        viewModel.webView = webView
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let request = viewModel.navigationRequest {
            uiView.load(request)
            viewModel.navigationRequest = nil
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var viewModel: WebViewModel

        init(_ viewModel: WebViewModel) {
            self.viewModel = viewModel
        }

        // MARK: - WKNavigationDelegate

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            viewModel.isLoading = true
            viewModel.canGoBack = webView.canGoBack
            viewModel.canGoForward = webView.canGoForward
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
           viewModel.isLoading = false
           viewModel.url = webView.url
           viewModel.title = webView.title
           viewModel.canGoBack = webView.canGoBack
           viewModel.canGoForward = webView.canGoForward

           let js = """
           // Example: Hide the header (replace with appropriate selector)
           // document.querySelector('header').style.display = 'none';
           """
           webView.evaluateJavaScript(js, completionHandler: nil)
       }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
             handleError(error, webView: webView)
         }

         func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
             handleError(error, webView: webView)
         }

        private func handleError(_ error: Error, webView: WKWebView) {
            viewModel.isLoading = false
            viewModel.canGoBack = webView.canGoBack
            viewModel.canGoForward = webView.canGoForward

             let nsError = error as NSError
             var errorMessage = "An error occurred: \(error.localizedDescription)"
             if nsError.domain == NSURLErrorDomain {
                 switch nsError.code {
                 case NSURLErrorNotConnectedToInternet:
                     errorMessage = "No Internet Connection. Please check your network settings."
                 case NSURLErrorTimedOut:
                     errorMessage = "The request timed out. Please try again later."
                 case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                     errorMessage = "Could not connect to the server.  Please check the URL."
                 default:
                     break
                 }
             }
            viewModel.alertItem = AlertItem(title: Text("Error"), message: Text(errorMessage))
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url, !url.host!.contains("quantamagazine.org") {
                 UIApplication.shared.open(url)
                 decisionHandler(.cancel)
             } else {
                 decisionHandler(.allow)
             }
         }

        // MARK: - WKUIDelegate

        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            viewModel.alertItem = AlertItem(title: Text("Alert"), message: Text(message), dismissButton: .default(Text("OK"), action: completionHandler))
        }

        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
             let alert = Alert(
                 title: Text("Confirm"),
                 message: Text(message),
                 primaryButton: .default(Text("OK"), action: { completionHandler(true) }),
                 secondaryButton: .cancel(Text("Cancel"), action: { completionHandler(false) })
             )
             viewModel.alertItem = AlertItem(alert: alert)
         }

        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            let alertController = UIAlertController(title: prompt, message: nil, preferredStyle: .alert)

            alertController.addTextField { textField in
                textField.text = defaultText
            }

            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(alertController.textFields?.first?.text)
            }
            alertController.addAction(okAction)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(nil)
            }
            alertController.addAction(cancelAction)

            if var topController = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(alertController, animated: true, completion: nil)
            }
        }

        // MARK: - WKFindDelegate
        @available(iOS 16.0, *)
        func find(_ webView: WKWebView, hasNextResult result: Bool, completionHandler: @escaping (Bool) -> Void) {
              completionHandler(result)
          }
        
        @available(iOS 16.0, *)
        func webView(_ webView: WKWebView, didFinishFindingInPage totalMatches: Int) {
             print("Total matches found: \(totalMatches)")
             viewModel.totalMatches = totalMatches
             if totalMatches == 0 {
                 viewModel.alertItem = AlertItem(title: Text("Not Found"), message: Text("No matches found for \"\(viewModel.searchText)\"."))
             }
         }
    }
}

// MARK: - ViewModel

class WebViewModel: ObservableObject {
    @Published var url: URL?
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var title: String?
    @Published var alertItem: AlertItem?
    @Published var navigationRequest: URLRequest?
    @Published var snapshotImage: UIImage?
    @Published var isFindInPageActive = false
    @Published var searchText: String = ""
    @Published var totalMatches: Int = 0

    weak var webView: WKWebView?

    private var cancellables: Set<AnyCancellable> = []

    init(url: URL) {
        self.url = url
        self.navigationRequest = URLRequest(url: url)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func reload() {
        webView?.reload()
    }
    
    func takeSnapshot() {
        guard let webView = webView else { return }

        let configuration = WKSnapshotConfiguration()

        webView.takeSnapshot(with: configuration) { [weak self] image, error in
            guard let self = self else { return }
            if let image = image {
                self.snapshotImage = image
            } else if let error = error {
               self.alertItem = AlertItem(title: Text("Snapshot Error"), message: Text(error.localizedDescription))
            }
        }
    }

    func openInSafari() {
        if let url = url {
            UIApplication.shared.open(url)
        }
    }
    
    func findInPage() {
          isFindInPageActive = true
      }

    @available(iOS 16.0, *)
      func findNext() {
           guard let webView = webView, !searchText.isEmpty else { return }
          webView.find(searchText, configuration: .init) { [weak self] result in
               guard let self = self else { return }
               print("Find result: \(result)")  // Debugging
               if !result.found {
                    // No (more) matches.  Could update UI to indicate this.
                   self.alertItem = AlertItem(title: Text("Not Found"), message: Text("No more matches found."))
               }
           }
       }

    @available(iOS 16.0, *)
       func findPrevious() {
           guard let webView = webView, !searchText.isEmpty else { return }
            // Note: .backwards is a valid option.
           let options: WKFindConfiguration.Options = [.caseInsensitive, .wrap, .backwards]
           webView.find(searchText, configuration: .init(options: options)) { [weak self] result in
               guard let self = self else { return }
               print("Find result: \(result)")  // Debugging
               if !result.found {
                    // No (more) matches.  Could update UI to indicate this.
                    self.alertItem = AlertItem(title: Text("Not Found"), message: Text("No previous matches found."))
               }
           }
       }

       func stopFindingInPage() {
           webView?.stopFindInPage() // Clears highlights.
           isFindInPageActive = false
           searchText = "" // Clear search
           totalMatches = 0 // Reset match count
       }
}

// MARK: - AlertItem

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text?
    let dismissButton: Alert.Button?
    var alert: Alert?

    init(title: Text, message: Text? = nil, dismissButton: Alert.Button? = nil) {
        self.title = title
        self.message = message
        self.dismissButton = dismissButton
    }

    init(alert: Alert) {
      self.alert = alert
      self.title = Text("")
      self.message = nil
      self.dismissButton = nil
    }
}

// MARK: - FindInPageView (Separate View for Find in Page)
@available(iOS 16.0, *)
struct FindInPageView: View {
    @ObservedObject var viewModel: WebViewModel
    @Environment(\.dismiss) private var dismiss // For dismissing the sheet

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .disableAutocorrection(true)
                    .onSubmit { // Trigger search on submit (Return key)
                        viewModel.findNext()
                    }

                HStack {
                    Button(action: {
                        viewModel.findPrevious()
                    }) {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(viewModel.searchText.isEmpty)

                    Button(action: {
                        viewModel.findNext()
                    }) {
                        Image(systemName: "chevron.down")
                    }
                    .disabled(viewModel.searchText.isEmpty)
                    
                    Text("\(viewModel.totalMatches) matches") // Show match count
                        .font(.caption)
                        .foregroundColor(.gray)


                    Button(action: {
                        viewModel.stopFindingInPage()
                        dismiss() // Dismiss on close
                    }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
                .padding()
            }
            .navigationBarTitle("Find in Page", displayMode: .inline) // Title
            .navigationBarItems(trailing: Button("Done") { dismiss() }) // Done button
        }
    }
}

#Preview {
    FacebookWebview()
}
