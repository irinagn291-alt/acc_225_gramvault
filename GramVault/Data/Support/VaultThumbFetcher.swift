// Role: three-tier product thumbnail: remote, shelf asset, placeholder.

import UIKit

actor VaultThumbFetcher {
    private let session: URLSession
    private var memory: [String: Data] = [:]

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 15
        configuration.httpAdditionalHeaders = ["User-Agent": VaultNetworkClient.userAgent]
        session = URLSession(configuration: configuration)
    }

    func image(for product: VaultProduct) async -> UIImage {
        if let urlString = product.imageURL, let cached = memory[urlString], let image = UIImage(data: cached) {
            return image
        }
        if let urlString = product.imageURL, let url = URL(string: urlString) {
            do {
                let data = try await session.data(from: url).0
                if let image = UIImage(data: data) {
                    memory[urlString] = data
                    return image
                }
            } catch {
                // Fall through to bundled art.
            }
        }
        if let asset = product.shelfAsset, let image = UIImage(named: asset) {
            return image
        }
        return UIImage(named: "gvt_ProductPlaceholder") ?? UIImage()
    }
}
