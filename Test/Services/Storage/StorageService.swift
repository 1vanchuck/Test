//
//  StorageService.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import Foundation

/// Handles offline data persistence using UserDefaults
final class StorageService {

    static let shared = StorageService()
    private let userDefaults = UserDefaults.standard

    private let moviesKey = "cached_movies"
    private let genresKey = "cached_genres"

    private init() {}

    // MARK: - Movies

    func saveMovies(_ movies: [Movie]) {
        Task.detached(priority: .background) {
            if let data = try? JSONEncoder().encode(movies) {
                await MainActor.run {
                    self.userDefaults.set(data, forKey: self.moviesKey)
                }
            }
        }
    }

    func loadMovies() -> [Movie]? {
        guard let data = userDefaults.data(forKey: moviesKey) else { return nil }
        return try? JSONDecoder().decode([Movie].self, from: data)
    }

    // MARK: - Genres

    func saveGenres(_ genres: [Genre]) {
        Task.detached(priority: .background) {
            if let data = try? JSONEncoder().encode(genres) {
                await MainActor.run {
                    self.userDefaults.set(data, forKey: self.genresKey)
                }
            }
        }
    }

    func loadGenres() -> [Genre]? {
        guard let data = userDefaults.data(forKey: genresKey) else { return nil }
        return try? JSONDecoder().decode([Genre].self, from: data)
    }

    // MARK: - Clear

    func clearCache() {
        userDefaults.removeObject(forKey: moviesKey)
        userDefaults.removeObject(forKey: genresKey)
    }
}