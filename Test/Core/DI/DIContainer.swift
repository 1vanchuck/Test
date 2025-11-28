//
//  DIContainer.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import Foundation

/// Simple dependency injection container
final class DIContainer {

    static let shared = DIContainer()

    private(set) lazy var networkManager: NetworkManager = NetworkManager.shared
    private(set) lazy var apiClient: APIClient = APIClient.shared
    private(set) lazy var storageService: StorageService = StorageService.shared

    // MARK: - ViewModels Factory

    func makeMoviesListViewModel() -> MoviesListViewModel {
        return MoviesListViewModel(
            networkManager: networkManager,
            storageService: storageService
        )
    }

    func makeMovieDetailsViewModel(movieId: Int) -> MovieDetailsViewModel {
        return MovieDetailsViewModel(
            movieId: movieId,
            networkManager: networkManager
        )
    }

    private init() {}
}