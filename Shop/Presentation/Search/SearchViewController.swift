import UIKit
import Combine

final class SearchViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: SearchViewModel
    private var cancellables = Set<AnyCancellable>()
    private var chipsHeightConstraint: NSLayoutConstraint!

    // MARK: - UI Elements

    private let searchContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.primaryPersian.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let searchIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass", withConfiguration: config))
        iv.tintColor = .secondaryLabel
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.setContentCompressionResistancePriority(.required, for: .horizontal)
        return iv
    }()

    private let searchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = NSLocalizedString("search_placeholder", comment: "")
        tf.font = .appSubheadline
        tf.textAlignment = .right
        tf.returnKeyType = .search
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        return tf
    }()

    private lazy var clearButton: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.tintColor = .primaryPersian
        button.isHidden = true
        button.addTarget(self, action: #selector(clearSearchTapped), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()

    private let recentSearchesContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let recentHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("recent_searches", comment: "")
        label.font = .appHeadline
        label.textColor = .label
        return label
    }()

    private lazy var deleteAllButton: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let image = UIImage(systemName: "trash", withConfiguration: config)
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.tintColor = .secondaryLabel
        button.addTarget(self, action: #selector(deleteAllTapped), for: .touchUpInside)
        return button
    }()

    private lazy var chipsCollectionView: UICollectionView = {
        let layout = makeChipsLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.semanticContentAttribute = .forceRightToLeft
        cv.register(RecentSearchChipCell.self, forCellWithReuseIdentifier: RecentSearchChipCell.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private lazy var resultsTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.reuseIdentifier)
        tv.dataSource = self
        tv.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 80)
        tv.keyboardDismissMode = .onDrag
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isHidden = true
        return tv
    }()

    private let searchingHintLabel: UILabel = {
        let label = UILabel()
        label.font = .appSubheadline
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var searchingHintView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.isHidden = true

        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass", withConfiguration: config))
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit

        let stack = UIStackView(arrangedSubviews: [imageView, searchingHintLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 60),
        ])

        return container
    }()

    private let emptyStateView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.isHidden = true

        let config = UIImage.SymbolConfiguration(pointSize: 48)
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass", withConfiguration: config))
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = NSLocalizedString("search_no_results", comment: "")
        label.font = .appSubheadline
        label.textColor = .secondaryLabel
        label.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        return container
    }()

    // MARK: - Init

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateChipsHeight()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("search_title", comment: "")
        navigationItem.largeTitleDisplayMode = .never

        setupSearchBar()
        setupRecentSearches()
        setupSearchingHint()
        setupResultsTable()
        setupEmptyState()
        setupTextFieldAction()
    }

    private func makeChipsLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(80),
            heightDimension: .absolute(36)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(36)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func setupSearchBar() {
        let searchStack = UIStackView(arrangedSubviews: [searchIcon, searchTextField, clearButton])
        searchStack.axis = .horizontal
        searchStack.spacing = 8
        searchStack.alignment = .center
        searchStack.translatesAutoresizingMaskIntoConstraints = false

        searchContainerView.addSubview(searchStack)
        view.addSubview(searchContainerView)

        NSLayoutConstraint.activate([
            searchContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchContainerView.heightAnchor.constraint(equalToConstant: 48),

            searchStack.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchStack.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            searchStack.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 12),
            searchStack.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -12),
        ])
    }

    private func setupRecentSearches() {
        let headerStack = UIStackView(arrangedSubviews: [recentHeaderLabel, UIView(), deleteAllButton])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        recentSearchesContainer.addSubview(headerStack)
        recentSearchesContainer.addSubview(chipsCollectionView)
        view.addSubview(recentSearchesContainer)

        chipsHeightConstraint = chipsCollectionView.heightAnchor.constraint(equalToConstant: 120)

        NSLayoutConstraint.activate([
            recentSearchesContainer.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 20),
            recentSearchesContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recentSearchesContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            headerStack.topAnchor.constraint(equalTo: recentSearchesContainer.topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: recentSearchesContainer.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: recentSearchesContainer.trailingAnchor, constant: -16),

            chipsCollectionView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 12),
            chipsCollectionView.leadingAnchor.constraint(equalTo: recentSearchesContainer.leadingAnchor, constant: 16),
            chipsCollectionView.trailingAnchor.constraint(equalTo: recentSearchesContainer.trailingAnchor, constant: -16),
            chipsHeightConstraint,
            chipsCollectionView.bottomAnchor.constraint(equalTo: recentSearchesContainer.bottomAnchor),
        ])
    }

    private func setupSearchingHint() {
        view.addSubview(searchingHintView)

        NSLayoutConstraint.activate([
            searchingHintView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            searchingHintView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchingHintView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchingHintView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupResultsTable() {
        view.addSubview(resultsTableView)

        NSLayoutConstraint.activate([
            resultsTableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 8),
            resultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupEmptyState() {
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupTextFieldAction() {
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$recentSearches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] searches in
                guard let self else { return }
                chipsCollectionView.reloadData()
                if searches.isEmpty {
                    recentSearchesContainer.isHidden = true
                } else {
                    view.setNeedsLayout()
                    view.layoutIfNeeded()
                    updateChipsHeight()
                    recentSearchesContainer.isHidden = false
                }
            }
            .store(in: &cancellables)

        viewModel.$searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.resultsTableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$showEmptyState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showEmpty in
                self?.emptyStateView.isHidden = !showEmpty
            }
            .store(in: &cancellables)

        viewModel.$searchText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self else { return }
                if self.searchTextField.text != text {
                    self.searchTextField.text = text
                }
                self.updateContentVisibility(for: text)
            }
            .store(in: &cancellables)
    }

    // MARK: - State

    private func updateContentVisibility(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        let charCount = trimmed.count
        let hasText = charCount > 0
        let isSearchable = charCount >= 3

        clearButton.isHidden = !hasText
        recentSearchesContainer.isHidden = hasText || viewModel.recentSearches.isEmpty
        resultsTableView.isHidden = !isSearchable
        searchingHintView.isHidden = !hasText || isSearchable

        if hasText && !isSearchable {
            searchingHintLabel.text = String(
                format: NSLocalizedString("search_hint_format", comment: ""),
                trimmed
            )
        }
    }

    private func updateChipsHeight() {
        let height = chipsCollectionView.collectionViewLayout.collectionViewContentSize.height
        if height > 0 && chipsHeightConstraint.constant != height {
            chipsHeightConstraint.constant = height
        }
    }

    // MARK: - Actions

    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.searchText = textField.text ?? ""
    }

    @objc private func clearSearchTapped() {
        viewModel.searchText = ""
        searchTextField.text = ""
    }

    @objc private func deleteAllTapped() {
        viewModel.deleteAllSearches()
    }
}

// MARK: - UICollectionViewDataSource & Delegate (Chips)

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.recentSearches.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecentSearchChipCell.reuseIdentifier,
            for: indexPath
        ) as! RecentSearchChipCell

        let term = viewModel.recentSearches[indexPath.item]
        cell.configure(with: term)
        cell.onDelete = { [weak self] in
            self?.viewModel.deleteSearch(term: term)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let term = viewModel.recentSearches[indexPath.item]
        viewModel.selectRecentSearch(term)
    }
}

// MARK: - UITableViewDataSource (Results)

extension SearchViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultCell.reuseIdentifier,
            for: indexPath
        ) as! SearchResultCell

        cell.configure(with: viewModel.searchResults[indexPath.row])
        return cell
    }
}
