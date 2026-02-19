import UIKit

final class BannerCell: UICollectionViewCell {

    private let bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .quaternarySystemFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        contentView.addSubview(bannerImageView)
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bannerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bannerImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    func configure(with banner: Banner) {
        bannerImageView.loadImage(from: banner.imageURL)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        bannerImageView.image = nil
    }
}
