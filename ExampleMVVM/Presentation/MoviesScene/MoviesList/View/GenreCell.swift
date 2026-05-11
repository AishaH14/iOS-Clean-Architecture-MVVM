//
//  GenreCell.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 19/11/1447 AH.
//

import UIKit

class GenreCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    func configure(with title: String) {
            titleLabel.text = title
            
            contentView.backgroundColor = .clear

            contentView.layer.cornerRadius = 5
            contentView.clipsToBounds = true
            
            titleLabel.textColor = .white
            titleLabel.textAlignment = .center
        }
    }

