import Foundation
import SwiftData

protocol SearchHistoryLocalDataSource: Sendable {
    func fetchAll() async -> [String]
    func save(term: String) async
    func delete(term: String) async
    func deleteAll() async
}

@ModelActor
actor DefaultDataSearchHistoryLocalDataSource: SearchHistoryLocalDataSource {

    func fetchAll() async -> [String] {
        let descriptor = FetchDescriptor<RecentSearchEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let results = (try? modelContext.fetch(descriptor)) ?? []
        return results.map(\.term)
    }

    func save(term: String) async {
        let predicate = #Predicate<RecentSearchEntity> { $0.term == term }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1

        if let existing = try? modelContext.fetch(descriptor).first {
            existing.createdAt = .now
        } else {
            modelContext.insert(RecentSearchEntity(term: term))
        }

        try? modelContext.save()
    }

    func delete(term: String) async {
        let predicate = #Predicate<RecentSearchEntity> { $0.term == term }
        let descriptor = FetchDescriptor(predicate: predicate)

        if let entity = try? modelContext.fetch(descriptor).first {
            modelContext.delete(entity)
            try? modelContext.save()
        }
    }

    func deleteAll() async {
        try? modelContext.delete(model: RecentSearchEntity.self)
        try? modelContext.save()
    }
}
