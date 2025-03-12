////
////  DataFlow.swift
////  MyApp
////
////  Created by Cong Le on 3/11/25.
////
//
//import SwiftUI
//
//// MARK: - Data Model and Manager
//
//// Simple Item struct representing an inventory item.
//struct Item: Identifiable, Equatable {
//    let id = UUID()
//    var barcode: String
//    var name: String
//    var quantity: Int
//    var details: String = ""
//}
//
//// An enum to represent potential error cases.
//enum InventoryError: Error {
//    case invalidInput, duplicateItem, updateFailure
//}
//
//// A simple ObservableObject to manage a list of items.
//class InventoryManager: ObservableObject {
//    @Published var items: [Item] = []
//    
//    // Lookup an item by barcode.
//    func getItem(byBarcode barcode: String) -> Item? {
//        return items.first { $0.barcode == barcode }
//    }
//    
//    // Add a new item; returns true if successful.
//    func addItem(item: Item) -> Result<Void, InventoryError> {
//        if item.barcode.isEmpty || item.name.isEmpty || item.quantity < 0 {
//            return .failure(.invalidInput)
//        }
//        if getItem(byBarcode: item.barcode) != nil {
//            return .failure(.duplicateItem)
//        }
//        items.append(item)
//        return .success(())
//    }
//    
//    // Update quantity for an existing item.
//    func updateQuantity(forBarcode barcode: String, newQuantity: Int) -> Result<Void, InventoryError> {
//        if let index = items.firstIndex(where: { $0.barcode == barcode }) {
//            items[index].quantity = newQuantity
//            return .success(())
//        }
//        return .failure(.updateFailure)
//    }
//    
//    // Search items by name or barcode.
//    func searchItems(query: String) -> [Item] {
//        if query.isEmpty { return items }
//        return items.filter { $0.name.lowercased().contains(query.lowercased()) ||
//                              $0.barcode.lowercased().contains(query.lowercased()) }
//    }
//}
//
//// MARK: - Main Content View
//
//struct DataFlowContentView: View {
//    @ObservedObject var inventoryManager = InventoryManager()
//    @State private var isScanning = false
//    @State private var showingAddItem = false
//    @State private var showingSettings = false
//    @State private var searchText: String = ""
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                // Search bar for filtering items.
//                TextField("Search items...", text: $searchText)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//                
//                // List of inventory items.
//                List {
//                    ForEach(inventoryManager.searchItems(query: searchText)) { item in
//                        NavigationLink(destination: ItemDetailView(item: item, inventoryManager: inventoryManager)) {
//                            VStack(alignment: .leading) {
//                                Text(item.name)
//                                    .font(.headline)
//                                HStack {
//                                    Text("Barcode: \(item.barcode)")
//                                    Spacer()
//                                    Text("Qty: \(item.quantity)")
//                                }
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                            }
//                        }
//                    }
//                }
//                
//                // Bottom Bar: Scan and Add buttons.
//                HStack {
//                    Button(action: { isScanning = true }) {
//                        Label("Scan", systemImage: "barcode.viewfinder")
//                            .frame(maxWidth: .infinity)
//                    }
//                    .buttonStyle(PrimaryButtonStyle())
//                    
//                    Button(action: { showingAddItem = true }) {
//                        Label("Add Item", systemImage: "plus.circle")
//                            .frame(maxWidth: .infinity)
//                    }
//                    .buttonStyle(PrimaryButtonStyle())
//                }
//                .padding(.horizontal)
//            }
//            .navigationBarTitle("Inventory")
//            .navigationBarItems(trailing:
//                Button(action: { showingSettings = true }) {
//                    Image(systemName: "gearshape")
//                }
//            )
//            .sheet(isPresented: $isScanning) {
//                // Present scanning view modally.
//                ScanView(inventoryManager: inventoryManager)
//            }
//            .sheet(isPresented: $showingAddItem) {
//                AddItemView(inventoryManager: inventoryManager)
//            }
//            .sheet(isPresented: $showingSettings) {
//                SettingsView()
//            }
//        }
//    }
//}
//
//// MARK: - Scan View
//
//struct ScanView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @ObservedObject var inventoryManager: InventoryManager
//    
//    // Simulated scanned barcode result.
//    @State private var scannedBarcode: String = ""
//    @State private var isProcessing: Bool = false
//    @State private var errorMessage: String?
//    @State private var navigateToDetail: Bool = false
//    @State private var foundItem: Item?
//    @State private var showingAddItem: Bool = false
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                // This rectangle simulates the camera preview.
//                Rectangle()
//                    .fill(Color.gray.opacity(0.3))
//                    .overlay(
//                        Text("Camera Preview\n(Barcode Detection Overlay)")
//                            .multilineTextAlignment(.center)
//                    )
//                    .frame(height: 300)
//                    .cornerRadius(10)
//                    .padding()
//                
//                if isProcessing {
//                    ProgressView("Processing Barcode...")
//                        .padding()
//                }
//                
//                // For demo, a manual trigger for a "detected barcode".
//                Button("Simulate Scan") {
//                    simulateBarcodeScan()
//                }
//                .buttonStyle(PrimaryButtonStyle())
//                .padding()
//                
//                // Display error if barcode decode failed.
//                if let errorMessage = errorMessage {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                        .padding()
//                }
//                
//                // NavigationLink to show item details if lookup succeeds.
//                NavigationLink(destination:
//                    ItemDetailView(item: foundItem ?? Item(barcode: "", name: "", quantity: 0),
//                                   inventoryManager: inventoryManager),
//                               isActive: $navigateToDetail) {
//                    EmptyView()
//                }
//            }
//            .navigationTitle("Scan Barcode")
//            .navigationBarItems(leading: Button("Close") {
//                presentationMode.wrappedValue.dismiss()
//            })
//        }
//    }
//    
//    // Simulate a barcode scan, decode and lookup.
//    private func simulateBarcodeScan() {
//        isProcessing = true
//        errorMessage = nil
//        
//        // Simulate asynchronous barcode processing.
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            // For demonstration, we generate a random barcode.
//            // In a real app, you’d use AVFoundation and Vision to detect and decode.
//            scannedBarcode = Bool.random() ? "123456789" : ""
//            
//            if scannedBarcode.isEmpty {
//                errorMessage = "Invalid Barcode. Try Again."
//                isProcessing = false
//            } else {
//                // Lookup item in inventory asynchronously.
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                    if let item = inventoryManager.getItem(byBarcode: scannedBarcode) {
//                        foundItem = item
//                        isProcessing = false
//                        navigateToDetail = true
//                    } else {
//                        // If not found, ask user if they want to add new item.
//                        errorMessage = "Item not found. Would you like to add it?"
//                        // In a complete app, here you’d prompt and navigate to AddItemView.
//                        // For demo, automatically navigate to AddItemView screen.
//                        showingAddItem = true
//                        isProcessing = false
//                        presentationMode.wrappedValue.dismiss()  // Close the scan view.
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Item Detail View
//
//struct ItemDetailView: View {
//    var item: Item
//    @ObservedObject var inventoryManager: InventoryManager
//    @State private var quantity: Int
//    @Environment(\.presentationMode) var presentationMode
//    @State private var errorMessage: String?
//    
//    init(item: Item, inventoryManager: InventoryManager) {
//        self.item = item
//        self.inventoryManager = inventoryManager
//        _quantity = State(initialValue: item.quantity)
//    }
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text(item.name)
//                .font(.largeTitle)
//                .padding(.top)
//            Text("Barcode: \(item.barcode)")
//                .foregroundColor(.secondary)
//            
//            HStack {
//                Button(action: {
//                    if quantity > 0 { quantity -= 1 }
//                }) {
//                    Image(systemName: "minus.circle")
//                        .font(.largeTitle)
//                }
//                Text("\(quantity)")
//                    .font(.title)
//                    .frame(minWidth: 60)
//                Button(action: {
//                    quantity += 1
//                }) {
//                    Image(systemName: "plus.circle")
//                        .font(.largeTitle)
//                }
//            }
//            .padding()
//            
//            if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//            }
//            
//            Button("Update Quantity") {
//                updateQuantity()
//            }
//            .buttonStyle(PrimaryButtonStyle())
//            
//            Spacer()
//        }
//        .padding()
//        .navigationBarTitle("Item Details", displayMode: .inline)
//    }
//    
//    private func updateQuantity() {
//        // Simulate asynchronous update.
//        let result = inventoryManager.updateQuantity(forBarcode: item.barcode, newQuantity: quantity)
//        switch result {
//        case .success:
//            // Optionally display a confirmation (for demo, we just pop back).
//            presentationMode.wrappedValue.dismiss()
//        case .failure:
//            errorMessage = "Failed to update quantity. Please try again."
//        }
//    }
//}
//
//// MARK: - Add/Edit Item View
//
//struct AddItemView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @ObservedObject var inventoryManager: InventoryManager
//    @State private var barcode: String = ""
//    @State private var name: String = ""
//    @State private var quantity: Int = 1
//    @State private var errorMessage: String?
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Item Details")) {
//                    TextField("Barcode", text: $barcode)
//                        .keyboardType(.numberPad)
//                        .accessibilityLabel("Barcode Input")
//                    TextField("Name", text: $name)
//                        .accessibilityLabel("Item Name Input")
//                    Stepper(value: $quantity, in: 1...1000) {
//                        Text("Quantity: \(quantity)")
//                            .accessibilityLabel("Quantity Input")
//                    }
//                }
//                
//                if let errorMessage = errorMessage {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                }
//                
//                Section {
//                    Button("Save Item") {
//                        saveItem()
//                    }
//                    .buttonStyle(PrimaryButtonStyle())
//                }
//            }
//            .navigationBarTitle("Add New Item", displayMode: .inline)
//            .navigationBarItems(leading: Button("Cancel") {
//                presentationMode.wrappedValue.dismiss()
//            })
//        }
//    }
//    
//    private func saveItem() {
//        // Validate and add the new item.
//        let newItem = Item(barcode: barcode, name: name, quantity: quantity)
//        let result = inventoryManager.addItem(item: newItem)
//        switch result {
//        case .success:
//            presentationMode.wrappedValue.dismiss()
//        case .failure(let error):
//            switch error {
//            case .invalidInput:
//                errorMessage = "Please enter valid item details."
//            case .duplicateItem:
//                errorMessage = "An item with this barcode already exists."
//            default:
//                errorMessage = "Failed to save item. Try again."
//            }
//        }
//    }
//}
//
//// MARK: - Settings View
//
//struct DataFlowSettingsView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @State private var soundFeedback: Bool = true
//    @State private var vibrationFeedback: Bool = true
//    @State private var autoScanOption: String = "Single"
//    @State private var cloudService: String = "iCloud"
//    @State private var syncFrequency: String = "Automatic"
//    @State private var theme: String = "Light"
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Scanner Configuration")) {
//                    Toggle("Sound Feedback", isOn: $soundFeedback)
//                    Toggle("Vibration Feedback", isOn: $vibrationFeedback)
//                    Picker("Auto-Scan Options", selection: $autoScanOption) {
//                        Text("Single").tag("Single")
//                        Text("Continuous").tag("Continuous")
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                }
//                
//                Section(header: Text("Data Synchronization")) {
//                    Picker("Cloud Service", selection: $cloudService) {
//                        Text("iCloud").tag("iCloud")
//                        Text("Custom").tag("Custom")
//                    }
//                    Picker("Sync Frequency", selection: $syncFrequency) {
//                        Text("Manual").tag("Manual")
//                        Text("Automatic").tag("Automatic")
//                    }
//                }
//                
//                Section(header: Text("User Interface")) {
//                    Picker("Theme", selection: $theme) {
//                        Text("Light").tag("Light")
//                        Text("Dark").tag("Dark")
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                    // Additional display options can be placed here.
//                }
//                
//                Section {
//                    NavigationLink(destination: AboutView()) {
//                        Text("About & Privacy Policy")
//                    }
//                }
//            }
//            .navigationBarTitle("Settings", displayMode: .inline)
//            .navigationBarItems(leading: Button("Close") {
//                presentationMode.wrappedValue.dismiss()
//            })
//        }
//    }
//}
//
//// MARK: - About & Privacy Policy View
//
//struct AboutView: View {
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                Text("About This App")
//                    .font(.title)
//                    .bold()
//                Text("This inventory app allows you to quickly manage items by scanning barcodes, manually entering data, and adjusting inventory quantities. The app follows user-centric design principles to ensure an intuitive and efficient experience.")
//                Text("Privacy Policy")
//                    .font(.title2)
//                    .bold()
//                Text("Your privacy is important. Data is stored securely locally and, if enabled, synced to the cloud via secure connections. For more details, please refer to our full privacy policy on our website.")
//            }
//            .padding()
//        }
//        .navigationBarTitle("About & Privacy", displayMode: .inline)
//    }
//}
//
//// MARK: - Custom Button Style
//
//struct PrimaryButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .padding()
//            .background(Color.accentColor.opacity(configuration.isPressed ? 0.6 : 1.0))
//            .foregroundColor(.white)
//            .cornerRadius(8)
//    }
//}
//
//// MARK: - Preview Providers
//
//struct DataFlowContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        DataFlowContentView()
//    }
//}
