import Combine
import Foundation

@MainActor
final class SearchViewModel {

    @Published var searchText = ""
    @Published private(set) var searchResults: [ShopItem] = []
    @Published private(set) var recentSearches: [String] = []
    @Published private(set) var showEmptyState = false

    private let allShops: [ShopItem]
    private let searchShopsUseCase: SearchShopsUseCase
    private let manageHistoryUseCase: ManageSearchHistoryUseCase
    private var cancellables = Set<AnyCancellable>()

    private static let debounceSeconds = 0.3
    private static let minDisplayCharacters = 3

    init(
        shops: [ShopItem],
        searchShopsUseCase: SearchShopsUseCase,
        manageHistoryUseCase: ManageSearchHistoryUseCase
    ) {
        self.allShops = shops
        self.searchShopsUseCase = searchShopsUseCase
        self.manageHistoryUseCase = manageHistoryUseCase
        setupSearchPipeline()
        loadRecentSearches()
    }

    func loadRecentSearches() {
        Task {
            recentSearches = await manageHistoryUseCase.fetchRecentSearches()
        }
    }

    func deleteSearch(term: String) {
        Task {
            await manageHistoryUseCase.deleteSearch(term: term)
            recentSearches = await manageHistoryUseCase.fetchRecentSearches()
        }
    }

    func deleteAllSearches() {
        Task {
            await manageHistoryUseCase.deleteAllSearches()
            recentSearches = []
        }
    }

    func selectRecentSearch(_ term: String) {
        searchText = term
    }

    // MARK: - Private

    private func setupSearchPipeline() {
        $searchText
            .debounce(for: .seconds(Self.debounceSeconds), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)

        Task {
            let results = await searchShopsUseCase.execute(query: query, in: allShops)
            searchResults = results
            showEmptyState = trimmed.count >= Self.minDisplayCharacters && results.isEmpty

            if !results.isEmpty {
                recentSearches = await manageHistoryUseCase.fetchRecentSearches()
            }
        }
    }
}
