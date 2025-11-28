//
//  MoviesListViewController.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import UIKit

final class MoviesListViewController: UIViewController {

    // MARK: - UI Elements

    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let refreshControl = UIRefreshControl()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    // Empty state
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No movies found"
        label.textAlignment = .center
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 17)
        label.isHidden = true
        return label
    }()

    // MARK: - Properties

    private let viewModel: MoviesListViewModel

    // MARK: - Init

    init(viewModel: MoviesListViewModel? = nil) {
        self.viewModel = viewModel ?? DIContainer.shared.makeMoviesListViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadMovies()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Popular Movies".localized

        // Navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down"),
            style: .plain,
            target: self,
            action: #selector(showSortOptions)
        )

        // Search bar
        searchBar.placeholder = "Search movies..."
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal

        // Table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieCell")
        tableView.rowHeight = 150
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.keyboardDismissMode = .onDrag

        // Refresh control
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        // Loading indicator
        loadingIndicator.hidesWhenStopped = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        // Layout
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            // Search bar
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Table view
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // Empty state
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupBindings() {
        // Update table when movies loaded
        viewModel.onMoviesUpdated = { [weak self] in
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
            self?.updateEmptyState()
        }

        // Show errors
        viewModel.onError = { [weak self] errorMessage in
            self?.showErrorAlert(message: errorMessage)
            self?.refreshControl.endRefreshing()
        }

        // Loading state
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            if isLoading {
                self?.loadingIndicator.startAnimating()
            } else {
                self?.loadingIndicator.stopAnimating()
            }
        }
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.loadMovies()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func showSortOptions() {
        if !NetworkMonitor.shared.isConnected {
            return
        }

        let alert = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)

        let sortOptions: [(String, MoviesListViewModel.SortOption)] = [
            ("Most Popular", .popularityDesc),
            ("Least Popular", .popularityAsc),
            ("Highest Rated", .ratingDesc),
            ("Lowest Rated", .ratingAsc),
            ("Newest", .releaseDateDesc),
            ("Oldest", .releaseDateAsc)
        ]

        for (title, option) in sortOptions {
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.viewModel.setSortOption(option)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }

        present(alert, animated: true)
    }

    // MARK: - Helpers

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func updateEmptyState() {
        let isEmpty = viewModel.displayMovies.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

// MARK: - UITableViewDataSource

extension MoviesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displayMovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
        let movie = viewModel.displayMovies[indexPath.row]
        let genreNames = viewModel.genreNames(for: movie.genreIds)
        cell.configure(with: movie, genres: genreNames)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MoviesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movie = viewModel.displayMovies[indexPath.row]

        if !NetworkMonitor.shared.isConnected {
            let alert = UIAlertController(
                title: "Error",
                message: "You are offline. Please, enable your Wi-Fi or connect using cellular data.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let detailsVC = MovieDetailsViewController(movieId: movie.id)
        navigationController?.pushViewController(detailsVC, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.loadMoreIfNeeded(currentIndex: indexPath.row)
    }
}

// MARK: - UISearchBarDelegate

extension MoviesListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        perform(#selector(performSearch), with: nil, afterDelay: 0.5)
    }

    @objc private func performSearch() {
        guard let query = searchBar.text else { return }
        viewModel.searchMovies(query: query)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.searchMovies(query: "")
    }
}

// MARK: - Canvas Preview

#if DEBUG
import SwiftUI

struct MoviesListViewController_Previews: PreviewProvider {
    static var previews: some View {
        MoviesListPreview()
            .previewDisplayName("Movies List")
    }
}

private struct MoviesListPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = MockMoviesListVC()
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = false
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

private class MockMoviesListVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Popular Movies"

        // Search bar
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search movies..."
        searchBar.searchBarStyle = .minimal

        // Table view
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none

        view.addSubview(searchBar)
        view.addSubview(tableView)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Add mock cells
        for i in 0..<3 {
            let cell = createMockCell(at: i)
            cell.frame = CGRect(x: 16, y: CGFloat(i * 160), width: view.bounds.width - 32, height: 150)
            tableView.addSubview(cell)
        }
    }

    private func createMockCell(at index: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4

        let poster = UIView()
        poster.backgroundColor = .systemGray5
        poster.layer.cornerRadius = 8

        let title = UILabel()
        title.text = "Movie Title \(index + 1)"
        title.font = .boldSystemFont(ofSize: 16)

        let year = UILabel()
        year.text = "2024"
        year.font = .systemFont(ofSize: 12)
        year.textColor = .secondaryLabel

        container.addSubview(poster)
        container.addSubview(title)
        container.addSubview(year)

        poster.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        year.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            poster.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            poster.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            poster.widthAnchor.constraint(equalToConstant: 60),
            poster.heightAnchor.constraint(equalToConstant: 90),

            title.topAnchor.constraint(equalTo: poster.topAnchor),
            title.leadingAnchor.constraint(equalTo: poster.trailingAnchor, constant: 12),

            year.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            year.leadingAnchor.constraint(equalTo: title.leadingAnchor)
        ])

        return container
    }
}
#endif