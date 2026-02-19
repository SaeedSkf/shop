import Foundation
import SwiftData

extension ModelContainer {

    static func makeAppContainer() -> ModelContainer {
        let schema = Schema([
            RecentSearchEntity.self
        ])

        let configuration = ModelConfiguration(schema: schema)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    static func makeInMemoryContainer() -> ModelContainer {
        let schema = Schema([
            RecentSearchEntity.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try! ModelContainer(for: schema, configurations: [configuration])
    }
}
