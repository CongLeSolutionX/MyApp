//
//  ComprehensiveView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//
import SwiftUI
import UniformTypeIdentifiers // Needed for file types (UTType)

// MARK: - Data Model

struct InventoryItem: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var barcode: String
    var scanDate: Date
    var quantity: Int
    var imageName: String? // Placeholder for image name/URL

    // Sample data generator (enhanced for edge cases)
    static func generateSampleData(count: Int) -> [InventoryItem] {
        let sampleNames = ["Organic Facial Cleanser", "Repairing Hand Cream", "Hydrating Serum", "Exfoliating Scrub", "Vitamin C Brightener", "Sunscreen SPF 50", "Night Renewal Cream", "Micellar Water", "Clay Mask"]
        let sampleImages = ["skincare.tube.fill", "hand.raised.fill", "eyedropper.halffull", "bubbles.and.sparkles", "sun.max.fill", "moon.stars.fill", "drop.fill", "face.smiling.inverse"] // Example system icons

        var items: [InventoryItem] = []
        let duplicateBarcode = "DUPLICATE999"

        for i in 1...count {
            var name = "\(sampleNames.randomElement() ?? "Product") \(i)"
            var currentBarcode = "1234567890\(i)"
            var currentQuantity = Int.random(in: 1...5)
            var currentImageName = i % 4 == 0 ? nil : sampleImages.randomElement() // Some items without images

            // --- Simulate Edge Cases for Admin View ---
            if i == count / 3 { name = "" } // Simulate empty name
            if i == count / 2 || i == count / 2 + 1 { currentBarcode = duplicateBarcode } // Duplicate barcode
            if i == count / 4 { currentQuantity = 0 } // Zero quantity
            if i == 1 { name = "Preview Detail Item"; currentImageName = "star.fill" } // Specific item for detail preview

            items.append(
                InventoryItem(
                    name: name,
                    barcode: currentBarcode,
                    scanDate: Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...90), to: Date()) ?? Date(),
                    quantity: currentQuantity,
                    imageName: currentImageName
                )
            )
        }
        // Ensure at least one duplicate pair exists if count is small
        if count > 2 && !items.contains(where: { $0.barcode == duplicateBarcode }) {
             items[0].barcode = duplicateBarcode
             items[1].barcode = duplicateBarcode
        }

        return items
    }
}

// MARK: - Supporting Views (Rows, Placeholders, Scan Components, Admin Helpers)

// Placeholder view for tabs or destinations not fully implemented
struct PlaceholderView: View {
    let text: String
    let showNavigationTitle: Bool // Control title visibility

    init(text: String, showNavigationTitle: Bool = true) {
        self.text = text
        self.showNavigationTitle = showNavigationTitle
    }

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.5))
            Text(text)
                .font(.title2)
                .foregroundColor(.secondary)
                .padding(.top, 5)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure it fills space
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.bottom)) // Match form background
        .navigationTitle(showNavigationTitle ? text : "") // Conditional title
        .navigationBarTitleDisplayMode(.inline)
    }
}

// View for a single row in the inventory list
struct InventoryRowView: View {
    let item: InventoryItem

    var body: some View {
        HStack(spacing: 15) {
            // Item Image
             Image(systemName: item.imageName ?? "photo.on.rectangle.angled")
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: 50, height: 50)
                 .padding(5)
                 .background(Color.gray.opacity(0.1))
                 .cornerRadius(8)
                 .foregroundColor(item.imageName == nil ? .secondary : .accentColor)

            // Item Details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name.isEmpty ? "(No Name)" : item.name) // Handle empty name display
                    .font(.headline)
                    .foregroundColor(item.name.isEmpty ? .red : .primary) // Highlight empty name issue
                    .lineLimit(2)

                Text("Scanned: \(item.scanDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Quantity Display
            Text("Qty: \(item.quantity)")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(item.quantity <= 0 ? Color.orange.opacity(0.15) : Color.blue.opacity(0.1)) // Highlight zero/low qty
                .foregroundColor(item.quantity <= 0 ? .orange : .blue)
                .cornerRadius(6)
        }
        .padding(.vertical, 6)
    }
}

// View displayed when the inventory list is empty
struct EmptyInventoryView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "archivebox")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.7))
            Text("Inventory is Empty")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Use the 'Scan' tab to add items or 'I/O' to import.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Detail view navigated to from an InventoryRowView
struct InventoryItemDetailView: View {
     let item: InventoryItem

     var body: some View {
         ScrollView {
             VStack(alignment: .leading, spacing: 20) {
                 // Image
                 Image(systemName: item.imageName ?? "photo.on.rectangle.angled")
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(maxWidth: .infinity)
                     .frame(height: 200)
                     .padding(.vertical)
                     .background(Color.gray.opacity(0.1))
                     .cornerRadius(10)
                     .foregroundColor(item.imageName == nil ? .secondary : .accentColor)
                     .padding(.bottom)

                 // Name (handling empty)
                 Text(item.name.isEmpty ? "(No Name)" : item.name)
                     .font(.largeTitle)
                     .fontWeight(.bold)
                     .foregroundColor(item.name.isEmpty ? .red : .primary)

                 // Key Info HStack
                 HStack {
                     VStack(alignment: .leading) {
                         Text("Quantity")
                             .font(.caption)
                             .foregroundColor(.secondary)
                         Text("\(item.quantity)")
                             .font(.title3)
                             .fontWeight(.medium)
                             .foregroundColor(item.quantity <= 0 ? .orange : .primary) // Highlight low qty
                     }
                     Spacer()
                     VStack(alignment: .trailing) {
                         Text("Scanned On")
                            .font(.caption)
                            .foregroundColor(.secondary)
                         Text("\(item.scanDate, style: .date) \(item.scanDate, style: .time)")
                            .font(.subheadline)
                     }
                 }
                 .padding(.vertical, 8)

                 Divider()

                 // Barcode Section
                 VStack(alignment: .leading, spacing: 5) {
                     Text("Barcode")
                         .font(.headline)
                     Text(item.barcode)
                         .font(.body)
                         .foregroundColor(.secondary)
                         .textSelection(.enabled) // Allow copying barcode
                 }

                 Spacer() // Pushes content up
             }
             .padding()
         }
         .navigationTitle("Item Details")
         .navigationBarTitleDisplayMode(.inline)
         .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.bottom))
     }
 }

// --- Scan View Placeholders ---

struct CameraPreviewPlaceholder: View {
    var body: some View {
        Color.black
            .overlay(
                Image(systemName: "camera.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .foregroundColor(.gray.opacity(0.4))
            )
    }
}

struct FocusZoneOverlay: View {
    let size: CGFloat = 280
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.8), lineWidth: 3)
                .frame(width: size, height: size * 0.6)
                .shadow(color: .black.opacity(0.7), radius: 5, x: 0, y: 2)

            Text("Align Barcode Here")
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color.black.opacity(0.5))
                .cornerRadius(4)
                .frame(maxWidth: size, maxHeight: size * 0.6, alignment: .bottom)
                .padding(.bottom, 10)
        }
    }
}

struct BottomControlsOverlay: View {
    @Binding var isFlashlightOn: Bool
    var modeAction: () -> Void = {}
    var manualEntryAction: () -> Void = {}

    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Button { modeAction() } label: {
                 Text("Standard Mode") // Example scan mode
                     .font(.system(size: 14, weight: .medium))
                     .padding(.horizontal, 16).padding(.vertical, 8)
                     .background(.ultraThinMaterial)
                     .foregroundColor(.primary)
                     .cornerRadius(20)
                     .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
            }

            Spacer()

            HStack(spacing: 20) {
                Button { isFlashlightOn.toggle() } label: {
                    Image(systemName: isFlashlightOn ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 20))
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .foregroundColor(isFlashlightOn ? .yellow : .primary)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
                }

                Button { manualEntryAction() } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .foregroundColor(.primary)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}

// --- Admin View Helper ---

// Helper View for Status Rows in Admin
struct StatusRow: View {
    let label: String
    let value: String
    let statusColor: Color

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary) // Ensure label text is readable
            Spacer()
            Text(value)
                .foregroundColor(statusColor == .gray ? .secondary : statusColor) // Use secondary for neutral status
                .fontWeight(statusColor != .gray ? .medium : .regular)
        }
    }
}

// --- I/O Helper ---

// Helper struct for CSV data transfer (needed for .fileExporter)
struct CSVDocument: Transferable {
    let text: String
    let filename: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .commaSeparatedText) { document in
            Data(document.text.utf8)
        } fileURL: { document in
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(document.filename).appendingPathExtension("csv")
            try document.text.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        }
    }
}

// MARK: - Main Tab Views

// --- Scan View ---
struct ScanView: View {
    @State private var isFlashlightOn = false
    @State private var showingManualEntrySheet = false // To present a manual entry form

    var body: some View {
        NavigationView {
            ZStack {
                CameraPreviewPlaceholder().edgesIgnoringSafeArea(.all)
                FocusZoneOverlay() // Centered focus zone

                VStack {
                    Spacer() // Pushes controls to bottom
                    BottomControlsOverlay(isFlashlightOn: $isFlashlightOn, modeAction: {
                        print("Mode button tapped (Action not implemented)")
                    }, manualEntryAction: {
                         print("Manual entry tapped")
                         showingManualEntrySheet = true // Show the sheet
                    })
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true) // Full-screen camera look
            .sheet(isPresented: $showingManualEntrySheet) {
                 // TODO: Create a ManualEntryView struct and present it here
                 PlaceholderView(text: "Manual Item Entry Form", showNavigationTitle: false)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// --- Inventory View ---
struct InventoryView: View {
    @Binding var inventoryItems: [InventoryItem]
    @State private var searchText: String = ""
    @State private var sortOrder: [KeyPathComparator<InventoryItem>] = [
        .init(\.scanDate, order: .reverse) // Default sort: newest first
    ]

    var filteredItems: [InventoryItem] {
        let baseItems: [InventoryItem]
        if searchText.isEmpty {
            baseItems = inventoryItems
        } else {
            baseItems = inventoryItems.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.barcode.localizedCaseInsensitiveContains(searchText)
            }
        }
        return baseItems.sorted(using: sortOrder)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredItems) { item in
                    NavigationLink(destination: InventoryItemDetailView(item: item)) {
                         InventoryRowView(item: item)
                    }
                }
                .onDelete(perform: deleteItems)

                 if filteredItems.isEmpty && !searchText.isEmpty && !inventoryItems.isEmpty {
                     Text("No items match '\(searchText)'")
                         .foregroundColor(.secondary)
                         .padding(.vertical)
                         .frame(maxWidth: .infinity, alignment: .center)
                 }
            }
            .listStyle(.plain)
            .navigationTitle("Inventory")
            .searchable(text: $searchText, prompt: "Search by Name or Barcode")
            .overlay {
                 if inventoryItems.isEmpty {
                     EmptyInventoryView()
                 }
            }
            .toolbar {
                 ToolbarItem(placement: .navigationBarLeading) {
                      EditButton()
                 }
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Menu {
                          Picker("Sort By", selection: $sortOrder) {
                             Text("Newest First").tag([KeyPathComparator(\InventoryItem.scanDate, order: .reverse)])
                             Text("Oldest First").tag([KeyPathComparator(\InventoryItem.scanDate, order: .forward)])
                             Text("Name (A-Z)").tag([KeyPathComparator(\InventoryItem.name, order: .forward)])
                             Text("Name (Z-A)").tag([KeyPathComparator(\InventoryItem.name, order: .reverse)])
                             Text("Quantity (Low-High)").tag([KeyPathComparator(\InventoryItem.quantity, order: .forward)])
                             Text("Quantity (High-Low)").tag([KeyPathComparator(\InventoryItem.quantity, order: .reverse)])
                         }.pickerStyle(.inline)
                     } label: {
                         Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                     }
                 }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func deleteItems(at offsets: IndexSet) {
        let idsToDelete = offsets.map { filteredItems[$0].id }
        inventoryItems.removeAll { item in
            idsToDelete.contains(item.id)
        }
    }
}

// --- Import/Export View ---
struct ImportExportView: View {
    @Binding var inventoryItems: [InventoryItem]

    @State private var showingExporter = false
    @State private var documentToExport: CSVDocument?
    @State private var showingImporter = false
    @State private var importFeedback: String?
    @State private var isImporting = false

    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // ISO-like format for CSV
        return formatter
    }()

    var body: some View {
        NavigationView {
            Form {
                Section("Export Data") {
                    Button {
                        prepareAndTriggerExport()
                    } label: {
                        Label("Export Inventory as CSV", systemImage: "square.and.arrow.up")
                    }
                    .disabled(inventoryItems.isEmpty)
                    .fileExporter(
                        isPresented: $showingExporter,
                        document: documentToExport,
                        contentType: .commaSeparatedText,
                        defaultFilename: "inventory_export_\(formattedDateString()).csv"
                    ) { result in handleExportResult(result) }

                    if inventoryItems.isEmpty {
                        Text("No inventory items available to export.")
                            .font(.caption).foregroundColor(.secondary)
                    }
                }

                Section("Import Data") {
                    Button {
                         importFeedback = nil
                         showingImporter = true
                    } label: {
                         Label("Import Inventory from CSV", systemImage: "square.and.arrow.down")
                    }
                    .fileImporter(
                        isPresented: $showingImporter,
                        allowedContentTypes: [.commaSeparatedText],
                        allowsMultipleSelection: false
                    ) { result in handleImportResult(result) }

                    if isImporting {
                        HStack { ProgressView(); Text("Importing...").foregroundColor(.secondary) }
                    } else if let feedback = importFeedback {
                        Label { Text(feedback) } icon: {
                             Image(systemName: feedback.contains("Error") || feedback.contains("Failed") ? "xmark.octagon.fill" : "checkmark.circle.fill")
                                 .foregroundColor(feedback.contains("Error") || feedback.contains("Failed") ? .red : .green)
                        }
                        .font(.callout)
                    }
                }
            }
            .navigationTitle("Import / Export")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func formattedDateString() -> String {
        let formatter = DateFormatter(); formatter.dateFormat = "yyyyMMdd_HHmmss"; return formatter.string(from: Date())
    }

    private func prepareAndTriggerExport() {
        guard !inventoryItems.isEmpty else { return }
        let header = "Name,Barcode,ScanDate,Quantity,ImageName\n"
        let rows = inventoryItems.map { item in
            let name = item.name.contains(",") ? "\"\(item.name)\"" : item.name
            return "\(name),\(item.barcode),\(dateFormatter.string(from: item.scanDate)),\(item.quantity),\(item.imageName ?? "")"
        }.joined(separator: "\n")
        self.documentToExport = CSVDocument(text: header + rows, filename: "inventory_export_\(formattedDateString())")
        self.showingExporter = true
        print("Prepared CSV for export.")
    }

     private func handleExportResult(_ result: Result<URL, Error>) {
          switch result {
          case .success(let url):
              print("Export successful to: \(url)")
              // Optionally show user success message
          case .failure(let error):
              print("Export failed: \(error.localizedDescription)")
              // Optionally show user error alert
          }
     }

    private func handleImportResult(_ result: Result<[URL], Error>) {
        isImporting = true
        importFeedback = nil
        Task { // Perform file reading asynchronously
            defer { isImporting = false }
            switch result {
            case .success(let urls):
                guard let url = urls.first else { importFeedback = "Error: No file selected."; return }
                guard url.startAccessingSecurityScopedResource() else { importFeedback = "Error: Could not access file."; print("Failed access: \(url)"); return }
                defer { url.stopAccessingSecurityScopedResource() }
                do {
                    let csvString = try String(contentsOf: url, encoding: .utf8)
                    let importedCount = parseAndImportCSV(csvString)
                    if importedCount >= 0 { importFeedback = "Successfully imported \(importedCount) items." }
                    print("Import successful from: \(url)")
                } catch { importFeedback = "Error reading file: \(error.localizedDescription)"; print("Read error: \(error)") }
            case .failure(let error):
                 if (error as? CocoaError)?.code == .userCancelled { importFeedback = "Import cancelled." ; print("Import cancelled.") }
                 else { importFeedback = "Import failed: \(error.localizedDescription)"; print("Import failed: \(error)") }
            }
        }
    }

    // Basic CSV parser - enhance for production robustness
    private func parseAndImportCSV(_ csvString: String) -> Int {
        var importedCount = 0
        let lines = csvString.split(whereSeparator: \.isNewline).map { String($0).trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        guard lines.count > 1 else { importFeedback = "Error: CSV file is empty or has no data rows."; return -1 }
        let headerLine = lines[0].lowercased()
        guard headerLine.contains("name") && headerLine.contains("barcode") && headerLine.contains("scandate") && headerLine.contains("quantity") else {
            importFeedback = "Error: CSV header missing required columns (Name, Barcode, ScanDate, Quantity)."; return -1
        }
        let dataLines = lines.dropFirst()
        var itemsToAdd: [InventoryItem] = []
        for line in dataLines {
            // Very basic split - won't handle commas in quoted fields
            let columns = line.components(separatedBy: ",")
            guard columns.count >= 4 else { print("Skipping row (columns < 4): \(line)"); continue }
            let name = columns[0].replacingOccurrences(of: "\"", with: "")
            let barcode = columns[1]
            guard let scanDate = dateFormatter.date(from: columns[2]) else { print("Skipping row (bad date): \(line)"); continue }
            guard let quantity = Int(columns[3]) else { print("Skipping row (bad qty): \(line)"); continue }
            let imageName = columns.count > 4 ? (columns[4].isEmpty ? nil : columns[4]) : nil
            itemsToAdd.append(InventoryItem(name: name, barcode: barcode, scanDate: scanDate, quantity: quantity, imageName: imageName))
            importedCount += 1
        }
        DispatchQueue.main.async { inventoryItems.append(contentsOf: itemsToAdd) }
        return importedCount
    }
}

// --- Admin View ---
struct AdminView: View {
    @Binding var inventoryItems: [InventoryItem]

    @State private var dataCheckResult: String? = nil
    @State private var systemStatus: String = "Status checks not run yet."
    @State private var showingClearLogsAlert = false
    @State private var showingArchiveConfirmAlert = false
    @State private var showingForceSyncAlert = false
    @State private var isCheckingData = false
    @State private var isRefreshingStatus = false

    private var itemsWithEmptyNames: Int { inventoryItems.filter { $0.name.trimmingCharacters(in: .whitespaces).isEmpty }.count }
    private var potentialDuplicateBarcodeGroups: Int { Dictionary(grouping: inventoryItems, by: { $0.barcode }).filter { $1.count > 1 }.count }
    private var itemsWithZeroOrLessQuantity: Int { inventoryItems.filter { $0.quantity <= 0 }.count }
    private var itemsOlderThan90Days: Int {
        let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        return inventoryItems.filter { $0.scanDate < ninetyDaysAgo }.count
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data Health"), footer: Text("Review potential issues in the inventory data.")) {
                    StatusRow(label: "Items with Empty Names:", value: "\(itemsWithEmptyNames)", statusColor: itemsWithEmptyNames > 0 ? .red : .green)
                    StatusRow(label: "Duplicate Barcode Groups:", value: "\(potentialDuplicateBarcodeGroups)", statusColor: potentialDuplicateBarcodeGroups > 0 ? .orange : .green)
                    StatusRow(label: "Items with <= 0 Quantity:", value: "\(itemsWithZeroOrLessQuantity)", statusColor: itemsWithZeroOrLessQuantity > 0 ? .orange : .green)

                    Button { runDataHealthCheck() } label: {
                         HStack { Label("Run Full Data Check", systemImage: "heart.text.square"); if isCheckingData { Spacer(); ProgressView()} }
                    }
                    .disabled(isCheckingData)

                    if let result = dataCheckResult {
                        Label { Text(result) } icon: {
                             Image(systemName: itemsWithEmptyNames > 0 || potentialDuplicateBarcodeGroups > 0 || itemsWithZeroOrLessQuantity > 0 ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                                .foregroundColor(itemsWithEmptyNames > 0 || potentialDuplicateBarcodeGroups > 0 || itemsWithZeroOrLessQuantity > 0 ? .orange : .green)
                        }
                        .font(.caption).padding(.top, 5)
                    }
                }

                Section("System Operations") {
                    Button { guard itemsOlderThan90Days > 0 else { return }; showingArchiveConfirmAlert = true } label: {
                        Label("Archive Items Older Than 90 Days (\(itemsOlderThan90Days))", systemImage: "archivebox")
                    }
                    .disabled(itemsOlderThan90Days == 0)
                    Button { showingForceSyncAlert = true } label: {
                        Label("Force Cloud Sync (Simulated)", systemImage: "icloud.and.arrow.up")
                    }
                    Button(role: .destructive) { showingClearLogsAlert = true } label: {
                        Label("Clear Diagnostic Logs (Simulated)", systemImage: "doc.text.magnifyingglass")
                    }
                }

                Section(header: Text("System Status"), footer: Text("Simulated overview of system components.")) {
                    StatusRow(label: "Backend Connection:", value: "Connected", statusColor: .green)
                    StatusRow(label: "Database Size:", value: "15.2 MB", statusColor: .gray)
                    StatusRow(label: "Last Backup:", value: "Today, 3:15 AM", statusColor: .gray)
                    Button { refreshSystemStatus() } label: {
                         HStack { Label("Refresh Live Status", systemImage: "arrow.clockwise"); if isRefreshingStatus { Spacer(); ProgressView()} }
                    }
                    .disabled(isRefreshingStatus)
                    Text(systemStatus).font(.caption).foregroundColor(.secondary).padding(.top, 5)
                }

                Section("User Administration") {
                     NavigationLink { PlaceholderView(text: "User Management", showNavigationTitle: true) } label: {
                          Label("Manage Users & Roles", systemImage: "person.2.badge.gearshape.fill")
                      }
                }
            }
            .navigationTitle("Admin Panel")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Clear Diagnostic Logs?", isPresented: $showingClearLogsAlert) {
                 Button("Cancel", role: .cancel) {}
                 Button("Clear Logs", role: .destructive) { print("Clearing logs (Simulated).") }
             } message: { Text("Remove historical diagnostic data?") }
             .alert("Archive Old Items?", isPresented: $showingArchiveConfirmAlert) {
                  Button("Cancel", role: .cancel) {}
                  Button("Archive \(itemsOlderThan90Days) Items", role: .destructive) { archiveOldItems() }
              } message: { Text("Remove \(itemsOlderThan90Days) items scanned over 90 days ago?") }
              .alert("Force Cloud Sync?", isPresented: $showingForceSyncAlert) {
                   Button("Cancel", role: .cancel) {}
                   Button("Force Sync") { print("Forcing sync (Simulated).") }
               } message: { Text("Immediately synchronize data with the cloud service (Simulated)?") }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func runDataHealthCheck() {
        guard !isCheckingData else { return }
        isCheckingData = true; dataCheckResult = "Running check..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
             let issuesFound = itemsWithEmptyNames > 0 || potentialDuplicateBarcodeGroups > 0 || itemsWithZeroOrLessQuantity > 0
             dataCheckResult = issuesFound ? "Check completed: Found issues." : "Check completed: No immediate issues found."
             isCheckingData = false
        }
    }
    private func refreshSystemStatus() {
        guard !isRefreshingStatus else { return }
        isRefreshingStatus = true; systemStatus = "Refreshing..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            systemStatus = "Status Refreshed at \(Date(), style: .time). All systems nominal."
            isRefreshingStatus = false
        }
    }
    private func archiveOldItems() {
        print("Archiving \(itemsOlderThan90Days) items.")
        let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        inventoryItems.removeAll { $0.scanDate < ninetyDaysAgo }
        runDataHealthCheck() // Re-run check
    }
}

// --- Settings View ---
struct SettingsView: View {
    @AppStorage("playSoundOnScan") private var playSoundOnScan: Bool = true
    @AppStorage("vibrateOnScan") private var vibrateOnScan: Bool = true
    @State private var showingClearDataAlert = false
    @Binding var inventoryItems: [InventoryItem]

    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Scanning"), footer: Text("Feedback during scans.")) {
                    Toggle(isOn: $playSoundOnScan) { Label("Sound Feedback", systemImage: "speaker.wave.2.fill") }
                    Toggle(isOn: $vibrateOnScan) { Label("Haptic Feedback", systemImage: "iphone.gen1.radiowaves.left.and.right") }
                }

                Section("Data Management") {
                    NavigationLink { PlaceholderView(text: "Export Options") } label: { // Placeholder destinations
                         Label("Export Inventory Data...", systemImage: "square.and.arrow.up")
                    }
                     NavigationLink { PlaceholderView(text: "Import Options") } label: {
                         Label("Import Inventory Data...", systemImage: "square.and.arrow.down")
                     }
                    Button(role: .destructive) { showingClearDataAlert = true } label: {
                        Label("Clear All Inventory Data", systemImage: "trash")
                    }
                }

                Section("Support") {
                   Link(destination: URL(string: "https://www.example.com/help")!) { Label("Help & FAQ", systemImage: "questionmark.circle") }
                    Link(destination: URL(string: "mailto:support@example.com")!) { Label("Contact Support", systemImage: "lifepreserver") }
                    Link(destination: URL(string: "https://www.example.com/feedback")!) { Label("Send Feedback", systemImage: "paperplane") }
                }

                Section("About") {
                   HStack { Text("App Version"); Spacer(); Text("\(appVersion) (\(buildNumber))").foregroundColor(.secondary) }
                   Link(destination: URL(string: "https://www.example.com/privacy")!) { Label("Privacy Policy", systemImage: "lock.shield") }
                   Link(destination: URL(string: "https://www.example.com/terms")!) { Label("Terms of Service", systemImage: "doc.text") }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Clear All Inventory Data?", isPresented: $showingClearDataAlert) {
                 Button("Cancel", role: .cancel) { }
                 Button("Clear Data", role: .destructive) { inventoryItems.removeAll() }
             } message: { Text("This action is permanent and cannot be undone.") }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Main App Container (TabView)

struct ContentView: View {
    @State private var selectedTab = 1 // Start on Inventory tab
    @State private var inventoryItems: [InventoryItem] = InventoryItem.generateSampleData(count: 25) // Main data source

    var body: some View {
        TabView(selection: $selectedTab) {
            ScanView()
                .tabItem { Label("Scan", systemImage: "barcode.viewfinder") }
                .tag(0)

            InventoryView(inventoryItems: $inventoryItems)
                .tabItem { Label("Inventory", systemImage: "list.bullet.rectangle.portrait") }
                .tag(1)

            ImportExportView(inventoryItems: $inventoryItems)
                .tabItem { Label("I / O", systemImage: "arrow.left.arrow.right.square") }
                .tag(2)

            AdminView(inventoryItems: $inventoryItems)
                .tabItem { Label("Admin", systemImage: "shield.checkerboard") }
                .tag(3)

            SettingsView(inventoryItems: $inventoryItems)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(4)
        }
        .accentColor(.blue) // Apply a global accent color
        // .onAppear { /* Load data from persistence if needed */ }
    }
}

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    // Shared state for previews needing bindings
    @State static var previewInventoryItems = InventoryItem.generateSampleData(count: 15)
    @State static var previewEmptyInventory: [InventoryItem] = []

    static var previews: some View {
        Group {
            ContentView() // Simulate full app launch
                .previewDisplayName("Full App Startup")

            // Preview individual tabs for focused development
            InventoryView(inventoryItems: $previewInventoryItems)
                .previewDisplayName("Inventory Screen")

            ImportExportView(inventoryItems: $previewInventoryItems)
                .previewDisplayName("I/O Screen")

            AdminView(inventoryItems: $previewInventoryItems)
                .previewDisplayName("Admin Screen")

            SettingsView(inventoryItems: $previewInventoryItems)
                .previewDisplayName("Settings Screen")

             ScanView()
                .previewDisplayName("Scan Screen")

            // Preview edge case / components
            InventoryView(inventoryItems: $previewEmptyInventory)
                .previewDisplayName("Empty Inventory")

            InventoryItemDetailView(item: previewInventoryItems.first ?? InventoryItem(name: "Sample", barcode: "123", scanDate: Date(), quantity: 1))
                 .previewDisplayName("Item Detail")
        }
    }
}

// MARK: - App Entry Point (If creating a full app target)
/*
 @main
 struct YourAppNameApp: App {
     var body: some Scene {
         WindowGroup {
             ContentView()
         }
     }
 }
*/
