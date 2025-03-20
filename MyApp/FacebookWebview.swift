//
//  FacebookWebview.swift
//  MyApp
//
//  Created by Cong Le on 3/20/25.
//

import SwiftUI
@preconcurrency import WebKit

struct FacebookWebview: View {
    var body: some View {
        WebView(url: URL(string: "https://www.quantamagazine.org")!)
            .overlay(alignment: .top) {
                CustomNavigationBar()
            }
    }
}

struct CustomNavigationBar: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.orange
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
                    Text("Facebook")
                        .font(.caption)
                        .foregroundColor(.white)
                    Text("arxiv.org")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity) // Ensure the title uses max width

                Spacer()

                Button(action: {
                    // Handle the "more" action (e.g., present a menu)
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                        .padding()
                }
            }
            .padding(.horizontal)

        }
        .frame(height: 44) // Standard navigation bar height

    }
}


struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator // Set the navigation delegate
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    // MARK: - Coordinator for handling navigation events
    func makeCoordinator() -> Coordinator {
          Coordinator(self)
      }

      class Coordinator: NSObject, WKNavigationDelegate {
          var parent: WebView

          init(_ parent: WebView) {
              self.parent = parent
          }

          // Implement WKNavigationDelegate methods here (optional, for custom behavior)
          func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
              print("Navigation started")
          }

          func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
              print("Navigation finished")

              // Inject JavaScript to customize appearance (if needed).
              // Example: Hide specific elements, change fonts/colors, etc.
              // Be VERY careful with this to avoid breaking the page layout.
              let js = """
              // Example: Hide the header (replace with appropriate selector)
              // document.querySelector('header').style.display = 'none';

              // Another Example: Change body background color (careful!)
              // document.body.style.backgroundColor = 'lightgray';
              """
              webView.evaluateJavaScript(js, completionHandler: nil)
          }
          
          func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
                  // Custom navigation handling (optional)
                 
                 // Allow all navigation
                 decisionHandler(.allow)
          }

          func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
              print("Navigation failed: \(error.localizedDescription)")
              // Handle navigation errors appropriately
          }
          
          func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
                print("Provisional navigation failed: \(error.localizedDescription)")
                // Handle provisional navigation errors appropriately
            }
          
      }
}

#Preview {
    FacebookWebview()
}
