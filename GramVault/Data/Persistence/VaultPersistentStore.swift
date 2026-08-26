// Role: single NSPersistentContainer. Writes hop through background contexts.

import CoreData
import Foundation

/// Container is isolated behind perform hops; no user-mutable state is shared.
final class VaultPersistentStore: @unchecked Sendable {
    let container: NSPersistentContainer
    private let settings: VaultSettingsStore
    private let inMemory: Bool

    init(inMemory: Bool, settings: VaultSettingsStore = VaultSettingsStore()) {
        self.inMemory = inMemory
        self.settings = settings
        let model = VaultManagedModel.make()
        let container = NSPersistentContainer(name: "GramVault", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        if !inMemory {
            let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            let storeURL = folder?.appendingPathComponent("GramVault.sqlite")
            description.url = storeURL ?? URL(fileURLWithPath: "/dev/null")
        }
        description.type = NSSQLiteStoreType
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        self.container = container
    }

    func open() async {
        let description = container.persistentStoreDescriptions.first
        let firstError = await loadOnce()
        if firstError != nil {
            await recover(description: description)
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.name = "gvt.view"
    }

    private func loadOnce() async -> Error? {
        await withCheckedContinuation { continuation in
            container.loadPersistentStores { _, error in
                continuation.resume(returning: error)
            }
        }
    }

    private func recover(description: NSPersistentStoreDescription?) async {
        let coordinator = container.persistentStoreCoordinator
        for store in coordinator.persistentStores {
            try? coordinator.remove(store)
        }
        if let url = description?.url, !inMemory {
            try? FileManager.default.removeItem(at: url)
            let sibling = url.deletingPathExtension().lastPathComponent
            let folder = url.deletingLastPathComponent()
            try? FileManager.default.removeItem(at: folder.appendingPathComponent("\(sibling).sqlite-shm"))
            try? FileManager.default.removeItem(at: folder.appendingPathComponent("\(sibling).sqlite-wal"))
        }
        let second = await loadOnce()
        if second == nil {
            settings.markRecoveredStore()
        }
    }

    func performWrite<T: Sendable>(_ work: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await container.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let result = try work(context)
            if context.hasChanges {
                try context.save()
            }
            return result
        }
    }

    func performRead<T: Sendable>(_ work: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await container.performBackgroundTask { context in
            try work(context)
        }
    }

    func resetAllData() async throws {
        try await performWrite { context in
            for name in ["VaultEntry", "VaultProduct", "VaultTarget"] {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                let delete = NSBatchDeleteRequest(fetchRequest: request)
                delete.resultType = .resultTypeObjectIDs
                let result = try context.execute(delete) as? NSBatchDeleteResult
                if let ids = result?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: [NSDeletedObjectsKey: ids],
                        into: [context]
                    )
                }
            }
        }
    }
}
