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
        
        //runInitializerInjectionDemo()
        //runPropertyInjectionDemo()
        runMethodInjectionDemo()
    }
    
    func runInitializerInjectionDemo() {
        
        // Usage: Injecting the dependency
        let realService = NetworkService()
        let viewModel = DataViewModel(networkFetcher: realService)
        viewModel.loadData()
        
        // For Testing: Injecting a mock
        class MockNetworkFetcher: NetworkFetching {
            func fetchData() -> Data? {
                print("Returning mock data...")
                return Data("Mock".utf8)
            }
        }
        let mockService = MockNetworkFetcher()
        let testViewModel = DataViewModel(networkFetcher: mockService)
        testViewModel.loadData()
        
    }
    
    func runPropertyInjectionDemo() {
        
        // Usage: Injecting after initialization
        let viewModel = AnotherViewModel()
        // Potential issue: viewModel is usable here, but `loadData` would fail
        viewModel.networkFetcher = NetworkService() // Injection via property
        viewModel.loadData()
    }
    
    func runMethodInjectionDemo() {
      
        // Usage
        let generator = ReportGenerator()
        let reportData = Data("Report Content".utf8)

        let standardFormatter = StandardFormatter()
        let standardReport = generator.generateReport(data: reportData, formatter: standardFormatter) // Inject StandardFormatter
        print("Injected standardReport: \(standardReport)")

        let fancyFormatter = FancyFormatter()
        let fancyReport = generator.generateReport(data: reportData, formatter: fancyFormatter) // Inject FancyFormatter
        print("Injected fancyReport: \(fancyReport)")

    }
}
