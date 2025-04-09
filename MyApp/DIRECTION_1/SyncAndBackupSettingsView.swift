////
////  SyncAndBackupSettingsView.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//
//// --- Mock Data & State ---
//// In a real app, this state would be managed by a ViewModel or Sync Service
//struct SyncState {
//    var isSyncEnabled: Bool = true // Default assumption: User wants sync
//    var lastSyncDate: Date? = Date().addingTimeInterval(-3600) // Mock: Synced an hour ago
//    var isSyncingNow: Bool = false
//    var syncStatusMessage: String? = nil // For errors or specific info
//    var storageUsedBytes: Int64 = 15 * 1024 * 1024 // Mock: 15 MB used
//    var icloudAccountEmail: String = "CongLeSolutionX@icloud.com" // Mock: Placeholder email
//}
//
//struct SyncAndBackupSettingsView: View {
//
//    // --- State ---
//    // Using @State for simplicity here. ViewModel approach recommended for real apps.
//    @State private var syncState = SyncState()
//
//    // --- Formatters ---
//    private var dateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .short
//        return formatter
//    }
//
//    private var byteCountFormatter: ByteCountFormatter {
//        let formatter = ByteCountFormatter()
//        formatter.allowedUnits = [.useMB, .useGB] // Show MB or GB
//        formatter.countStyle = .file
//        return formatter
//    }
//
//    // --- Computed Properties for Display ---
//    private var lastSyncString: String {
//        if syncState.isSyncingNow {
//            return "Syncing now..."
//        }
//        if let date = syncState.lastSyncDate {
//            return "Last sync: \(dateFormatter.string(from: date))"
//        }
//        return "Never synced"
//    }
//
//    private var storageUsedString: String {
//        return byteCountFormatter.string(fromByteCount: syncState.storageUsedBytes)
//    }
//
//    var body: some View {
//        Form { // Form is suitable for interactive settings like this
//            // --- Enable/Disable Section ---
//            Section(
//                header: Text("Cloud Sync"),
//                footer: Text("Keep your data backed up and available across all your devices signed in with the same iCloud account.")
//            ) {
//                Toggle("Enable iCloud Sync", isOn: $syncState.isSyncEnabled)
//                    .onChange(of: syncState.isSyncEnabled) {
//                        handleSyncToggle(enabled: syncState.isSyncEnabled)
//                    }
//            }
//
//            // --- Sync Status & Actions Section ---
//            // Only show details if sync is enabled
//            if syncState.isSyncEnabled {
//                Section(header: Text("Status")) {
//                    // Status Row with Progress Indicator
//                    HStack {
//                        Label(lastSyncString, systemImage: statusIcon())
//                            .foregroundColor(statusColor()) // Indicate status visually
//                        Spacer()
//                        if syncState.isSyncingNow {
//                            ProgressView()
//                                .scaleEffect(0.7) // Make spinner smaller
//                        }
//                    }
//
//                     // Display specific error or status message if available
//                    if let message = syncState.syncStatusMessage, !syncState.isSyncingNow {
//                         Text(message)
//                             .font(.caption)
//                             .foregroundColor(.red) // Typically used for errors
//                     }
//
//                    // Manual Sync Button
//                    Button {
//                        triggerManualSync()
//                    } label: {
//                        Label("Sync Now", systemImage: "arrow.triangle.2.circlepath")
//                    }
//                    .disabled(syncState.isSyncingNow) // Disable while sync is active
//                }
//
//                // --- Details Section ---
//                 Section(header: Text("Details")) {
//                     Label("Account: \(syncState.icloudAccountEmail)", systemImage: "person.crop.circle")
//                         .foregroundColor(.secondary)
//
//                     Label("Storage Used: \(storageUsedString)", systemImage: "icloud")
//                           .foregroundColor(.secondary)
//                 }
//            } else {
//                 // Optional: Show a message when sync is disabled
//                 Section {
//                     Text("Enable iCloud Sync to back up your data and access it on other devices.")
//                         .font(.footnote)
//                         .foregroundColor(.secondary)
//                 }
//            }
//        }
//        .navigationTitle("Sync & Backup")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//
//    // --- Helper Functions ---
//
//    private func statusIcon() -> String {
//        if syncState.isSyncingNow {
//            return "arrow.triangle.2.circlepath" // Indicates activity
//        }
//        if syncState.syncStatusMessage != nil { // Assuming message indicates an error for now
//             return "exclamationmark.triangle.fill"
//         }
//        if syncState.lastSyncDate != nil {
//            return "checkmark.icloud.fill" // Success
//        }
//        return "icloud.slash" // Not enabled or never synced
//    }
//
//     private func statusColor() -> Color {
//         if syncState.syncStatusMessage != nil && !syncState.isSyncingNow { // Check if not syncing before showing error color
//             return .red
//         }
//         return .secondary // Default neutral color
//     }
//
//    // --- Mock Action Handlers ---
//    private func handleSyncToggle(enabled: Bool) {
//        print("Sync Toggled: \(enabled)")
//        // --- Real App Logic ---
//        // 1. Update persistent setting for sync preference.
//        // 2. If enabling:
//        //    - Initialize sync service (e.g., CloudKit setup).
//        //    - Potentially trigger an initial sync.
//        //    - Start listening for remote changes.
//        //    - Update UI (remove "Never Synced" status maybe).
//        // 3. If disabling:
//        //    - Stop sync service (unregister listeners).
//        //    - Maybe ask user if they want to keep or delete *local* cloud data copies.
//        //    - Update UI (clear account/storage info, show "Never Synced").
//        // ---------------------
//
//        // Mock UI feedback:
//        if !enabled {
//            syncState.lastSyncDate = nil
//            syncState.syncStatusMessage = nil
//            syncState.isSyncingNow = false
//         } else {
//            // Simulate fetching initial state or triggering first sync
//            syncState.lastSyncDate = Date().addingTimeInterval(-3600) // Reset to a default last sync time
//           triggerManualSync(isInitial: true) // Trigger a sync on enabling
//         }
//    }
//
//    private func triggerManualSync(isInitial: Bool = false) {
//        guard syncState.isSyncEnabled && !syncState.isSyncingNow else { return }
//
//        print("Manual Sync Triggered (Initial: \(isInitial))")
//        syncState.isSyncingNow = true
//        syncState.syncStatusMessage = nil // Clear previous errors
//
//        // --- Real App Logic ---
//        // 1. Call sync service's function to initiate a push/pull.
//        // 2. Update UI based on progress/completion/errors reported by the service via callbacks/Combine/AsyncStream.
//        // ---------------------
//
//        // Simulate sync delay and outcome (can randomize success/failure)
//        DispatchQueue.main.asyncAfter(deadline: .now() + (isInitial ? 1.5 : 3.0)) { // Initial sync faster?
//             let success = Bool.random() || isInitial // Make initial more likely successful for demo
//             syncState.isSyncingNow = false
//             if success {
//                  syncState.lastSyncDate = Date()
//                  syncState.syncStatusMessage = nil
//                  // Maybe update storage used
//                 syncState.storageUsedBytes += Int64.random(in: 50...500) * 1024 // Add small random amount
//                 print("Mock Sync Successful")
//             } else {
//                  syncState.syncStatusMessage = "Sync failed. Check connection."
//                  print("Mock Sync Failed")
//             }
//        }
//    }
//}
//
//// --- Previews ---
//struct SyncAndBackupSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
////        Group {
//            // Default State (Enabled, Synced Recently)
//             NavigationView {
//                 SyncAndBackupSettingsView()
//             }
//             .previewDisplayName("Enabled (Default)")
//
//             // Sync Disabled State
//             NavigationView {
//                 SyncAndBackupSettingsView()
////                  SyncAndBackupSettingsView(syncState: SyncState(isSyncEnabled: false, lastSyncDate: nil))
//             }
//             .previewDisplayName("Disabled")
//
//              // Syncing State
//              NavigationView {
//                  SyncAndBackupSettingsView()
////                   SyncAndBackupSettingsView(syncState: SyncState(isSyncEnabled: true, lastSyncDate: Date().addingTimeInterval(-600), isSyncingNow: true))
//              }
//              .previewDisplayName("Syncing Now")
//
//              // Error State
//              NavigationView {
//                  SyncAndBackupSettingsView()
//                   //SyncAndBackupSettingsView(syncState: SyncState(isSyncEnabled: true, lastSyncDate: Date().addingTimeInterval(-86400), syncStatusMessage: "Unable to connect to iCloud."))
//              }
//              .previewDisplayName("Error State")
//
//               // Never Synced State
//               NavigationView {
//                   SyncAndBackupSettingsView()
//                    //SyncAndBackupSettingsView(syncState: SyncState(isSyncEnabled: true, lastSyncDate: nil))
//               }
//               .previewDisplayName("Enabled (Never Synced)")
////        }
//    }
//}
