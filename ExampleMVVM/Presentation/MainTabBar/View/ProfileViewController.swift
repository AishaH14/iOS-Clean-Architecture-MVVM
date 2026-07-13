//
//  ProfileViewController.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 16/11/1447 AH.
//

import UIKit

final class ProfileViewController: UIViewController, StoryboardInstantiable {
    
    // MARK: - IBOutlet
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var userCardView: UIView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    // MARK: - Properties
    var viewModel: ProfileViewModel!
    
    private let profileItems: [ProfileItem] = [
        .lists,
        .favorites,
        .watchlist,
        .logout
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
}

// MARK: - Private
private extension ProfileViewController {
    
    func setupView() {
        title = "Profile"
        
        userCardView.layer.cornerRadius = 12
        userCardView.layer.borderWidth = 1
        userCardView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        userCardView.clipsToBounds = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            UINib(nibName: "ProfileItemCell", bundle: nil),
            forCellReuseIdentifier: "ProfileItemCell"
        )
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        tableView.rowHeight = 70
        
        tableView.layer.cornerRadius = 12
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        tableView.clipsToBounds = true
    }
    }


// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        profileItems.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProfileItemCell",
            for: indexPath
        ) as? ProfileItemCell else {
            return UITableViewCell()
        }
        
        let item = profileItems[indexPath.row]
        cell.configure(with: item)
        cell.selectionStyle = item.isSelectable ? .default : .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = profileItems[indexPath.row]
        switch item {
        case .lists:
            viewModel.didTapLists()
        case .favorites, .watchlist, .logout:
            return
        }
    }
}

