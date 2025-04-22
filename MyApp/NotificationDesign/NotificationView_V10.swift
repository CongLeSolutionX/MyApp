////
////  NotificationView_V6.swift
////  ContentView_FullFeature.swift
////  MyApp
////
////  Created by Cong Le on 4/22/25.
////
////  Targets iOS 15+. Requires:
////    • NSCalendarsUsageDescription in Info.plist
////    • NSRemindersUsageDescription in Info.plist
////    • Add “MessageUI” framework
//
//import SwiftUI
//import MessageUI
//import EventKit
//import AVFoundation
//import PhotosUI
//
//// MARK: – Haptic Helper
//struct Haptics {
//    static let shared = Haptics()
//    private let impact = UIImpactFeedbackGenerator(style: .light)
//    private let selection = UISelectionFeedbackGenerator()
//    private let medium = UIImpactFeedbackGenerator(style: .medium)
//    private init() {
//        impact.prepare(); selection.prepare(); medium.prepare()
//    }
//    func tap()        { impact.impactOccurred() }
//    func select()     { selection.selectionChanged() }
//    func openSheet()  { medium.impactOccurred() }
//}
//
//// MARK: – Data Model
//enum FeatureDestination: Identifiable {
//    case composeMessage
//    case composeMail
//    case pickPhoto(source: UIImagePickerController.SourceType)
//    case showEventDetail(EKEvent)
//    case showReminders
//    case none
//    
//    var id: String {
//        switch self {
//        case .composeMessage:           return "msgCompose"
//        case .composeMail:              return "mailCompose"
//        case .pickPhoto(.camera):       return "photoCamera"
//        case .pickPhoto(.photoLibrary): return "photoLibrary"
//        case .showEventDetail(let e):   return e.eventIdentifier
//        case .showReminders:            return "reminders"
//        case .none:                     return "none"
//        case .pickPhoto(source: .savedPhotosAlbum):
//            return "pick photo from savedPhotosAlbum source"
//        case .pickPhoto(source: _):
//            return "pick photo from custom source"
//        }
//    }
//}
//
//struct NotificationData: Identifiable {
//    let id = UUID()
//    let icon: String
//    let appName: String
//    let title: String
//    let body: String
//    let date: Date
//    let destination: FeatureDestination
//    
//    var timeString: String {
//        let f = DateFormatter()
//        if Calendar.current.isDateInToday(date) {
//            f.timeStyle = .short
//            f.dateStyle = .none
//        } else if Calendar.current.isDateInYesterday(date) {
//            return "Yesterday"
//        } else {
//            f.dateStyle = .short
//            f.timeStyle = .short
//        }
//        return f.string(from: date)
//    }
//}
//
//// MARK: – EventKit Managers
//
//class CalendarManager: ObservableObject {
//    @Published var events: [EKEvent] = []
//    @Published var error: String?
//    @Published var loading = false
//    private let store = EKEventStore()
//    
//    func requestAndFetch() async { // Mark the function as async
//        await MainActor.run { // Ensure UI updates happen on the main thread
//            self.loading = true
//            self.error = nil
//        }
//        
//        do {
//            var granted = false
//            if #available(iOS 17.0, *) {
//                // Use the newer API for iOS 17+
//                granted = try await store.requestFullAccessToEvents()
//            } else {
//                // Fallback for older iOS versions
//                granted = try await store.requestAccess(to: .event) // Use await with the older async wrapper
//            }
//            
//            guard granted else {
//                await MainActor.run {
//                    self.error = "Calendar access denied."
//                    self.loading = false
//                }
//                return
//            }
//            
//            // If access granted, proceed to fetch (make fetch async too if needed)
//            await fetchEvents() // Rename or make fetch async
//            
//        } catch {
//            await MainActor.run {
//                self.error = "Error requesting calendar access: \(error.localizedDescription)"
//                self.loading = false
//            }
//        }
//    }
//    
//    // Make fetch async as well for consistency and potentially long operations
//    private func fetchEvents() async {
//        let start = Date()
//        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
//        let pred = store.predicateForEvents(withStart: start, end: end, calendars: store.calendars(for: .event))
//        
//        // Perform the potentially blocking fetch on a background task
//        let fetchedEvents = await Task.detached(priority: .userInitiated) {
//            return self.store.events(matching: pred)
//                .filter { !$0.isAllDay }
//                .sorted { $0.startDate < $1.startDate }
//        }.value // Get the result from the detached task
//        
//        // Update the published properties back on the main thread
//        await MainActor.run {
//            self.events = fetchedEvents
//            self.loading = false
//        }
//    }
//    private func fetch() {
//        let start = Date()
//        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
//        let pred = store.predicateForEvents(withStart: start, end: end, calendars: store.calendars(for: .event))
//        DispatchQueue.global(qos:.userInitiated).async {
//            let evs = self.store.events(matching: pred)
//                .filter { !$0.isAllDay }
//                .sorted { $0.startDate < $1.startDate }
//            DispatchQueue.main.async {
//                self.events = evs
//                self.loading = false
//            }
//        }
//    }
//}
//
//class RemindersManager: ObservableObject {
//    @Published var reminders: [EKReminder] = []
//    @Published var error: String?
//    @Published var loading = false
//    private let store = EKEventStore()
//    
//    func requestAndFetch() async { // Mark the function as async
//        await MainActor.run {
//            self.loading = true
//            self.error = nil
//        }
//        
//        do {
//            var granted = false
//            if #available(iOS 17.0, *) {
//                // Use the newer API for iOS 17+
//                granted = try await store.requestFullAccessToReminders()
//            } else {
//                // Fallback for older iOS versions
//                granted = try await store.requestAccess(to: .reminder) // Use await with the older async wrapper
//            }
//            
//            guard granted else {
//                await MainActor.run {
//                    self.error = "Reminders access denied."
//                    self.loading = false
//                }
//                return
//            }
//            // If access granted, proceed to fetch
//            await fetchReminders() // Make fetch async
//            //fetch() // the old way to fetching data
//            
//        } catch {
//            await MainActor.run {
//                self.error = "Error requesting reminders access: \(error.localizedDescription)"
//                self.loading = false
//            }
//        }
//    }
//    
//    // Make fetchReminders async
//    private func fetchReminders() async {
//        await MainActor.run {
//            self.loading = true
//            self.error = nil // Reset error state at the beginning
//        }
//        
//        let pred = store.predicateForReminders(in: store.calendars(for: .reminder))
//        
//        do {
//            // Bridge the completion handler API to async/await
//            let fetchedItems: [EKReminder] = try await withCheckedThrowingContinuation { continuation in
//                store.fetchReminders(matching: pred) { reminders in
//                    // This completion handler might not be on the main thread
//                    if let reminders = reminders {
//                        continuation.resume(returning: reminders)
//                    } else {
//                        // Handle the case where reminders are nil, perhaps return an empty array
//                        // or resume with an error depending on expected behavior.
//                        // Returning empty array is safer if nil is unexpected but possible.
//                        // continuation.resume(returning: [])
//                        // Or, if nil signifies an error state:
//                        continuation.resume(
//                            throwing:
//                                NSError(
//                                    domain: "RemindersFetch",
//                                    code: -1,
//                                    userInfo: [NSLocalizedDescriptionKey: "Failed to fetch reminders, returned nil."]
//                                )
//                        )
//                    }
//                    // Note: Error handling specific to the fetchReminders *method itself*
//                    // isn't directly provided in its completion handler signature,
//                    // unlike some other Apple APIs. We rely on the outer do-catch.
//                }
//            }
//            
//            // Filter the reminders *after* fetching them
//            let filteredReminders = fetchedItems.filter { $0.isCompleted == false }
//            
//            // Update state back on the Main Actor
//            await MainActor.run {
//                self.reminders = filteredReminders
//                self.loading = false
//            }
//            
//        } catch {
//            // Catch errors from withCheckedThrowingContinuation or permission checks
//            await MainActor.run {
//                self.error = "Error fetching reminders: \(error.localizedDescription)"
//                self.loading = false
//            }
//        }
//    }
//    
//    private func fetch() {
//        let pred = store.predicateForReminders(in: store.calendars(for: .reminder))
//        store.fetchReminders(matching: pred) { items in
//            DispatchQueue.main.async {
//                self.reminders = items?.filter { $0.isCompleted == false } ?? []
//                self.loading = false
//            }
//        }
//    }
//}
//
//// MARK: - UIKit Wrappers
//
//// Message Composer
//struct MessageComposeView: UIViewControllerRepresentable {
//    @Environment(\.dismiss) var dismiss
//    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
//        let vc = MFMessageComposeViewController()
//        vc.messageComposeDelegate = context.coordinator
//        return vc
//    }
//    func updateUIViewController(_ ui: MFMessageComposeViewController, context: Context) {}
//    func makeCoordinator() -> Coordinator { Coordinator(self) }
//    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
//        let parent: MessageComposeView
//        init(_ p: MessageComposeView) { parent = p }
//        func messageComposeViewController(_ vc: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
//            parent.dismiss()
//        }
//    }
//}
//
//// Mail Composer
//struct MailComposeView: UIViewControllerRepresentable {
//    @Environment(\.dismiss) var dismiss
//    func makeUIViewController(context: Context) -> MFMailComposeViewController {
//        let vc = MFMailComposeViewController()
//        vc.mailComposeDelegate = context.coordinator
//        return vc
//    }
//    func updateUIViewController(_ ui: MFMailComposeViewController, context: Context) {}
//    func makeCoordinator() -> Coordinator { Coordinator(self) }
//    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
//        let parent: MailComposeView
//        init(_ p: MailComposeView) { parent = p }
//        internal func mailComposeController(_ vc: MFMailComposeViewController, didFinishWith _: MFMailComposeResult, error _: Error?) {
//            parent.dismiss()
//        }
//    }
//}
//
//// Image Picker (Camera/Library)
//struct ImagePicker: UIViewControllerRepresentable {
//    @Environment(\.dismiss) var dismiss
//    let source: UIImagePickerController.SourceType
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.sourceType = source
//        picker.delegate = context.coordinator
//        return picker
//    }
//    func updateUIViewController(_ ui: UIImagePickerController, context: Context) {}
//    func makeCoordinator() -> Coordinator { Coordinator(self) }
//    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//        let parent: ImagePicker
//        init(_ p: ImagePicker) { parent = p }
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey:Any]) {
//            parent.dismiss()
//        }
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            parent.dismiss()
//        }
//    }
//}
//
//// MARK: - SwiftUI Views
//
//struct NotificationViewRow: View {
//    let data: NotificationData
//    var body: some View {
//        HStack(spacing:12) {
//            Image(systemName: data.icon)
//                .font(.title3)
//                .frame(width:36,height:36)
//                .background(Color.gray.opacity(0.2))
//                .clipShape(RoundedRectangle(cornerRadius:8))
//            VStack(alignment:.leading,spacing:4) {
//                HStack {
//                    Text(data.appName).font(.caption).foregroundColor(.secondary)
//                    Spacer()
//                    Text(data.timeString).font(.caption2).foregroundColor(.secondary)
//                }
//                Text(data.title).font(.headline)
//                Text(data.body).font(.subheadline).foregroundColor(.secondary).lineLimit(2)
//            }
//        }
//        .padding()
//        .background(.ultraThinMaterial)
//        .clipShape(RoundedRectangle(cornerRadius:16))
//        .shadow(color:.black.opacity(0.1),radius:4,y:2)
//    }
//}
//
//// MARK: - CONTENT VIEW - Refactored SwiftUI Views
//
//// MARK: 1. Background View
//struct BackgroundView: View {
//    var body: some View {
//        LinearGradient(colors: [.blue.opacity(0.8), .indigo.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
//            .ignoresSafeArea()
//    }
//}
//
//// MARK: 2. Loading/Error Status View
//struct LoadingErrorStatusView: View {
//    @ObservedObject var calMgr: CalendarManager
//    @ObservedObject var remMgr: RemindersManager
//    
//    var body: some View {
//        Group {
//            // Display loading/error states concisely
//            if calMgr.loading || remMgr.loading {
//                ProgressView().tint(.white)
//                    .padding(.vertical, 5) // Add some spacing
//            }
//            if let err = calMgr.error ?? remMgr.error { // Show first available error
//                Text(err)
//                    .font(.caption)
//                    .foregroundColor(.yellow)
//                    .padding(6)
//                    .background(.black.opacity(0.4))
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .multilineTextAlignment(.center)
//                
//            }
//        }
//    }
//}
//
//// MARK: 3. Expand/Collapse Buttons View
//struct ExpandCollapseControlsView: View {
//    let isCollapsed: Bool
//    let totalItemCount: Int
//    let maxShowWhenCollapsed: Int
//    let expandAction: () -> Void
//    let collapseAction: () -> Void
//    
//    var body: some View {
//        if isCollapsed && totalItemCount > maxShowWhenCollapsed {
//            // Use existing ExpandButton (ensure it's defined)
//            ExpandButton(count: totalItemCount - maxShowWhenCollapsed, action: expandAction)
//        } else if !isCollapsed && totalItemCount > maxShowWhenCollapsed {
//            // Use existing CollapseButton (ensure it's defined)
//            CollapseButton(action: collapseAction)
//        }
//        // No button needed if not collapsible (count <= max)
//    }
//}
//
//// MARK: 4. Notification List View (Displays the rows)
//struct NotificationListView: View {
//    let items: [NotificationData]
//    let launchAction: (FeatureDestination) -> Void
//    let deleteAction: (UUID) -> Void // Changed to accept UUID
//    
//    var body: some View {
//        // Add a subtle header only when showing the full list and it's not empty
//        if !items.isEmpty {
//            Text("Notifications")
//                .font(.caption2)
//                .foregroundColor(.white.opacity(0.8))
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.leading, 5) // Indent slightly
//        }
//        
//        // The actual list of notifications
//        ForEach(items) { note in
//            // Use existing InteractiveRow (ensure it's defined)
//            InteractiveRow(data: note, onTap: launchAction, onDelete: {
//                // Call delete action with the item's ID
//                deleteAction(note.id)
//            })
//        }
//    }
//}
//
//// MARK: 5. Notification Stack Container (Handles Collapsed/Expanded Logic)
//struct NotificationStackContainerView: View {
//    let items: [NotificationData] // Pass the base items
//    let calendarEvents: [EKEvent] // Pass fetched events
//    @Binding var isCollapsed: Bool
//    let maxShowWhenCollapsed: Int
//    let launchAction: (FeatureDestination) -> Void
//    let deleteAction: (UUID) -> Void
//    
//    // Computed property to prepare the final, sorted list including calendar events
//    private var preparedAndSortedItems: [NotificationData] {
//        var combined = items // Start with base items
//        // Add calendar events as NotificationData *only if not already present*
//        for ev in calendarEvents {
//            let noteId = ev.eventIdentifier // Use event ID as the unique identifier
//            if !combined.contains(where: { $0.id.uuidString == noteId }) { // Check for pre-existing ID
//                let calNote = NotificationData(
//                    icon: "calendar",
//                    appName: "Calendar",
//                    title: ev.title ?? "Event",
//                    body: (ev.location ?? ""),
//                    //body: (ev.location ?? "") + " — \(ev.startDate ?? Date(), style: .time)",
//                    date: ev.startDate ?? Date(), // Use start date for sorting
//                    destination: .showEventDetail(ev)
//                )
//                combined.append(calNote)
//            }
//        }
//        // Sort the final combined list
//        return combined.sorted { $0.date > $1.date }
//    }
//    
//    // Determine which items to display based on collapsed state
//    private var itemsToDisplay: [NotificationData] {
//        if isCollapsed && preparedAndSortedItems.count > maxShowWhenCollapsed {
//            return Array(preparedAndSortedItems.prefix(maxShowWhenCollapsed))
//        } else {
//            return preparedAndSortedItems
//        }
//    }
//    
//    var body: some View {
//        VStack(spacing:12) {
//            // Display the list (either prefix or full list)
//            NotificationListView(
//                items: itemsToDisplay,
//                launchAction: launchAction,
//                deleteAction: deleteAction
//            )
//            
//            // Display the Expand/Collapse button
//            ExpandCollapseControlsView(
//                isCollapsed: isCollapsed,
//                totalItemCount: preparedAndSortedItems.count, // Use count of full prepared list
//                maxShowWhenCollapsed: maxShowWhenCollapsed,
//                expandAction: { withAnimation(.spring()) { isCollapsed = false; Haptics.shared.tap() } },
//                collapseAction: { withAnimation(.spring()) { isCollapsed = true; Haptics.shared.tap() } }
//            )
//            
//            // Display empty state if the *prepared* list is empty after combining
//            if preparedAndSortedItems.isEmpty {
//                Text("No Notifications")
//                    .foregroundColor(.white.opacity(0.7))
//                    .padding(.vertical, 40)
//            }
//        }
//    }
//}
//
//// MARK: 6. Bottom Bar View
//struct BottomBarView: View {
//    @Binding var flashlightOn: Bool
//    let toggleFlashAction: () -> Void
//    let launchCameraAction: () -> Void
//    let showRemindersAction: () -> Void
//    
//    var body: some View {
//        HStack(spacing: 80) { // Keep spacing or adjust as needed
//            // Flashlight Button
//            Button {
//                toggleFlashAction() // Use the passed action
//            } label: {
//                Image(systemName: flashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
//                    .font(.title2)
//                    .frame(width: 50, height: 50)
//                    .background(.black.opacity(0.35)) // Slightly more opaque background
//                    .clipShape(Circle())
//            }
//            .buttonStyle(.plain) // Use plain style to avoid default button appearance
//            
//            // Camera Button
//            Button {
//                launchCameraAction() // Use the passed action
//            } label: {
//                Image(systemName: "camera.fill")
//                    .font(.title2)
//                    .frame(width: 50, height: 50)
//                    .background(.black.opacity(0.35))
//                    .clipShape(Circle())
//            }
//            .buttonStyle(.plain)
//            
//            // Reminders Button
//            Button {
//                showRemindersAction() // Use the passed action
//            } label: {
//                Image(systemName: "list.bullet")
//                    .font(.title2)
//                    .frame(width: 50, height: 50)
//                    .background(.black.opacity(0.35))
//                    .clipShape(Circle())
//            }
//            .buttonStyle(.plain)
//            
//        }
//        .padding(.bottom, 40) // Bottom padding for safe area
//        .foregroundColor(.white) // Ensure icons are white
//        .frame(maxWidth: .infinity) // Ensure HStack takes full width for centering
//        .background(.ultraThinMaterial.opacity(0.1)) // Optional subtle background for the bar itself
//    }
//}
//
//// MARK: - Main ContentView (Orchestrator)
//struct ContentView: View {
//    // MARK: State Objects and State Variables
//    @StateObject private var calMgr = CalendarManager()
//    @StateObject private var remMgr = RemindersManager()
//    
//    @State private var items: [NotificationData] = [ // Base items
//        .init(icon: "message.fill", appName: "Messages", title: "Lunch?", body: "Hey, free for lunch?", date: Date().addingTimeInterval(-300), destination: .composeMessage),
//        .init(icon: "envelope.fill", appName: "Mail", title: "Weekly Digest", body: "Your roundup is ready.", date: Date().addingTimeInterval(-3600), destination: .composeMail),
//        .init(icon: "photo.on.rectangle", appName: "Photos", title: "New Memory", body: "Your trip memory is here.", date: Date().addingTimeInterval(-86400), destination: .pickPhoto(source: .photoLibrary)),
//        // Add more sample data if needed
//    ]
//    @State private var isCollapsed = true
//    @State private var isFlashlightOn = false // Renamed to avoid conflict with binding name
//    @State private var activeDestination: FeatureDestination? = nil // Renamed to avoid conflict
//    @State private var showRemindersSheet = false
//    
//    // Constants
//    private let maxShowWhenCollapsed = 3 // Increased slightly
//    
//    // MARK: Body
//    var body: some View {
//        ZStack {
//            BackgroundView()
//            
//            ScrollView {
//                VStack(spacing: 15) { // Consistent spacing
//                    HeaderView() // Existing header
//                    
//                    LoadingErrorStatusView(calMgr: calMgr, remMgr: remMgr) // Extracted status view
//                    
//                    // Use the container view for notifications
//                    NotificationStackContainerView(
//                        items: items,   // Pass the base items
//                        calendarEvents: calMgr.events, // Pass fetched calendar events
//                        isCollapsed: $isCollapsed,
//                        maxShowWhenCollapsed: maxShowWhenCollapsed,
//                        launchAction: launchDestination, // Pass the launch function
//                        deleteAction: removeNotification // Pass the remove function
//                    )
//                    
//                }
//                .padding(.horizontal, 10)
//                .padding(.top, 50) // Top padding for status bar etc.
//                .padding(.bottom, 140) // Ample bottom padding for scroll over bottom bar
//            }
//            .scrollDismissesKeyboard(.interactively) // Good practice
//            
//            // Overlay the Bottom Bar
//            VStack {
//                Spacer() // Pushes the bar to the bottom
//                BottomBarView(
//                    flashlightOn: $isFlashlightOn,
//                    toggleFlashAction: toggleFlashlight, // Pass the toggle function
//                    launchCameraAction: { launchDestination(.pickPhoto(source: .camera)) }, // Pass camera launch closure
//                    showRemindersAction: presentReminders // Pass reminders launch closure
//                )
//            }
//            .ignoresSafeArea(.keyboard) // Prevent keyboard from pushing bar up
//        }
//        // MARK: Sheet Modifiers
//        .sheet(item: $activeDestination) { destination in // Use 'item' for identifiable destinations
//            // Destination View Builder
//            destinationView(for: destination)
//                .onAppear { Haptics.shared.openSheet() } // Haptic on sheet appear
//        }
//        .sheet(isPresented: $showRemindersSheet) {
//            // Reminders Sheet
//            NavigationView { // Wrap in NavigationView for title/toolbar
//                RemindersListView(manager: remMgr)
//                    .navigationTitle("Upcoming Reminders")
//                    .toolbar {
//                        ToolbarItem(placement: .navigationBarTrailing) { // Correct placement
//                            Button("Done") { showRemindersSheet = false; Haptics.shared.select() }
//                        }
//                    }
//            }
//            .onAppear { Haptics.shared.openSheet() } // Haptic on sheet appear
//        }
//        // MARK: Lifecycle and Appearance
//        .task { // Use .task for async operations on appear
//            await calMgr.requestAndFetch()
//        }
//        .preferredColorScheme(.dark) // Keep dark mode preference
//    }
//    
//    // MARK: Helper Functions
//    private func launchDestination(_ destination: FeatureDestination) {
//        guard destination.id != FeatureDestination.none.id else { return }
//        self.activeDestination = destination // Set the active destination to trigger the sheet
//    }
//    
//    private func removeNotification(id: UUID) {
//        withAnimation(.easeOut(duration: 0.3)) {
//            items.removeAll { $0.id == id }
//        }
//        Haptics.shared.tap() // Light tap for delete
//    }
//    
//    private func toggleFlashlight() {
//        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
//            print("Device does not have a torch.")
//            return
//        }
//        
//        do {
//            try device.lockForConfiguration()
//            device.torchMode = device.torchMode == .on ? .off : .on
//            device.unlockForConfiguration()
//            isFlashlightOn.toggle() // Update state AFTER successful toggle
//            Haptics.shared.select() // Selection haptic for toggle
//        } catch {
//            print("Error toggling torch: \(error.localizedDescription)")
//            // Optionally provide user feedback here
//        }
//    }
//    
//    private func presentReminders() {
//        Task { // Fetch reminders when the button is tapped
//            await remMgr.requestAndFetch()
//            // Only show the sheet *after* potentially getting permission/data
//            showRemindersSheet = true // Trigger the reminders sheet
//        }
//    }
//    
//    // MARK: Destination View Builder (Helper for sheet(item:))
//    @ViewBuilder
//    private func destinationView(for destination: FeatureDestination) -> some View {
//        switch destination {
//        case .composeMessage:
//            MessageComposeView()
//        case .composeMail:
//            MailComposeView()
//        case .pickPhoto(let source):
//            ImagePicker(source: source)
//        case .showEventDetail(let event):
//            // Embed in NavigationView for potential title/buttons later
//            NavigationView {
//                CalendarEventDetail(event: event)
//                    .navigationTitle("Event Details") // Add a title
//                    .toolbar { // Add a Done button
//                        ToolbarItem(placement: .confirmationAction) {
//                            Button("Done") { activeDestination = nil; Haptics.shared.select() }
//                        }
//                    }
//            }
//        case .showReminders: // This case is handled by the other sheet modifier
//            EmptyView() // Should not be reached via activeDestination
//        case .none:
//            EmptyView()
//        }
//    }
//}
//
//// MARK: - SUBVIEWS
//
//// Ensure ExpandButton and CollapseButton are defined as in the original code:
//struct ExpandButton: View {
//    let count: Int
//    let action: () -> Void
//    var body: some View {
//        Button(action: action) {
//            HStack {
//                Text("+\(count) more notification\(count > 1 ? "s" : "")") // Improved text
//                    .font(.footnote).bold()
//                Spacer()
//                Image(systemName: "chevron.down")
//            }
//            .padding(10) // Slightly larger padding
//            .background(.black.opacity(0.25))
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .foregroundColor(.white) // Ensure text/icon color
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//struct CollapseButton: View {
//    let action: () -> Void
//    var body: some View {
//        Button(action: action) {
//            Label("Show Less", systemImage: "chevron.up")
//                .font(.footnote).bold() // Make bold to match expand button
//                .padding(10) // Match padding
//                .background(.black.opacity(0.25))
//                .clipShape(RoundedRectangle(cornerRadius: 12)) // Match shape
//                .foregroundColor(.white) // Ensure text/icon color
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//// Make sure InteractiveRow is defined as well
//struct InteractiveRow: View {
//    let data: NotificationData
//    let onTap: (FeatureDestination) -> Void
//    let onDelete: () -> Void // Keep original onDelete signature for now
//    
//    var body: some View {
//        // NotificationViewRow needs to be defined as per the original code.
//        // Assume NotificationViewRow struct exists.
//        NotificationViewRow(data: data)
//            .contentShape(Rectangle()) // Ensure the whole row is tappable
//            .onTapGesture {
//                Haptics.shared.tap() // Tap haptic
//                onTap(data.destination)
//            }
//            .swipeActions(edge: .trailing, allowsFullSwipe: false) { // Disable full swipe delete
//                Button(role: .destructive) {
//                    onDelete() // Calls the closure passed from the parent
//                } label: {
//                    Label("Clear", systemImage: "trash.fill")
//                }
//                .tint(.red) // Ensure destructive tint
//            }
//        // Accessibility Enhancements
//            .accessibilityElement(children: .combine) // Combine child elements for better reading
//            .accessibilityLabel("\(data.appName): \(data.title)") // Clear label
//            .accessibilityHint("Tap to open or swipe left to clear") // Hint for actions
//    }
//}
//
//struct HeaderView: View {
//    var body: some View {
//        VStack(spacing:4) {
//            Text(Date(), style:.date).font(.title3).foregroundColor(.white.opacity(0.9))
//            Text(Date(), style:.time).font(.system(size:70, weight:.thin)).foregroundColor(.white)
//        }
//        .shadow(radius:3)
//    }
//}
//
//struct BottomBar: View {
//    @Binding var flashlightOn: Bool
//    let onCamera: () -> Void
//    let onReminders: () -> Void
//    let toggleFlash: () -> Void
//    
//    var body: some View {
//        HStack(spacing:80) {
//            Button { toggleFlash() }
//            label: {
//                Image(systemName: flashlightOn ? "flashlight.on.fill":"flashlight.off.fill")
//                    .font(.title2).frame(width:50,height:50)
//                    .background(.black.opacity(0.3)).clipShape(Circle())
//            }
//            .buttonStyle(.plain)
//            Button { onCamera() }
//            label: {
//                Image(systemName:"camera.fill")
//                    .font(.title2).frame(width:50,height:50)
//                    .background(.black.opacity(0.3)).clipShape(Circle())
//            }
//            .buttonStyle(.plain)
//            Button { onReminders() }
//            label: {
//                Image(systemName:"list.bullet")
//                    .font(.title2).frame(width:50,height:50)
//                    .background(.black.opacity(0.3)).clipShape(Circle())
//            }
//            .buttonStyle(.plain)
//        }
//        .padding(.bottom,40)
//        .foregroundColor(.white)
//    }
//}
//
//// Calendar Event Detail
//struct CalendarEventDetail: View {
//    let event: EKEvent
//    var body: some View {
//        VStack(spacing:20) {
//            Text(event.title ?? "Event").font(.title)
//            Text(event.startDate, style:.date).bold()
//            Text(event.startDate, style:.time)
//            if let loc = event.location {
//                Label(loc, systemImage:"mappin.and.ellipse")
//            }
//            Text(event.notes ?? "").padding()
//            Spacer()
//        }
//        .padding()
//    }
//}
//
//// Reminders List
//struct RemindersListView: View {
//    @ObservedObject var manager: RemindersManager
//    var body: some View {
//        NavigationView {
//            List {
//                if manager.loading {
//                    ProgressView()
//                } else if let err = manager.error {
//                    Text(err).foregroundColor(.red)
//                } else {
//                    ForEach(manager.reminders, id: \.calendarItemIdentifier) { r in
//                        HStack {
//                            Text(r.title)
//                            Spacer()
//                            if let d = r.dueDateComponents?.date {
//                                Text(d, style:.date).foregroundColor(.secondary)
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Reminders")
//            .toolbar {
//                ToolbarItem(placement:.automatic) {
//                    Button("Done") { UIApplication.shared.dismissAllSheets() }
//                }
//            }
//        }
//    }
//}
//// MARK: - Extension
//// Helper to dismiss sheets from UIKit (Updated for iOS 15+)
//extension UIApplication {
//    func dismissAllSheets(animated: Bool = true) {
//        // Get active scenes
//        let scenes = UIApplication.shared.connectedScenes
//        
//        // Filter for foreground active UIWindowScene
//        guard let windowScene = scenes
//            .filter({ $0.activationState == .foregroundActive })
//            .first(where: { $0 is UIWindowScene }) as? UIWindowScene else {
//            print("Could not find active window scene to dismiss sheet.")
//            return
//        }
//        
//        // Find the key window or the first window in that scene
//        guard let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first else {
//            print("Could not find window in scene to dismiss sheet.")
//            return
//        }
//        
//        // Check if there's actually something presented to dismiss
//        if window.rootViewController?.presentedViewController != nil {
//            window.rootViewController?.dismiss(animated: animated, completion: nil)
//            print("Dismissing presented view controller.")
//        } else {
//            print("No view controller presented to dismiss.")
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview("Content View") {
//    ContentView()
//}
