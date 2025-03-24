//
//  CoreDataView.swift
//  MyApp
//
//  Created by Cong Le on 3/24/25.
//

import CoreData
import SwiftUI
import Combine
import OSLog

// MARK: - Core Data Model

// Define entities, attributes, and relationships programmatically.  While you'd typically
// use the visual editor in Xcode, this demonstrates how it *could* be done in code.
// This is less common but shows full control.

func createCoreDataModel() -> NSManagedObjectModel {
    // 1. Create Attribute Descriptions

    // --- Item Entity Attributes ---
    let itemNameAttribute = NSAttributeDescription()
    itemNameAttribute.name = "name"
    itemNameAttribute.attributeType = .stringAttributeType
    itemNameAttribute.isOptional = false
//    itemNameAttribute.isIndexed = true // Indexing for performance // deprecared
    itemNameAttribute.index(ofAccessibilityElement: true)

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
    itemNotesAttribute.allowsExternalBinaryDataStorage = true // For large text/data

    // --- Category Entity Attributes ---
    let categoryNameAttribute = NSAttributeDescription()
    categoryNameAttribute.name = "name"
    categoryNameAttribute.attributeType = .stringAttributeType
    categoryNameAttribute.isOptional = false

    let categoryColorAttribute = NSAttributeDescription()
    categoryColorAttribute.name = "color"
    categoryColorAttribute.attributeType = .stringAttributeType // Store color as hex string
    categoryColorAttribute.isOptional = true

    // 2. Create Relationship Descriptions
        // --- Item -> Category ---
    let itemToCategoryRelationship = NSRelationshipDescription()
    itemToCategoryRelationship.name = "category"
    itemToCategoryRelationship.deleteRule = .nullifyDeleteRule // What happens to items if category is deleted?
    itemToCategoryRelationship.isOptional = true

    // --- Category -> Items ---
    let categoryToItemsRelationship = NSRelationshipDescription()
    categoryToItemsRelationship.name = "items"
    categoryToItemsRelationship.deleteRule = .cascadeDeleteRule // Delete items in category if category is deleted
    categoryToItemsRelationship.isToMany = true

     // 3. Create Fetched Property Description.
    let itemHighQuantity = NSPredicate(format: "quantity > 50")
    let highQuantityFetchedProperty = NSFetchedPropertyDescription()
    highQuantityFetchedProperty.name = "highQuantityItems"
    highQuantityFetchedProperty.predicate = itemHighQuantity

    // 4. Create Entity Descriptions
    let itemEntity = NSEntityDescription()
    itemEntity.name = "Item"
    itemEntity.managedObjectClassName = "Item" //  Will create this class below
    itemEntity.properties = [itemNameAttribute, itemTimestampAttribute, itemQuantityAttribute, itemIsFavoriteAttribute, itemNotesAttribute, itemToCategoryRelationship]

    let categoryEntity = NSEntityDescription()
    categoryEntity.name = "Category"
    categoryEntity.managedObjectClassName = "Category" // Will create this class below
    categoryEntity.properties = [categoryNameAttribute, categoryToItemsRelationship, categoryColorAttribute, highQuantityFetchedProperty]

    // 5. Set up Inverse Relationships (CRUCIAL)
    itemToCategoryRelationship.destinationEntity = categoryEntity
    itemToCategoryRelationship.inverseRelationship = categoryToItemsRelationship

    categoryToItemsRelationship.destinationEntity = itemEntity
    categoryToItemsRelationship.inverseRelationship = itemToCategoryRelationship

    highQuantityFetchedProperty.entity = itemEntity

    // 6. Create the Model
    let model = NSManagedObjectModel()
    model.entities = [itemEntity, categoryEntity]

       // Example of setting a configuration (e.g., for different stores)
    model.setEntities([itemEntity], forConfigurationName: "ItemsConfig")
    model.setEntities([categoryEntity], forConfigurationName: "CategoriesConfig")

    return model
}


// MARK: - NSManagedObject Subclasses

// Define our custom classes representing the entities.
class Item: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var timestamp: Date
    @NSManaged var quantity: Int32
    @NSManaged var isFavorite: Bool
    @NSManaged var notes: String?
    @NSManaged var category: Category? // Relationship
    
    // Example of custom validation
    override func willSave() {
        super.willSave()
        if name.isEmpty {
            // Handle empty name (e.g., set a default, or throw an error)
            name = "Unnamed Item"
        }
        if let notes = notes, notes.count > 1000 {  //Limit note length check
           // self.notes = notes.prefix(10)
        }

    }
    override func awakeFromInsert() {
      super.awakeFromInsert()
      setPrimitiveValue(Date(), forKey: "timestamp") //Set creation timestamp
    }

    // Helper method (a good practice to include in your NSManagedObject subclasses)
    static func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }
}


class Category: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var color: String?
    @NSManaged var items: Set<Item>?
    @NSManaged var highQuantityItems: [Item]

    // Helper methods to work with `items` as a set
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

    //Helper method
    static func fetchRequest() -> NSFetchRequest<Category>{
        return NSFetchRequest<Category>(entityName: "Category")
    }
}



// MARK: - Core Data Stack (using NSPersistentContainer)

class CoreDataManager {

    static let shared = CoreDataManager() // Singleton

    let persistentContainer: NSPersistentContainer
    let logger = Logger(subsystem: "com.example.MyCoreDataApp", category: "CoreDataManager") // OSLog

    private init() {
        let model = createCoreDataModel()
        persistentContainer = NSPersistentContainer(name: "MyModel", managedObjectModel: model) // Use custom programmatic model

        // Configure for CloudKit (Optional - but demonstrates advanced configuration)
        let cloudKitContainerIdentifier = "iCloud.com.your.app.bundle.id" // Replace

       guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Could not determine documents directory")
            }
        let storeURL = documentsDirectoryURL.appendingPathComponent("MyModel.sqlite")
        
       let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.shouldInferMappingModelAutomatically = true // Try lightweight migration
        storeDescription.shouldMigrateStoreAutomatically = true
        
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey) // Enable Persistent History Tracking
        //For CloudKit, configure options on description
        storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: cloudKitContainerIdentifier)



        persistentContainer.persistentStoreDescriptions = [storeDescription]

        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                self.logger.error("Core Data store failed to load: \(error.localizedDescription)")
                fatalError("Failed to load Core Data stack: \(error)") // Handle this more gracefully in a real app
            }
            self.logger.info("Core Data stack loaded successfully.")

            //Enable remote change notifications
            self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            // self.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy // Example merge policy setting
            self.persistentContainer.viewContext.mergePolicy =  NSMergePolicy.mergeByPropertyObjectTrump
        }
    }

    // MARK: - Context Management
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // Create temporary contexts
    func childViewContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = viewContext
        return context
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }

    // MARK: - CRUD Operations (Create, Read, Update, Delete)

    // Generic fetch function
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {
        do {
            let results = try viewContext.fetch(request)
            return results
        } catch {
            logger.error("Error fetching \(T.self): \(error.localizedDescription)")
            return []
        }
    }

     func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                logger.info("Main context saved successfully.")
            } catch {
               logger.error("Error saving main context\(error.localizedDescription)")
                // Handle the error appropriately.  Don't just print in a real app!
                print("Error saving context: \(error)")
            }
        }
    }
    // Generic save function for any context
      func save(context: NSManagedObjectContext) throws{
          guard context.hasChanges else { return }
          try context.save()
      }

    func createItem(name: String, quantity: Int32, categoryName: String? = nil, isFavorite: Bool = false) {
        let newItem = Item(context: viewContext) // Use the main context (viewContext) for UI-related operations
        newItem.name = name
        newItem.timestamp = Date()
        newItem.quantity = quantity
        newItem.isFavorite = isFavorite

        // Add or create category if needed
        if let categoryName = categoryName{
           addCategory(named: categoryName)
            if let category = fetchCategory(named: categoryName) {
                newItem.category = category
                category.addToItems(newItem) // For inverse relationship
            }
        }
        saveContext()
    }
    
    //Add category function
    func addCategory(named name: String){
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.fetchLimit = 1

        do{
         let result = try viewContext.fetch(fetchRequest)
            if result.isEmpty{
              let newCategory = Category(context: viewContext)
                newCategory.name = name
                try save(context: viewContext)
            }
        }
          catch{
              logger.error("Error adding category \(error.localizedDescription)")
              print("Error adding/creating category")
          }
    }
    //Fetch Category
    func fetchCategory(named name: String) -> Category?{
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.fetchLimit = 1

        do{
            let categories = try viewContext.fetch(fetchRequest)
            return categories.first
        } catch{
            logger.error("Error fetching category \(error.localizedDescription)")
            return nil
          }

    }
    
    func fetchAllItems(sortedBy: String? = "timestamp", ascending: Bool = false) -> [Item] {
        
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        // Predicate (Optional - Example of filtering)
         let predicate = NSPredicate(format: "quantity > %@", NSNumber(value: 0))
        fetchRequest.predicate = predicate
         // predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [highQuantityPredicate, isFavoritePredicate]) for complex predicates.

        // Sort Descriptors (Optional)
        if let sortKey = sortedBy {
            let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: ascending)
            fetchRequest.sortDescriptors = [sortDescriptor]
        }

       // Set batch size (Optional, but GOOD)
       fetchRequest.fetchBatchSize = 20 // Optimize based on your needs.
        return fetch(fetchRequest)
    }

    func fetchItems(withName name: String) -> [Item]{
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", name)
        return fetch(fetchRequest)
    }

    func updateItem(item: Item, newName: String, isFavorite: Bool? = nil) {
        item.name = newName //Modify data on MOC
        if let isFavorite = isFavorite{
            item.isFavorite = isFavorite
        }
        saveContext() //Save changes on MOC
    }

    // Updates involving relationships AND using a background context
    func categorizeItem(item: Item, categoryName: String) {
        performBackgroundTask { context in
            // You MUST fetch objects again within the background context
            guard let backgroundItem = context.object(with: item.objectID) as? Item else { return }
            if let existingCategory = self.fetchCategory(named: categoryName, in: context) {
                backgroundItem.category = existingCategory
            } else {
                let newCategory = Category(context: context)
                newCategory.name = categoryName
                backgroundItem.category = newCategory
            }

            do {
                try self.save(context: context)
                // Consider posting a notification that the data has changed, so the UI can update.
            } catch {
                // Handle errors
                print("Error categorizing item: \(error)")
            }
        }
    }

    // Fetches a category inside a specific context (useful for background contexts)
       func fetchCategory(named name: String, in context: NSManagedObjectContext) -> Category? {
           let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
           fetchRequest.predicate = NSPredicate(format: "name == %@", name)
           fetchRequest.fetchLimit = 1

           do {
               let categories = try context.fetch(fetchRequest) // Fetch in the provided context
               return categories.first
           } catch {
               print("Error fetching category: \(error)")
               return nil
           }
       }

    func deleteItem(item: Item) {
        viewContext.delete(item) //Marked for deletion on MOC
        saveContext() // Remove context
    }

    // Example using NSBatchDeleteRequest (more efficient for bulk deletes)
    func deleteAllItems() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Item")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs // Get IDs of deleted objects.

        performBackgroundTask { context in
            do {
                let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
                if let objectIDs = result?.result as? [NSManagedObjectID] {
                    // Optionally, use objectIDs to update other contexts, or notify observers.
                      NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs], into: [self.viewContext]) //Merge changes to other contexts.
                }

                try self.save(context: context)
            } catch {
                self.logger.error("Error performing batch delete: \(error.localizedDescription)")
                print("Error performing batch delete: \(error)")
            }
        }
    }

    // Example using NSBatchUpdateRequest
    func markAllItemsAsFavorite() {
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: "Item")
        batchUpdateRequest.propertiesToUpdate = ["isFavorite": true]
        batchUpdateRequest.resultType = .updatedObjectsCountResultType

        do {
            let result = try viewContext.execute(batchUpdateRequest) as? NSBatchUpdateResult
            logger.info("\(result?.result as? Int ?? 0) items updated.")
            print("\(result?.result as? Int ?? 0) items updated.")
        } catch {
            logger.error("Error update items as favorite: \(error.localizedDescription)")
            print("Error updating items: \(error)")
        }
    }

    // MARK: - Undo/Redo (Example)

    func enableUndo() {
        viewContext.undoManager = UndoManager()
    }

    func disableUndo() {
        viewContext.undoManager = nil
    }

    func undo() {
        viewContext.undo()
        saveContext()
    }

    func redo() {
        viewContext.redo()
        saveContext()
    }
    
     // MARK: - Error Handling (Example - could be expanded)
    
    enum CoreDataError: Error {
        case fetchError(underlyingError: Error)
        case saveError(underlyingError: Error)
        case validationError(message: String)
        // Add other specific cases as needed
    }


    // MARK: - Combine (Example)

    // Could use NSFetchedResultsController's publisher, or roll your own like this:
      private var cancellables = Set<AnyCancellable>()

      func observeItemChanges() -> AnyPublisher<[Item], Never> {
          NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: viewContext)
              .compactMap { notification -> [Item]? in // Could filter based on the notification's userInfo
                  return self.fetchAllItems() // Simple example: Fetch all items on any change.
              }
              .eraseToAnyPublisher()
      }

    // MARK: - Asynchronous fetching example.
      @available(iOS 15, *)
        func fetchAllItemsAsync() async throws -> [Item] {
            let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
            
            let asyncSequence = viewContext.fetchObjects(matching:fetchRequest)
            var fetchedItems: [Item] = []
             for try await item in asyncSequence{
                fetchedItems.append(item)
             }
            return fetchedItems
    }
    
    // MARK: - Query Generations Example
    func getCurrentQueryGenerationToken(){
        performBackgroundTask { context in
            do{
              let token = try context.queryGenerationToken(for: .current)
                print("Current query token: \(token)")
            }
            catch{
                print("Cannot retrieve current token")
            }
        }
    }


    // MARK: - Deinit (for completeness - though less critical with a singleton)

    deinit {
        cancellables.forEach { $0.cancel() } // Clean up Combine subscriptions
    }
}

// MARK: - SwiftUI Integration (Example)
// Demonstrates a very basic SwiftUI setup, including injecting the Core Data context.

struct ContentView: View {

    @Environment(\.managedObjectContext) private var viewContext // Get from the environment
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>  // Automatically updated

    @State private var showingAddItemView = false

    @StateObject private var coreDataManager = CoreDataManager.shared // Access singleton


    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text("Qty: \(item.quantity)")
                        if item.isFavorite{
                            Image(systemName: "star.fill")
                        }

                        if let category = item.category{
                            Text("(\(category.name))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        // Other item details
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Items")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Item") {
                        showingAddItemView = true
                    }
                }
                ToolbarItem(placement: .navigationBarLeading){
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddItemView){
                AddItemView()
                    .environment(\.managedObjectContext, coreDataManager.viewContext) //Provide managed object context.
            }
        }
    }
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(coreDataManager.deleteItem) // Use CD manager for CRUD
        }
    }
}


struct AddItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.dismiss) var dismiss

    @State private var itemName: String = ""
    @State private var itemQuantity: Int = 1
    @State private var isFavorite: Bool = false
    @State private var selectedCategory: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Item Name", text: $itemName)
                Stepper("Quantity: \(itemQuantity)", value: $itemQuantity, in: 1...100)
                Toggle("Favorite", isOn: $isFavorite)
                TextField("Category Name", text: $selectedCategory)


            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Use the CoreDataManager to create items:
                        CoreDataManager.shared.createItem(name: itemName, quantity: Int32(itemQuantity), categoryName: selectedCategory, isFavorite: isFavorite)
                        dismiss()
                    }
                    .disabled(itemName.isEmpty) // Basic validation
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }

        }
    }
}


// MARK: - Preview (for SwiftUI)
// Sets up an in-memory Core Data store for SwiftUI previews. VERY useful.

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an in-memory Core Data context for the preview
        let context = CoreDataManager.shared.persistentContainer.viewContext
        return ContentView().environment(\.managedObjectContext, context)
    }
}

//MARK: Initialization
//Put this in @main or initialize early

func initializeApp(){
    let _ = CoreDataManager.shared
}
