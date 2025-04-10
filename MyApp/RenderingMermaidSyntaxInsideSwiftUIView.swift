//
//  RenderingMermaidSyntaxInsideSwiftUIView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
import WebKit // Essential for WKWebView

// MARK: - Mermaid WebView (UIViewRepresentable Wrapper)

struct MermaidWebView: UIViewRepresentable {

    // The Mermaid syntax string to render
    let mermaidString: String

    // Coordinator class to handle potential WKNavigationDelegate callbacks if needed later
    // For this basic example, it's not strictly necessary but good practice.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: MermaidWebView

        init(_ parent: MermaidWebView) {
            self.parent = parent
        }

        // Example delegate method (optional): Called when navigation finishes
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Mermaid WebView finished loading.")
            // You could potentially inject more JS or check status here
        }

        // Example delegate method (optional): Called when content starts loading
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
             print("Mermaid WebView committed navigation.")
        }

        // Example delegate method (optional): Called on failure
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Mermaid WebView failed navigation: \(error.localizedDescription)")
        }
         func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
             print("Mermaid WebView failed provisional navigation: \(error.localizedDescription)")
         }
    }

    // Creates the underlying WKWebView
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator // Set the coordinator
        webView.scrollView.isScrollEnabled = true // Allow scrolling for larger diagrams
        // Optional: Disable zoom if desired
         webView.scrollView.minimumZoomScale = 1.0
         webView.scrollView.maximumZoomScale = 1.0
        // Optional: Make the webview background transparent if you want SwiftUI background to show through
         webView.isOpaque = false
        // webView.backgroundColor = UIColor.clear
        // webView.scrollView.backgroundColor = UIColor.clear
        return webView
    }

    // Updates the WKWebView when the mermaidString changes
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 1. Get the latest Mermaid string
        let content = mermaidString.trimmingCharacters(in: .whitespacesAndNewlines)

        // 2. Construct the HTML content
        //    - Uses a CDN for Mermaid.js (ensure network access)
        //    - Includes basic viewport meta tag for scaling
        //    - Places the Mermaid syntax string inside a <pre class="mermaid"> tag
        //    - Initializes Mermaid after the content is loaded
        let htmlContent = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Mermaid Render</title>
            <style>
                /* Basic styling */
                body {
                    margin: 15px; /* Add some padding around the diagram */
                    display: flex;
                    justify-content: center; /* Center diagram horizontally */
                    align-items: flex-start; /* Align diagram to top */
                    min-height: 95vh; /* Ensure body takes height for alignment */
                    background-color: #FFFFFF; /* Or use #clear if you made WKWebView transparent */
                 }
                .mermaid {
                     text-align: center; /* Ensure diagram itself is centered if it has a width */
                     max-width: 100%; /* Prevent overflow */
                 }
                /* Optional: Dark mode support via CSS media query */
                 @media (prefers-color-scheme: dark) {
                     body {
                         background-color: #1C1C1E; /* Dark background */
                     }
                 }
            </style>
        </head>
        <body>
            <!-- The Mermaid syntax goes inside this pre tag -->
            <pre class="mermaid">
        \(content)
            </pre>

            <!-- Load Mermaid library from CDN -->
            <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>

            <!-- Initialize Mermaid -->
            <script>
                try {
                  // Initialize Mermaid, automatically finding elements with class="mermaid"
                  // Optional: Configure themes, etc. here if needed, e.g., theme: 'dark'
                  mermaid.initialize({ startOnLoad: true });
                  console.log('Mermaid initialized successfully.');
                } catch (e) {
                  console.error('Error initializing Mermaid:', e);
                  // Optionally display an error message in the WebView
                  document.body.innerHTML = '<p style="color: red; font-family: sans-serif;">Error rendering Mermaid diagram: ' + e.message + '</p>';
                }
            </script>
        </body>
        </html>
        """

        // 3. Load the HTML string into the WKWebView
        //    baseURL: nil prevents access to local files for security
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

// MARK: - Content View (Example Usage)

struct RenderingMermaidInSwiftUIView: View {
    // State variable to hold the Mermaid syntax, initialized with a sample diagram
//    @State private var mermaidInput: String = """
//    graph TD
//        A[Start] --> B{Is it Friday?};
//        B -- Yes --> C[Celebrate!];
//        B -- No --> D[Work harder];
//        C --> E[Weekend!];
//        D --> E;
//        E --> F[End];
//
//    %% Example comment
//    %%{init: {'theme': 'default', 'logLevel': 1}}%%
//    """ // Default diagram

    @State private var mermaidInput: String = """
    ---
    title: "CHANGE_ME_DADDY"
    config:
      theme: base
    ---
    %%%%%%%% Mermaid version v11.4.1-b.14
    %%%%%%%% Available curve styles include the following keywords:
    %% basis, bumpX, bumpY, cardinal, catmullRom, linear, monotoneX, monotoneY, natural, step, stepAfter, stepBefore.
    %%{
      init: {
        'sequenceDiagram': { 'htmlLabels': false},
        'fontFamily': 'Monospace',
        'themeVariables': {
          'primaryColor': '#B28',
          'primaryTextColor': '#F8B229',
          'primaryBorderColor': '#7C33',
          'secondaryColor': '#0615'
        }
      }
    }%%
    sequenceDiagram
        autonumber

        participant View as View<br/>(e.g., LiveAPIView)

        box rgb(202, 12, 22, 0.1) Th App System
            participant Fetcher as USCISCaseStatusFetcher
            participant URLSession
            participant AuthAPI as USCIS Auth API
            participant CaseAPI as USCIS Case Status API
        end

        View->>Fetcher: fetchCaseStatus(receipt, mock: .none, completion)
        Fetcher->>Fetcher: getAccessToken()
        Fetcher->>URLSession: dataTask(authRequest POST)
        URLSession->>AuthAPI: POST /oauth/accesstoken<br/>(credentials)
        activate AuthAPI
        AuthAPI-->>URLSession: HTTP 200 OK + Token JSON
        deactivate AuthAPI
        activate URLSession
        URLSession-->>Fetcher: completion(data, response, error)
        deactivate URLSession

        alt Access Token Success
            rect rgb(100, 100, 255, 0.1)
                Fetcher->>Fetcher: performFetch(accessToken, receipt)
                Fetcher->>URLSession: dataTask(apiRequest GET)
                
                activate URLSession
                
                URLSession->>CaseAPI: GET /case-status/{receipt}<br/>(Auth Header)
                
                activate CaseAPI
                
                CaseAPI-->>URLSession: HTTP Response<br/>(200/4xx/5xx) + Data
                
                deactivate CaseAPI
                
                URLSession-->>Fetcher: completion(data, response, error)
                
                deactivate URLSession
                
                Fetcher->>Fetcher: Handle HTTP Status & Decode
                
                alt Status 200 OK & Decode Success
                    rect rgb(200, 225, 0, 0.5)
                        Fetcher-->>View: completion(.success(CaseStatus))
                    end
                else Status 4xx/5xx or Decode Error
                    rect rgb(200, 225, 0, 0.7)
                        Fetcher-->>View: completion(.failure(APIError))
                    end
                end
            end
        else Access Token Failure
            rect rgb(100, 100, 255, 0.2)
                Fetcher-->>View: completion(.failure(APIError))
            end
        end
        View->>View: Update UI<br/>(Display Status or Error)
        
    """ // Default diagram

    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) { // Use spacing 0 for seamless look if desired
                // TextEditor for inputting Mermaid syntax
                TextEditor(text: $mermaidInput)
                    .font(.system(.body, design: .monospaced)) // Monospaced font is good for code
                    .frame(height: 200) // Give the editor a fixed height
                    .border(Color.gray.opacity(0.5), width: 1) // Optional border
                    .padding([.horizontal, .top]) // Add padding around editor

                Divider().padding(.horizontal)

                // MermaidWebView to display the rendered diagram
                MermaidWebView(mermaidString: mermaidInput)
                    // The WebView will take the remaining space
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // Optional: Clip if needed, or add padding
                    // .padding()
            }
            .navigationTitle("Mermaid Renderer")
            .navigationBarTitleDisplayMode(.inline)
            // Hide keyboard when tapping outside TextEditor
            .onTapGesture {
                hideKeyboard()
            }
        }
         // Use stack style for consistent behavior across devices
        .navigationViewStyle(.stack)
    }
}

// MARK: - Keyboard Helper

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

// MARK: - Preview Provider

struct RenderingMermaidInSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        RenderingMermaidInSwiftUIView()
    }
}

// MARK: - App Entry Point (Required if this is the main app file)
/*
@main
struct MermaidApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
