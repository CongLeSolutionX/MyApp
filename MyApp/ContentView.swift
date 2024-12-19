//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
// Use in SwiftUI view
struct iOS_SwiftUI_RootContentView: View {  /// presenting this view to the App level of a SwiftUI-based project
    var body: some View {
        iOS_UIKit_ViewControllerWrapper()
            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
    }
}

// MARK: - Previews
// Before iOS 17, use this syntax for preview UIKit view controller
struct iOSUIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
            iOS_UIKit_MetalLightingView()
            iOS_UIKit_Metal3DView()
            iOS_UIKit_Metal2DView()
            iOS_SwiftUI_RootContentView()
            iOS_UIKit_ViewControllerWrapper() // preview the view through a wrapper controller view
            iOS_UIKit_MetalPlainView() // directly preview the view through protocol `UIViewRepresentable`
    }
}

// After iOS 17, we can use this syntax for preview:
#Preview("iOS SwiftUI RootContentView") {
    iOS_SwiftUI_RootContentView()
}

#elseif os(macOS)
struct NSMetalViewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        NSMetalView()
    }
}

#Preview("NSMetalView") {
    NSMetalView()
}
#endif
