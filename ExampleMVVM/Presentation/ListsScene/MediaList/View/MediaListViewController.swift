//
//  MediaListViewController.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 16/01/1448 AH.
//
import UIKit

final class MediaListViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var updatedLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private enum Layout {
        static let horizontalPadding: CGFloat = 16
        static let interitemSpacing: CGFloat = 12
        static let lineSpacing: CGFloat = 16
        static let columnsCount: CGFloat = 3
        static let cellHeight: CGFloat = 220
    }
        // MARK: - Properties
    private var viewModel: MediaListViewModel!
    private var posterImagesRepository: PosterImagesRepository?
    private var movies: [Movie] = []
    private var selectedIndexPaths = Set<IndexPath>()
    private var isEditingMode = false
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupViews()
            setupCollectionView()
            bind(to: viewModel)
            viewModel.viewDidLoad()
            
        }
    }
// MARK: - Create
extension MediaListViewController {
    
    func bind(to viewModel: MediaListViewModel) {
        viewModel.movies.observe(on: self) { [weak self] movies in
            self?.movies = movies
            self?.collectionView.reloadData()
            self?.infoLabel.text = "\(self?.viewModel.itemCount ?? 0) movies • Public"
        }
        
        viewModel.error.observe(on: self) { [weak self] message in
            guard !message.isEmpty else { return }
            self?.showError(message: message)
        }
    }
    static func create(
        with viewModel: MediaListViewModel,
        posterImagesRepository: PosterImagesRepository?
    ) -> MediaListViewController {
        
        let viewController = MediaListViewController(
            nibName: CellIdentifiers.MediaListViewController,
            bundle: nil
        )
        
        viewController.viewModel = viewModel
        viewController.posterImagesRepository = posterImagesRepository
        
        return viewController
    }
}

// MARK: - Private
private extension MediaListViewController{

    func setupViews() {
        view.backgroundColor = .white

        titleLabel.text = viewModel.title
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        infoLabel.text = "\(viewModel.itemCount) movies • Public"
        infoLabel.font = .systemFont(ofSize: 16)
        infoLabel.textColor = .gray
        infoLabel.textAlignment = .center

        updatedLabel.text = NSLocalizedString(
            "Updated 2 days ago",
            comment: ""
        )
        updatedLabel.font = .systemFont(ofSize: 16)
        updatedLabel.textColor = .gray
        updatedLabel.textAlignment = .center
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
    }
    func showError(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("Error", comment: ""),
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
    func setupCollectionView() {
        let nib = UINib(
            nibName: CellIdentifiers.listMovieCell,
            bundle: nil
        )

        collectionView.register(
            nib,
            forCellWithReuseIdentifier: CellIdentifiers.listMovieCell
        )

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.allowsMultipleSelection = false
          }
        }

// MARK: - UICollectionViewDataSource
extension MediaListViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        movies.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellIdentifiers.listMovieCell,
            for: indexPath
        ) as? ListMovieCell else {
            return UICollectionViewCell()
        }
        
        let movie = movies[indexPath.item]
        
        let cellViewModel = ListMovieCellViewModel(
            title: movie.title ?? "",
            posterPath: movie.posterPath
        )
        
        cell.configure(
            with: cellViewModel,
            posterImagesRepository: posterImagesRepository
        )
        cell.setEditing(
           isEditingMode,
           selected: selectedIndexPaths.contains(indexPath)
               )
        return cell
    }
    }

// MARK: - UICollectionViewDelegateFlowLayout
extension MediaListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let spacesCount = Layout.columnsCount - 1

        let totalSpacing =
            (Layout.horizontalPadding * 2) +
            (Layout.interitemSpacing * spacesCount)

        let width =
            (collectionView.bounds.width - totalSpacing) /
            Layout.columnsCount

        return CGSize(
            width: width,
            height: Layout.cellHeight
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        Layout.interitemSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        Layout.lineSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: Layout.horizontalPadding,
            left: Layout.horizontalPadding,
            bottom: Layout.horizontalPadding,
            right: Layout.horizontalPadding
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard isEditingMode else {
            collectionView.deselectItem(
                at: indexPath,
                animated: false
            )
            return
        }

        selectedIndexPaths.insert(indexPath)

        if let cell = collectionView.cellForItem(
            at: indexPath
        ) as? ListMovieCell {
            cell.setEditing(
                true,
                selected: true
            )
        }

        updateDeleteButton()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        guard isEditingMode else { return }

        selectedIndexPaths.remove(indexPath)

        if let cell = collectionView.cellForItem(
            at: indexPath
        ) as? ListMovieCell {
            cell.setEditing(
                true,
                selected: false
            )
        }

        updateDeleteButton()
    }
}
// MARK: - UICollectionViewDataSourcePrefetching
extension MediaListViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
        guard !isEditingMode else { return }
        guard !movies.isEmpty else { return }

        let lastItemIndex = movies.count - 1

        let shouldLoadNextPage = indexPaths.contains {
            $0.item >= lastItemIndex - 2
        }

        guard shouldLoadNextPage else { return }

        viewModel.didLoadNextPage()
    }
}
// MARK: - Editing
private extension MediaListViewController {

    @objc
    func editButtonTapped() {
        if isEditingMode && !selectedIndexPaths.isEmpty {
            deleteButtonTapped()
            return
        }

        isEditingMode.toggle()
        collectionView.allowsMultipleSelection = isEditingMode

        if !isEditingMode {
            clearSelection()
        }

        navigationItem.rightBarButtonItem?.title = isEditingMode ? "Cancel" : "Edit"

        collectionView.reloadData()
    }

    @objc
    func deleteButtonTapped() {
        guard !selectedIndexPaths.isEmpty else { return }
        showDeleteConfirmation()
    }
    func deleteSelectedMovies() {
        guard !selectedIndexPaths.isEmpty else { return }

        let selectedMovies = selectedIndexPaths
            .sorted { $0.item < $1.item }
            .map { movies[$0.item] }

        viewModel.deleteMovies(selectedMovies)

        clearSelection()
        navigationItem.rightBarButtonItem?.title = "Cancel"
        collectionView.reloadData()
    }
    func showDeleteConfirmation() {
        let count = selectedIndexPaths.count

        let alert = UIAlertController(
            title: NSLocalizedString(
                "Delete Movies",
                comment: ""
            ),
            message: String(
                format: NSLocalizedString(
                    "Are you sure you want to delete %d movie(s)?",
                    comment: ""
                ),
                count
            ),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString(
                    "Cancel",
                    comment: ""
                ),
                style: .cancel
            )
        )

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString(
                    "Delete",
                    comment: ""
                ),
                style: .destructive
            ) { [weak self] _ in
                self?.deleteSelectedMovies()
            }
        )

        present(alert, animated: true)
    }

    func clearSelection() {
        selectedIndexPaths.removeAll()
        collectionView.indexPathsForSelectedItems?.forEach {
            collectionView.deselectItem(at: $0, animated: false)
        }
    }

    func updateDeleteButton() {
        navigationItem.rightBarButtonItem?.title =
            selectedIndexPaths.isEmpty ? "Cancel" : "Delete"
    }
}
