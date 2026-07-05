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
        
    override func prepareForReuse() {

            super.prepareForReuse()
            posterImageView.image = nil
            posterImageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            titleLabel.text = nil
            descriptionLabel.text = nil
            countLabel.text = nil
            moreLabel.text = nil
        }

        // MARK: - Configure

        func configure(with list: MovieList) {
            titleLabel.text = list.name
            descriptionLabel.text = list.description
            countLabel.text = "\(list.itemCount) movies"
            moreLabel.text = "•••"
            posterImageView.image = nil
            posterImageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            posterImageView.layer.cornerRadius = 8
            posterImageView.clipsToBounds = true
            posterImageView.contentMode = .scaleAspectFill
        }
    }
