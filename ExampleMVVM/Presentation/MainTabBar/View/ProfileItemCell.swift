//
//  ProfileItemCell.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 14/01/1448 AH.
//

import UIKit

final class ProfileItemCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
        
        // MARK: - Configure
        func configure(with item: ProfileItem) {
            iconImageView.image = UIImage(named: item.iconName)?.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = item.textColor
            
            titleLabel.text = item.title
            titleLabel.textColor = item.textColor
            
        }
    }
