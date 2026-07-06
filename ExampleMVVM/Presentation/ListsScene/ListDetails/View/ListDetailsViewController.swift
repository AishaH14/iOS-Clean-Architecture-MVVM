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
    
    private enum Layout {
        static let horizontalPadding: CGFloat = 16
        static let interitemSpacing: CGFloat = 12
        static let lineSpacing: CGFloat = 16
        static let columnsCount: CGFloat = 3
        static let cellHeight: CGFloat = 220
    }
        // MARK: - Properties
    private var viewModel: ListDetailsViewModel!
    private var posterImagesRepository: PosterImagesRepository?
    private var movies: [Movie] = []
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
extension ListDetailsViewController {
    
    func bind(to viewModel: ListDetailsViewModel) {
        viewModel.movies.observe(on: self) { [weak self] movies in
            self?.movies = movies
            self?.collectionView.reloadData()
        }
    }
    static func create(
        with viewModel: ListDetailsViewModel,
        posterImagesRepository: PosterImagesRepository?
    ) -> ListDetailsViewController {
        let viewController = ListDetailsViewController(
            nibName: CellIdentifiers.listDetailsViewController,
            bundle: nil
        )

        viewController.viewModel = viewModel
        viewController.posterImagesRepository = posterImagesRepository

        return viewController
    }
}

// MARK: - Private
private extension ListDetailsViewController {

    func setupViews() {
        view.backgroundColor = .white

        titleLabel.text = viewModel.list.name

        
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center

        infoLabel.text = "\(viewModel.list.itemCount) movies • Public"
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
    }
}
// MARK: - UICollectionViewDataSource
extension ListDetailsViewController: UICollectionViewDataSource {
    
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
        return cell
    }
    }

// MARK: - UICollectionViewDelegateFlowLayout
extension ListDetailsViewController: UICollectionViewDelegateFlowLayout {

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
    }
