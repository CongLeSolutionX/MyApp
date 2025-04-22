//
//  KeyCardDesignView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

// Model: Represents the data for a digital hotel key
struct HotelKeyInfo: Identifiable {
    let id = UUID() // Unique identifier for the key
    var hotelName: String
    var location: String
    var checkInDate: Date
    var checkOutDate: Date
    var roomDescription: String
    var roomNumber: String?
    var backgroundImageName: String
    var brandColor: Color = .blue
    // --- New Mock Data ---
    var wifiNetworkName: String = "ResortGuestWiFi"
    var wifiPassword: String? = "paradise123" // Optional password
}

// Extension for formatted dates (no changes needed here)
extension HotelKeyInfo {
    var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        if yearFormatter.string(from: checkInDate) != yearFormatter.string(from: checkOutDate) {
            formatter.dateFormat = "MMM d, yyyy"
        }
        return "\(formatter.string(from: checkInDate)) - \(formatter.string(from: checkOutDate))".uppercased()
    }
}

import SwiftUI
import Combine

@MainActor // Ensure UI updates happen on the main thread
class HotelKeyViewModel: ObservableObject {
    
    // --- Published Properties (State) ---
    @Published var keyInfo: HotelKeyInfo
    @Published var showOptionsSheet: Bool = false
    @Published var isAttemptingUnlock: Bool = false
    @Published var unlockStatusMessage: String? = nil
    
    // --- New State for Functionality ---
    @Published var shareItems: [Any]? = nil // Items to pass to Share Sheet
    @Published var showReservationDetailsSheet: Bool = false
    @Published var showHelpAlert: Bool = false
    @Published var helpAlertTitle: String = "Get Help"
    @Published var helpAlertMessage: String = ""
    
    // Mock Data Initializer
    init(mockKey: HotelKeyInfo? = nil) {
        self.keyInfo = mockKey ?? HotelKeyViewModel.createMockKey()
    }
    
    // --- Actions (Triggered by the View) ---
    
    func doneButtonTapped() {
        // Simulate dismissal or navigation back
        print("Done button tapped. Simulating view dismissal.")
        // In a real app, you might set a binding or use Environment(\.presentationMode)
        // e.g., presentationMode.wrappedValue.dismiss()
    }
    
    func optionsButtonTapped() {
        showOptionsSheet = true
    }
    
    func dismissOptionsSheet() {
        showOptionsSheet = false
    }
    
    func attemptUnlock() {
        guard !isAttemptingUnlock else { return }
        
        isAttemptingUnlock = true
        unlockStatusMessage = "Contacting Door..." // More specific initial message
        print("Attempting to unlock room...")
        
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // Simulate 1.5 seconds delay
            
            // Simulate varied outcomes
            let outcome = Int.random(in: 0...10)
            
            switch outcome {
            case 0...6: // Success (higher chance)
                print("Unlock Successful!")
                unlockStatusMessage = "Door Unlocked!"
            case 7:
                print("Unlock Failed: Key Read Error.")
                unlockStatusMessage = "Read Error. Align phone."
            case 8:
                print("Unlock Failed: Out of Range.")
                unlockStatusMessage = "Move Closer to Reader."
            case 9:
                print("Unlock Failed: Network Issue.")
                unlockStatusMessage = "Connection Issue. Try Again."
            default: // Generic failure
                print("Unlock Failed. Please try again.")
                unlockStatusMessage = "Unlock Failed."
            }
            
            // Reset status after showing message
            try? await Task.sleep(nanoseconds: 2_000_000_000) // Show message for 2 seconds
            isAttemptingUnlock = false
            unlockStatusMessage = nil
        }
    }
    
    // --- Action Sheet Options Implementation ---
    
    func shareKey() {
        print("Sharing key action triggered.")
        let keyDetails = """
        Hotel Key Details:
        Hotel: \(keyInfo.hotelName)
        Location: \(keyInfo.location)
        Room: \(keyInfo.roomDescription) (\(keyInfo.roomNumber ?? "N/A"))
        Dates: \(keyInfo.dateRangeString)
        (Note: This is simulated data, not a functional key)
        """
        // Prepare items for the share sheet
        shareItems = [keyDetails]
        dismissOptionsSheet()
    }
    
    func viewReservation() {
        print("Viewing reservation action triggered.")
        showReservationDetailsSheet = true
        dismissOptionsSheet()
    }
    
    func getHelp() {
        print("Getting help action triggered.")
        // Prepare content for the alert
        helpAlertTitle = "Hotel Support"
        helpAlertMessage = """
        For assistance, please contact the front desk.
        Phone: 1-800-555-1234 (Simulated)
        In-Hotel Extension: 0
        """
        showHelpAlert = true
        dismissOptionsSheet()
    }
    
    // --- Mock Data Creation (Updated) ---
    static func createMockKey() -> HotelKeyInfo {
        let calendar = Calendar.current
        let checkIn = calendar.date(byAdding: .day, value: -1, to: Date())!
        let checkOut = calendar.date(byAdding: .day, value: 4, to: Date())!
        
        return HotelKeyInfo(
            hotelName: "Ocean Breeze Inn", // Different Name
            location: "Santa Monica, CA",
            checkInDate: checkIn,
            checkOutDate: checkOut,
            roomDescription: "King Bed Courtyard View",
            roomNumber: "315",
            backgroundImageName: "beach_sunset_placeholder", // Ensure this asset exists
            brandColor: Color(red: 0.2, green: 0.6, blue: 0.8), // Custom Blue
            wifiNetworkName: "OceanBreezeGuest",
            wifiPassword: "ocean fun 24" // Updated mock password
        )
    }
}

import SwiftUI
import UIKit

// Wrapper for UIActivityViewController
struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            // Dismiss the hosting sheet once the share sheet is dismissed
            self.presentationMode.wrappedValue.dismiss()
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update logic needed typically
    }
}

import SwiftUI

struct ReservationDetailsView: View {
    let keyInfo: HotelKeyInfo // Pass the data needed
    @Environment(\.presentationMode) var presentationMode // To dismiss the sheet
    
    var body: some View {
        NavigationView {
            List {
                Section("Reservation") {
                    Label(keyInfo.hotelName, systemImage: "building.2")
                    Label(keyInfo.location, systemImage: "map")
                    Label(keyInfo.dateRangeString, systemImage: "calendar")
                }
                
                Section("Room") {
                    Label(keyInfo.roomDescription, systemImage: "bed.double")
                    if let roomNum = keyInfo.roomNumber {
                        Label("Room Number: \(roomNum)", systemImage: "number.square")
                    }
                }
                
                Section("Hotel Amenities") {
                    Label("Wi-Fi Network: \(keyInfo.wifiNetworkName)", systemImage: "wifi")
                    if let password = keyInfo.wifiPassword, !password.isEmpty {
                        Label("Password: \(password)", systemImage: "lock.shield")
                    } else {
                        Label("Password: Not Required", systemImage: "lock.open.shield")
                    }
                    // Add more mock amenities if desired
                    Label("Pool Access Included", systemImage: "figure.pool.swim")
                    Label("Fitness Center Available", systemImage: "figure.strengthtraining.functional")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Reservation Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .tint(keyInfo.brandColor)
                }
            }
        }
    }
}
// Updated Card View: Accepts data model
struct HotelKeyCard: View {
    let keyInfo: HotelKeyInfo
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background Image
            Image(keyInfo.backgroundImageName)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipped()
            
            // Overlay Gradients
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.6), .clear]), startPoint: .top, endPoint: .center)
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.6), .clear]), startPoint: .bottom, endPoint: .center)
            
            // Content Layer
            VStack {
                HStack(alignment: .top) {
                    // Top Left Icon (Could be dynamic based on key type)
                    Image(systemName: "checkmark.seal.fill") // Example secure icon
                        .font(.title)
                        .foregroundColor(.white)
                        .padding([.top, .leading])
                        .shadow(radius: 2)
                    
                    Spacer()
                    
                    // Top Right Text
                    VStack(alignment: .trailing) {
                        Text(keyInfo.location.uppercased())
                            .font(.caption.weight(.medium))
                        Text(keyInfo.dateRangeString)
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .shadow(radius: 1)
                    .padding([.top, .trailing])
                }
                
                Spacer()
                
                HStack {
                    // Bottom Left Text
                    Text(keyInfo.roomDescription)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                        .shadow(radius: 1)
                        .padding([.leading, .bottom])
                    
                    Spacer()
                    // Optional: Room Number subtly here?
                    if let roomNumber = keyInfo.roomNumber {
                        Text("Room \(roomNumber)")
                            .font(.caption.weight(.bold))
                            .padding(6)
                            .background(.ultraThinMaterial)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                            .padding([.trailing, .bottom])
                            .shadow(radius: 1)
                    }
                    
                }
            }
        }
        .frame(height: 220)
        .background(keyInfo.brandColor.opacity(0.5)) // Use brand color as fallback/tint
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4) // Slightly stronger shadow
    }
}


struct HoldNearReaderInstruction: View {
    @Binding var isAttempting: Bool // Use binding to react to state changes
    let statusMessage: String
    let brandColor: Color
    let onTap: () -> Void // Action closure
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Image(systemName: "iphone.radiowaves.left.and.right.circle.fill") // Filled version
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(isAttempting ? .secondary : brandColor) // Dim when attempting
                    .opacity(isAttempting ? 0.3 : 1.0) // Fade icon when spinner is shown
                
                if isAttempting {
                    ProgressView() // Shows loading spinner
                        .progressViewStyle(CircularProgressViewStyle(tint: brandColor))
                        .scaleEffect(1.5) // Make spinner slightly larger
                }
            }
            .frame(width: 70, height: 70) // Ensure consistent size for ZStack
            
            Text(statusMessage)
                .font(isAttempting ? .headline : .title3) // Change font weight during attempt
                .foregroundColor(isAttempting ? brandColor : .secondary)
                .multilineTextAlignment(.center)
                .frame(minHeight: 40) // Reserve space for two lines if needed
                .animation(.easeInOut, value: isAttempting) // Animate text changes
            
        }
        .padding(.horizontal)
        .contentShape(Rectangle()) // Make the whole VStack tappable
        .onTapGesture(perform: onTap) // Trigger the action
        .disabled(isAttempting) // Disable taps while attempting
    }
}

import SwiftUI

struct HotelKeyView: View {
    @StateObject private var viewModel = HotelKeyViewModel() // Use private for internal state
    
    // Internal initializer for previews/injection (optional but good practice)
    //     init(viewModel: HotelKeyViewModel = HotelKeyViewModel()) {
    //        _viewModel = StateObject(wrappedValue: viewModel)
    //     }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                HotelKeyCard(keyInfo: viewModel.keyInfo)
                    .padding(.horizontal)
                Spacer()
                HoldNearReaderInstruction(
                    isAttempting: $viewModel.isAttemptingUnlock,
                    statusMessage: viewModel.unlockStatusMessage ?? "Hold Near Reader to Unlock", // Default message
                    brandColor: viewModel.keyInfo.brandColor,
                    onTap: viewModel.attemptUnlock
                )
                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(viewModel.keyInfo.hotelName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { viewModel.doneButtonTapped() }
                        .tint(viewModel.keyInfo.brandColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { viewModel.optionsButtonTapped() } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                    }
                    .tint(Color.primary) // Adapts to light/dark mode
                }
            }
            // --- Action Sheet ---
            .actionSheet(isPresented: $viewModel.showOptionsSheet) {
                ActionSheet(
                    title: Text("Key Options"),
                    message: Text("Room \(viewModel.keyInfo.roomNumber ?? "N/A")"),
                    buttons: [
                        .default(Text("Share Key")) { viewModel.shareKey() },
                        .default(Text("View Reservation")) { viewModel.viewReservation() },
                        .default(Text("Get Help")) { viewModel.getHelp() },
                        .cancel()
                    ]
                )
            }
            // --- NEW: Sheet for Sharing ---
            // Triggered when shareItems is not nil
            .sheet(item: $viewModel.shareItems) { items in
                ActivityViewController(activityItems: items)
            }
            // --- NEW: Sheet for Reservation Details ---
            .sheet(isPresented: $viewModel.showReservationDetailsSheet) {
                ReservationDetailsView(keyInfo: viewModel.keyInfo)
                // Pass brand color if needed inside the details view's environment
                // .environment(\.colorScheme, .dark) // Example: Force dark scheme
            }
            // --- NEW: Alert for Help ---
            .alert(viewModel.helpAlertTitle, isPresented: $viewModel.showHelpAlert) {
                Button("OK", role: .cancel) { } // Simple dismiss button
            } message: {
                Text(viewModel.helpAlertMessage)
            }
        }
        .navigationViewStyle(.stack)
        .environmentObject(viewModel) // Only needed if deeper views require access without passing explicitly
    }
}

// Helper extension to make [Any]? identifiable for the .sheet(item:) modifier
extension Optional: @retroactive Identifiable where Wrapped: Identifiable {
    public var id: Wrapped.ID? { self?.id }
}

// Make Array identifiable for the .sheet(item:) modifier by using its count or a stable identifier
// Note: This is a simple way. For more complex scenarios, consider a dedicated identifiable struct wrapper.
extension Array: @retroactive Identifiable where Element: Any {
    public var id: String { // Use a hash or description as an ID
        return self.description // Simple example, might need refinement
    }
}

// --- Sub Views (HotelKeyCard, HoldNearReaderInstruction - No changes needed) ---
// Add the HotelKeyCard and HoldNearReaderInstruction structs from the previous response here

// --- Previews (Updated) ---
#if DEBUG

struct HotelKeyView_Functional_Previews: PreviewProvider {
    static var previews: some View {
        
        HotelKeyView()
            .previewDisplayName("Default Functional")
        
        // Preview Help Alert Triggered State
        HotelKeyView()
            .previewDisplayName("Help Alert State")
        
    }
}

//struct HotelKeyView_Functional_Previews: PreviewProvider {
//    static var previews: some View {
//
//        HotelKeyView(viewModel: HotelKeyViewModel())
//            .previewDisplayName("Default Functional")
//
//        // Preview Help Alert Triggered State
//        HotelKeyView(viewModel: {
//            let vm = HotelKeyViewModel()
//            vm.optionsButtonTapped() // Need action sheet logic first normally
//            vm.getHelp() // Manually trigger help state for preview
//            return vm
//        }())
//        .previewDisplayName("Help Alert State")
//
//        // Preview Reservation Sheet Triggered State (may need manual trigger)
//        HotelKeyView(viewModel: {
//            let vm = HotelKeyViewModel()
//             vm.showReservationDetailsSheet = true // Manually trigger sheet state
//            return vm
//        }())
//        .previewDisplayName("Reservation Sheet State")
//
//       // Preview Unlock Attempt State
//        HotelKeyView(viewModel: {
//            let vm = HotelKeyViewModel()
//             vm.isAttemptingUnlock = true
//             vm.unlockStatusMessage = "Connection Issue..."
//            return vm
//        }())
//        .previewDisplayName("Unlock Attempting State")
//    }
//}

// Add placeholder images in Assets.xcassets:
// 1. "beach_sunset_placeholder" (e.g., an orange/purple rectangle)
// (Keep palm_trees_placeholder if used by other mocks)
#endif
