// Role: single client for both Open Food Facts endpoints.

import Foundation

actor VaultNetworkClient {
    static let userAgent = "GramVault/1.0 (iOS; +https://gramvault.pro)"
    static let pageSize = 24

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession? = nil) {
        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = 15
            configuration.timeoutIntervalForResource = 15
            configuration.httpAdditionalHeaders = ["User-Agent": Self.userAgent]
            self.session = URLSession(configuration: configuration)
        }
        decoder = JSONDecoder()
    }

    func search(terms: String) async throws -> [VaultProduct] {
        var components = URLComponents(string: "https://world.openfoodfacts.org/cgi/search.pl")
        components?.queryItems = [
            URLQueryItem(name: "search_terms", value: terms),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page_size", value: String(Self.pageSize))
        ]
        guard let url = components?.url else { throw VaultCatalogFailure.transport }
        let data = try await data(from: url)
        let payload: VaultSearchDTO
        do {
            payload = try decoder.decode(VaultSearchDTO.self, from: data)
        } catch {
            throw VaultCatalogFailure.decoding
        }
        return (payload.products ?? []).compactMap { $0.mapped(fallbackBarcode: $0.code ?? "") }
    }

    func lookup(code: String) async throws -> VaultProduct {
        guard let encoded = code.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(encoded).json")
        else {
            throw VaultCatalogFailure.transport
        }
        let data = try await data(from: url)
        let payload: VaultProductLookupDTO
        do {
            payload = try decoder.decode(VaultProductLookupDTO.self, from: data)
        } catch {
            throw VaultCatalogFailure.decoding
        }
        if payload.status == 0 {
            throw VaultCatalogFailure.notFound
        }
        guard let product = payload.product?.mapped(fallbackBarcode: code) else {
            throw VaultCatalogFailure.notFound
        }
        return product
    }

    private func data(from url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        do {
            return try await perform(request)
        } catch let failure as VaultCatalogFailure {
            throw failure
        } catch {
            do {
                return try await perform(request)
            } catch {
                throw VaultCatalogFailure.transport
            }
        }
    }

    private func perform(_ request: URLRequest) async throws -> Data {
        let pair: (Data, URLResponse)
        do {
            pair = try await session.data(for: request)
        } catch is CancellationError {
            throw VaultCatalogFailure.cancelled
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw VaultCatalogFailure.cancelled
        } catch {
            throw error
        }
        if let http = pair.1 as? HTTPURLResponse {
            if http.statusCode == 404 {
                throw VaultCatalogFailure.notFound
            }
            if http.statusCode >= 500 {
                throw URLError(.badServerResponse)
            }
            if http.statusCode >= 400 {
                throw VaultCatalogFailure.transport
            }
        }
        return pair.0
    }
}
