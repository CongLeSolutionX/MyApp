//
//  PhotoRepository.swift
//  MyApp
//
//  Created by Cong Le on 12/4/24.
//

import Foundation

class PhotoRepository: PhotoRepositoryProtocol {
    private let photoService: PhotoServiceProtocol

    init(photoService: PhotoServiceProtocol) {
        self.photoService = photoService
    }

    func getPhoto() async throws -> Photo {
        return try await photoService.fetchPhoto()
    }
}
