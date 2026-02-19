import UIKit

final class SearchBarButton: UIControl {

    private let iconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass", withConfiguration: config))
        iv.tintColor = .secondaryLabel
        iv.setContentHuggingPriority(.required, for: .horizontal)
        return iv
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("search_placeholder", comment: "")
        label.font = .appSubheadline
        label.textColor = .placeholderText
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = .white
        layer.borderColor = UIColor.styleInfo.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10

        let stack = UIStackView(arrangedSubviews: [iconView, placeholderLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.alpha = self.isHighlighted ? 0.6 : 1.0
            }
        }
    }
}
