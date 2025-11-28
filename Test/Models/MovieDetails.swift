//
//  MovieDetails.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import Foundation

// MARK: - Movie Details
struct MovieDetails: Codable {
    let id: Int
    let title: String
    let posterPath: String?
    let backdropPath: String?
    let genres: [Genre]
    let overview: String
    let voteAverage: Double
    let releaseDate: String
    let productionCountries: [ProductionCountry]
    let runtime: Int?
    let tagline: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case genres
        case overview
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case productionCountries = "production_countries"
        case runtime
        case tagline
    }

    // MARK: - Computed Properties
    var releaseYear: String {
        guard let year = releaseDate.split(separator: "-").first else {
            return "N/A"
        }
        return String(year)
    }

    var posterURL: URL? {
        return APIConfig.imageURL(path: posterPath, size: .poster_w500)
    }

    var genresString: String {
        return genres.map { $0.name }.joined(separator: ", ")
    }

    var countriesString: String {
        return productionCountries.map { $0.name }.joined(separator: ", ")
    }
}

// MARK: - Production Country
struct ProductionCountry: Codable {
    let iso31661: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case iso31661 = "iso_3166_1"
        case name
    }
}
