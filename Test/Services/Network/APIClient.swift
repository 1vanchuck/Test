//
//  APIClient.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import Foundation
import Alamofire

/// API client for network requests
final class APIClient {

    // MARK: - Properties

    static let shared = APIClient()
    private let session: Session

    // MARK: - Initialization

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30

        self.session = Session(configuration: configuration)
    }

    // MARK: - Request Method

    /// Perform network request with async/await
    func request<T: Codable>(
        _ endpoint: MovieEndpoint,
        expecting type: T.Type
    ) async throws -> T {

        // Check internet connection
        guard NetworkMonitor.shared.isConnected else {
            throw NetworkError.noInternet
        }

        let response = await session
            .request(endpoint)
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self)
            .response

        switch response.result {
        case .success(let value):
            return value
        case .failure(let error):
            throw mapError(error, response: response.response)
        }
    }

    // MARK: - Error Mapping

    private func mapError(_ error: AFError, response: HTTPURLResponse?) -> NetworkError {
        // Check status code
        if let statusCode = response?.statusCode {
            switch statusCode {
            case 401:
                return .unauthorized
            case 404:
                return .serverError(statusCode: 404)
            case 500...599:
                return .serverError(statusCode: statusCode)
            default:
                break
            }
        }

        // Check AFError type
        switch error {
        case .invalidURL:
            return .invalidURL

        case .responseSerializationFailed:
            return .decodingError(error)

        case .sessionTaskFailed(let urlError as URLError) where
            urlError.code == .notConnectedToInternet:
            return .noInternet

        default:
            return .networkError(error)
        }
    }
}