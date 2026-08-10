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
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var signInButton: UIButton!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    // MARK: - IBAction
    @IBAction private func signInButtonTapped(_ sender: UIButton) {
        viewModel.didTapSignIn()
    }
    // MARK: - Properties
    var viewModel: ProfileViewModel!
    
    private var profileItems: [ProfileItem] = [
        .lists,
        .favorites,
        .watchlist
    ]
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        viewModel.viewDidLoad()
        
    }
}

// MARK: - Private
private extension ProfileViewController {
    
    func setupView() {
        title = "Profile"
        setupUserCard()
        setupTableView()
        setupAvatarImageView()
    }
    func setupUserCard() {
        userCardView.layer.cornerRadius = 12
        userCardView.layer.borderWidth = 1
        userCardView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        userCardView.clipsToBounds = true
    }
    func setupTableView() {
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
    func setupAvatarImageView() {
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true
        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarImageView.tintColor = .systemGray3
        avatarImageView.contentMode = .scaleAspectFit
    }
    func bindViewModel() {
            viewModel.isSignInButtonHidden.observe(on: self) { [weak self] isHidden in
                self?.signInButton.isHidden = isHidden
            }
            viewModel.account.observe(on: self) { [weak self] account in
                if account != nil {
                    self?.profileItems.append(.logout)
                    self?.tableView.reloadData()
                }
                self?.updateTableViewHeight()
                guard let account = account else { return }
                self?.usernameLabel.text = account.username
                self?.subtitleLabel.text = "Signed in to TMDB"
            }
            viewModel.error.observe(on: self) { [weak self] message in
                guard !message.isEmpty else { return }
                self?.showError(message: message)
            }
        }
    private func updateTableViewHeight() {
        tableViewHeightConstraint.constant =
            CGFloat(profileItems.count) * tableView.rowHeight
    }
        func showError(message: String) {
            let alert = UIAlertController(
                title: "Error",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .default
                )
            )
            present(alert, animated: true)

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
            case .favorites:
                viewModel.didSelectFavorites()

            case .watchlist:
                viewModel.didSelectWatchlist()

            case .logout:
                viewModel.didSelectLogout()
            }
        }
    }

