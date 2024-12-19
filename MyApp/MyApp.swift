//
//  MyApp.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

#if os(iOS)
import UIKit
typealias MyViewController = UIViewController
#elseif os(macOS)
import AppKit
typealias MyViewController = NSViewController
#endif


class SharedLogic {  // Located in the 'Shared' directory
    func platformSpecificOperation() {
#if os(iOS)
        // iOS-specific implementation (e.g., UIKit calls)
#elseif os(macOS)
        // macOS-specific implementation (e.g., AppKit calls)
#endif
    }
}

@main
struct MyAppApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            // iOS-specific implementation (e.g., UIKit calls)
            
            // Display 3 iOS views from 3 different sources on the same screen
            iOS_SwiftUI_RootContentView()
            iOS_UIKit_MetalPlainView()
            iOS_UIKit_ViewControllerWrapper()
            iOS_UIKit_Metal2DView()
            #elseif os(macOS)
            // macOS-specific implementation (e.g., AppKit calls)
            NSMetalView()
            #endif
        }
    }
}
