# Project Technical Overview

**Project:** Shop (Ewano / Avano shop discovery app)  
**Platform:** iOS (UIKit)  
**Language:** Swift

---

## 1. Project Overview

### Short description
The Shop project is an iOS application for discovering and browsing online shops and categories. It presents a configurable home screen built from remote JSON (banners, categories, shop grid, fixed banners, FAQ) and provides search over shops with persistent recent-search history.

### Main business goal
- **Consume a remote shop configuration** (`/ebcom/shop.json`) and render a dynamic, section-based home UI (banners, categories, online shops grid, fixed banners, FAQ).
- **Enable search** over the list of shops (by title and tags) with **recent searches** persisted locally and RTL-friendly UX (Persian).

---

## 2. Architecture

### Architectural style
The app follows **Clean Architecture** with clear layer boundaries and **MVVM** at the presentation level:

- **Domain:** Protocols and models; no dependencies on UI or infrastructure.
- **Data:** Implementations of domain repositories; DTOs, data sources, mappers; depends only on Domain + infrastructure protocols (e.g. `NetworkClient`).
- **Infrastructure:** Networking, persistence (SwiftData), DI (Swinject), shared utilities (typography, colors, image loading).
- **Presentation:** ViewModels (state + use case calls), ViewControllers, routing, layout (compositional layout), and UI-specific identifiers for the diffable data source.

### Layer breakdown and responsibilities

| Layer | Responsibility | Key types |
|-------|----------------|-----------|
| **Domain** | Business entities, repository/use case protocols, section types | `ShopSection`, `Banner`, `ShopItem`, `ShopRepository`, `FetchShopUseCase`, `SearchHistoryRepository`, `ManageSearchHistoryUseCase`, `SearchShopsUseCase` |
| **Data** | Remote/local data access, DTOs → domain mapping | `ShopResponseDTO`, `DefaultShopRepository`, `DefaultSectionFactory`, `ShopRemoteDataSource`, `SearchHistoryLocalDataSource`, `RecentSearchEntity` |
| **Infrastructure** | HTTP client, SwiftData container, DI container, fonts, colors, image loading | `NetworkClient`, `URLSessionNetworkClient`, `AppContainer`, `ShopAssembly`, `SearchAssembly`, `AppTypography`, `UIImageView+Loading` |
| **Presentation** | Screens, ViewModels, routing, compositional layout, diffable data source | `ShopViewController`, `ShopViewModel`, `SearchViewController`, `SearchViewModel`, `ShopRouter`, `ShopLayoutFactory`, `ShopSectionIdentifier`, `ShopItemIdentifier` |

### Dependency direction
Dependencies point **inward** toward the domain:

- **Presentation** → Domain (ViewModels depend on use case protocols) and Infrastructure only for DI resolution at composition root (`SceneDelegate`).
- **Data** → Domain (repositories return domain types); Data uses Infrastructure (e.g. `NetworkClient`) via protocols.
- **Domain** has **no** imports of UIKit, SwiftData, or Swinject; it stays framework-agnostic.

The composition root is `SceneDelegate` and `AppContainer`: they resolve `ShopViewModel`, `ShopRouter`, and construct `ShopViewController`. Search screen is created by `DefaultShopRouter` with `SearchViewModel` and `SearchViewController` (router holds use cases and builds the VM/VC).

---

## 3. Project Structure

```
Shop/
├── AppDelegate.swift                    # RTL semantic content
├── SceneDelegate.swift                  # Window, nav, DI resolution for root VC
├── Domain/
│   ├── Models/                         # Entities & section types (Banner, Category, ShopItem, *Section, FAQItem)
│   ├── Repositories/                   # ShopRepository, SearchHistoryRepository (protocols)
│   └── Usecases/                       # FetchShopUseCase, SearchShopsUseCase, ManageSearchHistoryUseCase
├── Data/
│   ├── DTOs/                           # ShopResponseDTO, HomeSectionDTO, etc.
│   ├── Entities/                       # SwiftData model (RecentSearchEntity)
│   ├── LocalDatasources/               # SearchHistoryLocalDataSource + actor implementation
│   ├── Mappers/                        # SectionFactory (DTO → [ShopSection])
│   ├── RemoteDatasources/              # ShopRemoteDataSource
│   └── Repositories/                   # DefaultShopRepository, DefaultSearchHistoryRepository
├── Infrastructure/
│   ├── DI/                             # AppContainer, ShopAssembly, SearchAssembly (Swinject)
│   ├── Networking/                     # NetworkClient, APIRequest, APIError, URLSession impl
│   ├── Persistance/                    # ModelContainer+Factory (SwiftData schema)
│   └── Utilities/                      # AppConfig, AppTypography, UIColor+App, UIImageView+Loading
└── Presentation/
    ├── Navigation/                     # DefaultShopRouter
    ├── Search/                         # SearchViewController, SearchViewModel, cells (SearchResult, RecentSearchChip)
    └── Shop/
        ├── Cells/                      # BannerCell, CategoryCell, ShopGridCell, FixedBannerCell, FAQCell, SectionHeader, PageIndicator
        ├── Layout/                     # ShopLayoutFactory (compositional layout per section type)
        ├── Models/                     # ShopSectionIdentifier, ShopItemIdentifier, ShopSectionSnapshotProviding
        ├── Views/                      # SearchBarButton
        ├── ShopViewController.swift
        ├── ShopViewModel.swift
        └── ShopRouter.swift
```

- **Domain:** Pure business rules and types; no UI or I/O implementation.
- **Data:** All I/O and mapping; DTOs and SwiftData entity live here; repository implementations depend on data sources and mappers.
- **Infrastructure:** Cross-cutting (network, persistence, DI, shared UI utilities).
- **Presentation:** Feature-based (Shop vs Search) with shared navigation and layout; snapshot building is done via protocol extensions on domain section types (`ShopSectionSnapshotProviding`).

---

## 4. Design Patterns Used

| Pattern | Where / how |
|---------|-------------|
| **Dependency Injection** | Swinject `Container` in `AppContainer`; `ShopAssembly` and `SearchAssembly` register implementations; `resolve(_:)` used in `SceneDelegate` and inside assemblies. No singletons for core services. |
| **Repository** | `ShopRepository` (fetch sections from remote + mapper), `SearchHistoryRepository` (recent searches); domain depends on abstractions, Data provides concrete implementations. |
| **Use Case** | `FetchShopUseCase`, `SearchShopsUseCase`, `ManageSearchHistoryUseCase` encapsulate single operations; ViewModels and Router depend on these protocols. |
| **Protocol-oriented design** | Domain defines protocols (`ShopRepository`, `FetchShopUseCase`, `SearchHistoryRepository`, etc.); concrete types in Data/Infrastructure. |
| **Factory / Mapper** | `SectionFactory` turns `ShopResponseDTO` into `[any ShopSection]` using a type-based dispatch (`BANNER`, `FIXEDBANNER`, `CATEGORY`, `SHOP`) and lookups for banners/categories/shops/tags. |
| **Router** | `ShopRouter` protocol and `DefaultShopRouter` handle navigation to Search; router owns use cases and constructs `SearchViewModel` + `SearchViewController`. |
| **Snapshot-providing protocol** | `ShopSectionSnapshotProviding` extends domain section types to append sections/items to `NSDiffableDataSourceSnapshot` with section/item identifiers; keeps diffable data source logic out of the ViewController. |
| **Observer (reactive)** | ViewModels expose `@Published`; ViewControllers subscribe with Combine (`sink`, `receive(on: DispatchQueue.main)`). Search uses debounced `$searchText` pipeline. |

---

## 5. Technologies & Frameworks

| Area | Choice | Notes |
|------|--------|------|
| **UI** | UIKit | Programmatic UI; no storyboards. `UICollectionViewCompositionalLayout` + `UICollectionViewDiffableDataSource`. |
| **Networking** | URLSession + async/await | Generic `NetworkClient` with `APIRequest`; `URLSessionNetworkClient` performs request and JSON decode; errors wrapped in `APIError`. |
| **Persistence** | SwiftData | `RecentSearchEntity` (@Model); `ModelContainer` created via factory (`makeAppContainer`, `makeInMemoryContainer`); local data source is a `@ModelActor` actor. |
| **Dependency Injection** | Swinject | Container + assemblies; protocol-based registration; `resolve` at composition root (and inside router for Search). |
| **Concurrency** | async/await, MainActor, Combine | Use cases and repositories are async; ViewModels use `Task { @MainActor }` or `@MainActor` class; Combine for reactive bindings and debounce. |
| **Third-party** | Swinject (SPM) | Only external dependency; SwiftData and Combine are system frameworks. |

---

## 6. Data Flow Explanation

### Shop (home) screen
1. **UI:** `ShopViewController` is created with `ShopViewModel` and `ShopRouter` (resolved from `AppContainer` in `SceneDelegate`).
2. **Trigger:** `viewDidLoad` calls `viewModel.loadSections()`.
3. **ViewModel:** `ShopViewModel.loadSections()` sets `isLoading = true`, then `Task { @MainActor }` calls `fetchShopUseCase.execute()`.
4. **Use case:** `DefaultFetchShopUseCase.execute()` calls `repository.fetchSections()`.
5. **Repository:** `DefaultShopRepository.fetchSections()` calls `remoteDataSource.fetchShopResponse()` (returns `ShopResponseDTO`), then `sectionFactory.makeSections(from:)` → `[any ShopSection]`.
6. **Back to ViewModel:** On success, `sections` is set; on failure, `errorMessage` is set. `isLoading = false`. All on MainActor.
7. **UI:** ViewController binds to `viewModel.$sections` (and loading/error); on new sections it builds a snapshot by iterating `sections.compactMap { $0 as? ShopSectionSnapshotProviding }` and each section’s `appendToSnapshot`; applies snapshot to diffable data source. Layout is provided by `ShopLayoutFactory.layoutSection(for:environment:)` using `ShopSectionIdentifier` from the data source.

### Search
1. **Entry:** User taps search bar → `ShopRouter.showSearch(from:shops:)` → router creates `SearchViewModel` (with `allShops` and use cases) and `SearchViewController`, then pushes.
2. **Input:** User types → `SearchViewModel` receives updates to `searchText`; Combine pipeline debounces and calls `performSearch(query:)`.
3. **Search:** `performSearch` runs `searchShopsUseCase.execute(query:in: allShops)` (filters by title/tags, optionally saves to history); result sets `searchResults` and `showEmptyState`. Recent list comes from `manageHistoryUseCase.fetchRecentSearches()` (backed by SwiftData via repository).

### Role summary
- **ViewModel:** Holds UI state (`@Published`), calls use cases in `Task`/async, ensures MainActor for state updates.
- **Use cases:** Single responsibility (fetch sections, search shops, manage history); no UI or data source details.
- **Repository:** Single entry for a data area (shop remote + mapper, search history local); returns domain types.

---

## 7. Concurrency & Threading Model

- **MainActor:** `ShopViewModel` updates (e.g. `loadSections`) run in `Task { @MainActor [weak self] in ... }`. `SearchViewModel` is `@MainActor` and updates `searchResults`/`recentSearches` from async `performSearch`/history calls (implicitly on MainActor).
- **async/await:** Used end-to-end for network (`NetworkClient.request`), repository (`fetchSections`, `fetchRecentSearches`, etc.), use cases, and ViewModel methods that call them.
- **Sendable:** `SearchHistoryRepository` and `SearchHistoryLocalDataSource` are marked `Sendable`; persistence is isolated in an actor.
- **Actor:** `DefaultDataSearchHistoryLocalDataSource` is a `@ModelActor` actor; all SwiftData access is on that actor; repository and use cases call it with `await` and do not touch the model context.
- **Combine:** Used on the main thread for ViewModel → ViewController binding and for debounced search; no custom schedulers beyond `DispatchQueue.main` where used.
- **Image loading:** `UIImageView.loadImage(from:)` uses a fire-and-forget `Task` and updates image on `MainActor.run`; uses `tag` to avoid applying stale images.

No Swift 6 strict concurrency or full Sendable audit is evident; the project uses MainActor and one actor for persistence in a consistent way.

---

## 8. Scalability & Maintainability Considerations

- **Testing:** Domain and use cases depend only on protocols and are easy to unit test with mocks. Repository and data source protocols allow replacing network/SwiftData in tests. Current test target contains only placeholder tests; the structure is test-friendly.
- **Separation of concerns:** Domain has no UI or I/O; Data does not know about ViewModels or screens; Presentation depends on domain abstractions and receives implementations via DI.
- **Extensibility:** New section types can be added by (1) domain model + `ShopSection` conformance, (2) `SectionFactory` branch and mapping, (3) `ShopSectionSnapshotProviding` extension, (4) layout in `ShopLayoutFactory`, (5) cell registration and identifier in `ShopViewController`. Feature assemblies (Shop, Search) keep registration localized.
- **Single responsibility:** Thin use cases; repositories orchestrate one data source (or mapper); ViewModels coordinate use cases and state; ViewControllers handle layout and binding only.

---

## 9. Notable Engineering Decisions

- **Section-driven UI from JSON:** Home sections (BANNER, FIXEDBANNER, CATEGORY, SHOP) are defined in `home.sections` with type + list of IDs; `SectionFactory` resolves IDs against DTOs and builds a polymorphic `[any ShopSection]` with a single pass and lookups. This keeps the domain flexible and the UI data-driven.
- **Unique diffable identifiers for banners:** To support multiple banner sections with the same banner payload, item identifiers use `banner(sectionId: String, banner: Banner)` so that the same `Banner` in different sections gets different identities and avoids “identifier already exists” and wrong section content.
- **Snapshot building via protocol extension:** Each section type (e.g. `BannerSection`, `ShopGridSection`) conforms to `ShopSectionSnapshotProviding` and implements `appendToSnapshot` and section/item identifier mapping. The ViewController does not switch on section types; it iterates and calls `appendToSnapshot`, keeping snapshot logic close to the domain model.
- **Compositional layout per section type:** `ShopLayoutFactory` returns different `NSCollectionLayoutSection` for banner (horizontal paging + footer for page indicator), category (horizontal scroll), shop grid (4 columns with computed item width), fixed banner, and FAQ. Section provider uses `dataSource.sectionIdentifier(for: sectionIndex)` so layout is driven by the same identifiers as the snapshot.
- **Router builds Search screen:** Search does not use a separate assembly for the screen; `DefaultShopRouter` resolves search/history use cases from the container and constructs `SearchViewModel` and `SearchViewController`. This keeps Search as a pushed flow owned by Shop’s navigation.
- **RTL and localization:** `UIView.appearance().semanticContentAttribute = .forceRightToLeft`; back chevron uses `.chevron.right` for RTL; strings via `NSLocalizedString` and `Localizable.strings`.
- **SwiftData + ModelActor:** Recent search persistence uses SwiftData with an actor-based local data source and `Sendable` protocol for clear concurrency boundaries.

---

## 10. Summary

The project demonstrates **strong structural discipline**: Clean Architecture with a clear Domain at the center, Repository and Use Case patterns, protocol-based DI with Swinject, and a data-driven home screen built from a single remote configuration. Presentation uses modern UIKit (compositional layout, diffable data source) and keeps section-to-UI mapping in one place (layout factory + snapshot-providing extensions). Concurrency is handled with async/await, MainActor, and one actor for persistence, and the design avoids duplicate diffable identifiers and keeps the domain free of framework dependencies. The codebase is consistent, readable, and built for extension (new section types, new screens) and for testing (protocols and composition root).

---

## Code Quality & Engineering Maturity Assessment

### Estimated level: **Mid to Senior**

**Reasoning:**

- **Code consistency:** Naming is uniform (e.g. `Default*` for implementations, protocols without prefix); MARK usage and file organization are consistent; Swift idioms (value types, enums, protocol extensions) are used appropriately.
- **Separation of responsibilities:** Domain is pure; Data is the only place that knows DTOs and persistence; Presentation is limited to UI and ViewModel coordination. Use cases and repositories have narrow, well-defined roles.
- **Abstraction quality:** Domain protocols (`ShopRepository`, `FetchShopUseCase`, `SearchHistoryRepository`, etc.) are small and stable; implementations live in Data/Infrastructure. The snapshot-providing protocol keeps diffable logic attached to domain section types without polluting the ViewController.
- **SOLID:** Single responsibility (use cases, repositories, factories); Open/closed (new sections via new types and extensions); Liskov (implementations match protocol contracts); Interface segregation (focused protocols); Dependency inversion (ViewModels and Router depend on abstractions, resolved at composition root).
- **Error handling:** Network/repository errors surface as thrown errors; ViewModel catches and sets `errorMessage`; no silent failures. Decoding and network errors are wrapped in `APIError`. Persistence uses `try?` in the actor (could be refined to propagate errors if needed).
- **Testability:** High for domain and use cases (inject mocks); repositories and data sources are mockable. No tests implemented yet, but the architecture does not block unit or integration tests.
- **Dependency inversion:** Implemented: Domain defines interfaces; Data and Infrastructure implement them; Presentation and composition root depend on protocols; Swinject resolves concrete types in one place.
- **Domain purity:** Domain has no UIKit, SwiftData, or Swinject; only Foundation and domain types. Section types are simple value types; protocols are in Domain.
- **Data isolation:** DTOs and SwiftData entity stay in Data; mapping is in Data (`SectionFactory`); domain models have no persistence or API attributes.
- **Concurrency:** MainActor and one `@ModelActor` actor are used correctly; protocols that cross actor boundaries are `Sendable` where appropriate. No obvious data races; image loading uses a simple guard to avoid applying outdated images.

**Gaps that prevent “Senior+” without more work:** Test coverage is placeholder only; no error types or user-facing messages beyond `localizedDescription`; image loading has no caching or cancellation beyond the tag check; and Swift 6 strict concurrency is not fully applied. Those are natural next steps rather than architectural flaws.

Overall, the project is suitable for a **technical interviewer** to see Clean Architecture, clear layers, protocol-based DI, modern UIKit (compositional layout, diffable data source), async/await and actor usage, and thoughtful handling of dynamic sections and RTL, with a **Mid to Senior** level of engineering maturity and consistency.
