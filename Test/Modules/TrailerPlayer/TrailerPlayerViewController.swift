//
//  TrailerPlayerViewController.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import UIKit
import YouTubeiOSPlayerHelper

final class TrailerPlayerViewController: UIViewController {

    // MARK: - UI Elements

    private let playerView = YTPlayerView()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 20
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Properties

    private let videoKey: String

    // MARK: - Init

    init(videoKey: String) {
        self.videoKey = videoKey
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadVideo()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .black

        // Add subviews
        view.addSubview(playerView)
        view.addSubview(closeButton)
        view.addSubview(activityIndicator)

        // Layout
        playerView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Player View
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Close button
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),

            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Actions
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        // Delegate
        playerView.delegate = self

        activityIndicator.startAnimating()
    }

    private func loadVideo() {
        let playerVars = [
            "playsinline": 1,
            "showinfo": 0,
            "rel": 0,
            "modestbranding": 1,
            "controls": 1
        ] as [String : Any]

        playerView.load(withVideoId: videoKey, playerVars: playerVars)
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - YTPlayerViewDelegate

extension TrailerPlayerViewController: YTPlayerViewDelegate {

    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        activityIndicator.stopAnimating()
        playerView.playVideo()
    }

    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if state == .ended {
            dismiss(animated: true)
        }
    }

    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        activityIndicator.stopAnimating()

        let alert = UIAlertController(
            title: "Error",
            message: "Unable to load trailer. Please try again later.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - Canvas Preview

#if DEBUG
import SwiftUI

struct TrailerPlayerViewController_Previews: PreviewProvider {
    static var previews: some View {
        TrailerPlayerPreview()
            .previewDisplayName("Trailer Player")
    }
}

private struct TrailerPlayerPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = MockTrailerPlayerVC()
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

private class MockTrailerPlayerVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // Close button
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 20

        // Player placeholder
        let playerPlaceholder = UIView()
        playerPlaceholder.backgroundColor = .darkGray

        let playIcon = UILabel()
        playIcon.text = "▶"
        playIcon.font = .systemFont(ofSize: 60)
        playIcon.textColor = .white
        playIcon.textAlignment = .center

        view.addSubview(playerPlaceholder)
        view.addSubview(closeButton)
        playerPlaceholder.addSubview(playIcon)

        playerPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        playIcon.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            playerPlaceholder.topAnchor.constraint(equalTo: view.topAnchor),
            playerPlaceholder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerPlaceholder.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerPlaceholder.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            playIcon.centerXAnchor.constraint(equalTo: playerPlaceholder.centerXAnchor),
            playIcon.centerYAnchor.constraint(equalTo: playerPlaceholder.centerYAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
#endif