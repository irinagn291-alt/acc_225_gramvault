// Role: programmatic NSManagedObjectModel and record types. UI never sees these.

import CoreData
import Foundation

@objc(VaultProduct)
final class VaultProductObject: NSManagedObject {
    @NSManaged var barcode: String
    @NSManaged var name: String
    @NSManaged var brand: String
    @NSManaged var kcal100: NSNumber?
    @NSManaged var protein100: NSNumber?
    @NSManaged var carbs100: NSNumber?
    @NSManaged var fat100: NSNumber?
    @NSManaged var lastRefresh: Date
    @NSManaged var imageURL: String?
    @NSManaged var shelfAsset: String?
    @NSManaged var wishedAt: Date?
    @NSManaged var entries: Set<VaultEntryObject>
}

@objc(VaultEntry)
final class VaultEntryObject: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var grams: Double
    @NSManaged var slotRaw: String
    @NSManaged var dayKey: Int64
    @NSManaged var isEaten: Bool
    @NSManaged var createdAt: Date
    @NSManaged var product: VaultProductObject
}

@objc(VaultTarget)
final class VaultTargetObject: NSManagedObject {
    @NSManaged var kcal: Double
    @NSManaged var protein: Double
    @NSManaged var carbs: Double
    @NSManaged var fat: Double
}

enum VaultManagedModel {
    static let schemaVersion = "gvt.store.v1"

    static func make() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let product = NSEntityDescription()
        product.name = "VaultProduct"
        product.managedObjectClassName = NSStringFromClass(VaultProductObject.self)

        let entry = NSEntityDescription()
        entry.name = "VaultEntry"
        entry.managedObjectClassName = NSStringFromClass(VaultEntryObject.self)

        let target = NSEntityDescription()
        target.name = "VaultTarget"
        target.managedObjectClassName = NSStringFromClass(VaultTargetObject.self)

        product.properties = [
            attribute("barcode", .stringAttributeType, optional: false),
            attribute("name", .stringAttributeType, optional: false),
            attribute("brand", .stringAttributeType, optional: false),
            attribute("kcal100", .doubleAttributeType, optional: true),
            attribute("protein100", .doubleAttributeType, optional: true),
            attribute("carbs100", .doubleAttributeType, optional: true),
            attribute("fat100", .doubleAttributeType, optional: true),
            attribute("lastRefresh", .dateAttributeType, optional: false),
            attribute("imageURL", .stringAttributeType, optional: true),
            attribute("shelfAsset", .stringAttributeType, optional: true),
            attribute("wishedAt", .dateAttributeType, optional: true)
        ]

        entry.properties = [
            attribute("id", .UUIDAttributeType, optional: false),
            attribute("grams", .doubleAttributeType, optional: false),
            attribute("slotRaw", .stringAttributeType, optional: false),
            attribute("dayKey", .integer64AttributeType, optional: false),
            attribute("isEaten", .booleanAttributeType, optional: false),
            attribute("createdAt", .dateAttributeType, optional: false)
        ]

        target.properties = [
            attribute("kcal", .doubleAttributeType, optional: false),
            attribute("protein", .doubleAttributeType, optional: false),
            attribute("carbs", .doubleAttributeType, optional: false),
            attribute("fat", .doubleAttributeType, optional: false)
        ]

        let productEntries = NSRelationshipDescription()
        productEntries.name = "entries"
        productEntries.destinationEntity = entry
        productEntries.minCount = 0
        productEntries.maxCount = 0
        productEntries.deleteRule = .cascadeDeleteRule
        productEntries.isOptional = true

        let entryProduct = NSRelationshipDescription()
        entryProduct.name = "product"
        entryProduct.destinationEntity = product
        entryProduct.minCount = 1
        entryProduct.maxCount = 1
        entryProduct.deleteRule = .nullifyDeleteRule
        entryProduct.isOptional = false

        productEntries.inverseRelationship = entryProduct
        entryProduct.inverseRelationship = productEntries

        product.properties.append(productEntries)
        entry.properties.append(entryProduct)

        product.uniquenessConstraints = [["barcode"]]
        if let barcodeProperty = product.properties.first(where: { $0.name == "barcode" }) {
            product.indexes = [
                NSFetchIndexDescription(
                    name: "gvt_product_barcode",
                    elements: [NSFetchIndexElementDescription(property: barcodeProperty, collationType: .binary)]
                )
            ]
        }

        model.entities = [product, entry, target]
        model.versionIdentifiers = [schemaVersion]
        return model
    }

    private static func attribute(_ name: String, _ type: NSAttributeType, optional: Bool) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        return attribute
    }
}

enum VaultRecordMap {
    static func product(_ object: VaultProductObject) -> VaultProduct {
        VaultProduct(
            barcode: object.barcode,
            name: object.name,
            brand: object.brand,
            kcal100: object.kcal100?.doubleValue,
            protein100: object.protein100?.doubleValue,
            carbs100: object.carbs100?.doubleValue,
            fat100: object.fat100?.doubleValue,
            lastRefresh: object.lastRefresh,
            imageURL: object.imageURL,
            shelfAsset: object.shelfAsset,
            wishedAt: object.wishedAt
        )
    }

    static func entry(_ object: VaultEntryObject) -> VaultLogEntry? {
        guard let slot = VaultSlot(rawValue: object.slotRaw) else { return nil }
        return VaultLogEntry(
            id: object.id,
            product: product(object.product),
            grams: object.grams,
            slot: slot,
            dayKey: Int(object.dayKey),
            isEaten: object.isEaten,
            createdAt: object.createdAt
        )
    }

    static func targets(_ object: VaultTargetObject) -> VaultDailyTargets {
        VaultDailyTargets(kcal: object.kcal, protein: object.protein, carbs: object.carbs, fat: object.fat)
    }
}
