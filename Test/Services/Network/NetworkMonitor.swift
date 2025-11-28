//
//  NetworkMonitor.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import Foundation
import Reachability

/// Monitors network connectivity status
final class NetworkMonitor {

    static let shared = NetworkMonitor()

    private let reachability: Reachability?
    private(set) var isConnected: Bool = true

    var onReachabilityChanged: ((Bool) -> Void)?

    private init() {
        reachability = try? Reachability()
        setupReachability()
    }

    private func setupReachability() {
        guard let reachability = reachability else { return }

        reachability.whenReachable = { [weak self] _ in
            self?.isConnected = true
            self?.onReachabilityChanged?(true)
        }

        reachability.whenUnreachable = { [weak self] _ in
            self?.isConnected = false
            self?.onReachabilityChanged?(false)
        }

        do {
            try reachability.startNotifier()
        } catch {
            // Silently fail
        }
    }

    deinit {
        reachability?.stopNotifier()
    }
}