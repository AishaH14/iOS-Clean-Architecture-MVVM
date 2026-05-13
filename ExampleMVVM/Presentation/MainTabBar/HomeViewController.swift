//
//  HomeViewController.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 16/11/1447 AH.
//

import UIKit

final class HomeViewController: UIViewController, StoryboardInstantiable {
    
    private var viewModel: HomeViewModel!
    private var posterImagesRepository: PosterImagesRepository?
    private var sections: [HomeSectionViewModel] = []
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    static func create(
        with viewModel: HomeViewModel,
        posterImagesRepository: PosterImagesRepository?
    ) -> HomeViewController {
        let viewController = HomeViewController.instantiateViewController()
        viewController.viewModel = viewModel
        viewController.posterImagesRepository = posterImagesRepository
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
}

// MARK: - Private
private extension HomeViewController {
    
    func setupView() {
        title = viewModel.screenTitle
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func bind(to viewModel: HomeViewModel) {
        viewModel.sections.observe(on: self) { [weak self] sections in
            self?.sections = sections
            self?.collectionView.reloadData()
        }
        
        viewModel.loading.observe(on: self) { isLoading in
        }
        
        viewModel.error.observe(on: self) { error in
            guard !error.isEmpty else { return }
        }
    }
}
// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return min(sections[section].movies.count, 3)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeMovieCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? HomeMovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let movie = sections[indexPath.section].movies[indexPath.item]
        cell.configure(
            with: movie,
            posterImagesRepository: posterImagesRepository
        )
        
        return cell
    }
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HomeSectionHeaderView.reuseIdentifier,
                for: indexPath
              ) as? HomeSectionHeaderView else {
            return UICollectionReusableView()
        }
        
        header.configure(title: sections[indexPath.section].title)
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        viewModel.didSelectMovie(
            sectionIndex: indexPath.section,
            movieIndex: indexPath.item
        )
    }
}
