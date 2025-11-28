//
//  MovieTableViewCell.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import UIKit
import SDWebImage

final class MovieTableViewCell: UITableViewCell {

    // MARK: - UI Elements

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()

    private let genresLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .tertiaryLabel
        return label
    }()

    private let ratingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemOrange
        view.layer.cornerRadius = 4
        return view
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear

        // Add subviews
        contentView.addSubview(containerView)
        containerView.addSubview(posterImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(genresLabel)
        containerView.addSubview(yearLabel)
        containerView.addSubview(ratingContainerView)
        ratingContainerView.addSubview(ratingLabel)

        // Setup constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        genresLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingContainerView.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // Poster
            posterImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            posterImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            posterImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            posterImageView.widthAnchor.constraint(equalToConstant: 80),

            // Title
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            // Genres
            genresLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            genresLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            genresLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            // Year
            yearLabel.topAnchor.constraint(equalTo: genresLabel.bottomAnchor, constant: 4),
            yearLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            // Rating
            ratingContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            ratingContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            ratingContainerView.widthAnchor.constraint(equalToConstant: 36),
            ratingContainerView.heightAnchor.constraint(equalToConstant: 20),

            ratingLabel.centerXAnchor.constraint(equalTo: ratingContainerView.centerXAnchor),
            ratingLabel.centerYAnchor.constraint(equalTo: ratingContainerView.centerYAnchor)
        ])
    }

    // MARK: - Configuration

    func configure(with movie: Movie, genres: String) {
        titleLabel.text = movie.title
        genresLabel.text = genres.isEmpty ? "No genres" : genres

        // Year from release date
        if let date = movie.releaseDate.split(separator: "-").first {
            yearLabel.text = String(date)
        } else {
            yearLabel.text = "N/A"
        }

        // Rating
        ratingLabel.text = String(format: "%.1f", movie.voteAverage)

        // Rating color
        switch movie.voteAverage {
        case 7...:
            ratingContainerView.backgroundColor = .systemGreen
        case 5..<7:
            ratingContainerView.backgroundColor = .systemOrange
        default:
            ratingContainerView.backgroundColor = .systemRed
        }

        // Poster image
        if let posterPath = movie.posterPath {
            let imageURL = "\(APIConfig.imageBaseURL)/w342\(posterPath)"
            posterImageView.sd_setImage(
                with: URL(string: imageURL),
                placeholderImage: UIImage(systemName: "photo"),
                options: [.progressiveLoad, .retryFailed]
            )
        } else {
            posterImageView.image = UIImage(systemName: "photo")
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.sd_cancelCurrentImageLoad()
        posterImageView.image = nil
        titleLabel.text = nil
        genresLabel.text = nil
        yearLabel.text = nil
        ratingLabel.text = nil
    }
}