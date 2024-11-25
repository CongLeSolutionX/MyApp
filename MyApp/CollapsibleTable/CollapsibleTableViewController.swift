//
//  CollapsibleTableViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/24/24.
//

import UIKit

// MARK: - CollapsibleTableViewController

class CollapsibleTableViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private var expandedSections: Set<Int> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
        tableView.register(CollapsibleHeaderView.self, forHeaderFooterViewReuseIdentifier: "HeaderViewIdentifier")
        tableView.register(CollapsibleFooterView.self, forHeaderFooterViewReuseIdentifier: "FooterViewIdentifier")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemPink

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

// MARK: - UITableViewDataSource

extension CollapsibleTableViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 5 // Example: 5 sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandedSections.contains(section) ? 10 : 0 // Example: 10 rows when expanded
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        cell.textLabel?.text = "Row \(indexPath.row + 1) in Section \(indexPath.section + 1)"
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CollapsibleTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderViewIdentifier") as? CollapsibleHeaderView else {
            return nil
        }

        headerView.configure(with: "Section \(section + 1)", section: section, isExpanded: expandedSections.contains(section))
        headerView.delegate = self

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0 // Standard header height
    }
}

// MARK: - CollapsibleHeaderViewDelegate

extension CollapsibleTableViewController: CollapsibleHeaderViewDelegate {

    func didToggleSection(_ header: CollapsibleHeaderView, section: Int) {
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }

        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
}
