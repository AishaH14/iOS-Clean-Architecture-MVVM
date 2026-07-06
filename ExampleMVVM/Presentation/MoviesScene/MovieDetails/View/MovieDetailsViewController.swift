import UIKit

final class MovieDetailsViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet private var posterImageView: UIImageView!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var watchlistButton: UIButton!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private var overviewTextView: UITextView!
    @IBOutlet private weak var addToListButton: UIButton!
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
        viewModel.viewDidLoad()
        bind(to: viewModel)
    }
    
    private func bind(to viewModel: MovieDetailsViewModel) {
        viewModel.posterImage.observe(on: self) { [weak self]in
            self?.posterImageView.image = $0.flatMap(UIImage.init)
        }
        viewModel.isFavorite.observe(on: self) { [weak self] isFavorite in
            self?.updateFavoriteButton(isFavorite: isFavorite)
        }
        
        viewModel.isInWatchlist.observe(on: self) { [weak self] isInWatchlist in
            self?.updateWatchlistButton(isInWatchlist: isInWatchlist)
        }
        viewModel.isAddedToList.observe(on: self) { [weak self] isAdded in
            self?.updateAddToListButton(isAdded: isAdded)
        }
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
        
        updateAddToListButton(isAdded: false)
    }
    
    private func updateFavoriteButton(isFavorite: Bool) {
        var configuration = UIButton.Configuration.plain()

        let imageName = isFavorite ? "heart.fill" : "heart"

        configuration.image = UIImage(named: imageName)?
            .withRenderingMode(.alwaysTemplate)

        configuration.title = isFavorite
            ? "Added Favorite"
            : "Add Favorite"

        configuration.imagePlacement = .top
        configuration.imagePadding = 6
        configuration.baseForegroundColor = .systemRed

        configuration.titleTextAttributesTransformer =
            UIConfigurationTextAttributesTransformer { attributes in
                var attributes = attributes
                attributes.font = .systemFont(ofSize: 13)
                return attributes
            }

        favoriteButton.configuration = configuration
    }
    
    private func updateWatchlistButton(isInWatchlist: Bool) {
        var configuration = UIButton.Configuration.plain()

        let imageName = isInWatchlist ? "checkmark" : "bookmark"

        configuration.image = UIImage(named: imageName)?
            .withRenderingMode(.alwaysTemplate)

        configuration.title = isInWatchlist
            ? "Added Watchlist"
            : "Add Watchlist"

        configuration.imagePlacement = .top
        configuration.imagePadding = 6
        configuration.baseForegroundColor = isInWatchlist
            ? .systemGreen
            : .systemGray

        configuration.titleTextAttributesTransformer =
            UIConfigurationTextAttributesTransformer { attributes in
                var attributes = attributes
                attributes.font = .systemFont(ofSize: 13)
                return attributes
            }

        watchlistButton.configuration = configuration
    }
    private func showRemoveMovieConfirmation() {
        let alert = UIAlertController(
            title: NSLocalizedString(
                "Remove Movie?",
                comment: ""
            ),
            message: NSLocalizedString(
                "Are you sure you want to remove this movie from the list?",
                comment: ""
            ),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel
            )
        )

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Done", comment: ""),
                style: .destructive
            ) { [weak self] _ in
                self?.viewModel.addToList()
            }
        )

        present(alert, animated: true)
    }
    private func updateAddToListButton(isAdded: Bool) {
        var configuration = UIButton.Configuration.plain()

        configuration.image = UIImage(
            systemName: isAdded
                ? "checkmark.circle.fill"
                : "text.badge.plus"
        )

        configuration.title = isAdded
            ? "Added to List"
            : "Add to List"

        configuration.imagePlacement = .top
        configuration.imagePadding = 6
        configuration.baseForegroundColor = isAdded
            ? .systemGreen
            : .systemGray

        configuration.titleTextAttributesTransformer =
            UIConfigurationTextAttributesTransformer { attributes in
                var attributes = attributes
                attributes.font = .systemFont(ofSize: 13)
                return attributes
            }

        addToListButton.configuration = configuration
    }
    // MARK: - Actions
    
    @IBAction private func watchlistTapped(_ sender: UIButton) {
        viewModel.toggleWatchlist()
    }
    
    @IBAction private func favoriteTapped(_ sender: UIButton) {
        viewModel.toggleFavorite()
    }
    
    @IBAction private func addToListTapped(_ sender: UIButton) {
        if viewModel.isAddedToList.value {
            showRemoveMovieConfirmation()
        } else {
            viewModel.addToList()
        }
    }
}
