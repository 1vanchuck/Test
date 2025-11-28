//
//  MovieDetailsViewController.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import UIKit
import SDWebImage

final class MovieDetailsViewController: UIViewController {

    // MARK: - UI Elements

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray6
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()

    private let yearCountryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()

    private let genresLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let ratingView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemOrange
        view.layer.cornerRadius = 8
        return view
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let trailerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Trailer", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.isHidden = true
        return button
    }()

    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Properties

    private let viewModel: MovieDetailsViewModel

    // MARK: - Init

    init(movieId: Int) {
        self.viewModel = DIContainer.shared.makeMovieDetailsViewModel(movieId: movieId)
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
        viewModel.loadMovieDetails()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(yearCountryLabel)
        contentView.addSubview(genresLabel)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(ratingView)
        ratingView.addSubview(ratingLabel)
        contentView.addSubview(trailerButton)
        view.addSubview(loadingIndicator)

        // Setup constraints
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        yearCountryLabel.translatesAutoresizingMaskIntoConstraints = false
        genresLabel.translatesAutoresizingMaskIntoConstraints = false
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        trailerButton.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Poster
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            posterImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 200),
            posterImageView.heightAnchor.constraint(equalToConstant: 300),

            // Title
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Year & Country
            yearCountryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            yearCountryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            yearCountryLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            // Genres
            genresLabel.topAnchor.constraint(equalTo: yearCountryLabel.bottomAnchor, constant: 4),
            genresLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            genresLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            // Overview
            overviewLabel.topAnchor.constraint(equalTo: genresLabel.bottomAnchor, constant: 16),
            overviewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            overviewLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            // Rating
            ratingView.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: 16),
            ratingView.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: -16),
            ratingView.widthAnchor.constraint(equalToConstant: 50),
            ratingView.heightAnchor.constraint(equalToConstant: 30),

            ratingLabel.centerXAnchor.constraint(equalTo: ratingView.centerXAnchor),
            ratingLabel.centerYAnchor.constraint(equalTo: ratingView.centerYAnchor),

            // Trailer Button
            trailerButton.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 20),
            trailerButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            trailerButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            trailerButton.heightAnchor.constraint(equalToConstant: 50),
            trailerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            // Loading
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Actions
        trailerButton.addTarget(self, action: #selector(watchTrailer), for: .touchUpInside)

        // Poster tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showFullscreenPoster))
        posterImageView.addGestureRecognizer(tapGesture)

        loadingIndicator.hidesWhenStopped = true
    }

    private func setupBindings() {
        viewModel.onDetailsLoaded = { [weak self] in
            self?.updateUI()
        }

        viewModel.onError = { [weak self] errorMessage in
            self?.showErrorAlert(message: errorMessage)
        }

        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            if isLoading {
                self?.loadingIndicator.startAnimating()
            } else {
                self?.loadingIndicator.stopAnimating()
            }
        }
    }

    // MARK: - Update UI

    private func updateUI() {
        guard let details = viewModel.movieDetails else { return }

        // Title
        titleLabel.text = details.title
        title = details.title

        // Year & Country
        let year = String(details.releaseDate.prefix(4))
        yearCountryLabel.text = "\(year) • \(viewModel.formattedCountry)"

        // Genres
        genresLabel.text = viewModel.formattedGenres

        // Overview
        overviewLabel.text = details.overview.isEmpty ? "No description available" : details.overview

        // Rating
        ratingLabel.text = String(format: "%.1f", details.voteAverage)

        // Rating color
        switch details.voteAverage {
        case 7...:
            ratingView.backgroundColor = .systemGreen
        case 5..<7:
            ratingView.backgroundColor = .systemOrange
        default:
            ratingView.backgroundColor = .systemRed
        }

        // Poster
        if let posterPath = details.posterPath {
            let imageURL = "\(APIConfig.imageBaseURL)/w500\(posterPath)"
            posterImageView.sd_setImage(
                with: URL(string: imageURL),
                placeholderImage: UIImage(systemName: "photo"),
                options: [.progressiveLoad, .retryFailed]
            )
        }

        // Trailer button
        trailerButton.isHidden = viewModel.trailerKey == nil
    }

    // MARK: - Actions

    @objc private func watchTrailer() {
        guard let trailerKey = viewModel.trailerKey else { return }

        let trailerVC = TrailerPlayerViewController(videoKey: trailerKey)
        present(trailerVC, animated: true)
    }

    @objc private func showFullscreenPoster() {
        guard let image = posterImageView.image else { return }
        let fullscreenVC = FullscreenPosterViewController(image: image)
        fullscreenVC.modalPresentationStyle = .fullScreen
        present(fullscreenVC, animated: true)
    }

    // MARK: - Helpers

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}