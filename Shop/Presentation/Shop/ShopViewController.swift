import UIKit
import Combine

final class ShopViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: ShopViewModel
    private var cancellables = Set<AnyCancellable>()
    private var sections: [any ShopSectionSnapshotProviding] = []
    private var expandedFAQItems = Set<String>()

    private lazy var collectionView = makeCollectionView()
    private lazy var dataSource = makeDataSource(for: collectionView)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let searchController = UISearchController(searchResultsController: nil)

    private let errorImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 48)
        let iv = UIImageView(image: UIImage(systemName: "wifi.exclamationmark", withConfiguration: config))
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .appSubheadline
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var retryButton: UIButton = {
        var config = UIButton.Configuration.borderedProminent()
        config.title = NSLocalizedString("retry", comment: "")
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        return button
    }()

    private lazy var errorContainerView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [errorImageView, errorLabel, retryButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isHidden = true
        return stack
    }()

    // MARK: - Init

    init(viewModel: ShopViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadSections()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("shop_title", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true

        setupSearchController()
        setupCollectionView()
        setupActivityIndicator()
        setupErrorView()
    }

    private func setupSearchController() {
        searchController.searchBar.placeholder = NSLocalizedString("search_placeholder", comment: "")
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupErrorView() {
        view.addSubview(errorContainerView)
        NSLayoutConstraint.activate([
            errorContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            errorContainerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
        ])
    }

    // MARK: - Collection View

    private func makeCollectionView() -> UICollectionView {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        return cv
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 24

        return UICollectionViewCompositionalLayout(sectionProvider: {
            [weak self] (sectionIndex: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self,
                  let sectionId = self.dataSource.sectionIdentifier(for: sectionIndex),
                  let layoutSection = ShopLayoutFactory.layoutSection(for: sectionId, environment: environment) else
            { return nil }

            if case .banner = sectionId {
                updatePageIndicatorView(sectionIndex: sectionIndex, layoutSection: layoutSection)
            }
            
            return layoutSection
        }, configuration: config)
    }
    
    private func updatePageIndicatorView(sectionIndex: Int, layoutSection: NSCollectionLayoutSection) {
        layoutSection.visibleItemsInvalidationHandler = { [weak self] _, offset, env in
            guard let self, env.container.contentSize.width > 0 else { return }
            let page = Int(round(offset.x / env.container.contentSize.width))
            guard let indicator = self.collectionView.supplementaryView(
                forElementKind: ShopLayoutFactory.pageIndicatorKind,
                at: IndexPath(item: 0, section: sectionIndex)
            ) as? PageIndicatorReusableView else { return }
            indicator.setCurrentPage(page, animated: true)
        }
    }

    // MARK: - Data Source

    private func makeDataSource(
        for collectionView: UICollectionView
    ) -> UICollectionViewDiffableDataSource<ShopSectionIdentifier, ShopItemIdentifier> {
        let bannerReg = UICollectionView.CellRegistration<BannerCell, ShopItemIdentifier> {
            (cell: BannerCell, _: IndexPath, item: ShopItemIdentifier) in
            if case .banner(let banner) = item { cell.configure(with: banner) }
        }

        let categoryReg = UICollectionView.CellRegistration<CategoryCell, ShopItemIdentifier> {
            (cell: CategoryCell, _: IndexPath, item: ShopItemIdentifier) in
            if case .category(let category) = item { cell.configure(with: category) }
        }

        let shopReg = UICollectionView.CellRegistration<ShopGridCell, ShopItemIdentifier> {
            (cell: ShopGridCell, _: IndexPath, item: ShopItemIdentifier) in
            if case .shop(let shop) = item { cell.configure(with: shop) }
        }

        let fixedBannerReg = UICollectionView.CellRegistration<FixedBannerCell, ShopItemIdentifier> {
            [weak self] (cell: FixedBannerCell, _: IndexPath, item: ShopItemIdentifier) in
            if case .fixedBanners(let id) = item,
               let section = self?.findSection(id: id),
               let banners = section.fixedBannerData {
                cell.configure(with: banners)
            }
        }

        let faqReg = UICollectionView.CellRegistration<FAQCell, ShopItemIdentifier> {
            [weak self] (cell: FAQCell, _: IndexPath, item: ShopItemIdentifier) in
            if case .faq(let faqItem) = item {
                let isExpanded = self?.expandedFAQItems.contains(faqItem.id) ?? false
                cell.configure(with: faqItem, isExpanded: isExpanded)
            }
        }

        let ds = UICollectionViewDiffableDataSource<ShopSectionIdentifier, ShopItemIdentifier>(
            collectionView: collectionView
        ) { (collectionView: UICollectionView, indexPath: IndexPath, item: ShopItemIdentifier) -> UICollectionViewCell? in
            switch item {
            case .banner:
                return collectionView.dequeueConfiguredReusableCell(using: bannerReg, for: indexPath, item: item)
            case .category:
                return collectionView.dequeueConfiguredReusableCell(using: categoryReg, for: indexPath, item: item)
            case .shop:
                return collectionView.dequeueConfiguredReusableCell(using: shopReg, for: indexPath, item: item)
            case .fixedBanners:
                return collectionView.dequeueConfiguredReusableCell(using: fixedBannerReg, for: indexPath, item: item)
            case .faq:
                return collectionView.dequeueConfiguredReusableCell(using: faqReg, for: indexPath, item: item)
            }
        }

        let headerReg = UICollectionView.SupplementaryRegistration<SectionHeaderReusableView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] (view: SectionHeaderReusableView, _: String, indexPath: IndexPath) in
            guard let self,
                  let sectionId = self.dataSource.sectionIdentifier(for: indexPath.section),
                  let section = self.findSection(id: sectionId.sectionId),
                  let title = section.headerTitle else { return }
            view.configure(title: title, actionTitle: section.headerActionTitle)
        }

        let indicatorReg = UICollectionView.SupplementaryRegistration<PageIndicatorReusableView>(
            elementKind: ShopLayoutFactory.pageIndicatorKind
        ) { [weak self] (view: PageIndicatorReusableView, _: String, indexPath: IndexPath) in
            guard let self,
                  let sectionId = self.dataSource.sectionIdentifier(for: indexPath.section),
                  let section = self.findSection(id: sectionId.sectionId),
                  let pageCount = section.pageIndicatorCount else { return }
            view.configure(numberOfPages: pageCount, currentPage: 0)
        }

        ds.supplementaryViewProvider = {
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerReg, for: indexPath)
            case ShopLayoutFactory.pageIndicatorKind:
                return collectionView.dequeueConfiguredReusableSupplementary(using: indicatorReg, for: indexPath)
            default:
                return nil
            }
        }

        return ds
    }

    // MARK: - Snapshot

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<ShopSectionIdentifier, ShopItemIdentifier>()
        for section in sections {
            section.appendToSnapshot(&snapshot)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] domainSections in
                self?.sections = domainSections.compactMap { $0 as? (any ShopSectionSnapshotProviding) }
                self?.applySnapshot()
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.updateErrorState(error)
            }
            .store(in: &cancellables)
    }

    // MARK: - State Updates

    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            collectionView.isHidden = true
            errorContainerView.isHidden = true
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func updateErrorState(_ errorMessage: String?) {
        if let errorMessage {
            errorLabel.text = errorMessage
            errorContainerView.isHidden = false
            collectionView.isHidden = true
        } else {
            errorContainerView.isHidden = true
            collectionView.isHidden = false
        }
    }

    // MARK: - Helpers

    private func findSection(id: String) -> (any ShopSectionSnapshotProviding)? {
        sections.first { $0.id == id }
    }

    @objc private func retryTapped() {
        viewModel.loadSections()
    }

    private func toggleFAQ(_ item: FAQItem) {
        if expandedFAQItems.contains(item.id) {
            expandedFAQItems.remove(item.id)
        } else {
            expandedFAQItems.insert(item.id)
        }

        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems([.faq(item)])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate

extension ShopViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        if case .faq(let faqItem) = item {
            toggleFAQ(faqItem)
        }
    }
}
