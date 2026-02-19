import UIKit

extension UIImageView {

    func loadImage(from url: URL) {
        let urlHash = url.absoluteString.hashValue
        tag = urlHash

        Task {
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let loaded = UIImage(data: data) else { return }

            await MainActor.run { [weak self] in
                guard self?.tag == urlHash else { return }
                self?.image = loaded
            }
        }
    }
}
