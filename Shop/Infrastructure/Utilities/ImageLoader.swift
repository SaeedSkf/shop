import UIKit

actor ImageLoader {

    static let shared = ImageLoader()

    private let cache = NSCache<NSString, UIImage>()
    private var inflightTasks: [NSString: Task<UIImage?, Error>] = [:]

    init() {
        cache.countLimit = 200
        cache.totalCostLimit = 50 * 1024 * 1024
    }

    func image(for url: URL) async throws -> UIImage? {
        let key = url.absoluteString as NSString

        if let cached = cache.object(forKey: key) {
            return cached
        }

        if let existing = inflightTasks[key] {
            return try await existing.value
        }

        let task = Task<UIImage?, Error> {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        }

        inflightTasks[key] = task

        do {
            let image = try await task.value
            inflightTasks[key] = nil
            if let image {
                cache.setObject(image, forKey: key)
            }
            return image
        } catch {
            inflightTasks[key] = nil
            throw error
        }
    }

    func cancel(for url: URL) {
        let key = url.absoluteString as NSString
        inflightTasks[key]?.cancel()
        inflightTasks[key] = nil
    }
}
