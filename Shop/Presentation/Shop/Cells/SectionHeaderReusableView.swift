import UIKit

final class SectionHeaderReusableView: UICollectionReusableView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .appHeadline
        label.textColor = .boldGray
        return label
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .appCaption
        button.setTitleColor(.primaryPersian, for: .normal)
        button.isHidden = true
        return button
    }()

    private var actionHandler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [titleLabel, spacer, actionButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
    }

    func configure(title: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        titleLabel.text = title
        if let actionTitle {
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.isHidden = false
            actionHandler = action
        } else {
            actionButton.isHidden = true
            actionHandler = nil
        }
    }

    @objc private func actionTapped() {
        actionHandler?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        actionButton.isHidden = true
        actionHandler = nil
    }
}
