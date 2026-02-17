import UIKit

final class FixedBannerCell: UICollectionViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var aspectConstraint: NSLayoutConstraint?
    private let spacing: CGFloat = 8

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with banners: [Banner]) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        aspectConstraint?.isActive = false

        switch banners.count {
        case 1: layoutOneBanner(banners)
        case 2: layoutTwoBanners(banners)
        case 3: layoutThreeBanners(banners)
        case 4: layoutFourBanners(banners)
        default: break
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        containerView.subviews.forEach { $0.removeFromSuperview() }
        aspectConstraint?.isActive = false
    }

    // MARK: - Layouts

    private func layoutOneBanner(_ banners: [Banner]) {
        let iv = makeBannerImageView(url: banners[0].imageURL)
        containerView.addSubview(iv)

        setAspectRatio(2.5)

        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: containerView.topAnchor),
            iv.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            iv.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }

    private func layoutTwoBanners(_ banners: [Banner]) {
        let leading = makeBannerImageView(url: banners[0].imageURL)
        let trailing = makeBannerImageView(url: banners[1].imageURL)
        [leading, trailing].forEach { containerView.addSubview($0) }

        setAspectRatio(2.5)
        let half = spacing / 2

        NSLayoutConstraint.activate([
            leading.topAnchor.constraint(equalTo: containerView.topAnchor),
            leading.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            leading.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leading.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5, constant: -half),

            trailing.topAnchor.constraint(equalTo: containerView.topAnchor),
            trailing.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            trailing.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            trailing.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5, constant: -half),
        ])
    }

    private func layoutThreeBanners(_ banners: [Banner]) {
        let large = makeBannerImageView(url: banners[0].imageURL)
        let topSmall = makeBannerImageView(url: banners[1].imageURL)
        let bottomSmall = makeBannerImageView(url: banners[2].imageURL)
        [large, topSmall, bottomSmall].forEach { containerView.addSubview($0) }

        setAspectRatio(1.2)
        let half = spacing / 2

        NSLayoutConstraint.activate([
            large.topAnchor.constraint(equalTo: containerView.topAnchor),
            large.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            large.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            large.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5, constant: -half),

            topSmall.topAnchor.constraint(equalTo: containerView.topAnchor),
            topSmall.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            topSmall.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5, constant: -half),
            topSmall.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.5, constant: -half),

            bottomSmall.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            bottomSmall.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bottomSmall.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5, constant: -half),
            bottomSmall.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.5, constant: -half),
        ])
    }

    private func layoutFourBanners(_ banners: [Banner]) {
        let views = banners.map { makeBannerImageView(url: $0.imageURL) }
        views.forEach { containerView.addSubview($0) }

        setAspectRatio(1.0)
        let half = spacing / 2

        NSLayoutConstraint.activate([
            views[0].topAnchor.constraint(equalTo: containerView.topAnchor),
            views[0].leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            views[0].widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5, constant: -half),
            views[0].heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.5, constant: -half),

            views[1].topAnchor.constraint(equalTo: containerView.topAnchor),
            views[1].trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            views[1].widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5, constant: -half),
            views[1].heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.5, constant: -half),

            views[2].bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            views[2].leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            views[2].widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5, constant: -half),
            views[2].heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.5, constant: -half),

            views[3].bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            views[3].trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            views[3].widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5, constant: -half),
            views[3].heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.5, constant: -half),
        ])
    }

    // MARK: - Helpers

    private func setAspectRatio(_ ratio: CGFloat) {
        aspectConstraint = containerView.heightAnchor.constraint(
            equalTo: containerView.widthAnchor,
            multiplier: 1.0 / ratio
        )
        aspectConstraint?.priority = .defaultHigh
        aspectConstraint?.isActive = true
    }

    private func makeBannerImageView(url: URL) -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .primaryLight
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.loadImage(from: url)
        return iv
    }
}
