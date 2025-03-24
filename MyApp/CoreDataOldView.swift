//
//  CoreDataOldView.swift
//  MyApp
//
//  Created by Cong Le on 3/24/25.
//

//  This file demonstrates a Core Data setup without using the newer APIs that
//  cause errors in older deployments (e.g., 'currentQueryGenerationToken'),
//  avoids assigning read-only properties like 'isToMany,' and removes the
//  deprecated 'isIndexed' usage.
//

import CoreData
import SwiftUI
import Combine
import OSLog

// MARK: - Create Core Data Model
func createCoreDataModel() -> NSManagedObjectModel {

    // --- Item Entity Attributes ---
    let itemNameAttribute = NSAttributeDescription()
    itemNameAttribute.name = "name"
    itemNameAttribute.attributeType = .stringAttributeType
    itemNameAttribute.isOptional = false
    // itemNameAttribute.isIndexed = true // Deprecated in iOS 11; remove or replace with NSEntityDescription.indexes

    let itemTimestampAttribute = NSAttributeDescription()
    itemTimestampAttribute.name = "timestamp"
    itemTimestampAttribute.attributeType = .dateAttributeType
    itemTimestampAttribute.isOptional = false

    let itemQuantityAttribute = NSAttributeDescription()
    itemQuantityAttribute.name = "quantity"
    itemQuantityAttribute.attributeType = .integer32AttributeType
    itemQuantityAttribute.isOptional = true
    itemQuantityAttribute.defaultValue = 1

    let itemIsFavoriteAttribute = NSAttributeDescription()
    itemIsFavoriteAttribute.name = "isFavorite"
    itemIsFavoriteAttribute.attributeType = .booleanAttributeType
    itemIsFavoriteAttribute.isOptional = false
    itemIsFavoriteAttribute.defaultValue = false

    let itemNotesAttribute = NSAttributeDescription()
    itemNotesAttribute.name = "notes"
    itemNotesAttribute.attributeType = .stringAttributeType
    itemNotesAttribute.isOptional = true
    itemNotesAttribute.allowsExternalBinaryDataStorage = true

    // --- Category Entity Attributes ---
    let categoryNameAttribute = NSAttributeDescription()
    categoryNameAttribute.name = "name"
    categoryNameAttribute.attributeType = .stringAttributeType
    categoryNameAttribute.isOptional = false

    let categoryColorAttribute = NSAttributeDescription()
    categoryColorAttribute.name = "color"
    categoryColorAttribute.attributeType = .stringAttributeType
    categoryColorAttribute.isOptional = true

    // --- Relationship Descriptions ---
    // Instead of setting ".isToMany = true" (which is read-only),
    // define minCount and maxCount for a to-many relationship.
    let categoryToItemsRelation = NSRelationshipDescription()
    categoryToItemsRelation.name = "items"
    categoryToItemsRelation.deleteRule = .cascadeDeleteRule
    categoryToItemsRelation.minCount = 0      // 0 implies optional
    categoryToItemsRelation.maxCount = 0      // 0 implies "unbounded" => to-many

    let itemToCategoryRelation = NSRelationshipDescription()
    itemToCategoryRelation.name = "category"
    itemToCategoryRelation.deleteRule = .nullifyDeleteRule
    itemToCategoryRelation.minCount = 0
    itemToCategoryRelation.maxCount = 1       // single category => to-one

    // We can’t assign categoryToItemsRelation.isToMany = true, because 'isToMany' is read-only.

    // --- Fetched Property Description (optional example) ---
    let itemHighQuantityPredicate = NSPredicate(format: "quantity > 50")
    let highQuantityFetchedProperty = NSFetchedPropertyDescription()
    highQuantityFetchedProperty.name = "highQuantityItems"
//    highQuantityFetchedProperty.predicate = itemHighQuantityPredicate

    // --- Entity Descriptions ---
    let itemEntity = NSEntityDescription()
    itemEntity.name = "Item"
    itemEntity.managedObjectClassName = "Item"
    itemEntity.properties = [itemNameAttribute, itemTimestampAttribute,
                             itemQuantityAttribute, itemIsFavoriteAttribute,
                             itemNotesAttribute, itemToCategoryRelation]

    let categoryEntity = NSEntityDescription()
    categoryEntity.name = "Category"
    categoryEntity.managedObjectClassName = "Category"
    categoryEntity.properties = [categoryNameAttribute, categoryColorAttribute,
                                 categoryToItemsRelation, highQuantityFetchedProperty]

    // Set inverse relationships
    categoryToItemsRelation.destinationEntity = itemEntity
    categoryToItemsRelation.inverseRelationship = itemToCategoryRelation
    itemToCategoryRelation.destinationEntity = categoryEntity
    itemToCategoryRelation.inverseRelationship = categoryToItemsRelation

    // Be sure to associate the fetched property with its entity after creation
//    highQuantityFetchedProperty.entity = categoryEntity

    // Create the model
    let model = NSManagedObjectModel()
    model.entities = [itemEntity, categoryEntity]

    return model
}

// MARK: - NSManagedObject Subclasses

class Item: NSManagedObject, Identifiable {
    @NSManaged var name: String
    @NSManaged var timestamp: Date
    @NSManaged var quantity: Int32
    @NSManaged var isFavorite: Bool
    @NSManaged var notes: String?
    @NSManaged var category: Category?

    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(Date(), forKey: "timestamp")
    }
    static func fetchRequest() -> NSFetchRequest<Item> {
        NSFetchRequest<Item>(entityName: "Item")
    }
}

class Category: NSManagedObject, Identifiable {
    @NSManaged var name: String
    @NSManaged var color: String?
    @NSManaged var items: Set<Item>?
    @NSManaged var highQuantityItems: [Item]

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)
}

// MARK: - Core Data Manager

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer
    private let logger = Logger(subsystem: "com.example.MyCoreDataApp", category: "CoreDataManager")

    private init() {
        let model = createCoreDataModel()
        persistentContainer = NSPersistentContainer(name: "MyModel", managedObjectModel: model)

        let storeDescription = NSPersistentStoreDescription()
        storeDescription.shouldInferMappingModelAutomatically = true
        storeDescription.shouldMigrateStoreAutomatically = true

        persistentContainer.persistentStoreDescriptions = [storeDescription]

        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                self.logger.error("Error loading store: \(error.localizedDescription)")
                fatalError("Unable to load store: \(error)")
            }
            self.logger.info("Successfully loaded store: \(description.url?.absoluteString ?? "")")
            self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        }
    }

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // Example CRUD

    func saveContext() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            logger.error("Save Error: \(error.localizedDescription)")
        }
    }

    func createItem(name: String, quantity: Int32) {
        let item = Item(context: viewContext)
        item.name = name
        item.quantity = quantity
        saveContext()
    }

    func fetchItems() -> [Item] {
        let request = Item.fetchRequest()
        do {
            return try viewContext.fetch(request)
        } catch {
            logger.error("Fetch Error: \(error.localizedDescription)")
            return []
        }
    }

    // etc. (addYourOwn)
}

// MARK: - SwiftUI Example

struct CoreDataContentView: View {
    // Provided by @main App or SceneDelegate
    @Environment(\.managedObjectContext) private var context

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default
    )
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    VStack(alignment: .leading) {
                        Text(item.name)
                        Text("Qty: \(item.quantity)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Core Data Fixes")
            .toolbar {
                Button("Add Random Item") {
                    CoreDataManager.shared.createItem(
                        name: "Item \(Int.random(in: 1...999))",
                        quantity: Int32.random(in: 1...100)
                    )
                }
            }
        }
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // In-memory for previews
        let manager = CoreDataManager.shared
        return CoreDataContentView()
            .environment(\.managedObjectContext, manager.viewContext)
    }
}
