//
//  ListDetailsViewController.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 16/01/1448 AH.
//
import UIKit

final class ListDetailsViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var updatedLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
        // MARK: - Properties
        private var list: MovieList!
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupViews()
        }
    }

    // MARK: - Create
    extension ListDetailsViewController {
        
        static func create(with list: MovieList) -> ListDetailsViewController {
            let viewController = ListDetailsViewController(
                nibName: "ListDetailsViewController",
                bundle: nil
            )
            viewController.list = list
            return viewController
        }
    }

    // MARK: - Private
    private extension ListDetailsViewController {
        
        func setupViews() {
            view.backgroundColor = .white
            
            titleLabel.text = list.name
            titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
            titleLabel.textAlignment = .center
            
            infoLabel.text = "\(list.itemCount) movies • Public"
            infoLabel.font = UIFont.systemFont(ofSize: 16)
            infoLabel.textColor = .gray
            infoLabel.textAlignment = .center
            
            updatedLabel.text = NSLocalizedString("Updated 2 days ago", comment: "")
            updatedLabel.font = UIFont.systemFont(ofSize: 16)
            updatedLabel.textColor = .gray
            updatedLabel.textAlignment = .center
        }
    }
