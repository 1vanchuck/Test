//
//  Movie.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import Foundation

// MARK: - Movies Response
struct MoviesResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Movie
struct Movie: Codable {
    let id: Int
    let title: String
    let posterPath: String?
    let genreIds: [Int]
    let voteAverage: Double
    let releaseDate: String
    let overview: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case genreIds = "genre_ids"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case overview
    }

    // MARK: - Computed Properties
    var releaseYear: String {
        guard let year = releaseDate.split(separator: "-").first else {
            return "N/A"
        }
        return String(year)
    }

    var posterURL: URL? {
        return APIConfig.imageURL(path: posterPath, size: .poster_w342)
    }
}
