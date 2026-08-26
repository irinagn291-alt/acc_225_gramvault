// Role: wish list. Duplicate barcode updates the existing row.

import CoreData
import Foundation

actor VaultWishRepository {
    private let store: VaultPersistentStore

    init(store: VaultPersistentStore) {
        self.store = store
    }

    func all() async throws -> [VaultWishItem] {
        try await store.performRead { context in
            let request = NSFetchRequest<VaultProductObject>(entityName: "VaultProduct")
            request.fetchBatchSize = 20
            request.predicate = NSPredicate(format: "wishedAt != nil")
            request.sortDescriptors = [
                NSSortDescriptor(key: "wishedAt", ascending: false),
                NSSortDescriptor(key: "barcode", ascending: true)
            ]
            return try context.fetch(request).compactMap { object in
                guard let added = object.wishedAt else { return nil }
                return VaultWishItem(product: VaultRecordMap.product(object), added: added)
            }
        }
    }

    func add(_ product: VaultProduct) async throws -> VaultWishItem {
        let now = Date()
        return try await store.performWrite { context in
            let request = NSFetchRequest<VaultProductObject>(entityName: "VaultProduct")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "barcode == %@", product.barcode)
            request.sortDescriptors = [NSSortDescriptor(key: "barcode", ascending: true)]
            let object = try context.fetch(request).first ?? VaultProductObject(context: context)
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
                object.wishedAt = now
            }
            let added = object.wishedAt ?? now
            return VaultWishItem(product: VaultRecordMap.product(object), added: added)
        }
    }

    func remove(barcode: String) async throws {
        try await store.performWrite { context in
            let request = NSFetchRequest<VaultProductObject>(entityName: "VaultProduct")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "barcode == %@", barcode)
            request.sortDescriptors = [NSSortDescriptor(key: "barcode", ascending: true)]
            if let object = try context.fetch(request).first {
                object.wishedAt = nil
            }
        }
    }

    func contains(barcode: String) async throws -> Bool {
        try await store.performRead { context in
            let request = NSFetchRequest<VaultProductObject>(entityName: "VaultProduct")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "barcode == %@ AND wishedAt != nil", barcode)
            request.sortDescriptors = [NSSortDescriptor(key: "barcode", ascending: true)]
            return try context.fetch(request).first != nil
        }
    }
}
