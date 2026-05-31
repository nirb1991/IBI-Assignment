//
//  ProductDetailsViewController.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import SnapKit
import UIKit

final class ProductDetailsViewController: UIViewController {
    private let viewModel: ProductDetailsViewModel
    private var imageTasks: [URLSessionDataTask] = []

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let imageScrollView = UIScrollView()
    private let imageStackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let priceLabel = UILabel()
    private let categoryLabel = UILabel()
    private let brandLabel = UILabel()
    private let ratingLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)

    init(viewModel: ProductDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureHierarchy()
        configureContent()
        bindViewModel()

        Task {
            await viewModel.loadFavoriteState()
        }
    }

    deinit {
        imageTasks.forEach { $0.cancel() }
    }

    private func configureView() {
        view.backgroundColor = .systemBackground
        title = "Product Details"
    }

    private func configureHierarchy() {
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        contentStackView.isLayoutMarginsRelativeArrangement = true

        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.isPagingEnabled = true

        imageStackView.axis = .horizontal
        imageStackView.spacing = 12

        favoriteButton.configuration = .borderedProminent()
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        imageScrollView.addSubview(imageStackView)

        [
            imageScrollView,
            titleLabel,
            descriptionLabel,
            priceLabel,
            categoryLabel,
            brandLabel,
            ratingLabel,
            favoriteButton
        ].forEach { contentStackView.addArrangedSubview($0) }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentStackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        imageScrollView.snp.makeConstraints { make in
            make.height.equalTo(280)
        }

        imageStackView.snp.makeConstraints { make in
            make.edges.equalTo(imageScrollView.contentLayoutGuide)
            make.height.equalTo(imageScrollView.frameLayoutGuide)
        }
    }

    private func configureContent() {
        let product = viewModel.product

        titleLabel.text = product.title
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.numberOfLines = 0

        descriptionLabel.text = product.description
        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.numberOfLines = 0

        priceLabel.attributedText = detailText(title: "Price", value: product.price.formatted(.currency(code: "USD")))
        categoryLabel.attributedText = detailText(title: "Category", value: product.category.capitalized)
        brandLabel.attributedText = detailText(title: "Brand", value: product.brand ?? "Unknown")
        ratingLabel.attributedText = detailText(title: "Rating", value: product.rating.formatted(.number.precision(.fractionLength(1))))

        [priceLabel, categoryLabel, brandLabel, ratingLabel].forEach {
            $0.font = .preferredFont(forTextStyle: .subheadline)
            $0.numberOfLines = 0
        }

        configureImages()
        updateFavoriteButton(isFavorite: viewModel.isFavorite)
    }

    private func configureImages() {
        let imageURLs = viewModel.product.images.isEmpty
            ? [viewModel.product.thumbnail]
            : viewModel.product.images

        for imageURLString in imageURLs {
            let imageView = UIImageView()
            imageView.backgroundColor = .secondarySystemBackground
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 8

            imageStackView.addArrangedSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.width.equalTo(imageScrollView.frameLayoutGuide)
            }
            loadImage(from: imageURLString, into: imageView)
        }
    }

    private func loadImage(from imageURLString: String, into imageView: UIImageView) {
        guard let url = URL(string: imageURLString) else {
            imageView.image = UIImage(systemName: "photo")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data,
                  let image = UIImage(data: data) else {
                return
            }

            DispatchQueue.main.async {
                imageView.image = image
            }
        }

        imageTasks.append(task)
        task.resume()
    }

    private func bindViewModel() {
        viewModel.onFavoriteStateChanged = { [weak self] isFavorite in
            self?.updateFavoriteButton(isFavorite: isFavorite)
        }
    }

    private func updateFavoriteButton(isFavorite: Bool) {
        var configuration = favoriteButton.configuration ?? .borderedProminent()
        configuration.title = isFavorite ? "Remove from Favorites" : "Add to Favorites"
        configuration.image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
        configuration.imagePadding = 8
        favoriteButton.configuration = configuration
    }

    private func detailText(title: String, value: String) -> NSAttributedString {
        let result = NSMutableAttributedString(
            string: "\(title): ",
            attributes: [.font: UIFont.preferredFont(forTextStyle: .headline)]
        )
        result.append(NSAttributedString(string: value))
        return result
    }

    @objc
    private func favoriteButtonTapped() {
        Task {
            await viewModel.toggleFavorite()
        }
    }
}
