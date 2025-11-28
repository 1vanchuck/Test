//
//  MoviesListViewModel.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import Foundation

final class MoviesListViewModel {

    // MARK: - Properties

    private let networkManager: NetworkManager
    private let storageService: StorageService
    private var genres: [Genre] = []

    private(set) var movies: [Movie] = []
    private(set) var filteredMovies: [Movie] = []

    private var currentPage = 1
    private var totalPages = 1
    private var isLoadingMore = false

    private var searchQuery = ""
    private var isSearching = false

    enum SortOption {
        case popularityDesc
        case popularityAsc
        case ratingDesc
        case ratingAsc
        case releaseDateDesc
        case releaseDateAsc
    }

    private var currentSortOption: SortOption = .popularityDesc

    // MARK: - Callbacks

    var onMoviesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?

    // MARK: - Init

    init(networkManager: NetworkManager, storageService: StorageService) {
        self.networkManager = networkManager
        self.storageService = storageService
        loadOfflineDataIfNeeded()
    }

    // MARK: - Public Methods

    func loadMovies() {
        guard !isLoadingMore else { return }

        currentPage = 1
        fetchMovies()
    }

    func loadMoreIfNeeded(currentIndex: Int) {
        guard currentIndex >= movies.count - 5,
              !isLoadingMore,
              currentPage < totalPages,
              !isSearching else { return }

        currentPage += 1
        fetchMovies(isLoadMore: true)
    }

    func searchMovies(query: String) {
        searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        if searchQuery.isEmpty {
            isSearching = false
            filteredMovies = []
            onMoviesUpdated?()
            return
        }

        isSearching = true
        currentPage = 1

        // Offline search
        if !NetworkMonitor.shared.isConnected {
            filteredMovies = movies.filter { movie in
                movie.title.localizedCaseInsensitiveContains(searchQuery)
            }
            onMoviesUpdated?()
            return
        }

        Task {
            do {
                onLoadingStateChanged?(true)
                let response = try await networkManager.searchMovies(query: searchQuery, page: currentPage)

                await MainActor.run {
                    self.filteredMovies = response.results
                    self.totalPages = response.totalPages
                    self.onLoadingStateChanged?(false)
                    self.onMoviesUpdated?()
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.handleError(error)
                }
            }
        }
    }

    var displayMovies: [Movie] {
        let moviesToDisplay = isSearching ? filteredMovies : movies
        return sortMovies(moviesToDisplay)
    }

    func setSortOption(_ option: SortOption) {
        currentSortOption = option
        onMoviesUpdated?()
    }

    private func sortMovies(_ movies: [Movie]) -> [Movie] {
        switch currentSortOption {
        case .popularityDesc:
            return movies
        case .popularityAsc:
            return movies.reversed()
        case .ratingDesc:
            return movies.sorted { $0.voteAverage > $1.voteAverage }
        case .ratingAsc:
            return movies.sorted { $0.voteAverage < $1.voteAverage }
        case .releaseDateDesc:
            return movies.sorted { $0.releaseDate > $1.releaseDate }
        case .releaseDateAsc:
            return movies.sorted { $0.releaseDate < $1.releaseDate }
        }
    }

    func genreNames(for genreIds: [Int]) -> String {
        let names = genreIds.compactMap { id in
            genres.first { $0.id == id }?.name
        }
        return names.joined(separator: ", ")
    }

    // MARK: - Private Methods

    private func fetchMovies(isLoadMore: Bool = false) {
        isLoadingMore = true

        Task {
            do {
                onLoadingStateChanged?(true)

                if genres.isEmpty {
                    self.genres = try await networkManager.fetchGenres()
                    storageService.saveGenres(self.genres)
                }

                let response = try await networkManager.fetchPopularMovies(page: currentPage)

                await MainActor.run {
                    if isLoadMore {
                        self.movies.append(contentsOf: response.results)
                    } else {
                        self.movies = response.results
                    }

                    self.storageService.saveMovies(self.movies)

                    self.totalPages = response.totalPages
                    self.isLoadingMore = false
                    self.onLoadingStateChanged?(false)
                    self.onMoviesUpdated?()
                }
            } catch {
                await MainActor.run {
                    self.isLoadingMore = false
                    self.onLoadingStateChanged?(false)

                    if let networkError = error as? NetworkError,
                       case .noInternet = networkError {
                        self.loadOfflineData()
                    } else {
                        self.handleError(error)
                    }
                }
            }
        }
    }

    private func loadOfflineDataIfNeeded() {
        if !NetworkMonitor.shared.isConnected {
            loadOfflineData()
        }
    }

    private func loadOfflineData() {
        if let savedMovies = storageService.loadMovies() {
            self.movies = savedMovies
            onMoviesUpdated?()
        }

        if let savedGenres = storageService.loadGenres() {
            self.genres = savedGenres
        }
    }

    private func handleError(_ error: Error) {
        let errorMessage: String

        if let networkError = error as? NetworkError {
            errorMessage = networkError.userFriendlyMessage
        } else {
            errorMessage = "Something went wrong. Please try again."
        }

        onError?(errorMessage)
    }
}