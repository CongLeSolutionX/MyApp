//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

// Use in SwiftUI view
struct ContentView: View { // The app will load view from this entry point
    var body: some View {
        UIKitViewControllerWrapper_NativeUIKitViewController()
            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
    }
}

// MARK: - Using PreviewProvider to preview views - connecting UIKit views
/// The name of the view when loaded on the canvas screen is determined
/// by the name of the struct that conforms to the `PreviewProvider` protocol,
/// excluding any reserved system keywords and
/// removing the `_Previews` suffix from the struct's name.

// Before iOS 17, use this syntax for preview UIKit view controller
struct GenericUIKitView_Previews: PreviewProvider { // The previews on canvas will load from this entry point
    static var previews: some View {
        UIKitViewControllerWrapper_GeneralUIKitViewController()
    }
}

struct NativeUIKitView_Previews: PreviewProvider { // The previews on canvas will load from this entry point
    static var previews: some View {
        UIKitViewControllerWrapper_NativeUIKitViewController()
    }
}

struct ContentLoaderWithActivityIndicatorView_Previews: PreviewProvider { // The previews on canvas will load from this entry point
    static var previews: some View {
        UIKitViewControllerWrapper_ContentLoaderWithActivityIndicatorViewController()
    }
}

struct AttributedTextView_Previews: PreviewProvider { // The previews on canvas will load from this entry point
    static var previews: some View {
        UIKitViewControllerWrapper_AttributedTextViewController()
    }
}

struct ContenLoaderView_Previews: PreviewProvider { // The previews on canvas will load from this entry point
    static var previews: some View {
        UIKitViewControllerWrapper_ContentLoaderViewController()
    }
}

struct AudioVideoPlayerView_Previews: PreviewProvider { // The previews on canvas will load from this entry point
    static var previews: some View {
        UIKitViewControllerWrapper_AudioVideoPlayerViewController()
    }
}


struct WKWebView_Previews: PreviewProvider { // The previews on canvas will load from this entry point
    static var previews: some View {
        UIKitViewControllerWrapper_WKWebViewController()
    }
}

struct SafariView_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper_SFViewController()
    }
}

struct RichTextView_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper_RichTextViewController()
    }
}

// MARK: - Using macros to preview views - connecting SwiftUI views
// After iOS 17, we can use this syntax for preview
#Preview {
    ContentView()
}
