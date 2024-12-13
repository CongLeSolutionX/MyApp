//
//  SpriteKitViewController.swift
//  MyApp
//
//  Created by Cong Le on 12/12/24.
//

import SpriteKit
import UIKit

class SpiritKitViewController: UIViewController {
    
    lazy var skView: SKView = {
        let skView = SKView()
        skView.backgroundColor = .systemGreen
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
        return skView
    }()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if skView.scene == nil {
            let scene = MyScene(size: skView.bounds.size)
            skView.presentScene(scene)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add more logics here
        view.backgroundColor = .systemOrange
    }
}
