//
//  LaunchScreenViewController.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import UIKit
import SDWebImage

final class LaunchScreenViewController: UIViewController {

    var onReady: (() -> Void)?
    private var dummySearchBar: UISearchBar?

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .systemGray
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startPrewarmingAndTimer()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        activityIndicator.startAnimating()
    }

    private func startPrewarmingAndTimer() {
        // Start keyboard prewarming after 0.1 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.prewarmKeyboard()
        }

        // Initialize basic components after 0.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.prewarmBasicComponents()
        }

        // Show screen for 3.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.cleanupAndTransition()
        }
    }

    private func prewarmKeyboard() {
        // Create UISearchBar matching the main app
        dummySearchBar = UISearchBar(frame: CGRect(x: 0, y: -100, width: view.bounds.width, height: 44))

        // Settings matching MoviesListViewController
        dummySearchBar?.placeholder = "Search movies..."
        dummySearchBar?.searchBarStyle = .minimal
        dummySearchBar?.autocorrectionType = .no
        dummySearchBar?.autocapitalizationType = .none
        dummySearchBar?.spellCheckingType = .no
        dummySearchBar?.keyboardType = .default
        dummySearchBar?.returnKeyType = .search

        // Make minimally visible
        dummySearchBar?.alpha = 0.001

        if let searchBar = dummySearchBar {
            view.addSubview(searchBar)

            // Get internal text field
            if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
                searchField.keyboardType = .asciiCapable

                // Allow time for rendering
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    // Activate keyboard
                    searchField.becomeFirstResponder()

                    // Keep keyboard active for 1.5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        searchField.resignFirstResponder()
                        searchBar.frame.origin.y = -1000
                    }
                }
            }
        }
    }

    private func prewarmBasicComponents() {
        // Basic initialization without network requests
        DispatchQueue.global(qos: .background).async {
            _ = NetworkMonitor.shared.isConnected

            SDImageCache.shared.config.maxMemoryCost = 100 * 1024 * 1024 // 100MB
            SDImageCache.shared.config.maxDiskAge = 3 * 24 * 60 * 60 // 3 days

            _ = StorageService.shared.loadMovies()
            _ = StorageService.shared.loadGenres()
        }
    }

    private func cleanupAndTransition() {
        dummySearchBar?.removeFromSuperview()
        dummySearchBar = nil

        activityIndicator.stopAnimating()
        onReady?()
    }
}