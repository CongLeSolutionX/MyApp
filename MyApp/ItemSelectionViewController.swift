//
//  ItemSelectionViewController.swift
//  MyApp
//
//  Created by Cong Le on 3/14/25.
//

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The view controller for selecting items.
*/
import UIKit

protocol ItemSelectionViewControllerDelegate: AnyObject {
    func itemSelectionViewController<Item>(_ itemSelectionViewController: ItemSelectionViewController<Item>,
                                             didFinishSelectingItems selectedItems: [Item])
}

class ItemSelectionViewController<Item: Equatable & RawRepresentable>: UITableViewController {
    weak var delegate: ItemSelectionViewControllerDelegate?
    
    let identifier: String
    let allItems: [Item]
    var selectedItems: [Item]
    let allowsMultipleSelection: Bool
    
    private let itemCellIdentifier = "Item"
    
    init(delegate: ItemSelectionViewControllerDelegate,
         identifier: String,
         allItems: [Item],
         selectedItems: [Item],
         allowsMultipleSelection: Bool) {
        self.delegate = delegate
        self.identifier = identifier
        self.allItems = allItems
        self.selectedItems = selectedItems
        self.allowsMultipleSelection = allowsMultipleSelection
        super.init(style: .grouped)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(done))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: itemCellIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("ItemSelectionViewController cannot be initialized with init(coder:)")
    }
    
    @objc private func done() {
        delegate?.itemSelectionViewController(self, didFinishSelectingItems: selectedItems)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = allItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: indexPath)
        cell.tintColor = .black
        cell.textLabel?.text = "\(item.rawValue)"
        cell.accessoryType = selectedItems.contains(item) ? .checkmark : .none
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = allItems[indexPath.row]
        if allowsMultipleSelection {
            if selectedItems.contains(item) {
                selectedItems.removeAll { $0 == item }
            } else {
                selectedItems.append(item)
            }
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            var indexPathsToReload: [IndexPath] = []
            if let previousIndex = allItems.firstIndex(where: { $0 == selectedItems.first }) {
                indexPathsToReload.append(IndexPath(row: previousIndex, section: 0))
            }
            indexPathsToReload.append(indexPath)

            selectedItems = [item]
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.reloadRows(at: indexPathsToReload, with: .automatic)
        }
    }
}
