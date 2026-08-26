// Role: catalogue seam. Caches every resolved OFF product. Honours Sealed.

import CoreData
import Foundation

actor VaultCatalogRepository {
    private let store: VaultPersistentStore
    private let client: VaultNetworkClient
    private let settings: VaultSettingsStore

    init(store: VaultPersistentStore, client: VaultNetworkClient, settings: VaultSettingsStore) {
        self.store = store
        self.client = client
        self.settings = settings
    }

    func search(query: String) async throws -> [VaultProduct] {
        try Task.checkCancellation()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let local = try await localMatches(query: trimmed)
        let policy = VaultSealedPolicy(isSealed: settings.isSealed())
        guard policy.shouldQueryRemote(query: trimmed, cachedCount: local.count) else {
            return merge(local, VaultShelfCatalog.matches(query: trimmed))
        }
        do {
            let remote = try await client.search(terms: trimmed)
            for product in remote {
                try await upsert(product)
            }
            let refreshed = try await localMatches(query: trimmed)
            let merged = merge(refreshed, remote, VaultShelfCatalog.matches(query: trimmed))
            if merged.isEmpty {
                return VaultShelfCatalog.matches(query: trimmed)
            }
            return merged
        } catch is CancellationError {
            throw VaultCatalogFailure.cancelled
        } catch let failure as VaultCatalogFailure where failure == .cancelled {
            throw failure
        } catch {
            let fallback = merge(local, VaultShelfCatalog.matches(query: trimmed))
            if fallback.isEmpty {
                throw VaultCatalogFailure.transport
            }
            return fallback
        }
    }

    func resolve(raw: String) async throws -> VaultProduct {
        let codes = VaultBarcodeNormalizer.candidates(from: raw)
        guard !codes.isEmpty else { throw VaultCatalogFailure.notFound }
        var last: VaultCatalogFailure = .notFound
        for code in codes {
            do {
                return try await resolveSingle(code)
            } catch let failure as VaultCatalogFailure {
                last = failure
            }
        }
        throw last
    }

    func cached(barcode: String) async throws -> VaultProduct? {
        try await store.performRead { context in
            try Self.fetchProduct(barcode: barcode, context: context).map(VaultRecordMap.product)
        }
    }

    func cachedCount() async throws -> Int {
        try await store.performRead { context in
            let request = NSFetchRequest<VaultProductObject>(entityName: "VaultProduct")
            request.fetchBatchSize = 20
            return try context.count(for: request)
        }
    }

    func upsert(_ product: VaultProduct) async throws {
        try await store.performWrite { context in
            let object = try Self.fetchProduct(barcode: product.barcode, context: context) ?? VaultProductObject(context: context)
            object.barcode = product.barcode
            object.name = product.name
            object.brand = product.brand
            object.kcal100 = product.kcal100.map { NSNumber(value: $0) }
            object.protein100 = product.protein100.map { NSNumber(value: $0) }
            object.carbs100 = product.carbs100.map { NSNumber(value: $0) }
            object.fat100 = product.fat100.map { NSNumber(value: $0) }
            object.lastRefresh = product.lastRefresh
            object.imageURL = product.imageURL
            if object.shelfAsset == nil {
                object.shelfAsset = product.shelfAsset
            }
            if object.wishedAt == nil {
                object.wishedAt = product.wishedAt
            }
        }
    }

    func seedShelfIfNeeded() async throws {
        for product in VaultShelfCatalog.products {
            if try await cached(barcode: product.barcode) == nil {
                try await upsert(product)
            }
        }
    }

    private func resolveSingle(_ code: String) async throws -> VaultProduct {
        if let cached = try await cached(barcode: code) {
            return cached
        }
        if let shelf = VaultShelfCatalog.product(barcode: code) {
            try await upsert(shelf)
            return shelf
        }
        let policy = VaultSealedPolicy(isSealed: settings.isSealed())
        guard policy.shouldResolveRemote(barcode: code, cached: nil) else {
            throw VaultCatalogFailure.sealedOffline
        }
        let remote = try await client.lookup(code: code)
        try await upsert(remote)
        return remote
    }

    private func localMatches(query: String) async throws -> [VaultProduct] {
        try await store.performRead { context in
            let request = NSFetchRequest<VaultProductObject>(entityName: "VaultProduct")
            request.fetchBatchSize = 20
            request.sortDescriptors = [
                NSSortDescriptor(key: "name", ascending: true),
                NSSortDescriptor(key: "barcode", ascending: true)
            ]
            if !query.isEmpty {
                request.predicate = NSPredicate(
                    format: "name CONTAINS[cd] %@ OR brand CONTAINS[cd] %@ OR barcode CONTAINS %@",
                    query, query, query
                )
            }
            return try context.fetch(request).map(VaultRecordMap.product)
        }
    }

    private func merge(_ lists: [VaultProduct]...) -> [VaultProduct] {
        var seen: Set<String> = []
        var result: [VaultProduct] = []
        for list in lists {
            for product in list where seen.insert(product.barcode).inserted {
                result.append(product)
            }
        }
        return result
    }

    private static func fetchProduct(barcode: String, context: NSManagedObjectContext) throws -> VaultProductObject? {
        let request = NSFetchRequest<VaultProductObject>(entityName: "VaultProduct")
        request.fetchLimit = 1
        request.fetchBatchSize = 20
        request.predicate = NSPredicate(format: "barcode == %@", barcode)
        request.sortDescriptors = [NSSortDescriptor(key: "barcode", ascending: true)]
        return try context.fetch(request).first
    }
}
