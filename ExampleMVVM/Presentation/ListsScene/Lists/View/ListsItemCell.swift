//
//  ListsItemCell.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 14/01/1448 AH.
//

import UIKit

final class ListsItemCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var moreLabel: UILabel!
    
        // MARK: - Properties
        private var posterPath: String?
        private var posterImagesRepository: PosterImagesRepository?
        private var imageLoadTask: Cancellable? {
            willSet {
                imageLoadTask?.cancel()
            }
        }
        private let mainQueue: DispatchQueueType = DispatchQueue.main

        // MARK: - Lifecycle
        override func awakeFromNib() {
            super.awakeFromNib()

            descriptionLabel.numberOfLines = 2
            descriptionLabel.lineBreakMode = .byWordWrapping

            posterImageView.layer.cornerRadius = 8
            posterImageView.clipsToBounds = true
            posterImageView.contentMode = .scaleAspectFill
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            imageLoadTask?.cancel()
            imageLoadTask = nil
            posterPath = nil
            posterImagesRepository = nil
            posterImageView.image = nil
            posterImageView.backgroundColor =
                UIColor.lightGray.withAlphaComponent(0.2)
            titleLabel.text = nil
            descriptionLabel.text = nil
            countLabel.text = nil
            moreLabel.text = nil
        }

        // MARK: - Configure
    func configure(
        with viewModel: ListsItemViewModel,
        posterImagesRepository: PosterImagesRepository?
    ) {
        posterPath = viewModel.posterPath
        self.posterImagesRepository = posterImagesRepository

        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        countLabel.text = viewModel.moviesCountText
        moreLabel.text = "•••"

        updatePosterImage()
    }

        private func updatePosterImage() {
            posterImageView.image = nil
            posterImageView.backgroundColor =
                UIColor.lightGray.withAlphaComponent(0.2)

            guard let posterPath = posterPath else {
                return
            }

            let width = Int(posterImageView.bounds.width)

            imageLoadTask = posterImagesRepository?.fetchImage(
                with: posterPath,
                width: width
            ) { [weak self] result in
                self?.mainQueue.async {
                    guard self?.posterPath == posterPath else {
                        return
                    }

                    if case let .success(data) = result {
                        self?.posterImageView.image = UIImage(data: data)
                        self?.posterImageView.backgroundColor = .clear
                    }

                    self?.imageLoadTask = nil
                }
            }
        }
    }
