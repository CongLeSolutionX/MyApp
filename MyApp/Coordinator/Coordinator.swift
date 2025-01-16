//
//  Coordinator.swift
//  MyApp
//
//  Created by Cong Le on 1/11/25.

import SwiftUI

// MARK: - Coordinator
protocol Coordinator: AnyObject {
    var navigationPath: [AnyHashable] { get set }
    func start()
    func push<T: Hashable>(_ page: T)
    func pop()
    func popToRoot()
}

// MARK: - Default implementations
extension Coordinator {
    func pop() {
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath = .init()
    }
}
