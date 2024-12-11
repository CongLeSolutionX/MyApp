//
//  MainMenuViewController.swift
//  MyApp
//
//  Created by Cong Le on 12/10/24.
//

import UIKit
import SwiftUI


private struct MenuItem {
    var title: String
    var subtitle: String
    var viewControllerProvider: () -> UIViewController
    
    static let allExamples = [
        MenuItem(title: "SwiftUI View Controllers",
                 subtitle: "Using UIHostingController",
                 viewControllerProvider: { HostingControllerViewController() }),
        MenuItem(title: "SwiftUI in Cells",
                 subtitle: "Using UIHostingConfiguration",
                 viewControllerProvider: { HostingConfigurationViewController() }),
        MenuItem(title: "Data Flow with SwiftUI Cells",
                 subtitle: "Using ObservableObject",
                 viewControllerProvider: { MedicalConditionsViewController() })
    ]
}

// MARK: - MainMenuViewController
class MainMenuViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
            let layoutSection = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnvironment)
            return layoutSection
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    override func loadView() {
        view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Example"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, MenuItem> = {
        .init { cell, indexPath, item in
            cell.accessories = [.disclosureIndicator()]
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.secondaryText = item.subtitle
            content.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = content
        }
    }()
}

// MARK: - UICollectionViewDelegate
extension MainMenuViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        MenuItem.allExamples.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = MenuItem.allExamples[indexPath.item]
        return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }
}

// MARK: - UICollectionViewDataSource
extension MainMenuViewController: UICollectionViewDataSource {
    
}
