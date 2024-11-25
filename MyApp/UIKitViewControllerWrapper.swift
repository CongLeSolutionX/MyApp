//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit

// UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyUIKitViewController
    
    // Required methods implementation
    func makeUIViewController(context: Context) -> MyUIKitViewController {
        // Instantiate and return the UIKit view controller
        return MyUIKitViewController()
    }
    
    func updateUIViewController(_ uiViewController: MyUIKitViewController, context: Context) {
        // Update the view controller if needed
    }
}

class MyUIKitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        // Create a SwiftUI view
        let settingsView = SettingsView()
        
        // Create a UIHostingController to host the SwiftUI view
        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false // Essential for constraints
        
        // Add the hosting controller's view as a subview
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Set constraints (crucial for proper layout)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            hostingController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            hostingController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            hostingController.view.heightAnchor.constraint(equalToConstant: 200) //Adjust height as needed
        ])
        
        hostingController.didMove(toParent: self)
    }
}

struct SettingsView: View {
    @State private var notificationsEnabled: Bool = true // State variable for Toggle
    @State private var sliderValue: Double = 50        // State variable for Slider
    
    var body: some View {
        VStack {
            Text("Settings Panel - SwiftUI view")
                .font(.title)
            Toggle("Enable Notifications", isOn: $notificationsEnabled) // bind to state variable
            Slider(value: $sliderValue, in: 0...100) // bind to state variable
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}
