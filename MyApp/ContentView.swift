//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}
// MARK: - Data Models (Representing Vehicle State & Configuration)

import SwiftUI
import Combine // Needed for ObservableObject

// Represents the overall state and configuration of the simulated vehicle
struct VehicleState {
    // Connection Status (Simulated)
    var isConnected: Bool = true // Simulate wireless connection
    var isiPhoneDetected: Bool = true

    // Drive State
    var speed: Double = 0.0 // Meters per hour (for smooth animation)
    var displaySpeedKmh: Int = 0 // For numerical display
    var displaySpeedMph: Int = 0 // For numerical display
    var rpm: Double = 800.0
    var engineState: EngineState = .normal
    var gear: Gear = .park
    var isReversing: Bool { gear == .reverse }

    // Climate Control State (Reflecting the configuration example)
    var climateConfig: ClimateConfiguration = .defaultFiveSeaterSedan
    var climateState: ClimateZoneStates = ClimateZoneStates() // Holds current temps, fan speeds, etc.
    var isAcOn: Bool = true
    var isRecirculationOn: Bool = false
    var syncMode: ClimateSyncMode = .passengerToDriver

    // Tire Pressure State
    var tirePressures: [VehicleLayoutKey: TirePressureInfo] = defaultTirePressures
    var showTirePressureWarning: Bool = false
    var allowDismissTireWarning: Bool = true

    // Camera State
    var showBackupCamera: Bool = false
    var backupCameraViewMode: CameraViewMode = .standard // Bird's eye, etc.

    // Customization / Automaker Features
    var customSettings: [CustomSetting] = defaultCustomSettings
    var automakerNotifications: [AutomakerNotification] = []
    var showCustomPunchThrough: Bool = false // e.g., linked from a custom setting

    // Other potential states mirroring the categories list...
    // ... Closures, Charging, Driver Assistance, Media Info, etc.

    // --- Enums and Sub-structs ---
    enum Gear { case park, reverse, neutral, drive }
    enum EngineState { case off, normal, exceedingMaxRpm }
    enum PressureState { case normal, low, deflation, unknown }
    enum ClimateSyncMode { case none, passengerToDriver, allToDriver }
    enum CameraViewMode { case standard, birdsEye, parkingAssist }

    struct TirePressureInfo {
        var pressureValue: Double // e.g., in PSI or kPa
        var state: PressureState = .normal
    }

    struct ClimateZoneState {
        var temperature: Double = 22.0 // Celsius
        var fanLevel: Int = 3 // 0-10 perhaps
        var vents: Set<VentDirection> = [.middle] // Upper, Middle, Lower
        var seatHeaterLevel: Int = 0
        var seatFanLevel: Int = 0
    }

    struct ClimateZoneStates {
        var driver: ClimateZoneState = ClimateZoneState()
        var passenger: ClimateZoneState = ClimateZoneState(temperature: 20.0, fanLevel: 2)
        var rear: ClimateZoneState = ClimateZoneState(temperature: 21.0, fanLevel: 1)
        // Add more zones if needed by config
    }

    enum VentDirection { case upper, middle, lower }

    // Placeholder for custom settings structure
    struct CustomSetting: Identifiable {
        let id = UUID()
        var name: String
        var iconName: String?
        var type: SettingType
        var targetZone: VehicleLayoutKey? // For zone-specific settings like massage
        // ... other properties like current value, options, etc.
    }

    enum SettingType {
        case toggle(isOn: Bool)
        case slider(value: Double, range: ClosedRange<Double>)
        case options(selected: String, options: [String])
        case deepLink(appName: String, targetScreen: String)
        case subMenu(settings: [CustomSetting])
        case punchThroughTrigger // Triggers a custom Punch-Through view
    }

    struct AutomakerNotification: Identifiable {
        let id = UUID()
        var title: String
        var message: String
        var iconName: String?
        var displayLocation: DisplayLocation // Cluster or Center
        var isLocallyRendered: Bool // Affects how quickly it might appear
        var actions: [NotificationAction] = []
        var isDismissible: Bool = true
    }
    enum DisplayLocation { case instrumentCluster, centerDisplay }
    enum NotificationActionType { case dismiss, configure(target: ActionTarget)}
    enum ActionTarget { case deepLink(appName: String, targetScreen: String), customMenu, punchThrough }
    struct NotificationAction {
        var label: String
        var type: NotificationActionType
    }
}

// Defines the physical/logical locations in the car
enum VehicleLayoutKey: String, CaseIterable, Hashable {
    case seat_front_left // Driver (example LHD)
    case seat_front_right // Passenger
    case seat_2nd_row_left
    case seat_2nd_row_middle
    case seat_2nd_row_right
    case seat_2nd_row // General rear zone
    case tire_front_left
    case tire_front_right
    case tire_rear_left
    case tire_rear_right
    case global // For controls not tied to a specific seat/zone
}

// Represents the configurable aspects (trim levels, features enabled)
struct ClimateConfiguration {
    var vehicleIdentifier: String // e.g., "5SeaterSedan", "SportSUV"
    var interiorImageAsset: String // Maps identifier to an image name
    var supportedZones: Set<VehicleLayoutKey> = [.seat_front_left, .seat_front_right, .seat_2nd_row]
    var driverControls: Set<ClimateControl> = [.temperature, .fanLevel, .vents, .seatHeater]
    var passengerControls: Set<ClimateControl> = [.temperature, .fanLevel, .vents, .seatHeater]
    var rearControls: Set<ClimateControl> = [.temperature, .fanLevel] // Example: Rear only gets Temp/Fan
    var globalControls: Set<ClimateControl> = [.recirculation, .acToggle, .syncZones]

    enum ClimateControl {
        case temperature, fanLevel, vents, seatHeater, seatFan, recirculation, acToggle, syncZones
    }

    // Example Static Configuration
    static let defaultFiveSeaterSedan = ClimateConfiguration(
        vehicleIdentifier: "5SeaterSedan",
        interiorImageAsset: "sedan_interior_tan" // Placeholder image name
        // Uses default supportedZones and controls
    )
    // Add other static configs for simulation...
}

// MARK: - Default Data (for simulation)

let defaultTirePressures: [VehicleLayoutKey: VehicleState.TirePressureInfo] = [
    .tire_front_left: .init(pressureValue: 35.0),
    .tire_front_right: .init(pressureValue: 35.0),
    .tire_rear_left: .init(pressureValue: 34.0),
    .tire_rear_right: .init(pressureValue: 34.0)
]

let defaultCustomSettings: [VehicleState.CustomSetting] = [
    .init(name: "Ambient Lighting", iconName: "lightbulb", type: .options(selected: "Blue", options: ["Blue", "Red", "Green", "White"])),
    .init(name: "Driver Massage", iconName: "figure.wave", type: .punchThroughTrigger, targetZone: .seat_front_left),
    .init(name: "Launch Off-Road App", iconName: "car.circle", type: .deepLink(appName: "TrailMaster", targetScreen: "main")),
    .init(name: "Advanced Vehicle Dynamics", iconName: "gearshape.2", type: .subMenu(settings: [
        .init(name: "Traction Control", type: .toggle(isOn: true)),
        .init(name: "Stability Assist", type: .toggle(isOn: true))
    ]))
]

// MARK: - ViewModel (The Brain)

@MainActor // Ensure UI updates happen on the main thread
class CarPlayViewModel: ObservableObject {
    @Published var vehicleState: VehicleState = VehicleState()
    @Published var syncPulse: Int = 0 // Conceptual pulse for simulated sync

    private var displayLink: CADisplayLink?
    private var simulationTimer: Timer? // For less frequent state changes

    init() {
        // Simulate high-frequency updates (e.g., for gauges) conceptually
        // Using CADisplayLink for timing closer to screen refresh if possible
        displayLink = CADisplayLink(target: self, selector: #selector(updateSyncPulse))
        // Target 60fps conceptually. Actual SwiftUI updates depend on changes.
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 60, preferred: 60)
        displayLink?.add(to: .current, forMode: .default)

        // Simulate slower vehicle state changes (e.g., temperature drift, mock notifications)
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.simulateRandomEvents()
        }
    }

    deinit {
        displayLink?.invalidate()
        simulationTimer?.invalidate()
    }

    // --- Simulation Logic ---

    @objc private func updateSyncPulse() {
        // This pulse conceptually represents the UI Sync signal and frame timestamps.
        // Views can observe this to *conceptually* align animations.
        syncPulse += 1

        // Simulate continuous changes like speed decay when not accelerating
        if vehicleState.speed > 0 {
            // Simulate simple deceleration
            // A real system would get this from vehicle state protocol
           // updateSpeed(max(0, vehicleState.speed - 5)) // Reduce slightly each "frame"
        }
         if vehicleState.rpm > 800 { // Simulate idle return
           //  updateRPM(max(800, vehicleState.rpm - 20))
        }
    }

    private func simulateRandomEvents() {
       // Randomly trigger a notification (example)
        if Int.random(in: 0..<10) == 0 {
           let newNotification = VehicleState.AutomakerNotification(
                title: "Service Due",
                message: "Oil change recommended soon.",
                iconName: "wrench.and.screwdriver",
                displayLocation: .centerDisplay, // Or .instrumentCluster
                isLocallyRendered: false // Example: Comes from iPhone app logic
            )
            vehicleState.automakerNotifications.append(newNotification)
           // Limit history
            if vehicleState.automakerNotifications.count > 3 {
               vehicleState.automakerNotifications.removeFirst()
            }
        }

       // Simulate tire pressure drop
        if Int.random(in: 0..<20) == 0 {
            let tireKey = VehicleLayoutKey.allCases.filter { $0.rawValue.contains("tire") }.randomElement() ?? .tire_front_left
            if vehicleState.tirePressures[tireKey]?.state == .normal {
                print("Simulating low pressure for \(tireKey.rawValue)")
                vehicleState.tirePressures[tireKey]?.pressureValue -= 10
                vehicleState.tirePressures[tireKey]?.state = .low
                triggerTireWarning()
            }
        }
    }

    // --- Actions Triggered by UI Controls ---

    func setGear(_ gear: VehicleState.Gear) {
        vehicleState.gear = gear
        vehicleState.showBackupCamera = (gear == .reverse)
        // In real system, this sends state back, car confirms, state updates. Here we do it directly.
        if gear != .drive {
            // Simulate speed reduction when not in drive
            updateSpeed(vehicleState.speed * 0.5)
        }
    }

    func updateSpeed(_ newSpeed: Double) {
        vehicleState.speed = newSpeed
        // Convert to display units (example calculation)
        vehicleState.displaySpeedKmh = Int((newSpeed / 1000) * 3600) // m/h to km/h
        vehicleState.displaySpeedMph = Int(Double(vehicleState.displaySpeedKmh) * 0.621371)
    }

    func updateRPM(_ newRPM: Double) {
        vehicleState.rpm = newRPM
        if newRPM > 6500 { // Example threshold
            vehicleState.engineState = .exceedingMaxRpm
        } else {
            vehicleState.engineState = .normal
        }
    }
    
    func accelerate() {
        // Simulate acceleration affecting speed and RPM
        updateSpeed(vehicleState.speed + 500) // Arbitrary increase
        updateRPM(vehicleState.rpm + 300)
    }
    
    func brake() {
        // Simulate braking
        updateSpeed(max(0, vehicleState.speed - 1000))
        updateRPM(max(800, vehicleState.rpm - 500))
    }

    func setTemperature(zone: VehicleLayoutKey, temp: Double) {
        // Update the specific zone - Requires more elaborate state management
        // For simplicity, we'll just update the driver temp here
        vehicleState.climateState.driver.temperature = temp
        // Real system would involve checking sync state etc.
    }

    func triggerTireWarning() {
        vehicleState.showTirePressureWarning = true
        // Possibly trigger a specific Automaker Notification as well
    }

    func dismissTireWarning() {
        if vehicleState.allowDismissTireWarning {
            vehicleState.showTirePressureWarning = false
        }
    }

    func toggleCustomPunchThrough() {
        vehicleState.showCustomPunchThrough.toggle()
    }
    
    func dismissNotification(id: UUID) {
        vehicleState.automakerNotifications.removeAll { $0.id == id }
    }
    
    func simulateDeepLink(appName: String, screen: String) {
        print("Simulating Deep Link: Go to \(appName) -> \(screen)")
         // In a real app, you might try UIApplication.shared.open() if the app is installed
         // Or just show a confirmation message in the simulator UI
    }
}

// MARK: - SwiftUI Views (Representing UI Layers & Compositors)

struct ContentView: View {
    @StateObject private var viewModel = CarPlayViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // Background (representing the car interior/display background)
                Color(UIColor.systemGray6).ignoresSafeArea()

                // --- The Core Simulated Display ---
                SimulatedSystemCompositorView()

                // --- Simulation Controls ---
                VStack {
                    Spacer() // Push controls to the bottom
                    SimulationControlPanel()
                }
            }
            .environmentObject(viewModel) // Provide ViewModel to all child views
            .navigationTitle("Next-Gen CarPlay Sim")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Config", destination: ConfigurationView())
                }
            }
        }
    }
}

// Represents the final composition step by the main Vehicle System
struct SimulatedSystemCompositorView: View {
    @EnvironmentObject var viewModel: CarPlayViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) { // Base layer, usually full screen
                
                // Layer 1: The output of the dedicated CarPlay Compositor
                SimulatedCarPlayCompositorView()
                    .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.8) // Simulate display area

                // Layer 2: Overlay UI (Always on top, rendered by vehicle)
                OverlayUIView()
                     .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.8) // Match CarPlay area
                    .allowsHitTesting(false) // Overlays usually don't intercept taps

                // --- Notifications (Conceptually part of Center Display's final composition) ---
                 notificationArea
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding()

            }
             .frame(maxWidth: .infinity, maxHeight: .infinity) // Center the stack
            .clipped() // Simulate physical screen bounds
            .border(Color.black, width: 2) // Represent physical display bezel
        }
    }
    
    // Displaying automaker notifications on the center display conceptually
    private var notificationArea: some View {
        VStack(alignment: .trailing, spacing: 10) {
            ForEach(viewModel.vehicleState.automakerNotifications.filter { $0.displayLocation == .centerDisplay }.suffix(2)) { notification in
                 NotificationView(notification: notification) { actionType in
                     handleNotificationAction(notification.id, actionType)
                 }
                 .transition(.move(edge: .bottom).combined(with: .opacity)) // Added animation
            }
        }
//        .animation(.default, value: viewModel.vehicleState.automakerNotifications) // Animate changes
    }
    
    private func handleNotificationAction(_ notificationId: UUID, _ actionType: VehicleState.NotificationActionType) {
         switch actionType {
         case .dismiss:
             viewModel.dismissNotification(id: notificationId)
         case .configure(let target):
             // Handle configure actions (deep link, menu, punch-through)
             print("Configure action tapped for notification \(notificationId): \(target)")
             // Add simulation logic here based on target
             switch target {
                 case .deepLink(let appName, let screen): viewModel.simulateDeepLink(appName: appName, screen: screen)
                 case .customMenu: print("Simulate showing custom menu") // Could show a sheet
                 case .punchThrough: viewModel.toggleCustomPunchThrough()
             }
         }
    }
}

// Represents the dedicated CarPlay Compositor (OpenGL based in reality)
struct SimulatedCarPlayCompositorView: View {
    @EnvironmentObject var viewModel: CarPlayViewModel

    var body: some View {
        ZStack {
            Color.clear // Base for compositing

            // Layer 1: Remote UI (iPhone Video Stream)
            RemoteUIView()
                .zIndex(1) // Lower layer

            // Layer 2: Local UI (Locally Rendered Gauges etc.)
            LocalUIView()
                .zIndex(2) // Middle layer

            // Layer 3: Punch-Through UI (Cameras, Vehicle Features)
            // Shown conditionally based on state
            if viewModel.vehicleState.showBackupCamera || viewModel.vehicleState.showCustomPunchThrough {
                PunchThroughUIView()
                    .zIndex(3) // Higher layer
                    .transition(.opacity.combined(with: .scale(scale: 0.9))) // Example transition
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.vehicleState.showBackupCamera) // Animate punch-through visibility
         .animation(.easeInOut(duration: 0.4), value: viewModel.vehicleState.showCustomPunchThrough)
        // In reality, this compositor handles frame-level sync via timestamps and UI Sync.
        // SwiftUI handles updates based on state changes.
        .background(VisualEffectView(effect: UIBlurEffect(style: .dark))) // Give it a distinct look
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

// MARK: --- UI Layer Views ---

struct RemoteUIView: View {
    @EnvironmentObject var viewModel: CarPlayViewModel

    var body: some View {
        ZStack {
            // Simulate different Remote UI "apps"
            VStack {
                 Text("Remote UI (Simulated - from iPhone)")
                     .font(.caption)
                     .foregroundColor(.gray)
                     .padding(.top, 5)
                Spacer()
                // Example: Show Climate UI if configured
                 if viewModel.vehicleState.climateConfig.supportedZones.count > 0 {
                     SimulatedClimateView()
                         .padding()
                 } else {
                     Text("Climate Not Configured")
                         .foregroundColor(.gray)
                 }
                
                Spacer()

                 // Example: Show Tire Pressure Warning Detail
                 if viewModel.vehicleState.showTirePressureWarning {
                     SimulatedTirePressureWarningDetailView()
                         .padding()
                         .background(Color.red.opacity(0.3))
                         .cornerRadius(10)
                 }
                 

                // Example: Media Player Placeholder
                SimulatedMediaControls()
                    .padding(.bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue.opacity(0.1)) // Visual indicator for the layer
    }
}

struct LocalUIView: View {
    @EnvironmentObject var viewModel: CarPlayViewModel

    var body: some View {
        ZStack {
            // Example Instrument Cluster Simulation
            HStack {
                Spacer()
                SimulatedSpeedoView()
                Spacer()
                SimulatedTachoView()
                Spacer()
            }
            .padding(.horizontal)
            .allowsHitTesting(false) // Gauges usually aren't interactive

            // Other local elements (e.g., turn signals - part of Overlay usually, but could be here)
              VStack {
                  Text("Local UI (Simulated - Vehicle Rendered)")
                      .font(.caption)
                      .foregroundColor(.gray)
                  Spacer()
             }
             .padding(.top, 5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // No background needed - often transparent over Remote UI
    }
}

struct PunchThroughUIView: View {
    @EnvironmentObject var viewModel: CarPlayViewModel

    var body: some View {
        ZStack {
            // Simulate Backup Camera
            if viewModel.vehicleState.showBackupCamera {
                VStack {
                    Text("Punch-Through: Backup Camera (Simulated)")
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(5)
                    Spacer()
                    Image(systemName: "camera.viewfinder")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                         .padding(50)
                     // Add simulated controls if needed (e.g., view mode buttons)
                     HStack {
                         Button("Standard") { /* Change view mode */ }
                         Button("Birds Eye") { /* Change view mode */ }
                     }.buttonStyle(.bordered).tint(.white)
                     Spacer()
                }
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .background(Color.black.opacity(0.8)) // Simulate camera feed area
            }
            // Simulate Custom Punch-Through (e.g., Massage Seat UI)
            else if viewModel.vehicleState.showCustomPunchThrough {
                VStack {
                    Text("Punch-Through: Custom (e.g., Massage) (Simulated)")
                        .foregroundColor(.white)
                        .padding(5)
                         .background(Color.purple.opacity(0.8))
                        .cornerRadius(5)
                    Spacer()
                    Image(systemName: "figure.seated.seatbelt") // Example icon
                        .resizable()
                        .scaledToFit()
                        .padding(40)
                        .foregroundColor(.white)
                    Text("Select Massage Intensity...")
                         .foregroundColor(.white)
                    // Add sliders, buttons for the custom UI
                     Slider(value: .constant(0.5)) // Placeholder
                         .padding()
                         .tint(.white)
                     Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.purple.opacity(0.6)) // Different background
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct OverlayUIView: View {
     @EnvironmentObject var viewModel: CarPlayViewModel
    // These are CRITICAL indicators, rendered by the vehicle system.
    // They must be accurate and reliable.
    var body: some View {
        ZStack(alignment: .top) {
            // Example: Telltales at the top
            HStack {
                Image(systemName: "lightbulb.fill") // Headlights (Example)
                    .foregroundColor(Color.green)
                Image(systemName: "exclamationmark.triangle.fill") // Generic Warning (Example)
                    .foregroundColor(viewModel.vehicleState.engineState == .exceedingMaxRpm ? Color.red : Color.clear) // Show if engine redlines
                Spacer()
                Text(viewModel.vehicleState.gear.hashValue.description) // Gear Indicator
                     .padding(.horizontal, 8)
                     .background(Color.gray.opacity(0.5))
                     .cornerRadius(5)
                 
                Image(systemName: "fuelpump.fill") // Fuel Level (Example)
                    .foregroundColor(Color.orange)
                Image(systemName: "lock.fill") // Doors Locked (Example)
                    .foregroundColor(Color.yellow)

            }
            .padding(.horizontal)
            .padding(.top, 8)
            .font(.title2)
            .shadow(radius: 1)

             // Add other necessary overlays (seatbelt, airbag status etc.)
             // These should directly reflect critical vehicle system status.
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

// MARK: --- Component Views (Examples) ---

struct SimulatedSpeedoView: View {
    @EnvironmentObject var viewModel: CarPlayViewModel
    // Conceptual sync pulse - see if speed update coincides
    let syncPulse: Int

    init() {
        // In a real View observing an EnvirontmentObject,
        // you don't typically initialize with environment data directly.
        // We'll grab the pulse inside the body or via a wrapper if needed,
        // but for this simulation, just observing the ViewModel change is sufficient.
        syncPulse = 0 // Placeholder, viewModel is the source of truth
    }

    var body: some View {
        VStack {
            Text("\(viewModel.vehicleState.displaySpeedKmh)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
            Text("km/h")
                .font(.caption)
             Text("(\(viewModel.vehicleState.displaySpeedMph) mph)")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        // Add gauge drawing here using Path, Shape etc. for a real look
        // Animate changes based on viewModel.vehicleState.speed
        .animation(.linear(duration: 0.05), value: viewModel.vehicleState.speed) // Fast animation for gauge
    }
}

struct SimulatedTachoView: View {
     @EnvironmentObject var viewModel: CarPlayViewModel

    var body: some View {
        VStack {
            Text("\(Int(viewModel.vehicleState.rpm))")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(viewModel.vehicleState.engineState == .exceedingMaxRpm ? .red : .primary)
            Text("RPM")
                .font(.caption)
        }
        .animation(.linear(duration: 0.05), value: viewModel.vehicleState.rpm)
         .animation(.default, value: viewModel.vehicleState.engineState) // Color change animation
    }
}

struct SimulatedClimateView: View {
     @EnvironmentObject var viewModel: CarPlayViewModel

    var body: some View {
         VStack {
             Text("Climate Controls")
                 .font(.headline)
             Image(viewModel.vehicleState.climateConfig.interiorImageAsset) // Load the configured image
                 .resizable()
                 .scaledToFit()
                 .frame(height: 100) // Placeholder size
                 .background(Color.gray.opacity(0.3))
                 .overlay(Text(viewModel.vehicleState.climateConfig.vehicleIdentifier).font(.caption).padding(3).background(.ultraThinMaterial), alignment: .topLeading)

             HStack {
                 // Driver Zone (Example)
                 if viewModel.vehicleState.climateConfig.supportedZones.contains(.seat_front_left) {
                     VStack {
                         Text("Driver")
                         Text("\(viewModel.vehicleState.climateState.driver.temperature, specifier: "%.0f")°C")
                         Stepper("", value: $viewModel.vehicleState.climateState.driver.temperature, in: 16...30)
                         Text("Fan: \(viewModel.vehicleState.climateState.driver.fanLevel)")
                         // Add vent controls etc.
                     }
                     .padding(5).border(Color.gray)
                 }

                 // Passenger Zone (Example)
                  if viewModel.vehicleState.climateConfig.supportedZones.contains(.seat_front_right) {
                     VStack {
                         Text("Passenger")
                          Text("\(viewModel.vehicleState.climateState.passenger.temperature, specifier: "%.0f")°C")
                          Stepper("", value: $viewModel.vehicleState.climateState.passenger.temperature, in: 16...30)
                          Text("Fan: \(viewModel.vehicleState.climateState.passenger.fanLevel)")
                     }
                     .padding(5).border(Color.gray)
                 }
             }
             // Add Rear Zone, Global Controls if configured...
             Toggle("A/C", isOn: $viewModel.vehicleState.isAcOn) // Example global control
         }
         .padding()
         .background(.thinMaterial)
         .cornerRadius(10)
    }
}

struct SimulatedTirePressureWarningDetailView: View {
    @EnvironmentObject var viewModel: CarPlayViewModel

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("Tire Pressure Low!")
                    .bold()
            }
            // Display which tires are low
            ForEach(VehicleLayoutKey.allCases.filter { $0.rawValue.contains("tire") }, id: \.self) { key in
               if let tireInfo = viewModel.vehicleState.tirePressures[key], tireInfo.state != .normal {
                   Text("\(key.rawValue)")
//                   Text("\(key.rawValue.replacingOccurred(with: "tire_", with: "").capitalized): \(tireInfo.state.rawValue.capitalized)")
               }
            }

             if viewModel.vehicleState.allowDismissTireWarning {
                 Button("Dismiss") {
                     viewModel.dismissTireWarning()
                 }
                 .buttonStyle(.bordered)
                 .tint(.yellow)
             }
        }
    }
}

struct SimulatedMediaControls: View {
    var body: some View {
        VStack {
            Text("Now Playing: Song Title - Artist Name") // Placeholder
            HStack {
                Spacer()
                Image(systemName: "backward.fill")
                Spacer()
                Image(systemName: "play.fill") // Or "pause.fill"
                Spacer()
                Image(systemName: "forward.fill")
                Spacer()
            }
             .font(.title)
             .padding(.top, 5)
        }
         .padding()
         .background(.ultraThinMaterial)
    }
}

struct NotificationView: View {
    let notification: VehicleState.AutomakerNotification
    let actionHandler: (VehicleState.NotificationActionType) -> Void

    var body: some View {
        HStack {
            if let iconName = notification.iconName {
                Image(systemName: iconName)
                    .foregroundColor(.secondary) // Use theme color potentially
                     .font(.title2)
            }
            VStack(alignment: .leading) {
                Text(notification.title).font(.headline)
                Text(notification.message).font(.subheadline).foregroundColor(.gray)
                // Add buttons based on notification.actions
                 if !notification.actions.isEmpty {
                     HStack {
                         ForEach(notification.actions, id: \.label) { action in
                             Button(action.label) {
                                 actionHandler(action.type)
                             }
                             .buttonStyle(.bordered)
                             .font(.caption)
                         }
                     }
                    .padding(.top, 2)
                 }
            }
            Spacer()
             if notification.isDismissible {
                 Button { actionHandler(.dismiss) } label: { Image(systemName: "xmark.circle.fill").foregroundColor(.gray) }
             }
        }
        .padding()
         .background(.regularMaterial) // Use material for overlay effect
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

// MARK: - Simulation Controls View

struct SimulationControlPanel: View {
    @EnvironmentObject var viewModel: CarPlayViewModel

    var body: some View {
         VStack {
             Text("Simulation Controls").font(.caption).foregroundColor(.gray)
             HStack {
                 Button { viewModel.accelerate() } label: { Image(systemName: "arrow.up.circle.fill") }
                 Button { viewModel.brake() } label: { Image(systemName: "arrow.down.circle.fill") }

                 Picker("Gear", selection: $viewModel.vehicleState.gear) {
                     ForEach([VehicleState.Gear.park, .reverse, .neutral, .drive], id: \.self) { gear in
                         Text(gear.hashValue.description)
//                         Text(gear.rawValue.capitalized).tag(gear)
                     }
                 }
                 .pickerStyle(.segmented)
                 .onChange(of: viewModel.vehicleState.gear) { newGear in
                     // Update view model when picker changes
                     // We do this directly in the binding now.
                     // If more complex logic is needed, keep the onChange.
                      viewModel.setGear(newGear) // Ensure camera state updates etc.
                 }
             }
              .font(.title2)
             
             // Example: Trigger specific issues
             HStack {
                 Button("Trigger Tire Low") { viewModel.triggerTireWarning() }
                  .font(.caption)
                 Button("Toggle Custom PT") { viewModel.toggleCustomPunchThrough() }
                  .font(.caption)
             }
             .buttonStyle(.borderedProminent)
             .tint(.orange)

         }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .padding(.horizontal) // Add padding from screen edges
        .padding(.bottom, 5)
    }
}

// MARK: - Configuration View

struct ConfigurationView: View {
     @EnvironmentObject var viewModel: CarPlayViewModel
     // Allow changing the simulated configuration
    
     // Example: Selectable configurations
     let availableConfigs: [ClimateConfiguration] = [.defaultFiveSeaterSedan /*, addMoreConfigsHere */]

    var body: some View {
        Form {
            Section("Vehicle Setup") {
                 Picker("Climate Config", selection: $viewModel.vehicleState.climateConfig.vehicleIdentifier) {
                     ForEach(availableConfigs, id: \.vehicleIdentifier) { config in
                         Text(config.vehicleIdentifier).tag(config.vehicleIdentifier)
                     }
                 }
                 // Add toggles for features if needed for dynamic config simulation
                Toggle("Simulate AC On", isOn: $viewModel.vehicleState.isAcOn)
                Toggle("Allow Tire Dismiss", isOn: $viewModel.vehicleState.allowDismissTireWarning)
            }
            
            Section("Custom Settings Defined") {
                 // Display the list of custom settings (read-only view for simulation)
                 List(viewModel.vehicleState.customSettings) { setting in
                     HStack {
                         if let iconName = setting.iconName { Image(systemName: iconName) }
                         Text(setting.name)
                         Spacer()
                         Text("(\(settingTypeName(setting.type)))") // Show type
                             .font(.caption)
                             .foregroundColor(.gray)
                     }
                 }
            }
        }
        .navigationTitle("Sim Configuration")
        .onChange(of: viewModel.vehicleState.climateConfig.vehicleIdentifier) { newIdentifier in
              // Update the whole config struct when the identifier changes
              if let newConfig = availableConfigs.first(where: { $0.vehicleIdentifier == newIdentifier }) {
                  viewModel.vehicleState.climateConfig = newConfig
              }
        }
    }
    
    // Helper to display setting type name
    func settingTypeName(_ type: VehicleState.SettingType) -> String {
        switch type {
        case .toggle: return "Toggle"
        case .slider: return "Slider"
        case .options: return "Options"
        case .deepLink: return "Deep Link"
        case .subMenu: return "Sub-Menu"
        case .punchThroughTrigger: return "Punch-Through"
        }
    }
}

// MARK: - Helpers

// Simple Blur ViewRepresentable
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
//
//// App Entry Point
////@main // <-- Uncomment this line if this is your main App file
//struct CarPlaySimApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

#Preview {
    ContentView()
}
