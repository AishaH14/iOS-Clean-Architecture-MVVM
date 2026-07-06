//
//  ListsViewController.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import UIKit

final class ListsViewController: UIViewController, StoryboardInstantiable {
    
    // MARK: - IBOutlet
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    var viewModel: ListsViewModel!
    private var lists: [MovieList] = []
    private var posterPaths: [Int: String] = [:]
    var posterImagesRepository: PosterImagesRepository?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        bindViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewDidLoad()
    }
}

    // MARK: - Private
    private extension ListsViewController {
        
        func setupViews() {
            title = NSLocalizedString("My Lists", comment: "")
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(didTapAddButton)
            )
            
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(
                UINib(nibName: "ListsItemCell", bundle: nil),
                forCellReuseIdentifier: "ListsItemCell"
            )
            tableView.rowHeight = 120
                tableView.tableFooterView = UIView()
                tableView.separatorStyle = .singleLine
                tableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.25)
                tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                tableView.layer.cornerRadius = 12
                tableView.layer.borderWidth = 1
                tableView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.25).cgColor
                tableView.clipsToBounds = true
            }
        
        func bindViewModel() {
            viewModel.lists.observe(on: self) { [weak self] lists in
                self?.lists = lists
                self?.tableView.reloadData()
            }
            
            viewModel.error.observe(on: self) { [weak self] error in
                guard !error.isEmpty else { return }
                self?.showError(message: error)
            }
            viewModel.posterPaths.observe(on: self) { [weak self] posterPaths in
                self?.posterPaths = posterPaths
                self?.tableView.reloadData()
            }
        }
        
        func showError(message: String) {
            let alert = UIAlertController(
                title: nil,
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("OK", comment: ""),
                    style: .default
                )
            )
            
            present(alert, animated: true)
        }
        
        @objc func didTapAddButton() {
            viewModel.didTapCreateList()
        }
    }

    // MARK: - UITableViewDataSource
    extension ListsViewController: UITableViewDataSource {
        func tableView(
            _ tableView: UITableView,
            numberOfRowsInSection section: Int
        ) -> Int {
            lists.count
        }
        
        func tableView(
            _ tableView: UITableView,
            cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier:CellIdentifiers.listsItemCell,
                for: indexPath
            ) as? ListsItemCell else {
                return UITableViewCell()
            }
            
            let list = lists[indexPath.row]
            let itemViewModel = ListsItemViewModel(
                title: list.name,
                description: list.description ?? "",
                moviesCountText: "\(list.itemCount) movies",
                posterPath: posterPaths[list.id]
            )

            cell.configure(
                with: itemViewModel,
                posterImagesRepository: posterImagesRepository
            )
            cell.selectionStyle = .none
            
            return cell
        }
    }

// MARK: - UITableViewDelegate
extension ListsViewController: UITableViewDelegate {
    
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectList(at: indexPath.row)
    }
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(
            style: .normal,
            title: NSLocalizedString("Delete", comment: "")
        ) { [weak self] _, _, completion in
            self?.showDeleteConfirmation(at: indexPath)
            completion(false)
        }
        
        deleteAction.backgroundColor = UIColor(
            red: 239 / 255,
            green: 35 / 255,
            blue: 60 / 255,
            alpha: 1
        )
        
        deleteAction.image = UIImage(systemName: "trash")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    private func showDeleteConfirmation(at indexPath: IndexPath) {
        let list = lists[indexPath.row]
        
        let alert = UIAlertController(
            title: "\n\nDelete \"\(list.name)\"?",
            message: NSLocalizedString(
                "This list and all its movies will be permanently deleted. This action cannot be undone.",
                comment: ""
            ),
            preferredStyle: .alert
        )
        
        let trashImageView = UIImageView(
            image: UIImage(systemName: "trash")
        )
        
        trashImageView.tintColor = .systemRed
        trashImageView.contentMode = .scaleAspectFit
        trashImageView.frame = CGRect(
            x: 122,
            y: 14,
            width: 28,
            height: 28
        )
        
        alert.view.addSubview(trashImageView)
        
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Delete", comment: ""),
                style: .destructive
            ) { [weak self] _ in
                self?.viewModel.didRequestDeleteList(at: indexPath.row)
            }
        )
        
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel
            )
        )
        
        present(alert, animated: true)
    }
}
