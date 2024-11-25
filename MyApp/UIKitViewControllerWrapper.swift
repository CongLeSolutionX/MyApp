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
    typealias UIViewControllerType = SettingsPanelViewController
    
    // Required methods implementation
    func makeUIViewController(context: Context) -> SettingsPanelViewController {
        // Instantiate and return the UIKit view controller
        return SettingsPanelViewController()
    }
    
    func updateUIViewController(_ uiViewController: SettingsPanelViewController, context: Context) {
        // Update the view controller if needed
    }
}

/// A `UIKit view controller` that embeds a `SwiftUI settings panel`.
/// This demonstrates a niche use case for `UIHostingController`,
/// primarily for embedding relatively small `SwiftUI` views within a larger `UIKit` context.
/// For larger integrations, `UIViewControllerRepresentable` is generally preferred.
class SettingsPanelViewController: UIViewController {
    /// `viewDidLoad()` is overridden to setup and embed the `SwiftUI settings view`.
    /// It uses `Auto Layout constraints` to precisely place and size the embedded `SwiftUI view`
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        // Create a SwiftUI view
        let settingsView = SettingsView()
        
        // Create a UIHostingController to host the SwiftUI view. This acts as a bridge between UIKit and SwiftUI.
        let hostingController = UIHostingController(rootView: settingsView)
        /// This line is crucial.  Without it, Auto Layout constraints won't work correctly, leading to layout issues.
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the hostingController's view as a subview of the main view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        /// Set up `Auto Layout constraints` to position the `SwiftUI view` within the `UIKit view controller`.
        /// Adjust constants to customize the position and dimensions of the settings panel.
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            hostingController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            hostingController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            hostingController.view.heightAnchor.constraint(equalToConstant: 200) //Adjust height as needed
        ])
        
        hostingController.didMove(toParent: self)
    }
}
/// A` SwiftUI view` representing a simple settings panel.
/// This view is embedded within a `UIKit view controller` using `UIHostingController`
struct SettingsView: View {
    @State private var notificationsEnabled: Bool = true // State variable for Toggle
    @State private var sliderValue: Double = 50        // State variable for Slider
    /// The body of the SettingsView, defining its layout and content
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
