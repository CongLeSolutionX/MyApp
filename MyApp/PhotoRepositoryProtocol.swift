//
//  PhotoRepositoryProtocol.swift
//  MyApp
//
//  Created by Cong Le on 12/4/24.
//

import Foundation

protocol PhotoRepositoryProtocol {
    func getPhoto() async throws -> Photo
}
