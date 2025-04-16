//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit

// Step 1a: UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyUIKitViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> MyUIKitViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return MyUIKitViewController()
    }
    
    func updateUIViewController(_ uiViewController: MyUIKitViewController, context: Context) {
        // Update the view controller if needed
    }
}

// Example UIKit view controller
class MyUIKitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        // Additional setup
        
        // Official Test Case Check again:
        print(getMinimumSecondsRequired(5, [2,5,3,6,5], 1, 1))  // Expected: 5
        print(getMinimumSecondsRequired(3, [100,100,100], 2, 3))// Expected: 5
        print(getMinimumSecondsRequired(3, [100,100,100], 7, 3))// Expected: 9
        print(getMinimumSecondsRequired(4, [6,5,4,3], 10, 1))   // Expected: 19
        print(getMinimumSecondsRequired(4, [100,100,1,1], 2,1)) // Expected: 207
        print(getMinimumSecondsRequired(6,[6,5,2,4,4,7],1,1))   // Expected: 10
   
    }
}

// Step 2: Use in SwiftUI view
struct ContentView: View {
    var body: some View {
        UIKitViewControllerWrapper()
            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
    }
}

// Before iOS 17, use this syntax for preview UIKit view controller
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper()
    }
}
