//
//  Coordinator.swift
//  MyApp
//
//  Created by Cong Le on 1/11/25.
//

import SwiftUI

protocol Coordinator: AnyObject {
    var navigationPath: NavigationPath { get set }
    func start()
    func push(_ page: any Hashable)
    func pop()
    func popToRoot()
}

extension Coordinator {
    func pop() {
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath = .init()
    }
}
