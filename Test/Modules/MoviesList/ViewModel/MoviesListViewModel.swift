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
    private var cachedSortedMovies: [Movie] = []
    private var cachedSortOption: SortOption? = nil
    private var cachedSourceMovies: [Movie] = []
    private var genreCache: [Int: String] = [:]

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

        Task {
            await fetchMoviesAsync()
        }
    }

    func loadMoreIfNeeded(currentIndex: Int) {
        guard currentIndex >= movies.count - 5,
              !isLoadingMore,
              currentPage < totalPages,
              !isSearching else { return }

        currentPage += 1

        Task {
            await fetchMoviesAsync(isLoadMore: true)
        }
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

        if cachedSortOption == currentSortOption &&
           cachedSourceMovies == moviesToDisplay {
            return cachedSortedMovies
        }

        cachedSourceMovies = moviesToDisplay
        cachedSortOption = currentSortOption
        cachedSortedMovies = sortMovies(moviesToDisplay)
        return cachedSortedMovies
    }

    func setSortOption(_ option: SortOption) {
        currentSortOption = option
        cachedSortOption = nil
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
        let cacheKey = genreIds.hashValue
        if let cached = genreCache[cacheKey] {
            return cached
        }

        let names = genreIds.compactMap { id in
            genres.first { $0.id == id }?.name
        }
        let result = names.joined(separator: ", ")
        genreCache[cacheKey] = result
        return result
    }

    // MARK: - Private Methods

    private func fetchMoviesAsync(isLoadMore: Bool = false) async {
        isLoadingMore = true

        do {
            await MainActor.run {
                self.onLoadingStateChanged?(true)
            }

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

                self.totalPages = response.totalPages
                self.isLoadingMore = false
                self.cachedSortOption = nil
                self.onLoadingStateChanged?(false)
                self.onMoviesUpdated?()
            }

            self.storageService.saveMovies(self.movies)
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

    private func loadOfflineDataIfNeeded() {
        if !NetworkMonitor.shared.isConnected {
            loadOfflineData()
        }
    }

    private func loadOfflineData() {
        if let savedMovies = storageService.loadMovies() {
            self.movies = savedMovies
            self.cachedSortOption = nil
            onMoviesUpdated?()
        }

        if let savedGenres = storageService.loadGenres() {
            self.genres = savedGenres
            self.genreCache = [:]
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