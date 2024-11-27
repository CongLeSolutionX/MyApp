//
//  EnhancedUIViewControllerRepresentablePattern.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import SwiftUI
import UIKit

// 1. Define the UIKit View Controller
class MyEnhancedUIKitViewController: UIViewController {
    var data: String? {
        didSet {
            updateUI()
        }
    }

    var eventHandler: ((String) -> Void)?

    private let label = UILabel()
    private let button = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        view.addSubview(label)

        button.setTitle("Tap Me", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(button)

        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20)
        ])

        updateUI()
    }

    private func updateUI() {
        label.text = data ?? "No Data"

        // Update the interface based on the current trait collection (e.g., dark mode)
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
            label.textColor = .white
            button.tintColor = .white
        } else {
            view.backgroundColor = .white
            label.textColor = .black
            button.tintColor = .systemBlue
        }

        // Handle Dynamic Type
        label.font = UIFont.preferredFont(forTextStyle: .headline)
    }

    @objc private func buttonTapped() {
        eventHandler?("Button Tapped from UIKit")
    }
    
    //Trait collection changes
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //TODO: Update to new API
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateUI()
        }
    }
}

// 2. Create a Coordinator
class EnhancedUIKitViewControllerCoordinator: NSObject {
    var parent: EnhancedUIKitViewControllerWrapper

    init(_ parent: EnhancedUIKitViewControllerWrapper) {
        self.parent = parent
    }

    @objc func buttonTapped() {
        parent.onButtonTap("Button Tapped from Coordinator")
    }
}

// 3. Implement UIViewControllerRepresentable
struct EnhancedUIKitViewControllerWrapper: UIViewControllerRepresentable {
    var data: String
    var onButtonTap: (String) -> Void

    func makeUIViewController(context: Context) -> MyEnhancedUIKitViewController {
        let viewController = MyEnhancedUIKitViewController()
        viewController.data = data
        viewController.eventHandler = { event in
            onButtonTap(event)
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: MyEnhancedUIKitViewController, context: Context) {
        uiViewController.data = data
    }

    func makeCoordinator() -> EnhancedUIKitViewControllerCoordinator {
        EnhancedUIKitViewControllerCoordinator(self)
    }
}

// 4. Usage in SwiftUI
struct DemoEnhancedContentView: View {
    @State private var text: String = "Initial Text"
    @State private var eventMessage: String = ""

    var body: some View {
        VStack {
            Text("Event Message: \(eventMessage)")
                .padding()
            TextField("Enter Text", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            EnhancedUIKitViewControllerWrapper(data: text) { message in
                eventMessage = message
            }
            .frame(height: 300)
           
        }
        .padding()
    }
}

// 5. Preview
struct DemoEnhancedUIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        DemoEnhancedContentView()
    }
}
