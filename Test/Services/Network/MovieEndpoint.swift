//
//  MovieEndpoint.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import Foundation
import Alamofire

/// API endpoints for TMDb Movie API
enum MovieEndpoint {
    case popular(page: Int)
    case details(movieId: Int)
    case videos(movieId: Int)
    case genres
    case search(query: String, page: Int)
}

// MARK: - URLRequestConvertible
extension MovieEndpoint: URLRequestConvertible {

    // MARK: - Properties

    /// Base URL path
    private var path: String {
        switch self {
        case .popular:
            return "/movie/popular"
        case .details(let movieId):
            return "/movie/\(movieId)"
        case .videos(let movieId):
            return "/movie/\(movieId)/videos"
        case .genres:
            return "/genre/movie/list"
        case .search:
            return "/search/movie"
        }
    }

    /// HTTP method
    private var method: HTTPMethod {
        // All our endpoints use GET
        return .get
    }

    /// Query parameters
    private var parameters: Parameters? {
        var params: Parameters = [
            "api_key": APIConfig.apiKey
        ]

        switch self {
        case .popular(let page):
            params["page"] = page
            params["language"] = getCurrentLanguage()

        case .details:
            params["language"] = getCurrentLanguage()

        case .videos:
            params["language"] = getCurrentLanguage()

        case .genres:
            params["language"] = getCurrentLanguage()

        case .search(let query, let page):
            params["query"] = query
            params["page"] = page
            params["language"] = getCurrentLanguage()
        }

        return params
    }

    // MARK: - URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try APIConfig.baseURL.asURL()
        let urlWithPath = url.appendingPathComponent(path)

        var urlRequest = URLRequest(url: urlWithPath)
        urlRequest.httpMethod = method.rawValue

        // Add headers if needed
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode parameters
        let encodedRequest = try URLEncoding.default.encode(urlRequest, with: parameters)

        return encodedRequest
    }

    // MARK: - Helpers

    /// Get current language code for localization
    private func getCurrentLanguage() -> String {
        let languageCode = Locale.current.languageCode ?? "en"
        let regionCode = Locale.current.regionCode ?? "US"
        return "\(languageCode)-\(regionCode)"
    }
}