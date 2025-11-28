//
//  Genre.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import Foundation

// MARK: - Genres Response
struct GenresResponse: Codable {
    let genres: [Genre]
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
