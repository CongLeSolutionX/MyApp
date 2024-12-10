//
//  YOLOSettingsViewController.swift
//  MyApp
//
//  Created by Cong Le on 12/9/24.
//

import UIKit

/// A view controller for managing application settings.
class YOLOSettingsViewController: UIViewController {

    // MARK: - UI Elements

    private var developerModeSwitch: UISwitch!
    private var telephotoCameraSwitch: UISwitch!
    private var versionLabel: UILabel!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadSettings()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Developer Mode Switch
        let developerModeLabel = createLabel(text: "Developer Mode")
        developerModeSwitch = UISwitch()
        developerModeSwitch.addTarget(self, action: #selector(developerModeToggled(_:)), for: .valueChanged)

        // Telephoto Camera Switch
        let telephotoCameraLabel = createLabel(text: "Use Telephoto Camera")
        telephotoCameraSwitch = UISwitch()
        telephotoCameraSwitch.addTarget(self, action: #selector(telephotoCameraToggled(_:)), for: .valueChanged)

        // Version Label
        versionLabel = createLabel(text: "Version: N/A")
        versionLabel.textAlignment = .center

        // Add subviews
        view.addSubview(developerModeLabel)
        view.addSubview(developerModeSwitch)
        view.addSubview(telephotoCameraLabel)
        view.addSubview(telephotoCameraSwitch)
        view.addSubview(versionLabel)

        // Layout
        developerModeLabel.translatesAutoresizingMaskIntoConstraints = false
        developerModeSwitch.translatesAutoresizingMaskIntoConstraints = false
        telephotoCameraLabel.translatesAutoresizingMaskIntoConstraints = false
        telephotoCameraSwitch.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            developerModeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            developerModeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),

            developerModeSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            developerModeSwitch.centerYAnchor.constraint(equalTo: developerModeLabel.centerYAnchor),

            telephotoCameraLabel.leadingAnchor.constraint(equalTo: developerModeLabel.leadingAnchor),
            telephotoCameraLabel.topAnchor.constraint(equalTo: developerModeLabel.bottomAnchor, constant: 20),

            telephotoCameraSwitch.trailingAnchor.constraint(equalTo: developerModeSwitch.trailingAnchor),
            telephotoCameraSwitch.centerYAnchor.constraint(equalTo: telephotoCameraLabel.centerYAnchor),

            versionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            versionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    private func setupNavigationBar() {
        navigationItem.title = "Settings"
    }

    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .label
        return label
    }

    private func loadSettings() {
        let userDefaults = UserDefaults.standard
        developerModeSwitch.isOn = userDefaults.bool(forKey: "developer_mode")
        telephotoCameraSwitch.isOn = userDefaults.bool(forKey: "use_telephoto")
        versionLabel.text = "Version: \(userDefaults.string(forKey: "app_version") ?? "N/A")"
    }

    // MARK: - Actions

    @objc func developerModeToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "developer_mode")
    }

    @objc func telephotoCameraToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "use_telephoto")
    }
}
