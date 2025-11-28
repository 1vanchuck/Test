//
//  Video.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import Foundation

// MARK: - Videos Response
struct VideosResponse: Codable {
    let id: Int
    let results: [Video]
}

// MARK: - Video
struct Video: Codable {
    let id: String
    let key: String
    let site: String
    let type: String
    let name: String
    let official: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case key
        case site
        case type
        case name
        case official
    }

    // MARK: - Computed Properties
    var isYouTube: Bool {
        return site.lowercased() == "youtube"
    }

    var isTrailer: Bool {
        return type.lowercased() == "trailer"
    }

    var youtubeURL: URL? {
        guard isYouTube else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }
}
