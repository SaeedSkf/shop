import UIKit

final class PageIndicatorReusableView: UICollectionReusableView {

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var dotViews: [UIView] = []
    private var currentPage = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(numberOfPages: Int, currentPage: Int) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dotViews.removeAll()

        for _ in 0..<numberOfPages {
            let dot = UIView()
            dot.layer.cornerRadius = 3
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.heightAnchor.constraint(equalToConstant: 6).isActive = true
            let width = dot.widthAnchor.constraint(equalToConstant: 6)
            width.isActive = true
            stackView.addArrangedSubview(dot)
            dotViews.append(dot)
        }

        self.currentPage = currentPage
        updateDots(animated: false)
    }

    func setCurrentPage(_ page: Int, animated: Bool = true) {
        guard page != currentPage, page >= 0, page < dotViews.count else { return }
        currentPage = page
        updateDots(animated: animated)
    }

    private func updateDots(animated: Bool) {
        let update = {
            for (index, dot) in self.dotViews.enumerated() {
                let isSelected = index == self.currentPage
                dot.backgroundColor = isSelected ? .primaryPersian : .lightestGray
                dot.constraints.first { $0.firstAttribute == .width }?.constant = isSelected ? 12 : 6
                dot.layer.cornerRadius = 3
            }
            self.stackView.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: update)
        } else {
            update()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dotViews.removeAll()
        currentPage = 0
    }
}
