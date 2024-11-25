//
//  CollapsibleHeaderView.swift
//  MyApp
//
//  Created by Cong Le on 11/24/24.
//

import UIKit

// MARK: - CollapsibleHeaderView

class CollapsibleHeaderView: UITableViewHeaderFooterView {

    weak var delegate: CollapsibleHeaderViewDelegate?
    private var section: Int = 0
    private var isExpanded: Bool = false

    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
        setupAccessibility()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupAccessibility()
    }

    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageView)
        contentView.backgroundColor = .systemMint

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            arrowImageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 16),
            arrowImageView.heightAnchor.constraint(equalToConstant: 16)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        contentView.addGestureRecognizer(tapGesture)
    }

    func configure(with title: String, section: Int, isExpanded: Bool) {
        self.titleLabel.text = title
        self.section = section
        self.isExpanded = isExpanded
        self.arrowImageView.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down")
        updateAccessibility()
    }

    @objc private func headerTapped() {
        delegate?.didToggleSection(self, section: section)
    }

    // MARK: - Accessibility

    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = [.button, .header]
    }

    private func updateAccessibility() {
        accessibilityLabel = titleLabel.text
        accessibilityHint = isExpanded ? "Double-tap to collapse" : "Double-tap to expand"

        // Custom actions
        let actionName = isExpanded ? "Collapse Section" : "Expand Section"
        let action = UIAccessibilityCustomAction(name: actionName, target: self, selector: #selector(accessibilityToggleSection))
        accessibilityCustomActions = [action]
    }

    @objc private func accessibilityToggleSection() -> Bool {
        headerTapped()
        let announcement = isExpanded ? "Section \(section + 1) collapsed" : "Section \(section + 1) expanded"
        UIAccessibility.post(notification: .announcement, argument: announcement)
        return true
    }
}
