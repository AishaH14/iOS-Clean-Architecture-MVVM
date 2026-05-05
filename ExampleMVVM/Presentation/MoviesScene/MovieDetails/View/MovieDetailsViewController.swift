import UIKit

final class MovieDetailsViewController: UIViewController, StoryboardInstantiable {

    @IBOutlet private var posterImageView: UIImageView!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var watchlistButton: UIButton!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private var overviewTextView: UITextView!

    // MARK: - Lifecycle

    private var viewModel: MovieDetailsViewModel!
    
    static func create(with viewModel: MovieDetailsViewModel) -> MovieDetailsViewController {
        let view = MovieDetailsViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: viewModel)
        updateFavoriteButton()
        updateWatchlistButton()
    }

    private func bind(to viewModel: MovieDetailsViewModel) {
        viewModel.posterImage.observe(on: self) { [weak self] in self?.posterImageView.image = $0.flatMap(UIImage.init) }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.updatePosterImage(width: Int(posterImageView.imageSizeAfterAspectFit.scaledSize.width))
    }

    // MARK: - Private

    private func setupViews() {
        title = viewModel.title
        overviewTextView.text = viewModel.overview
        posterImageView.isHidden = viewModel.isPosterImageHidden
        ratingLabel.text = "⭐️ \(viewModel.rating)"
        view.accessibilityIdentifier = AccessibilityIdentifier.movieDetailsView
        favoriteButton.semanticContentAttribute = .forceLeftToRight
        favoriteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        
        watchlistButton.semanticContentAttribute = .forceLeftToRight
        watchlistButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    }
    
    private func updateFavoriteButton() {
        let isFavorite = viewModel.isFavorite
        
        favoriteButton.setImage(
            UIImage(named: isFavorite ? "heart.fill" : "heart"),
            for: .normal
        )
        
        favoriteButton.setTitle(
            isFavorite ? " Added Favorite" : " Add Favorite",
            for: .normal
        )
        
        let color: UIColor = isFavorite ? .systemRed : .systemGray
        favoriteButton.tintColor = color
        favoriteButton.setTitleColor(color, for: .normal)
    }
    private func updateWatchlistButton() {
        let isInWatchlist = viewModel.isInWatchlist
        
        watchlistButton.setImage(
            UIImage(named: isInWatchlist ? "checkmark" : "plus"),
            for: .normal
        )
        
        watchlistButton.setTitle(
            isInWatchlist ? " Added Watchlist" : " Add Watchlist",
            for: .normal
        )
        
        let color: UIColor = isInWatchlist ? .systemGreen : .systemGray
        watchlistButton.tintColor = color
        watchlistButton.setTitleColor(color, for: .normal)
    }
    // MARK: - Actions
    
    @IBAction private func watchlistTapped(_ sender: UIButton) {
        viewModel.toggleWatchlist()
        updateWatchlistButton()
    }
    
    @IBAction private func favoriteTapped(_ sender: UIButton) {
        viewModel.toggleFavorite()
        updateFavoriteButton()
    }
}
