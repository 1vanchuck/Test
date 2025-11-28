//
//  NetworkManager.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import Foundation

/// Network manager for movie API operations
final class NetworkManager {

    // MARK: - Properties

    static let shared = NetworkManager()
    private let apiClient = APIClient.shared

    // MARK: - Initialization

    private init() {}

    // MARK: - API Methods

    /// Fetch popular movies
    func fetchPopularMovies(page: Int = 1) async throws -> MoviesResponse {
        try await apiClient.request(.popular(page: page), expecting: MoviesResponse.self)
    }

    /// Fetch movie details
    func fetchMovieDetails(movieId: Int) async throws -> MovieDetails {
        try await apiClient.request(.details(movieId: movieId), expecting: MovieDetails.self)
    }

    /// Fetch movie videos
    func fetchMovieVideos(movieId: Int) async throws -> VideosResponse {
        try await apiClient.request(.videos(movieId: movieId), expecting: VideosResponse.self)
    }

    /// Search movies
    func searchMovies(query: String, page: Int = 1) async throws -> MoviesResponse {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            throw NetworkError.invalidURL
        }
        return try await apiClient.request(.search(query: trimmedQuery, page: page), expecting: MoviesResponse.self)
    }

    /// Fetch genres
    func fetchGenres() async throws -> [Genre] {
        let response = try await apiClient.request(.genres, expecting: GenresResponse.self)
        return response.genres
    }
}