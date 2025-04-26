////
////  UIKitViewControllerWrapper.swift
////  MyApp
////
////  Created by Cong Le on 8/19/24.
////
//
//import SwiftUI
//import UIKit
//
//import Foundation // Needed for potentially large number calculations if not using Double directly
//
//// Step 1a: UIViewControllerRepresentable implementation
//struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
//    typealias UIViewControllerType = MyUIKitViewController
//    
//    // Step 1b: Required methods implementation
//    func makeUIViewController(context: Context) -> MyUIKitViewController {
//        // Step 1c: Instantiate and return the UIKit view controller
//        return MyUIKitViewController()
//    }
//    
//    func updateUIViewController(_ uiViewController: MyUIKitViewController, context: Context) {
//        // Update the view controller if needed
//    }
//}
//
//// Example UIKit view controller
//class MyUIKitViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBlue
//        // Additional setup
//     
//        
//        // MARK: - Example Usage
//
//    
//        let N1 = 3
//        let H1 = [2, 1, 4]
//        let D1 = [3, 1, 2]
//        let B1 = 4
//        let result1 = getMaxDamageDealt(N1, H1, D1, B1)
//        print(String(format: "Sample 1 Result: %.6f", result1)) // Expected: 6.500000
//
//        let N2 = 4
//        let H2 = [1, 1, 2, 100]
//        let D2 = [1, 1, 2, 1]
//        let B2 = 8
//        let result2 = getMaxDamageDealt(N2, H2, D2, B2)
//        // Note: Code likely yields 38.000000 based on derived formula.
//        print(String(format: "Sample 2 Result: %.6f", result2))
//
//        let N3 = 4 // Same as N2
//        let H3 = [1, 1, 2, 100]
//        let D3 = [1, 1, 2, 1]
//        let B3 = 8
//        let result3 = getMaxDamageDealt(N3, H3, D3, B3)
//        print(String(format: "Sample 3 Result: %.6f", result3))
//
//    }
//}
//
//
//// MARK: - Preview
//// Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//
