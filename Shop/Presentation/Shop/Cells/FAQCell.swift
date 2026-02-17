import UIKit

final class FAQCell: UICollectionViewCell {

    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = .appSubheadline
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let chevronImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(font: .appCaption)
        let iv = UIImageView(image: UIImage(systemName: "chevron.down", withConfiguration: config))
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let answerLabel: UILabel = {
        let label = UILabel()
        label.font = .appCaption
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        let questionRow = UIStackView(arrangedSubviews: [questionLabel, chevronImageView])
        questionRow.axis = .horizontal
        questionRow.spacing = 8
        questionRow.alignment = .center

        let mainStack = UIStackView(arrangedSubviews: [questionRow, answerLabel])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)
        contentView.addSubview(separatorView)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: separatorView.topAnchor, constant: -12),

            chevronImageView.widthAnchor.constraint(equalToConstant: 16),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16),

            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    func configure(with item: FAQItem, isExpanded: Bool) {
        questionLabel.text = item.title
        answerLabel.text = item.answer
        answerLabel.isHidden = !isExpanded

        UIView.animate(withDuration: 0.25) {
            self.chevronImageView.transform = isExpanded
                ? CGAffineTransform(rotationAngle: .pi)
                : .identity
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        questionLabel.text = nil
        answerLabel.text = nil
        answerLabel.isHidden = true
        chevronImageView.transform = .identity
    }
}
