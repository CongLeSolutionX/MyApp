//
//  Caching_Journey_Content_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//

import SwiftUI
import Combine

// MARK: - Data Models & Enums (Slightly Refined)

enum CacheStatus: Equatable { // Make Equatable for easier state comparison
    case idle
    case checking
    case hit
    case miss
    case fetching // General term for getting data from network
    case downloading(progress: Double?) // More specific for prefetch/update
    case error(message: String)

    // Helper for disabling buttons
    var isProcessing: Bool {
        switch self {
        case .checking, .fetching, .downloading: return true
        default: return false
        }
    }
}

enum ValidationStatus: Equatable { // Make Equatable
    case unknown
    case checking
    case current
    case stale
    case updating // Renamed from downloading for clarity in validation context
    case error(message: String)

    var isProcessing: Bool {
        switch self {
        case .checking, .updating: return true
        default: return false
        }
    }
}

struct PrefetchItem: Identifiable, Equatable {
    let id = UUID()
    let journeyId: String // Added Journey ID
    let description: String // Use description instead of name
    var status: CacheStatus
    let isEssential: Bool
}

// Represents a piece of content (simplistic)
struct JourneyData: Equatable {
    let content: String
    let version: Date // Timestamp represents version
}

// MARK: - ViewModel with Simulated Logic

@MainActor // Ensure UI updates happen on the main thread
class CachingViewModel: ObservableObject {

    // --- Simulated State ---
    @Published var currentJourneyId: String = "JourneyA" // Default/Selected Journey
    let availableJourneyIds = ["JourneyA", "JourneyB", "JourneyC", "JourneyD_Video", "JourneyE"]

    // Represents data loaded into RAM
    private var memoryCacheStore: [String: JourneyData] = [:]
    // Represents data saved to "disk"
    private var diskCacheStore: [String: JourneyData] = [:]
    // Represents the "latest version" available on the server
    private var networkDataVersions: [String: JourneyData] = [
        "JourneyA": JourneyData(content: "Content for A v1", version: Calendar.current.date(byAdding: .minute, value: -10, to: Date())!),
        "JourneyB": JourneyData(content: "Content for B v2", version: Date()), // Newer
        "JourneyC": JourneyData(content: "Content for C v1", version: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!),
        "JourneyD_Video": JourneyData(content: "Large Video Data", version: Calendar.current.date(byAdding: .day, value: -2, to: Date())!),
             "JourneyE": JourneyData(content: "Content for E v1", version: Calendar.current.date(byAdding: .minute, value: -5, to: Date())!) // Fairly recent
    ]

    // --- UI-Facing Published Properties ---
    @Published var memoryStatus: CacheStatus = .idle
    @Published var diskStatus: CacheStatus = .idle
    @Published var networkStatus: CacheStatus = .idle
    @Published var validationState: ValidationStatus = .unknown
    @Published var prefetchItems: [PrefetchItem] = []
    @Published var displayedContent: String? = nil // Show fetched content
    @Published var isProcessing: Bool = false // Master busy indicator

    private var activeTasks = Set<AnyCancellable>() // For Combine cancellables if needed
    private var backgroundTask: Task<Void, Never>? = nil // To manage overlapping tasks

    // --- Core Logic Functions ---

    func selectJourney(_ journeyId: String) {
        currentJourneyId = journeyId
        resetStatusForJourneyChange()
        print("ViewModel: Selected Journey: \(journeyId)")
    }

    func requestContent() {
        guard !isProcessing else { return }
         let journeyId = currentJourneyId
        print("ViewModel: Requesting content for \(journeyId)...")
        isProcessing = true
        displayedContent = nil // Clear previous content
        resetStatusIndicators() // Reset indicators for this specific request

        Task {
            // 1. Check Memory
            memoryStatus = .checking
            try? await Task.sleep(nanoseconds: 50_000_000) // Tiny delay
            if let data = memoryCacheStore[journeyId] {
                memoryStatus = .hit
                diskStatus = .idle // No need to check disk
                networkStatus = .idle
                displayedContent = data.content // Display from memory
                print("ViewModel: Memory Hit for \(journeyId)")
                isProcessing = false
                // Optionally: Trigger background validation after a memory hit
                validateCache(isBackground: true)
            } else {
                memoryStatus = .miss
                print("ViewModel: Memory Miss for \(journeyId), checking Disk...")
                await checkDisk(journeyId: journeyId) // Proceed to check disk
            }
        }
    }

    private func checkDisk(journeyId: String) async {
        diskStatus = .checking
        do {
            try await Task.sleep(nanoseconds: 200_000_000) // Simulate disk I/O delay
            if let data = diskCacheStore[journeyId] {
                diskStatus = .hit
                networkStatus = .idle
                print("ViewModel: Disk Hit for \(journeyId). Loading into memory.")
                // Load into memory cache
                memoryCacheStore[journeyId] = data
                memoryStatus = .hit
                displayedContent = data.content // Display from disk
                isProcessing = false
                // Trigger validation after disk hit (can be background)
                validateCache(isBackground: true)
            } else {
                diskStatus = .miss
                print("ViewModel: Disk Miss for \(journeyId), fetching from Network...")
                await fetchFromNetwork(journeyId: journeyId) // Proceed to fetch network
            }
        } catch {
            await safeSetDiskStatus(.error(message: "Disk check failed"))
            print("ViewModel: Disk check error for \(journeyId)")
            isProcessing = false
        }
    }

    private func fetchFromNetwork(journeyId: String) async {
        guard let networkData = networkDataVersions[journeyId] else {
            print("ViewModel: No network data definition found for \(journeyId)")
            await safeSetNetworkStatus(.error(message: "Unknown Journey ID"))
            isProcessing = false
            return
        }

        networkStatus = .fetching
        do {
            print("ViewModel: Simulating network fetch for \(journeyId)...")
            try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay

            // Success: Update caches
            diskCacheStore[journeyId] = networkData
            memoryCacheStore[journeyId] = networkData // Also load into memory

            print("ViewModel: Network fetch successful for \(journeyId). Caches updated.")
            await safeSetNetworkStatus(.idle)
            await safeSetDiskStatus(.hit)
            await safeSetMemoryStatus(.hit)
            await MainActor.run { displayedContent = networkData.content } // Update UI

            // After fetch, cache is implicitly current
            await MainActor.run { validationState = .current }

            isProcessing = false

        } catch {
            print("ViewModel: Network fetch error for \(journeyId)")
            await safeSetNetworkStatus(.error(message: "Network fetch failed"))
            isProcessing = false
        }
    }

    func validateCache(isBackground: Bool = false) {
        guard !isProcessing || isBackground else { return } // Prevent overlap unless background
         let journeyId = currentJourneyId

        if !isBackground {
            guard !isProcessing else { return }
            print("ViewModel: Manual Validation Requested for \(journeyId)...")
            isProcessing = true
             resetStatusIndicators() // Reset primary indicators only on manual validation
        } else {
             print("ViewModel: Background Validation Triggered for \(journeyId)...")
             // Don't block UI or reset primary indicators for background checks
             guard validationState != .checking && validationState != .updating else {
                 print("ViewModel: Background validation already in progress. Skipping.")
                 return
             }
        }

        validationState = .checking

        Task(priority: isBackground ? .background : .userInitiated) {
            do {
                try await Task.sleep(nanoseconds: 400_000_000) // Simulate network check delay

                guard let localData = diskCacheStore[journeyId] else {
                    await safeSetValidationState(.unknown) // No local data to validate
                    print("ViewModel: Validation skipped - No local data for \(journeyId)")
                     if !isBackground { isProcessing = false }
                    return
                }
                guard let networkData = networkDataVersions[journeyId] else {
                     await safeSetValidationState(.error(message: "Cannot reach server")) // Server/Network "error"
                     print("ViewModel: Validation failed - Could not get network version for \(journeyId)")
                     if !isBackground { isProcessing = false }
                    return
                }

                // Compare versions (using dates in this simulation)
                if localData.version >= networkData.version {
                    await safeSetValidationState(.current)
                    print("ViewModel: Cache for \(journeyId) is CURRENT.")
                     // Ensure content is displayed if validation passes and it's manual
                    if !isBackground { await MainActor.run { displayedContent = localData.content }}

                } else {
                    await safeSetValidationState(.stale)
                    print("ViewModel: Cache for \(journeyId) is STALE. Simulating update...")

                    // --- Simulate Update ---
                    await safeSetValidationState(.updating)
                    networkStatus = .downloading(progress: 0.0) // Show download progress on network row
                    try await Task.sleep(nanoseconds: 1_500_000_000) // Update delay

                    // Update successful, update local caches
                    diskCacheStore[journeyId] = networkData
                    memoryCacheStore[journeyId] = networkData // Immediately available in memory too

                    await safeSetValidationState(.current)
                    await safeSetNetworkStatus(.idle) // Reset network status after update "download"
                    await safeSetDiskStatus(.hit) // Disk is now hit (updated)
                    await safeSetMemoryStatus(.hit) // Memory is now hit (updated)
                     if !isBackground { await MainActor.run { displayedContent = networkData.content }} // Show updated content
                     print("ViewModel: Cache for \(journeyId) updated successfully.")

                }
                if !isBackground { isProcessing = false }

            } catch {
                 print("ViewModel: Validation error for \(journeyId)")
                 await safeSetValidationState(.error(message: "Validation check error"))
                 if !isBackground { isProcessing = false }
            }
        }
    }

    func simulatePrefetch() {
        guard !isProcessing else { return } // Don't prefetch if busy with main tasks
        print("ViewModel: Initiating predictive prefetch...")

        // Determine next items to prefetch (simple logic: next 2 journeys)
        guard let currentIndex = availableJourneyIds.firstIndex(of: currentJourneyId) else {
            print("ViewModel: Cannot determine current index for prefetch.")
            return
        }

        let nextItemsToFetch = availableJourneyIds
            .dropFirst(currentIndex + 1) // Items after the current one
            .prefix(2) // Take the next two

        guard !nextItemsToFetch.isEmpty else {
             print("ViewModel: No subsequent journeys to prefetch.")
             return
        }

        // Reset prefetch list and add new candidates
        prefetchItems = nextItemsToFetch.map { journeyId in
            PrefetchItem(
                journeyId: journeyId,
                description: "Content for \(journeyId)",
                status: diskCacheStore[journeyId] != nil ? .hit : .idle, // Show hit if already "on disk"
                isEssential: journeyId == availableJourneyIds[safe: currentIndex + 1] // Mark the very next one as essential
            )
        }

        // We only *simulate* downloading items not already marked as Hit
        let itemsNeedingDownload = prefetchItems.indices.filter { prefetchItems[$0].status == .idle }

        guard !itemsNeedingDownload.isEmpty else {
            print("ViewModel: All identified prefetch items are already cached.")
                return
        }

         // Use a background task group for concurrent downloads simulation if needed
         // For simplicity, simulate sequentially here
        backgroundTask?.cancel() // Cancel previous prefetch task if any
        backgroundTask = Task(priority: .background) {
             var updatedItems = prefetchItems // Create mutable copy

              for index in itemsNeedingDownload {
                 guard !Task.isCancelled else {
                     print("ViewModel: Prefetch task cancelled.")
                     return
                 }

                 let item = updatedItems[index]
                 print("ViewModel: Starting prefetch download for \(item.journeyId)")
                 updatedItems[index].status = .downloading(progress: 0.0)
                 await updatePrefetchUI(items: updatedItems) // Update UI immediately

                 guard let networkData = networkDataVersions[item.journeyId] else {
                      print("ViewModel: Prefetch Error - No network data for \(item.journeyId)")
                      updatedItems[index].status = .error(message: "Missing data")
                      await updatePrefetchUI(items: updatedItems)
                      continue // Skip to next item
                 }

                 // Simulate download progress
                 for progressTick in 1...5 {
                      guard !Task.isCancelled else {
                           print("ViewModel: Prefetch task cancelled during download of \(item.journeyId).")
                           updatedItems[index].status = .idle // Reset status? Or leave as downloading? -> Idle is clearer
                           await updatePrefetchUI(items: updatedItems)
                           return
                      }
                      try? await Task.sleep(nanoseconds: 250_000_000) // 0.25 sec per tick
                      let progress = Double(progressTick) / 5.0
                      updatedItems[index].status = .downloading(progress: progress)
                      await updatePrefetchUI(items: updatedItems)
                 }

                 // Download complete: update disk cache and status
                 diskCacheStore[item.journeyId] = networkData // Store it!
                 updatedItems[index].status = .hit
                 print("ViewModel: Prefetch download complete for \(item.journeyId). Stored to disk.")
                 await updatePrefetchUI(items: updatedItems) // Final status update for this item
                 try? await Task.sleep(nanoseconds: 100_000_000) // Small delay before next
             }
             print("ViewModel: Prefetch simulation sequence complete.")
        }
    }

    private func updatePrefetchUI(items: [PrefetchItem]) async {
         // Update the main @Published property on the main thread
         await MainActor.run {
              self.prefetchItems = items
         }
    }

    func resetSimulation() {
        print("ViewModel: Resetting Simulation State...")
        backgroundTask?.cancel() // Stop any ongoing prefetch
        isProcessing = false
        memoryCacheStore.removeAll()
        diskCacheStore.removeAll() // Clear simulated caches

        // Maybe keep network versions, or reset them too if needed
        // networkDataVersions = [...]

        currentJourneyId = availableJourneyIds.first ?? "JourneyA" // Reset to first
        resetStatusForJourneyChange()

        print("ViewModel: Simulation Reset Complete.")
    }

    // --- Helper Methods ---

     private func resetStatusIndicators() {
         memoryStatus = .idle
         diskStatus = .idle
         networkStatus = .idle
         validationState = .unknown // Reset validation too on new request/manual validation
    }

    private func resetStatusForJourneyChange() {
         resetStatusIndicators()
         prefetchItems.removeAll() // Clear prefetch list when journey changes
         displayedContent = nil // Clear displayed content
         // Check initial state of the new journey
         if memoryCacheStore[currentJourneyId] != nil {
              memoryStatus = .hit
              diskStatus = .hit // Assumed if in memory
              displayedContent = memoryCacheStore[currentJourneyId]?.content
              validateCache(isBackground: true) // Validate in background
         } else if diskCacheStore[currentJourneyId] != nil {
              memoryStatus = .miss
              diskStatus = .hit
              displayedContent = diskCacheStore[currentJourneyId]?.content
              validateCache(isBackground: true) // Validate in background
         } else {
              memoryStatus = .miss
              diskStatus = .miss
         }
    }

    // Helpers to ensure state updates are safe from background threads
    private func safeSetMemoryStatus(_ status: CacheStatus) async { await MainActor.run { memoryStatus = status } }
    private func safeSetDiskStatus(_ status: CacheStatus) async { await MainActor.run { diskStatus = status } }
    private func safeSetNetworkStatus(_ status: CacheStatus) async { await MainActor.run { networkStatus = status } }
    private func safeSetValidationState(_ state: ValidationStatus) async { await MainActor.run { validationState = state } }

}

// MARK: - SwiftUI Views (Mostly Unchanged, but integrated with ViewModel)

struct CachingStatusView: View {
    @StateObject private var viewModel = CachingViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    journeySelector

                    if let content = viewModel.displayedContent {
                        displayedContentView(content)
                    }

                    cacheLayersSection

                    validationSection

                    prefetchSection

                    actionButtons

                    Spacer() // Push buttons up if content is short

                    resetButton // Add reset button

                }
                .padding()
                 // Use overlay for a global progress indicator if desired
                 .overlay(
                    Group { // Group allows conditional content in overlay
                        if viewModel.isProcessing && viewModel.validationState != .checking && viewModel.validationState != .updating { // Show only for primary actions
                            ProgressView("Processing...")
                                .padding()
                                .background(.thinMaterial)
                                .cornerRadius(8)
                        }
                    }
                 )
            }
            .navigationTitle("Caching Demo")
            .onChange(of: viewModel.currentJourneyId) {
                // Optional: trigger actions when picker changes,
                // but direct button presses are clearer for this demo.
            }
        }
    }

    private var journeySelector: some View {
        Picker("Select Journey", selection: $viewModel.currentJourneyId) {
            ForEach(viewModel.availableJourneyIds, id: \.self) { id in
                Text(id.replacingOccurrences(of: "_", with: " ")) // Nicer formatting
            }
        }
        .pickerStyle(.menu)
        .padding(.bottom, 5)
        .disabled(viewModel.isProcessing) // Disable during processing
        .onChange(of: viewModel.currentJourneyId) {
            let newId = viewModel.currentJourneyId
            viewModel.selectJourney(newId) // Call ViewModel function on change
        }
    }

     private func displayedContentView(_ content: String) -> some View {
         GroupBox("Displayed Content") {
              Text(content)
                  .font(.body)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding(5)
                  .multilineTextAlignment(.leading)
                  .lineLimit(4) // Limit lines shown for brevity
         }
     }

    private var cacheLayersSection: some View {
        GroupBox("Cache Layers Status") {
            VStack(spacing: 15) {
                CacheLayerView(label: "Memory", systemImage: "memorychip", status: viewModel.memoryStatus)
                CacheLayerView(label: "Disk", systemImage: "internaldrive", status: viewModel.diskStatus)
                // Network row now also shows update progress during validation
                 let networkDisplayStatus = (viewModel.validationState == .updating) ? .downloading(progress: nil) : viewModel.networkStatus // Simplified progress for update
                CacheLayerView(label: "Network", systemImage: "network", status: networkDisplayStatus) // Use 'network' icon
            }
            .padding(.vertical, 5)
        }
    }

    private var validationSection: some View {
        GroupBox("Cache Validity") {
            HStack {
                Text("Status:")
                Spacer()
                ValidationStatusView(status: viewModel.validationState)
            }
            .padding(.vertical, 5)
        }
    }

    private var prefetchSection: some View {
         GroupBox("Prefetch Queue (\(viewModel.prefetchItems.count))") {
             if viewModel.prefetchItems.isEmpty {
                 Text("No items waiting for prefetch.")
                     .font(.caption)
                     .foregroundColor(.secondary)
                     .frame(maxWidth: .infinity, alignment: .center)
                     .padding(.vertical)
             } else {
                 VStack(alignment: .leading, spacing: 10) {
                     ForEach(viewModel.prefetchItems) { item in
                         PrefetchItemView(item: item)
                         if item != viewModel.prefetchItems.last { // Avoid divider after last item
                            Divider()
                         }
                     }
                 }
                 .padding(.vertical, 5)
             }
         }
    }

    private var actionButtons: some View {
         VStack(spacing: 10) {
             Button {
                 viewModel.requestContent()
             } label: {
                 Label("Request Content", systemImage: "arrow.down.circle")
                     .frame(maxWidth: .infinity)
             }
             .buttonStyle(.borderedProminent)
            .disabled(viewModel.isProcessing) // Disable button when busy

              Button {
                 viewModel.validateCache() // Trigger manual validation
             } label: {
                 Label("Validate Cache", systemImage: "arrow.triangle.2.circlepath")
                      .frame(maxWidth: .infinity)
             }
             .buttonStyle(.bordered)
            .disabled(viewModel.isProcessing || viewModel.diskStatus == .miss) // Disable if no disk cache or busy

             Button {
                 viewModel.simulatePrefetch()
             } label: {
                 Label("Prefetch Next Items", systemImage: "square.stack.3d.down.forward")
                     .frame(maxWidth: .infinity)
             }
             .buttonStyle(.bordered)
            .disabled(viewModel.isProcessing ) // Allow prefetch even if content loaded, but not while other actions run
         }
         .padding(.top)
    }

     private var resetButton: some View {
        Button(role: .destructive) {
             viewModel.resetSimulation()
        } label: {
             Label("Reset Simulation", systemImage: "trash")
                 .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .padding(.top, 30)
     }
}

#Preview("Caching Status View") {
    CachingStatusView()
}
// MARK: - Helper Subviews (Minor adjustments possible, but mostly reusable)
// MARK: - CacheLayerView
struct CacheLayerView: View {
    let label: String
    let systemImage: String
    let status: CacheStatus

    var body: some View {
        HStack {
            Image(systemName: systemImage).foregroundColor(.blue).frame(width: 25)
            Text(label).font(.headline).frame(width: 80, alignment: .leading)
            Spacer()
            CacheStatusIndicator(status: status)
                 .animation(.default, value: status) // Animate status changes
        }
    }
}

#Preview("Cache Layer View", body: {
    CacheLayerView(label: "Checking Status", systemImage: "questionmark.circle", status: .checking)
    CacheLayerView(label: "Hit Status", systemImage: "questionmark.circle", status: .hit)
    CacheLayerView(label: "Downloading Status", systemImage: "questionmark.circle", status: .downloading(progress: 0.5))
    CacheLayerView(label: "Error Status", systemImage: "questionmark.circle", status: .error(message: "Error Message"))
    CacheLayerView(label: "Fetching Status", systemImage: "questionmark.circle", status: .fetching)
    CacheLayerView(label: "Idle Status", systemImage: "questionmark.circle", status: .idle)
    CacheLayerView(label: "Miss Status", systemImage: "questionmark.circle", status: .miss)
})

// MARK: - CacheStatusIndicator
struct CacheStatusIndicator: View {
    let status: CacheStatus

    var body: some View {
        HStack(spacing: 5) {
             // More robust progress handling
            let progressValue: Double? = {
                if case .downloading(let prog) = status { return prog }
                return nil
            }()

            if let progressValue = progressValue {
                 ProgressView(value: progressValue)
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .frame(width: 50)
                 Text(String(format: "%.0f%%", (progressValue * 100)))
                    .font(.caption)
                    .foregroundColor(.orange)
                    .frame(width: 40, alignment: .leading)
                    .id("progress_\(progressValue)") // Add ID to help SwiftUI differentiate updates
            } else {
                indicatorIcon
                    .frame(width: 20, height: 20) // Ensure icon size consistency
                indicatorText
                    .frame(minWidth: 70, alignment: .leading)
            }
        }
        .frame(height: 22) // Consistent height for the whole indicator unit
    }

     @ViewBuilder // Ensures compiler treats this as returning one View
     private var indicatorIcon: some View {
         switch status {
         case .idle: Image(systemName: "circle.dotted").foregroundColor(.gray)
         case .checking: ProgressView().tint(.blue) // Use ProgressView for checking
         case .hit: Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
         case .miss: Image(systemName: "xmark.circle").foregroundColor(.pink) // Subtle change
         case .fetching: ProgressView().tint(.purple)
         case .downloading: ProgressView().tint(.orange) // Show spinner if progress is nil
         case .error: Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
         }
     }

     private var indicatorText: Text {
         switch status {
             case .idle: return Text("Idle").foregroundColor(.gray)
             case .checking: return Text("Checking...").foregroundColor(.blue)
             case .hit: return Text("Hit").foregroundColor(.green)
             case .miss: return Text("Miss").foregroundColor(.pink)
             case .fetching: return Text("Fetching...").foregroundColor(.purple)
             case .downloading: return Text("Downloading...").foregroundColor(.orange)
         case .error(message: let message):
             // return Text("Error").foregroundColor(.red).help(msg) // Add help text
             // return Text("Error").foregroundColor(.red).help(msg) // Add help text
             return Text("Error: \(message)").foregroundColor(.red)
         }
     }
}
#Preview("Cache Status Indicator") {
    CacheStatusIndicator(status: .checking)
    CacheStatusIndicator(status: .downloading(progress: 10.2))
    CacheStatusIndicator(status: .error(message: "Error mesasge goes here"))
    CacheStatusIndicator(status: .fetching)
    CacheStatusIndicator(status: .hit)
    CacheStatusIndicator(status: .idle)
    CacheStatusIndicator(status: .miss)
}

// MARK: - ValidationStatusView
struct ValidationStatusView: View {
    let status: ValidationStatus

    var body: some View {
        HStack(spacing: 5) {
           indicatorIcon
           indicatorText
        }
        .font(.callout)
         .animation(.default, value: status) // Animate status changes
    }

     @ViewBuilder
    private var indicatorIcon: some View {
         switch status {
             case .unknown: Image(systemName: "questionmark.circle").foregroundColor(.gray)
             case .checking: ProgressView().tint(.blue)
             case .current: Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
             case .stale: Image(systemName: "hourglass.tophalf.filled").foregroundColor(.orange)
             case .updating: ProgressView().tint(.purple) // Progress for updating
             case .error: Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
         }
    }

    private var indicatorText: Text {
        switch status {
            case .unknown: return Text("Unknown").foregroundColor(.gray)
            case .checking: return Text("Checking...").foregroundColor(.blue)
            case .current: return Text("Current").foregroundColor(.green)
            case .stale: return Text("Stale").foregroundColor(.orange)
            case .updating: return Text("Updating...").foregroundColor(.purple)
        case .error(message: let message):
            // return Text("Error").foregroundColor(.red).help(msg) // Add help text
            // return Text("\(message)").foregroundColor(.red).help(Text("\(message)")) as! Text // Add help text
            return Text("\(message)").foregroundColor(.red)
        }
    }
}
#Preview("Validation Status View") {
    ValidationStatusView(status: .checking)
    ValidationStatusView(status: .current)
    ValidationStatusView(status: .error(message: "Something went wrong!"))
    ValidationStatusView(status: .stale)
    ValidationStatusView(status: .updating)
    ValidationStatusView(status: .unknown)
}

// MARK: - PrefetchItemView
struct PrefetchItemView: View {
    let item: PrefetchItem

    var body: some View {
        HStack {
            Image(systemName: item.isEssential ? "bolt.shield.fill" : "shield") // More indicative icons
                .foregroundColor(item.isEssential ? .yellow : .gray)
                .help(item.isEssential ? "Essential for next step" : "Optional/Future content")
                 .frame(width: 20)

            Text(item.description).font(.callout)
                .lineLimit(1) // Prevent long text breaking layout

            Spacer()

            CacheStatusIndicator(status: item.status) // Re-use the indicator
        }
         .opacity(item.status == .hit ? 0.7 : 1.0) // Dim completed items slightly
         .contentShape(Rectangle()) // Ensure whole row is tappable if actions added later
    }
}

#Preview("Prefetch Item View", body: {
    PrefetchItemView(item: .init(journeyId: "123", description: "Some prefetch item", status: .hit, isEssential: true))
})

// MARK: - Utility Extension

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - App Entry Point (No change needed assuming it exists)
// struct CachingDemoApp: App {
//     var body: some Scene {
//         WindowGroup {
//             CachingStatusView()
//         }
//     }
// }
