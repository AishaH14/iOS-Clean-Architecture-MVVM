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

    override func awakeFromNib() {
        super.awakeFromNib()

        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 8
        posterImageView.contentMode = .scaleAspectFill
        titleLabel.numberOfLines = 2
    }
}
