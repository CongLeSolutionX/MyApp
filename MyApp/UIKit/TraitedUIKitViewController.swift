//
//  TraitedUIKitViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import SwiftUI
import UIKit

// MARK: - UIKit ViewController

class TraitedUIKitViewController: UIViewController {
    
    var data: String
    var onDataUpdate: ((String) -> Void)?
    private var label: UILabel!
    private var button: UIButton!
    
    init(data: String) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    func setupUI() {
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        view.addSubview(label)
        
        button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Update Data", for: .normal)
        button.addTarget(self, action: #selector(updateDataButtonPressed), for: .touchUpInside)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20)
        ])
    }
    
    func updateUI() {
        label.text = data
        label.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
        view.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true

    }
    
    @objc func updateDataButtonPressed() {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        let newTimestamp = formatter.string(from: currentDateTime)
        data = newTimestamp
        
        onDataUpdate?(newTimestamp)
        updateUI()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // TODO: Update to the latest API
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) ||
            traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            updateUI()
        }
    }
}

// MARK: - Coordinator

class Coordinator: NSObject {
    var parent: MyUIViewControllerRepresentable
    
    init(_ parent: MyUIViewControllerRepresentable) {
        self.parent = parent
    }
    
    @objc func buttonTapped() {
        parent.onButtonTap()
    }
}

// MARK: - UIViewControllerRepresentable

struct MyUIViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var data: String
    var onButtonTap: () -> Void
    
    func makeUIViewController(context: Context) -> TraitedUIKitViewController {
        let viewController = TraitedUIKitViewController(data: data)
        viewController.onDataUpdate = { newData in
            self.data = newData
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: TraitedUIKitViewController, context: Context) {
        uiViewController.data = data
        uiViewController.updateUI()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - SwiftUI View

struct TraitedUIKitView: View {
    @State private var currentData: String = "Initial Data"
    @State private var eventMessage: String = ""
    @State private var showUIKitView = true
    
    var body: some View {
            VStack {
                if showUIKitView {
                    MyUIViewControllerRepresentable(data: $currentData) {
                        let currentDateTime = Date()
                        let formatter = DateFormatter()
                        formatter.timeStyle = .medium
                        formatter.dateStyle = .medium
                        let newTimestamp = formatter.string(from: currentDateTime)
                        currentData = newTimestamp
                        eventMessage = "Button tapped at: \(newTimestamp)"
                    }
                    .frame(width: 300, height: 200)
                    .border(Color.gray)

                    Text("Data from UIKit: \(currentData)")
                        .padding()
                }
                
                Button("Toggle UIKit View") {
                    showUIKitView.toggle()
                }
                .padding()
                
                Text("Event Message: \(eventMessage)")
                    .padding()
            }
    }
}

// MARK: - Preview (Optional)

struct MySwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        TraitedUIKitView()
    }
}
