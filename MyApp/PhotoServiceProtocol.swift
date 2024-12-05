//
//  PhotoServiceProtocol.swift
//  MyApp
//
//  Created by Cong Le on 12/4/24.
//

import Foundation

protocol PhotoServiceProtocol {
    func fetchPhoto() async throws -> Photo
}
