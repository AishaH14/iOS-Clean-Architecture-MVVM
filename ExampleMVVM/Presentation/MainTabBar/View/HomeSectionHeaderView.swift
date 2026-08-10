//
//  HomeSectionHeaderView.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 23/11/1447 AH.
//

import UIKit

final class HomeSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: HomeSectionHeaderView.self)
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var seeAllButton: UIButton!
    
    private var didTapSeeAll: (() -> Void)?
    
    func configure(title: String,didTapSeeAll: @escaping () -> Void) {
        titleLabel.text = title
        self.didTapSeeAll = didTapSeeAll
        seeAllButton.removeTarget(
                   self,
                   action: #selector(seeAllButtonTapped),
                   for: .touchUpInside
               )
               seeAllButton.addTarget(
                   self,
                   action: #selector(seeAllButtonTapped),
                   for: .touchUpInside
               )
           }
           
           @objc private func seeAllButtonTapped() {
               didTapSeeAll?()
           }
       }
