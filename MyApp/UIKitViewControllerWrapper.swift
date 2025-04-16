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
        
        let expectedReturnValue_1 = getMaxVisitableWebpages(4, 4, [1,2,3,4], [4,1,2,1])
        let expectedReturnValue_2 = getMaxVisitableWebpages(5, 6, [3,5,3,1,3,2], [2,1,2,4,5,4])
        let expectedReturnValue_3 = getMaxVisitableWebpages(10, 9, [3, 2, 5, 9, 10, 3, 3, 9, 4], [9, 5, 7, 8, 6, 4, 5, 3, 9])
            
            
        print("\(expectedReturnValue_1)")
        print("\(expectedReturnValue_2)")
        print("\(expectedReturnValue_3)")
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
