//
//  ConsolidatedView.swift
//  MyApp
//
//  Created by Cong Le on 3/11/25.
//

import SwiftUI
import AVFoundation // For barcode scanning

// MARK: - Error Handling

enum InventoryError: Error, LocalizedError {
    case invalidInput
    case duplicateItem
    case databaseError(Error)
    case barcodeScanError(String)
    case cameraPermissionDenied

    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Invalid input provided."
        case .duplicateItem:
            return "An item with this barcode already exists."
        case .databaseError(let underlyingError):
            return "A database error occurred: \(underlyingError.localizedDescription)"
        case .barcodeScanError(let message):
            return "Barcode scanning error: \(message)"
        case .cameraPermissionDenied:
            return "Camera permission is required to scan barcodes. Please enable it in Settings."
        }
    }
}

// MARK: - Data Models (Simplified for UI Focus)

// In a real app, these would be Core Data or Realm objects.
struct Item: Identifiable {
    let id = UUID() // Use UUID for Identifiable
    var barcode: String
    var name: String
    var quantity: Int
    var category: String?
    var imageURL: String?
    var itemDescription: String?
    var price: Double?
    // var lastUpdated: Date? // For simplicity, we won't directly use Date in the UI in this example.

    // Example initializer for adding new item
    init(barcode: String, name: String, quantity: Int, category: String? = nil, imageURL: String? = nil, description: String? = nil, price:Double? = nil) {
        self.barcode = barcode
        self.name = name
        self.quantity = quantity
        self.category = category
        self.imageURL = imageURL
        self.itemDescription = description
        self.price = price
    }
}

// Category struct (simplified)
struct Category: Identifiable {  // Identifiable for easier use in SwiftUI Lists, etc.
    let id = UUID()
    var categoryID: String
    var categoryName: String
}


// MARK: - View Models (Simplified)

// In a complete application, this would be more robust, handling data persistence,
// asynchronous operations, and potentially using Combine for data binding.

class InventoryViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var categories: [Category] = [] // Add categories
    @Published var isShowingScanner = false
    @Published var isShowingAddItemSheet = false
    @Published var scannedBarcode: String = ""
    @Published var lastScannedItems: [Item] = [] // For continuous scan mode
    @Published var errorMessage: String?
    @Published var isShowingErrorAlert = false

    // Computed property to check if an item with the scanned barcode exists
       var itemExists: Bool {
           !items.filter { $0.barcode == scannedBarcode }.isEmpty
       }

    // MARK: Error Handling
    func presentError(_ error: InventoryError) {
           errorMessage = error.localizedDescription
           isShowingErrorAlert = true
       }
    
    // Placeholder function to add a new item
    func addItem(item: Item) {
        // Input validation
        let validationResult = validateItem(item)
        switch validationResult {
        case .success:
             // Check for duplicates
            if items.contains(where: { $0.barcode == item.barcode }) {
                presentError(.duplicateItem)
                return
            }
            
            // Add the item if validation passes and it's not a duplicate
            items.append(item)
            isShowingAddItemSheet = false
            scannedBarcode = ""  // Reset barcode after adding
        case .failure(let error):
             // Display the error
            presentError(error)
        }
    }

    // Placeholder function to update an existing item
    func updateItem(updatedItem: Item) {
        if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
            items[index] = updatedItem
        }
    }
    
    func validateItem(_ item: Item) -> Result<Void, InventoryError> {
        guard !item.barcode.isEmpty, !item.name.isEmpty, item.quantity >= 0 else {
                return .failure(.invalidInput)
            }
            return .success(())
    }
    
    // Delete item by barcode
    func deleteItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    // MARK: Scanning Methods
       func handleScannedBarcode(_ barcode: String) {
           scannedBarcode = barcode

           if let existingItem = items.first(where: { $0.barcode == barcode }) {
               // Update existing item
               let updatedItem = Item(barcode: existingItem.barcode,
                                      name: existingItem.name,
                                      quantity: existingItem.quantity + 1,
                                      category: existingItem.category,
                                      imageURL: existingItem.imageURL,
                                      description: existingItem.itemDescription,
                                      price: existingItem.price)
               updateItem(updatedItem: updatedItem)
           } else {
               // Show "Add Item" sheet
               isShowingAddItemSheet = true
           }
       }
    // Add categories
    func addCategory(category: Category) {
            categories.append(category)
        }
}



// MARK: - Main App View

struct ContentView: View {
    @StateObject private var viewModel = InventoryViewModel()
    @State private var isShowingSettings = false
    @State private var selection: String?  = "Items"
    
    var body: some View {
        NavigationView {
            List {
                if selection == "Items" {
                ForEach(viewModel.items) { item in
                    NavigationLink(destination: ItemDetailView(item: item, viewModel: viewModel)) {
                        ItemRow(item: item)
                    }
                }
                .onDelete(perform: viewModel.deleteItem)
                } else if selection == "Categories" {
                            ForEach(viewModel.categories) { category in
                                CategoryRow(category: category) // Assuming you have a CategoryRow view
                            }
                        }
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker("", selection: $selection) {
                        Text("Items").tag("Items")
                        Text("Categories").tag("Categories")
                    }
                    .pickerStyle(.segmented)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                    Button(action: {
                        viewModel.isShowingScanner = true
                    }) {
                        Image(systemName: "barcode.viewfinder")
                    }
                    Button(action: {
                                    viewModel.isShowingAddItemSheet = true
                                }) {
                                    Image(systemName: "plus")
                                }
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingScanner) {
                BarcodeScannerView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.isShowingAddItemSheet) {
                            AddItemView(viewModel: viewModel)
            }
            .alert(isPresented: $viewModel.isShowingErrorAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
        }
    }
}

// MARK: - Supporting Views
struct ItemRow: View {
    let item: Item

    var body: some View {
        HStack {
            // Placeholder for image loading (you'd use an image loading library like Kingfisher or SDWebImage)
            Image(systemName: "photo")
                .resizable()
                .frame(width: 40, height: 40)
                .cornerRadius(8)

            VStack(alignment: .leading) {
                Text(item.name).font(.headline)
                Text("Barcode: \(item.barcode)")
                Text("Quantity: \(item.quantity)")
            }
        }
    }
}

// A simple view to show the CategoryRow
struct CategoryRow: View {
    let category: Category

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(category.categoryName).font(.headline)
                Text("Category ID: \(category.categoryID)")
            }
        }
    }
}


struct ItemDetailView: View {
    @ObservedObject var viewModel: InventoryViewModel
    @State var item: Item
    @State private var isEditing = false
    @State private var editedName: String
    @State private var editedQuantity: Int
    @State private var editedCategory: String?
    @State private var editedDescription: String?
    @State private var editedPrice: String?
    

    init(item: Item, viewModel: InventoryViewModel) {
        self.viewModel = viewModel
        self._item = State(initialValue: item)  // Initialize the @State variable
        self._editedName = State(initialValue: item.name)
        self._editedQuantity = State(initialValue: item.quantity)
        self._editedCategory = State(initialValue: item.category)
        self._editedDescription = State(initialValue: item.itemDescription)
        self._editedPrice = State(initialValue: String(item.price ?? 0.00) )
    }

    var body: some View {
        Form {
            Section(header: Text("Item Details")) {
                if isEditing {
                    TextField("Name", text: $editedName)
                    Stepper("Quantity: \(editedQuantity)", value: $editedQuantity, in: 0...Int.max)
                    TextField("Category", text: Binding(
                        get: { self.editedCategory ?? "" },
                        set: { self.editedCategory = $0 }
                    ))
                    TextField("Description", text: Binding(
                        get: { self.editedDescription ?? "" },
                        set: { self.editedDescription = $0 }
                    ))
                    TextField("Price", text: Binding(
                        get: { self.editedPrice ?? ""},
                        set: { self.editedPrice = $0}
                    ))
                } else {
                    Text("Name: \(item.name)")
                    Text("Quantity: \(item.quantity)")
                    Text("Barcode: \(item.barcode)")
                    if let category = item.category {
                        Text("Category: \(category)")
                    }
                    if let description = item.itemDescription {
                                            Text("Description: \(description)")
                                        }
                    if let price = item.price {
                                            Text("Price: \(price)")
                                        }
                }
            }

            Section {
                Button(isEditing ? "Save Changes" : "Edit") {
                    if isEditing {
                        // Convert editedPrice to Double
                        let price = Double(editedPrice ?? "")
                        
                        // Update the item
                        let updatedItem = Item(barcode: item.barcode,
                                               name: editedName,
                                               quantity: editedQuantity,
                                               category: editedCategory,
                                               imageURL: item.imageURL,
                                               description: editedDescription,
                                               price: price)
                        
                        // Validate before updating
                                       let validationResult = viewModel.validateItem(updatedItem)
                                       switch validationResult {
                                       case .success:
                                           viewModel.updateItem(updatedItem: updatedItem)
                                           item = updatedItem // Update the local item
                                           isEditing = false
                                       case .failure(let error):
                                           viewModel.presentError(error) // Show error
                                       }
                    } else {
                        isEditing = true
                    }
                }
            }
        }
        .navigationTitle("Item Details")
    }
}

// MARK: - Add Item View

struct AddItemView: View {
    @ObservedObject var viewModel: InventoryViewModel
    @Environment(\.dismiss) var dismiss
    @State private var newItemName: String = ""
    @State private var newItemQuantity: Int = 1
    @State private var newItemCategory: String? = nil
    @State private var newItemDescription: String? = ""
    @State private var newItemPrice: String? = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $newItemName)
                    Stepper("Quantity: \(newItemQuantity)", value: $newItemQuantity, in: 0...Int.max)
                    TextField("Category", text: Binding(
                        get: { self.newItemCategory ?? "" },
                        set: { self.newItemCategory = $0 }))
                    TextField("Barcode", text: $viewModel.scannedBarcode)
                        .disabled(true)  // Initially, the barcode field is populated by the scan
                    TextField("Description", text: Binding(
                        get: { self.newItemDescription ?? "" },
                        set: { self.newItemDescription = $0 }))
                    TextField("Price", text: Binding(
                        get: { self.newItemPrice ?? ""},
                        set: { self.newItemPrice = $0}
                    ))
                }

                Section {
                    Button("Add Item") {
                        // Convert editedPrice to Double
                        let price = Double(newItemPrice ?? "")
                        
                        // Create the new item
                        let newItem = Item(barcode: viewModel.scannedBarcode,
                                           name: newItemName,
                                           quantity: newItemQuantity,
                                           category: newItemCategory,
                                           description: newItemDescription,
                                           price: price)
                        
                        viewModel.addItem(item: newItem)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Add New Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}


// MARK: - Barcode Scanner View (using a UIViewControllerRepresentable)

struct BarcodeScannerView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: InventoryViewModel
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> ScannerViewController {
        let scannerVC = ScannerViewController()
        scannerVC.delegate = context.coordinator
        return scannerVC
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(scannerView: self)
    }

    class Coordinator: NSObject, ScannerViewDelegate {
        let scannerView: BarcodeScannerView

        init(scannerView: BarcodeScannerView) {
            self.scannerView = scannerView
        }

        func didFindBarcode(barcode: String) {
            scannerView.viewModel.handleScannedBarcode(barcode)  // Call viewModel to handle
            scannerView.presentationMode.wrappedValue.dismiss()
        }

        func didSurfaceError(error: Error) {
            // Handle errors (e.g., display an alert)
            print("Scanner error: \(error)") // Log for debugging
            if let inventoryError = error as? InventoryError {
                scannerView.viewModel.presentError(inventoryError)
            } else {
                // Handle other types of errors
                scannerView.viewModel.presentError(.barcodeScanError(error.localizedDescription))
            }
        }
    }
}

// MARK: - Scanner View Controller (AVFoundation)

protocol ScannerViewDelegate: AnyObject {
    func didFindBarcode(barcode: String)
    func didSurfaceError(error: Error)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: ScannerViewDelegate?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()

        // Check for camera permissions.
        checkCameraPermission()
    }

    func checkCameraPermission() {
           switch AVCaptureDevice.authorizationStatus(for: .video) {
           case .authorized: // The user has previously granted access to the camera.
               setupCaptureSession()

           case .notDetermined: // The user has not yet been asked for camera access.
               AVCaptureDevice.requestAccess(for: .video) { granted in
                   if granted {
                       DispatchQueue.main.async {
                           self.setupCaptureSession()
                       }
                   } else {
                       DispatchQueue.main.async {
                           // Handle the case where the user denies access.
                           self.delegate?.didSurfaceError(error: InventoryError.cameraPermissionDenied)
                           self.dismiss(animated: true)
                       }
                   }
               }

           case .denied: // The user has previously denied access.
               // Inform the user and potentially guide them to settings.
               delegate?.didSurfaceError(error: InventoryError.cameraPermissionDenied)
               return

           case .restricted: // The user can't grant access due to restrictions.
               // Inform the user that camera access is restricted.
                delegate?.didSurfaceError(error: InventoryError.cameraPermissionDenied)
               return
           @unknown default:
               fatalError()
           }
       }
    
    func setupCaptureSession() {
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                delegate?.didSurfaceError(error: InventoryError.barcodeScanError("Camera not available"))
                return
            }
            let videoInput: AVCaptureDeviceInput

            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                delegate?.didSurfaceError(error: InventoryError.barcodeScanError(error.localizedDescription))
                return
            }

            if (captureSession.canAddInput(videoInput)) {
                captureSession.addInput(videoInput)
            } else {
                delegate?.didSurfaceError(error: InventoryError.barcodeScanError("Could not add video input"))
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if (captureSession.canAddOutput(metadataOutput)) {
                captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce, .code39, .code128, .qr] // Add supported barcode types
            } else {
                delegate?.didSurfaceError(error: InventoryError.barcodeScanError("Could not add metadata output"))
                return
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in // Capture session start should be on background thread.
                self?.captureSession.startRunning()
            }
        }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in  // Also restart on appear
                self?.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) // Add haptic feedback
            delegate?.didFindBarcode(barcode: stringValue)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}



// MARK: - Preview Provider (for Xcode Canvas)

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
