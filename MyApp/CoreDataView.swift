////
////  CoreDataView.swift
////  MyApp
////
////  Created by Cong Le on 3/24/25.
////
//import CoreData
//import SwiftUI
//import Combine
//import OSLog
//
//// MARK: - Core Data Model
//
//func createCoreDataModel() -> NSManagedObjectModel {
//    // --- Item Entity Attributes ---
//    let itemNameAttribute = NSAttributeDescription()
//    itemNameAttribute.name = "name"
//    itemNameAttribute.attributeType = .stringAttributeType
//    itemNameAttribute.isOptional = false
//    // If you need to index this attribute in Core Data:
//    itemNameAttribute.isIndexed = true
//
//    let itemTimestampAttribute = NSAttributeDescription()
//    itemTimestampAttribute.name = "timestamp"
//    itemTimestampAttribute.attributeType = .dateAttributeType
//    itemTimestampAttribute.isOptional = false
//
//    let itemQuantityAttribute = NSAttributeDescription()
//    itemQuantityAttribute.name = "quantity"
//    itemQuantityAttribute.attributeType = .integer32AttributeType
//    itemQuantityAttribute.isOptional = true
//    itemQuantityAttribute.defaultValue = 1
//
//    let itemIsFavoriteAttribute = NSAttributeDescription()
//    itemIsFavoriteAttribute.name = "isFavorite"
//    itemIsFavoriteAttribute.attributeType = .booleanAttributeType
//    itemIsFavoriteAttribute.isOptional = false
//    itemIsFavoriteAttribute.defaultValue = false
//
//    let itemNotesAttribute = NSAttributeDescription()
//    itemNotesAttribute.name = "notes"
//    itemNotesAttribute.attributeType = .stringAttributeType
//    itemNotesAttribute.isOptional = true
//    itemNotesAttribute.allowsExternalBinaryDataStorage = true
//
//    // --- Category Entity Attributes ---
//    let categoryNameAttribute = NSAttributeDescription()
//    categoryNameAttribute.name = "name"
//    categoryNameAttribute.attributeType = .stringAttributeType
//    categoryNameAttribute.isOptional = false
//
//    let categoryColorAttribute = NSAttributeDescription()
//    categoryColorAttribute.name = "color"
//    categoryColorAttribute.attributeType = .stringAttributeType
//    categoryColorAttribute.isOptional = true
//
//    // --- Relationship Descriptions ---
//    let itemToCategoryRelationship = NSRelationshipDescription()
//    itemToCategoryRelationship.name = "category"
//    itemToCategoryRelationship.deleteRule = .nullifyDeleteRule
//    itemToCategoryRelationship.isOptional = true
//
//    let categoryToItemsRelationship = NSRelationshipDescription()
//    categoryToItemsRelationship.name = "items"
//    categoryToItemsRelationship.deleteRule = .cascadeDeleteRule
//    categoryToItemsRelationship.isToMany = true // Ensure it is a to-many relationship
//
//    // --- Fetched Property Description (Optional) ---
//    // If you decide to use a fetched property:
//    let highQuantityFetchedProperty = NSFetchedPropertyDescription()
//    highQuantityFetchedProperty.name = "highQuantityItems"
//    // Example usage:
//    // let itemHighQuantity = NSPredicate(format: "quantity > 50")
//    // highQuantityFetchedProperty.predicate = itemHighQuantity
//
//    // --- Entity Descriptions ---
//    let itemEntity = NSEntityDescription()
//    itemEntity.name = "Item"
//    itemEntity.managedObjectClassName = "Item"
//    itemEntity.properties = [
//        itemNameAttribute,
//        itemTimestampAttribute,
//        itemQuantityAttribute,
//        itemIsFavoriteAttribute,
//        itemNotesAttribute,
//        itemToCategoryRelationship
//    ]
//
//    let categoryEntity = NSEntityDescription()
//    categoryEntity.name = "Category"
//    categoryEntity.managedObjectClassName = "Category"
//    categoryEntity.properties = [
//        categoryNameAttribute,
//        categoryColorAttribute,
//        categoryToItemsRelationship,
//        highQuantityFetchedProperty
//    ]
//
//    // Inverse relationship
//    itemToCategoryRelationship.destinationEntity = categoryEntity
//    itemToCategoryRelationship.inverseRelationship = categoryToItemsRelationship
//    categoryToItemsRelationship.destinationEntity = itemEntity
//    categoryToItemsRelationship.inverseRelationship = itemToCategoryRelationship
//
//    // If using the fetched property:
//    // highQuantityFetchedProperty.entity = categoryEntity
//
//    // Create the Model
//    let model = NSManagedObjectModel()
//    model.entities = [itemEntity, categoryEntity]
//    model.setEntities([itemEntity], forConfigurationName: "ItemsConfig")
//    model.setEntities([categoryEntity], forConfigurationName: "CategoriesConfig")
//
//    return model
//}
//
//// MARK: - NSManagedObject Subclasses
//
//class Item: NSManagedObject, Identifiable {
//    @NSManaged var name: String
//    @NSManaged var timestamp: Date
//    @NSManaged var quantity: Int32
//    @NSManaged var isFavorite: Bool
//    @NSManaged var notes: String?
//    @NSManaged var category: Category?
//
//    override func willSave() {
//        super.willSave()
//        if name.isEmpty {
//            name = "Unnamed Item"
//        }
//    }
//
//    override func awakeFromInsert() {
//        super.awakeFromInsert()
//        setPrimitiveValue(Date(), forKey: "timestamp")
//    }
//
//    static func fetchRequest() -> NSFetchRequest<Item> {
//        NSFetchRequest<Item>(entityName: "Item")
//    }
//}
//
//class Category: NSManagedObject, Identifiable {
//    @NSManaged var name: String
//    @NSManaged var color: String?
//    @NSManaged var items: Set<Item>?
//    @NSManaged var highQuantityItems: [Item] // If you are actually using the fetched property
//
//    @objc(addItemsObject:)
//    @NSManaged public func addToItems(_ value: Item)
//
//    @objc(removeItemsObject:)
//    @NSManaged public func removeFromItems(_ value: Item)
//
//    @objc(addItems:)
//    @NSManaged public func addToItems(_ values: NSSet)
//
//    @objc(removeItems:)
//    @NSManaged public func removeFromItems(_ values: NSSet)
//
//    static func fetchRequest() -> NSFetchRequest<Category> {
//        NSFetchRequest<Category>(entityName: "Category")
//    }
//}
//
//// MARK: - Core Data Stack
//
//class CoreDataManager: ObservableObject {
//    static let shared = CoreDataManager()
//
//    let persistentContainer: NSPersistentContainer
//    let logger = Logger(subsystem: "com.example.MyCoreDataApp", category: "CoreDataManager")
//
//    private init() {
//        let model = createCoreDataModel()
//        persistentContainer = NSPersistentContainer(name: "MyModel", managedObjectModel: model)
//
//        let cloudKitContainerIdentifier = "iCloud.com.your.app.bundle.id"
//
//        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            fatalError("Could not determine documents directory")
//        }
//        let storeURL = documentsDirectoryURL.appendingPathComponent("MyModel.sqlite")
//
//        let storeDescription = NSPersistentStoreDescription(url: storeURL)
//        storeDescription.shouldInferMappingModelAutomatically = true
//        storeDescription.shouldMigrateStoreAutomatically = true
//        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//        storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
//            containerIdentifier: cloudKitContainerIdentifier
//        )
//
//        persistentContainer.persistentStoreDescriptions = [storeDescription]
//        persistentContainer.loadPersistentStores { (description, error) in
//            if let error = error {
//                self.logger.error("Core Data store failed to load: \(error.localizedDescription)")
//                fatalError("Failed to load Core Data stack: \(error)")
//            }
//            self.logger.info("Core Data stack loaded successfully.")
//            self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
//            self.persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
//        }
//    }
//
//    var viewContext: NSManagedObjectContext {
//        persistentContainer.viewContext
//    }
//
//    // If you need a child context:
//    func childViewContext() -> NSManagedObjectContext {
//        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        context.parent = viewContext
//        return context
//    }
//
//    // If you need a private background context:
//    func newBackgroundContext() -> NSManagedObjectContext {
//        persistentContainer.newBackgroundContext()
//    }
//
//    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
//        persistentContainer.performBackgroundTask(block)
//    }
//
//    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {
//        do {
//            return try viewContext.fetch(request)
//        } catch {
//            logger.error("Error fetching \(T.self): \(error.localizedDescription)")
//            return []
//        }
//    }
//
//    func saveContext() {
//        guard viewContext.hasChanges else { return }
//        do {
//            try viewContext.save()
//            logger.info("Main context saved successfully.")
//        } catch {
//            logger.error("Error saving main context: \(error.localizedDescription)")
//        }
//    }
//
//    func save(context: NSManagedObjectContext) throws {
//        guard context.hasChanges else { return }
//        try context.save()
//    }
//
//    // MARK: - Example CRUD
//
//    func createItem(name: String, quantity: Int32, categoryName: String? = nil, isFavorite: Bool = false) {
//        let newItem = Item(context: viewContext)
//        newItem.name = name
//        newItem.timestamp = Date()
//        newItem.quantity = quantity
//        newItem.isFavorite = isFavorite
//
//        if let categoryName = categoryName {
//            addCategory(named: categoryName)
//            if let category = fetchCategory(named: categoryName) {
//                newItem.category = category
//                category.addToItems(newItem)
//            }
//        }
//        saveContext()
//    }
//
//    func addCategory(named name: String) {
//        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
//        fetchRequest.fetchLimit = 1
//
//        do {
//            let result = try viewContext.fetch(fetchRequest)
//            if result.isEmpty {
//                let newCategory = Category(context: viewContext)
//                newCategory.name = name
//                try save(context: viewContext)
//            }
//        } catch {
//            logger.error("Error adding category: \(error.localizedDescription)")
//        }
//    }
//
//    func fetchCategory(named name: String) -> Category? {
//        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
//        fetchRequest.fetchLimit = 1
//
//        do {
//            return try viewContext.fetch(fetchRequest).first
//        } catch {
//            logger.error("Error fetching category: \(error.localizedDescription)")
//            return nil
//        }
//    }
//
//    func fetchAllItems(sortedBy: String? = "timestamp", ascending: Bool = false) -> [Item] {
//        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "quantity > %@", NSNumber(value: 0))
//
//        if let sortKey = sortedBy {
//            let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: ascending)
//            fetchRequest.sortDescriptors = [sortDescriptor]
//        }
//
//        fetchRequest.fetchBatchSize = 20
//        return fetch(fetchRequest)
//    }
//
//    func fetchItems(withName name: String) -> [Item] {
//        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", name)
//        return fetch(fetchRequest)
//    }
//
//    func updateItem(item: Item, newName: String, isFavorite: Bool? = nil) {
//        item.name = newName
//        if let isFavorite = isFavorite {
//            item.isFavorite = isFavorite
//        }
//        saveContext()
//    }
//
//    func categorizeItem(item: Item, categoryName: String) {
//        performBackgroundTask { context in
//            guard let backgroundItem = context.object(with: item.objectID) as? Item else { return }
//            if let existingCategory = self.fetchCategory(named: categoryName, in: context) {
//                backgroundItem.category = existingCategory
//            } else {
//                let newCategory = Category(context: context)
//                newCategory.name = categoryName
//                backgroundItem.category = newCategory
//            }
//
//            do {
//                try self.save(context: context)
//            } catch {
//                print("Error categorizing item: \(error)")
//            }
//        }
//    }
//
//    func fetchCategory(named name: String, in context: NSManagedObjectContext) -> Category? {
//        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
//        fetchRequest.fetchLimit = 1
//
//        do {
//            return try context.fetch(fetchRequest).first
//        } catch {
//            print("Error fetching category: \(error)")
//            return nil
//        }
//    }
//
//    func deleteItem(item: Item) {
//        viewContext.delete(item)
//        saveContext()
//    }
//
//    func deleteAllItems() {
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Item")
//        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        batchDeleteRequest.resultType = .resultTypeObjectIDs
//
//        performBackgroundTask { context in
//            do {
//                let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
//                if let objectIDs = result?.result as? [NSManagedObjectID] {
//                    NSManagedObjectContext.mergeChanges(
//                        fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
//                        into: [self.viewContext]
//                    )
//                }
//                try self.save(context: context)
//            } catch {
//                self.logger.error("Error performing batch delete: \(error.localizedDescription)")
//            }
//        }
//    }
//
//    func markAllItemsAsFavorite() {
//        let batchUpdateRequest = NSBatchUpdateRequest(entityName: "Item")
//        batchUpdateRequest.propertiesToUpdate = ["isFavorite": true]
//        batchUpdateRequest.resultType = .updatedObjectIDsResultType
//
//        do {
//            let result = try viewContext.execute(batchUpdateRequest) as? NSBatchUpdateResult
//            if let objectIDs = result?.result as? [NSManagedObjectID] {
//                NSManagedObjectContext.mergeChanges(
//                    fromRemoteContextSave: [NSUpdatedObjectsKey: objectIDs],
//                    into: [viewContext]
//                )
//            }
//            logger.info("\(result?.result as? Int ?? 0) items updated.")
//        } catch {
//            logger.error("Error updating items as favorite: \(error.localizedDescription)")
//        }
//    }
//
//    // MARK: - Undo/Redo
//
//    func enableUndo() {
//        viewContext.undoManager = UndoManager()
//    }
//
//    func disableUndo() {
//        viewContext.undoManager = nil
//    }
//
//    func undo() {
//        viewContext.undo()
//        saveContext()
//    }
//
//    func redo() {
//        viewContext.redo()
//        saveContext()
//    }
//
//    // MARK: - Combine
//
//    private var cancellables = Set<AnyCancellable>()
//
//    func observeItemChanges() -> AnyPublisher<[Item], Never> {
//        NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: viewContext)
//            .map { _ in
//                self.fetchAllItems()
//            }
//            .eraseToAnyPublisher()
//    }
//
//    @available(iOS 16, *)
//    func fetchAllItemsAsync() async throws -> [Item] {
//        // For an actual async sequence-based fetch in iOS 16+, use:
//        // return try await viewContext.perform {
//        //     try viewContext.fetch(Item.fetchRequest())
//        // }
//        // Below is a simplified version returning a normal array:
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        return try viewContext.fetch(request)
//    }
//
//    // MARK: - Query Generations Example
//    func getCurrentQueryGenerationToken() {
//        do {
//            let token = try viewContext.currentQueryGenerationToken
//            print("Current query token: \(String(describing: token))")
//        } catch {
//            print("Cannot retrieve current token: \(error)")
//        }
//    }
//
//    deinit {
//        cancellables.forEach { $0.cancel() }
//    }
//}
//
//// MARK: - SwiftUI Views
//
//struct CoreDataContentView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
//
//    @State private var showingAddItemView = false
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(items) { item in
//                    HStack {
//                        Text(item.name)
//                        Spacer()
//                        Text("Qty: \(item.quantity)")
//                        if item.isFavorite {
//                            Image(systemName: "star.fill")
//                        }
//                        if let category = item.category {
//                            Text("(\(category.name))")
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                        }
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .navigationTitle("Items")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Add Item") {
//                        showingAddItemView = true
//                    }
//                }
//                ToolbarItem(placement: .navigationBarLeading) {
//                    EditButton()
//                }
//            }
//            .sheet(isPresented: $showingAddItemView) {
//                AddItemView()
//                    .environment(\.managedObjectContext, viewContext)
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        offsets.map { items[$0] }.forEach(viewContext.delete)
//        CoreDataManager.shared.saveContext()
//    }
//}
//
//struct AddItemView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @Environment(\.dismiss) var dismiss
//
//    @State private var itemName: String = ""
//    @State private var itemQuantity: Int = 1
//    @State private var isFavorite: Bool = false
//    @State private var selectedCategory: String = ""
//
//    var body: some View {
//        NavigationView {
//            Form {
//                TextField("Item Name", text: $itemName)
//                Stepper("Quantity: \(itemQuantity)", value: $itemQuantity, in: 1...100)
//                Toggle("Favorite", isOn: $isFavorite)
//                TextField("Category Name", text: $selectedCategory)
//            }
//            .navigationTitle("Add Item")
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Save") {
//                        CoreDataManager.shared.createItem(
//                            name: itemName,
//                            quantity: Int32(itemQuantity),
//                            categoryName: selectedCategory,
//                            isFavorite: isFavorite
//                        )
//                        dismiss()
//                    }
//                    .disabled(itemName.isEmpty)
//                }
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        // In-memory store for previews
//        CoreDataContentView()
//            .environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
//    }
//}
//
//// MARK: - Initialization
//
//func initializeApp() {
//    _ = CoreDataManager.shared
//}
