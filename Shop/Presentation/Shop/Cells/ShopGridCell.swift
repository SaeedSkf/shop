import UIKit

final class ShopGridCell: UICollectionViewCell {

    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .deactiveGray
        view.layer.borderColor = UIColor.deviderGray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .appCaption
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [iconContainerView, titleLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        iconContainerView.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            iconContainerView.widthAnchor.constraint(equalTo: stack.widthAnchor),
            iconContainerView.heightAnchor.constraint(equalTo: iconContainerView.widthAnchor),

            iconImageView.topAnchor.constraint(equalTo: iconContainerView.topAnchor, constant: 12),
            iconImageView.leadingAnchor.constraint(equalTo: iconContainerView.leadingAnchor, constant: 12),
            iconImageView.trailingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: -12),
            iconImageView.bottomAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: -12),
        ])
    }

    func configure(with shop: ShopItem) {
        titleLabel.text = shop.title
        iconImageView.loadImage(from: shop.iconURL)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        titleLabel.text = nil
    }
}
