//
//  APIConfig.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import Foundation

/// API Configuration for The Movie Database
enum APIConfig {
    // MARK: - Base URLs
    static let baseURL = "https://api.themoviedb.org/3"
    static let imageBaseURL = "https://image.tmdb.org/t/p"

    // MARK: - API Key
    /// API key is stored in Secrets.swift (not in Git for security)
    static let apiKey = Secrets.tmdbAPIKey

    // MARK: - Image Sizes
    enum ImageSize: String {
        case poster_w92 = "w92"
        case poster_w154 = "w154"
        case poster_w185 = "w185"
        case poster_w342 = "w342"
        case poster_w500 = "w500"
        case poster_w780 = "w780"
        case original = "original"

        var path: String {
            return rawValue
        }
    }

    // MARK: - Helper Methods
    static func imageURL(path: String?, size: ImageSize = .poster_w342) -> URL? {
        guard let path = path else { return nil }
        let urlString = "\(imageBaseURL)/\(size.path)\(path)"
        return URL(string: urlString)
    }
}
