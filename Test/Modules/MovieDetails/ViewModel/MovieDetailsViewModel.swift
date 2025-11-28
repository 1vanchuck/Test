//
//  MovieDetailsViewModel.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import Foundation

final class MovieDetailsViewModel {

    // MARK: - Properties

    private let networkManager: NetworkManager
    private let movieId: Int

    // Data
    private(set) var movieDetails: MovieDetails?
    private(set) var trailerKey: String?

    // Callbacks
    var onDetailsLoaded: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?

    // MARK: - Init

    init(movieId: Int, networkManager: NetworkManager) {
        self.movieId = movieId
        self.networkManager = networkManager
    }

    // MARK: - Public Methods

    func loadMovieDetails() {
        Task {
            do {
                onLoadingStateChanged?(true)

                let details = try await networkManager.fetchMovieDetails(movieId: movieId)
                let videos = try await networkManager.fetchMovieVideos(movieId: movieId)
                let trailer = videos.results.first { video in
                    video.site == "YouTube" && video.type == "Trailer"
                }

                await MainActor.run {
                    self.movieDetails = details
                    self.trailerKey = trailer?.key
                    self.onLoadingStateChanged?(false)
                    self.onDetailsLoaded?()
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.handleError(error)
                }
            }
        }
    }

    var trailerURL: URL? {
        guard let key = trailerKey else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }

    var formattedCountry: String {
        guard let country = movieDetails?.productionCountries.first else { return "N/A" }
        return country.name
    }

    var formattedGenres: String {
        guard let genres = movieDetails?.genres else { return "N/A" }
        return genres.map { $0.name }.joined(separator: ", ")
    }

    // MARK: - Private Methods

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