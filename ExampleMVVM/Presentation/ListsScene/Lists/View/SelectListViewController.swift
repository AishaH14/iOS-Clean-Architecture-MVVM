//
//  SelectListViewController.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 20/01/1448 AH.
//

import UIKit

final class SelectListViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: SelectListViewModel
    private var lists: [MovieList] = []
    private var selectedIndex: Int?
    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Init
    init(viewModel: SelectListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        bindViewModel()
        viewModel.viewDidLoad()
    }
}

// MARK: - Private
private extension SelectListViewController {

    func setupViews() {
        title = NSLocalizedString("Add to List", comment: "")
        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
}

// MARK: - UITableViewDataSource
extension SelectListViewController: UITableViewDataSource {

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
        let identifier = "SelectListCell"

        let cell = tableView.dequeueReusableCell(
            withIdentifier: identifier
        ) ?? UITableViewCell(
            style: .subtitle,
            reuseIdentifier: identifier
        )

        let list = lists[indexPath.row]

        cell.textLabel?.text = list.name
        cell.detailTextLabel?.text = "\(list.itemCount) movies"
        cell.selectionStyle = .none

        let isSelected = selectedIndex == indexPath.row

        let selectionImageView = UIImageView(
            image: UIImage(
                systemName: isSelected
                    ? "record.circle.fill"
                    : "circle"
            )
        )

        selectionImageView.tintColor = isSelected
            ? .systemPink
            : .systemGray3

        selectionImageView.contentMode = .scaleAspectFit
        selectionImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: 26,
            height: 26
        )

        cell.accessoryView = selectionImageView

        return cell
    }
}
// MARK: - UITableViewDelegate
extension SelectListViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        selectedIndex = indexPath.row
        tableView.reloadData()

        viewModel.didSelectList(at: indexPath.row)
    }
}
