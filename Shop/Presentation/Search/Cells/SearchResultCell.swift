import UIKit

final class SearchResultCell: UITableViewCell {

    static let reuseIdentifier = "SearchResultCell"

    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.layer.borderColor = UIColor.separator.cgColor
        view.layer.borderWidth = 0.5
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
        label.font = .appHeadline
        label.textColor = .label
        return label
    }()

    private let tagsLabel: UILabel = {
        let label = UILabel()
        label.font = .appCaption
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let chevronImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "chevron.left", withConfiguration: config))
        iv.tintColor = .tertiaryLabel
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.setContentCompressionResistancePriority(.required, for: .horizontal)
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        selectionStyle = .none

        let textStack = UIStackView(arrangedSubviews: [titleLabel, tagsLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [iconContainerView, textStack, chevronImageView])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)
        iconContainerView.addSubview(iconImageView)

        let iconSize: CGFloat = 52

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            iconContainerView.widthAnchor.constraint(equalToConstant: iconSize),
            iconContainerView.heightAnchor.constraint(equalToConstant: iconSize),

            iconImageView.topAnchor.constraint(equalTo: iconContainerView.topAnchor, constant: 8),
            iconImageView.bottomAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: -8),
            iconImageView.leadingAnchor.constraint(equalTo: iconContainerView.leadingAnchor, constant: 8),
            iconImageView.trailingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: -8),
        ])
    }

    func configure(with shop: ShopItem) {
        titleLabel.text = shop.title
        tagsLabel.text = shop.tags.joined(separator: " · ")
        tagsLabel.isHidden = shop.tags.isEmpty
        iconImageView.loadImage(from: shop.iconURL)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        titleLabel.text = nil
        tagsLabel.text = nil
    }
}
