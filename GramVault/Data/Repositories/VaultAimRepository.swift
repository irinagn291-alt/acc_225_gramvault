// Role: daily targets persistence.

import CoreData
import Foundation

actor VaultAimRepository {
    private let store: VaultPersistentStore

    init(store: VaultPersistentStore) {
        self.store = store
    }

    func load() async throws -> VaultDailyTargets {
        try await store.performRead { context in
            if let object = try Self.fetch(context) {
                return VaultRecordMap.targets(object)
            }
            return VaultDailyTargets.factory
        }
    }

    func save(_ targets: VaultDailyTargets) async throws {
        guard targets.isValid else { throw VaultCatalogFailure.invalidGrams }
        try await store.performWrite { context in
            let object = try Self.fetch(context) ?? VaultTargetObject(context: context)
            object.kcal = targets.kcal
            object.protein = targets.protein
            object.carbs = targets.carbs
            object.fat = targets.fat
        }
    }

    private static func fetch(_ context: NSManagedObjectContext) throws -> VaultTargetObject? {
        let request = NSFetchRequest<VaultTargetObject>(entityName: "VaultTarget")
        request.fetchLimit = 1
        request.fetchBatchSize = 20
        request.sortDescriptors = [NSSortDescriptor(key: "kcal", ascending: true)]
        return try context.fetch(request).first
    }
}
