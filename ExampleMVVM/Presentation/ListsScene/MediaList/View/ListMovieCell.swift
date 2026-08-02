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
        // MARK: - Properties
        private var posterPath: String?
        private var posterImagesRepository: PosterImagesRepository?
        private var imageLoadTask: Cancellable? {
            willSet {
                imageLoadTask?.cancel()
            }
        }
        private let mainQueue: DispatchQueueType = DispatchQueue.main
        
        private lazy var selectionIndicatorView: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 12
            view.layer.borderWidth = 2
            view.layer.borderColor = UIColor.white.cgColor
            view.isHidden = true
            view.isUserInteractionEnabled = false
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private lazy var checkmarkImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(
                systemName: "checkmark"
            )
            imageView.tintColor = .white
            imageView.contentMode = .scaleAspectFit
            imageView.isHidden = true
            imageView.isUserInteractionEnabled = false
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        // MARK: - Lifecycle
        override func awakeFromNib() {
            super.awakeFromNib()
            
            setupViews()
            setupSelectionIndicator()
        }

        override func prepareForReuse() {
            super.prepareForReuse()

            imageLoadTask?.cancel()
            imageLoadTask = nil
            posterPath = nil
            posterImagesRepository = nil
            posterImageView.image = nil
            titleLabel.text = nil
            setEditing(false, selected: false)
        }

        // MARK: - Configuration
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

        func setEditing(
            _ isEditing: Bool,
            selected: Bool
        ) {
            selectionIndicatorView.isHidden = !isEditing
            
            if selected {
                selectionIndicatorView.backgroundColor = .systemBlue
                selectionIndicatorView.layer.borderColor =
                    UIColor.systemBlue.cgColor
                checkmarkImageView.isHidden = false
            } else {
                selectionIndicatorView.backgroundColor =
                    UIColor.white.withAlphaComponent(0.9)
                selectionIndicatorView.layer.borderColor =
                    UIColor.white.cgColor
                checkmarkImageView.isHidden = true
            }
        }
    }

    // MARK: - Private
    private extension ListMovieCell {

        func setupViews() {
            posterImageView.layer.cornerRadius = 8
            posterImageView.clipsToBounds = true
            posterImageView.contentMode = .scaleAspectFill
            
            titleLabel.numberOfLines = 2
        }

        func setupSelectionIndicator() {
            contentView.addSubview(selectionIndicatorView)
            selectionIndicatorView.addSubview(checkmarkImageView)
            
            NSLayoutConstraint.activate([
                selectionIndicatorView.topAnchor.constraint(
                    equalTo: posterImageView.topAnchor,
                    constant: 8
                ),
                selectionIndicatorView.trailingAnchor.constraint(
                    equalTo: posterImageView.trailingAnchor,
                    constant: -8
                ),
                selectionIndicatorView.widthAnchor.constraint(
                    equalToConstant: 24
                ),
                selectionIndicatorView.heightAnchor.constraint(
                    equalToConstant: 24
                ),
                
                checkmarkImageView.centerXAnchor.constraint(
                    equalTo: selectionIndicatorView.centerXAnchor
                ),
                checkmarkImageView.centerYAnchor.constraint(
                    equalTo: selectionIndicatorView.centerYAnchor
                ),
                checkmarkImageView.widthAnchor.constraint(
                    equalToConstant: 14
                ),
                checkmarkImageView.heightAnchor.constraint(
                    equalToConstant: 14
                )
            ])
        }
        
        func updatePosterImage(width: Int) {
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
