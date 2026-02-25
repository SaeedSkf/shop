import UIKit
import ObjectiveC

extension UIImageView {

    private static var taskKey: UInt8 = 0
    private static var urlKey: UInt8 = 0

    private var loadingTask: Task<Void, Never>? {
        get { objc_getAssociatedObject(self, &Self.taskKey) as? Task<Void, Never> }
        set { objc_setAssociatedObject(self, &Self.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var currentURL: URL? {
        get { objc_getAssociatedObject(self, &Self.urlKey) as? URL }
        set { objc_setAssociatedObject(self, &Self.urlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        cancelImageLoad()
        currentURL = url
        image = placeholder

        loadingTask = Task { [weak self] in
            do {
                guard let loaded = try await ImageLoader.shared.image(for: url) else { return }
                guard !Task.isCancelled else { return }
                await MainActor.run { [weak self] in
                    guard self?.currentURL == url else { return }
                    self?.image = loaded
                }
            } catch {
                // Cancelled or network failure — keep placeholder
            }
        }
    }

    func cancelImageLoad() {
        loadingTask?.cancel()
        loadingTask = nil
        currentURL = nil
    }
}
