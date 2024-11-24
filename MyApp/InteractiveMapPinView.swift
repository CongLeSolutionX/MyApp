//
//  InteractiveMapPinView.swift
//  MyApp
//
//  Created by Cong Le on 11/24/24.
//


// MARK: - MapKit UIView
import UIKit
import MapKit

class InteractiveMapPinView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 0 // Allow multiple lines
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let detailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Details", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false //Needed for constraints
        return button
    }()

    var location: CLLocationCoordinate2D? {
        didSet {
            updateAccessibilityValues()
        }
    }
    var title: String? {
        didSet {
            titleLabel.text = title
            updateAccessibilityValues()
        }
    }
    var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle
            updateAccessibilityValues()
        }
    }

    var detailAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .white
        isAccessibilityElement = true
        accessibilityTraits = [.button, .image] //Initially a button and an image

        // Setup views
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(detailButton)

        //Constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            detailButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 4),
            detailButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            detailButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)

        ])


        detailButton.addTarget(self, action: #selector(detailButtonTapped), for: .touchUpInside)
    }

    @objc private func detailButtonTapped() {
        detailAction?()
    }

    private func updateAccessibilityValues() {
        if let location = location, let title = title, let subtitle = subtitle {
            accessibilityLabel = "\(title) at (\(location.latitude), \(location.longitude))"
            accessibilityValue = subtitle
        } else {
            accessibilityLabel = "Map Pin"
            accessibilityValue = ""
        }
    }

    override func accessibilityActivate() -> Bool {
        detailButtonTapped()
        return true
    }
}
