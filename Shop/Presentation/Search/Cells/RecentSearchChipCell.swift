import UIKit

final class RecentSearchChipCell: UICollectionViewCell {

    static let reuseIdentifier = "RecentSearchChipCell"

    var onDelete: (() -> Void)?

    private let clockIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90", withConfiguration: config))
        iv.tintColor = .secondaryLabel
        iv.setContentHuggingPriority(.required, for: .horizontal)
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .appCaption
        label.textColor = .label
        return label
    }()

    private lazy var stack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [clockIcon, titleLabel])
        s.axis = .horizontal
        s.spacing = 6
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 16
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
        ])
    }

    private func setupGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        contentView.addGestureRecognizer(longPress)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        onDelete?()
    }

    func configure(with term: String) {
        titleLabel.text = term
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        onDelete = nil
    }
}
