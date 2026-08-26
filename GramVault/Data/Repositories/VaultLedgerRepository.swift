// Role: eaten and planned entries. Value types only at the boundary.

import CoreData
import Foundation

actor VaultLedgerRepository {
    private let store: VaultPersistentStore

    init(store: VaultPersistentStore) {
        self.store = store
    }

    func entries(dayKey: Int, eaten: Bool?) async throws -> [VaultLogEntry] {
        try await store.performRead { context in
            let request = NSFetchRequest<VaultEntryObject>(entityName: "VaultEntry")
            request.fetchBatchSize = 20
            var predicates = [NSPredicate(format: "dayKey == %d", dayKey)]
            if let eaten {
                predicates.append(NSPredicate(format: "isEaten == %@", NSNumber(value: eaten)))
            }
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            request.sortDescriptors = [
                NSSortDescriptor(key: "slotRaw", ascending: true),
                NSSortDescriptor(key: "createdAt", ascending: true),
                NSSortDescriptor(key: "id", ascending: true)
            ]
            return try context.fetch(request).compactMap(VaultRecordMap.entry)
        }
    }

    func plannedHorizon(from dayKey: Int, days: Int) async throws -> [VaultLogEntry] {
        let end = VaultDayClock.shift(dayKey, days: days)
        return try await store.performRead { context in
            let request = NSFetchRequest<VaultEntryObject>(entityName: "VaultEntry")
            request.fetchBatchSize = 20
            request.predicate = NSPredicate(
                format: "isEaten == NO AND dayKey > %d AND dayKey < %d",
                dayKey,
                end
            )
            request.sortDescriptors = [
                NSSortDescriptor(key: "dayKey", ascending: true),
                NSSortDescriptor(key: "slotRaw", ascending: true),
                NSSortDescriptor(key: "id", ascending: true)
            ]
            return try context.fetch(request).compactMap(VaultRecordMap.entry)
        }
    }

    func insert(product: VaultProduct, grams: Double, slot: VaultSlot, dayKey: Int, eaten: Bool) async throws -> UUID {
        let id = UUID()
        try await store.performWrite { context in
            let request = NSFetchRequest<VaultProductObject>(entityName: "VaultProduct")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "barcode == %@", product.barcode)
            request.sortDescriptors = [NSSortDescriptor(key: "barcode", ascending: true)]
            guard let stored = try context.fetch(request).first else {
                throw VaultCatalogFailure.store
            }
            let entry = VaultEntryObject(context: context)
            entry.id = id
            entry.grams = grams
            entry.slotRaw = slot.rawValue
            entry.dayKey = Int64(dayKey)
            entry.isEaten = eaten
            entry.createdAt = Date()
            entry.product = stored
        }
        return id
    }

    func delete(id: UUID) async throws {
        try await store.performWrite { context in
            let request = NSFetchRequest<VaultEntryObject>(entityName: "VaultEntry")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            if let object = try context.fetch(request).first {
                context.delete(object)
            }
        }
    }

    func convertToEaten(id: UUID, dayKey: Int) async throws {
        try await store.performWrite { context in
            let request = NSFetchRequest<VaultEntryObject>(entityName: "VaultEntry")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            guard let object = try context.fetch(request).first else { return }
            object.isEaten = true
            object.dayKey = Int64(dayKey)
        }
    }
}
