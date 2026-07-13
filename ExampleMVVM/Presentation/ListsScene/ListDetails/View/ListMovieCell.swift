//
//  ListMovieCell.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 20/01/1448 AH.
//
import UIKit

final class ListMovieCell: UICollectionViewCell {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!


        private var posterPath: String?
        private var posterImagesRepository: PosterImagesRepository?
        private var imageLoadTask: Cancellable? {
            willSet {
                imageLoadTask?.cancel()
            }
        }

        private let mainQueue: DispatchQueueType = DispatchQueue.main

        override func awakeFromNib() {
            super.awakeFromNib()

            posterImageView.layer.cornerRadius = 8
            posterImageView.clipsToBounds = true
            posterImageView.contentMode = .scaleAspectFill

            titleLabel.numberOfLines = 2
        }

        override func prepareForReuse() {
            super.prepareForReuse()

            imageLoadTask?.cancel()
            imageLoadTask = nil
            posterPath = nil
            posterImagesRepository = nil
            posterImageView.image = nil
            titleLabel.text = nil
        }

        func configure(
            with viewModel: ListMovieCellViewModel,
            posterImagesRepository: PosterImagesRepository?
        ) {
            posterPath = viewModel.posterPath
            self.posterImagesRepository = posterImagesRepository

            titleLabel.text = viewModel.title

            updatePosterImage(
                width: Int(posterImageView.bounds.width)
            )
        }

        private func updatePosterImage(width: Int) {
            posterImageView.image = nil

            guard let posterPath = posterPath else {
                return
            }

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
                    }

                    self?.imageLoadTask = nil
                }
            }
        }
    }
