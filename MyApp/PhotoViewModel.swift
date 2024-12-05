//
//  PhotoViewModel.swift
//  MyApp
//
//  Created by Cong Le on 12/4/24.
//

import Foundation
import Combine

@MainActor
class PhotoViewModel: ObservableObject {
    @Published private(set) var photo: Photo?
    @Published private(set) var isLoading: Bool = false
    @Published var error: NetworkError?
    
    private let photoRepository: PhotoRepositoryProtocol

    init(photoRepository: PhotoRepositoryProtocol) {
        self.photoRepository = photoRepository
    }
    
    func fetchPhoto() async {
        isLoading = true
        do {
            let photo = try await photoRepository.getPhoto()
            self.photo = photo
        } catch {
            if let networkError = error as? NetworkError {
                self.error = networkError
            } else {
                self.error = .apiError(error)
            }
        }
        isLoading = false
    }
}
