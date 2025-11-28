//
//  NetworkError.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import Foundation

/// Network layer error types
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case serverError(statusCode: Int)
    case unauthorized
    case noInternet
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .unauthorized:
            return "Invalid API key or unauthorized access"
        case .noInternet:
            return "You are offline. Please, enable your Wi-Fi or connect using cellular data."
        case .unknown:
            return "An unknown error occurred"
        }
    }

    /// User-friendly error message for alerts
    var userFriendlyMessage: String {
        switch self {
        case .noInternet:
            // Exact text from requirements
            return "You are offline. Please, enable your Wi-Fi or connect using cellular data."
        case .unauthorized:
            return "Authentication failed. Please check your API key."
        case .serverError(let code) where code >= 500:
            return "Server is temporarily unavailable. Please try again later."
        case .serverError(let code) where code == 404:
            return "The requested content was not found."
        default:
            return "Something went wrong. Please try again."
        }
    }
}