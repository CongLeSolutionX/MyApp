//
//  KeyCardDesignView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

import Foundation
import SwiftUI // Needed for Color

// Model: Represents the data for a digital hotel key
struct HotelKeyInfo: Identifiable {
    let id = UUID() // Unique identifier for the key
    var hotelName: String
    var location: String
    var checkInDate: Date
    var checkOutDate: Date
    var roomDescription: String
    var roomNumber: String? // Optional, might not always be displayed directly
    var backgroundImageName: String // Name of the image asset
    var brandColor: Color = .blue // Default color, can be customized per hotel
}

// Extension for formatted dates
extension HotelKeyInfo {
    var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // e.g., "SEP 23"

        // Handle potential year change if range crosses New Year
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        if yearFormatter.string(from: checkInDate) != yearFormatter.string(from: checkOutDate) {
             formatter.dateFormat = "MMM d, yyyy"
        }

        return "\(formatter.string(from: checkInDate)) - \(formatter.string(from: checkOutDate))".uppercased()
    }
}

import SwiftUI
import Combine // Needed for ObservableObject

// ViewModel: Manages the state and logic for the HotelKeyView
@MainActor // Ensure UI updates happen on the main thread
class HotelKeyViewModel: ObservableObject {

    // --- Published Properties (State) ---
    @Published var keyInfo: HotelKeyInfo
    @Published var showOptionsSheet: Bool = false
    @Published var isAttemptingUnlock: Bool = false
    @Published var unlockStatusMessage: String? = nil // For showing feedback

    // Mock Data Initializer
    init(mockKey: HotelKeyInfo? = nil) {
        // Use provided mock key or default mock data
        self.keyInfo = mockKey ?? HotelKeyViewModel.createMockKey()
    }

    // --- Actions (Triggered by the View) ---

    func doneButtonTapped() {
        // In a real app, this would likely dismiss the current view (e.g., a modal sheet)
        // For simulation, we just print a message.
        print("Done button tapped. Dismissing view (simulated).")
        // If this view was presented as a sheet, you'd use @Environment(\.presentationMode) var presentationMode
        // and call presentationMode.wrappedValue.dismiss()
    }

    func optionsButtonTapped() {
        showOptionsSheet = true
    }

    func dismissOptionsSheet() {
        showOptionsSheet = false
    }

    func attemptUnlock() {
        guard !isAttemptingUnlock else { return } // Prevent multiple attempts

        isAttemptingUnlock = true
        unlockStatusMessage = "Attempting Unlock..."
        print("Attempting to unlock room...")

        // Simulate network/NFC interaction delay
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // Simulate 2 seconds delay

            // Simulate success/failure (randomly for demo)
            let success = Bool.random()
            if success {
                print("Unlock Successful!")
                unlockStatusMessage = "Door Unlocked!"
            } else {
                print("Unlock Failed. Please try again.")
                unlockStatusMessage = "Unlock Failed. Try Again."
            }

            // Reset status after showing message for a bit
            try? await Task.sleep(nanoseconds: 1_500_000_000) // Show message for 1.5 seconds
            isAttemptingUnlock = false
            unlockStatusMessage = nil // Clear the message
        }
    }

    // --- Action Sheet Options ---
    func shareKey() {
        print("Sharing key action triggered (implementation pending).")
        dismissOptionsSheet()
         // TODO: Implement key sharing logic (e.g., present share sheet)
    }

    func viewReservation() {
        print("Viewing reservation action triggered (implementation pending).")
        dismissOptionsSheet()
        // TODO: Implement navigation to reservation details screen
    }

     func getHelp() {
        print("Getting help action triggered (implementation pending).")
        dismissOptionsSheet()
        // TODO: Implement navigation to help/support screen or trigger call/chat
    }

    // --- Mock Data Creation ---
    static func createMockKey() -> HotelKeyInfo {
        let calendar = Calendar.current
        let checkIn = calendar.date(byAdding: .day, value: -2, to: Date())!
        let checkOut = calendar.date(byAdding: .day, value: 5, to: Date())!

        return HotelKeyInfo(
            hotelName: "Paradise Bay Resort",
            location: "Maui, Hawaii",
            checkInDate: checkIn,
            checkOutDate: checkOut,
            roomDescription: "Beachfront Suite",
            roomNumber: "1204", // Added room number
            backgroundImageName: "palm_trees_placeholder", // Ensure this asset exists
            brandColor: .teal // Use a different color for variety
        )
    }
}


import SwiftUI

// Main View: Connects to the ViewModel
struct HotelKeyView: View {
    // Use @StateObject to create and own the ViewModel instance
    @StateObject private var viewModel: HotelKeyViewModel

    // Allow initializing with a specific key (useful for previews or navigation)
    init(viewModel: HotelKeyViewModel = HotelKeyViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 30) { // Adjusted spacing
                Spacer()

                HotelKeyCard(keyInfo: viewModel.keyInfo) // Pass data to card
                    .padding(.horizontal)

                Spacer()

                HoldNearReaderInstruction(
                    isAttempting: $viewModel.isAttemptingUnlock, // Bind state
                    statusMessage: viewModel.unlockStatusMessage ?? "Hold Near Reader",
                    brandColor: viewModel.keyInfo.brandColor,
                    onTap: viewModel.attemptUnlock // Pass action closure
                )

                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(viewModel.keyInfo.hotelName) // Use hotel name as title
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Leading Button (Done)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        viewModel.doneButtonTapped() // Call ViewModel action
                    }
                    .tint(viewModel.keyInfo.brandColor) // Use brand color
                }
                // Trailing Button (Ellipsis)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.optionsButtonTapped() // Call ViewModel action
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                    }
                    .tint(Color.primary) // Use primary color (adapts to light/dark)
                }
            }
            // --- Action Sheet ---
            .actionSheet(isPresented: $viewModel.showOptionsSheet) {
                 ActionSheet(
                    title: Text("Key Options"),
                    message: Text("Select an action for Room \(viewModel.keyInfo.roomNumber ?? "N/A")"),
                    buttons: [
                        .default(Text("Share Key")) { viewModel.shareKey() },
                        .default(Text("View Reservation")) { viewModel.viewReservation() },
                        .default(Text("Get Help")) { viewModel.getHelp() },
                        .cancel() // Standard cancel button
                    ]
                )
            }
        }
        .navigationViewStyle(.stack)
        // Inject ViewModel into environment if needed by deeper views (optional here)
        // .environmentObject(viewModel)
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

// Updated Instruction View: Shows dynamic status and progress
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

// --- Previews ---
#if DEBUG
struct HotelKeyView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with default mock data
        HotelKeyView()
            .previewDisplayName("Default Mock")

        // Preview with specific options for testing
         HotelKeyView(viewModel: HotelKeyViewModel(mockKey: HotelKeyInfo(
            hotelName: "City Center Hotel",
            location: "New York, NY",
            checkInDate: Date(),
            checkOutDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            roomDescription: "Standard Queen",
            roomNumber: "801",
            backgroundImageName: "city_skyline_placeholder", // Use another placeholder
            brandColor: .purple)))
            .previewDisplayName("Custom Mock (NYC)")

         // Preview the attempting state
        HotelKeyView(viewModel: {let vm = HotelKeyViewModel(); vm.isAttemptingUnlock = true; vm.unlockStatusMessage = "Attempting..."; return vm}())
              .previewDisplayName("Attempting Unlock")
    }
}

// Add placeholder images in Assets.xcassets:
// 1. "palm_trees_placeholder" (e.g., a blue rectangle)
// 2. "city_skyline_placeholder" (e.g., a gray rectangle)
#endif
