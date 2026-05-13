//
//  HomeMovieCollectionViewCell.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 23/11/1447 AH.
//

import UIKit

final class HomeMovieCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: HomeMovieCollectionViewCell.self)
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        titleLabel.text = nil
        ratingLabel.text = nil
        imageLoadTask?.cancel()
    }
    
    func configure(
        with movie: Movie,
        posterImagesRepository: PosterImagesRepository?
    ) {
        titleLabel.text = movie.title
        ratingLabel.text = String(format: "%.1f", movie.voteAverage ?? 0)
        
        guard let posterPath = movie.posterPath else { return }
        
        imageLoadTask = posterImagesRepository?.fetchImage(
            with: posterPath,
            width: Int(posterImageView.bounds.width)
        ) { [weak self] result in
            guard case .success(let data) = result else { return }
            
            DispatchQueue.main.async {
                self?.posterImageView.image = UIImage(data: data)
            }
        }
    }
}
