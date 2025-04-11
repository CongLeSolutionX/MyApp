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


import SwiftUI
import MapKit // Import MapKit framework

// MARK: - Data Model for Annotations (Optional but good practice)

// Simple identifiable annotation structure
struct IdentifiablePlace: Identifiable {
    let id: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D

    init(id: UUID = UUID(), lat: Double, long: Double, name: String = "Pin") {
        self.id = id
        self.name = name
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}

// MARK: - MapView Representable (Bridge between SwiftUI and MKMapView)

struct MapViewRepresentable: UIViewRepresentable {

    // Binding to the region state in the SwiftUI view
    @Binding var region: MKCoordinateRegion

    // Array of places to show as annotations
    let places: [IdentifiablePlace]

    // State variable to track if initial region is set to prevent unwanted updates
    @State private var isInitialRegionSet = false

    // --- UIViewRepresentable Required Methods ---

    // 1. Create the underlying MKMapView
    func makeUIView(context: Context) -> MKMapView {
        print("MapViewRepresentable: makeUIView")
        let mapView = MKMapView()
        mapView.delegate = context.coordinator // Set the Coordinator as the delegate
        mapView.showsUserLocation = true // Show the blue dot for user location
        return mapView
    }

    // 2. Update the MKMapView when SwiftUI state changes
    func updateUIView(_ uiView: MKMapView, context: Context) {
        print("MapViewRepresentable: updateUIView")

        // Update map region *only if* it differs significantly from the binding
        // AND if the change didn't originate from the map delegate itself.
         // Allow initial setting or significant external changes.
        if !isInitialRegionSet || regionHasChangedSignificantly(from: uiView.region, to: region) {
            print(" -> Setting region programmatically")
            uiView.setRegion(region, animated: true)
            // After the first programmatic set driven by initial state, mark it as set.
            // Subsequent external changes will still trigger this block.
            if !isInitialRegionSet {
                 isInitialRegionSet = true
            }
        }

        // Update annotations: Compare existing annotations with the new `places` array
        updateAnnotations(for: uiView)
    }

    // 3. Create the Coordinator instance
    func makeCoordinator() -> Coordinator {
        print("MapViewRepresentable: makeCoordinator")
        return Coordinator(self)
    }

    // --- Helper Methods ---

    // Check if two regions are significantly different to avoid update loops
    private func regionHasChangedSignificantly(from oldRegion: MKCoordinateRegion, to newRegion: MKCoordinateRegion) -> Bool {
        let tolerance = 0.0001 // Adjust tolerance as needed
        return abs(oldRegion.center.latitude - newRegion.center.latitude) > tolerance ||
               abs(oldRegion.center.longitude - newRegion.center.longitude) > tolerance ||
               abs(oldRegion.span.latitudeDelta - newRegion.span.latitudeDelta) > tolerance ||
               abs(oldRegion.span.longitudeDelta - newRegion.span.longitudeDelta) > tolerance
    }

    // Efficiently update annotations on the map
    private func updateAnnotations(for mapView: MKMapView) {
        // Convert IdentifiablePlace to MKPointAnnotation if needed, or directly use objects conforming to MKAnnotation
        let currentAnnotations = mapView.annotations.compactMap { $0 as? MKPointAnnotation } // Or your custom annotation class
        let newPlaceIDs = Set(places.map { $0.id })

        // Annotations to remove
        let annotationsToRemove = currentAnnotations.filter { annotation in
            guard let customIDString = annotation.subtitle, let customID = UUID(uuidString: customIDString) else {
                // If annotation doesn't have our expected ID structure, maybe keep it or remove it based on policy
                // For this example, we assume annotations managed here have the ID in subtitle
                return !newPlaceIDs.contains(UUID()) // Placeholder, adjust logic
            }
            return !newPlaceIDs.contains(customID)
        }
        mapView.removeAnnotations(annotationsToRemove)
        print(" -> Removed \(annotationsToRemove.count) annotations")

        // Annotations to add
        let currentPlaceIDs = Set(currentAnnotations.compactMap { UUID(uuidString: $0.subtitle ?? "") })
        let placesToAdd = places.filter { !currentPlaceIDs.contains($0.id) }

        let newAnnotations = placesToAdd.map { place -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = place.coordinate
            annotation.title = place.name
            annotation.subtitle = place.id.uuidString // Store ID to identify later
            return annotation
        }
        mapView.addAnnotations(newAnnotations)
        print(" -> Added \(newAnnotations.count) annotations")
    }

    // MARK: - Coordinator Class

    // Handles MKMapViewDelegate callbacks
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(_ parent: MapViewRepresentable) {
            self.parent = parent
            print("Coordinator: init")
        }

        // --- MKMapViewDelegate Methods ---

        // Called when the map's visible region changes (e.g., user pans/zooms)
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            print("Coordinator: regionDidChangeAnimated")
            // Update the SwiftUI @Binding state
            // Crucially, update the binding *before* the next updateUIView cycle
            // This prevents updateUIView from resetting the region immediately
            // Use DispatchQueue.main.async to avoid modifying state during view update warnings
            DispatchQueue.main.async {
                 print(" -> Updating binding from delegate")
                self.parent.region = mapView.region
                // Mark initial region set if user interacts before programmatic set finishes
                 if !self.parent.isInitialRegionSet {
                     self.parent.isInitialRegionSet = true
                 }
            }
        }

        // Called to provide the view for each annotation
        // (Customize pin appearance here)
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            print("Coordinator: viewFor annotation \(String(describing: annotation.title ?? "No Title"))")
            // Don't customize the user location blue dot
            if annotation is MKUserLocation {
                return nil
            }

            // Use reusable annotation views for performance
            let identifier = "PlaceAnnotation"
            var view: MKMarkerAnnotationView // Or MKPinAnnotationView

            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
                print(" --> Reusing view")
            } else {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true // Show bubble popup on tap
                // Add a button or other accessory to the callout (optional)
                // view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                 view.markerTintColor = UIColor.systemRed // Customize pin color
                 view.glyphText = "📍" // Optional: Text/Emoji inside pin
                 print(" --> Creating new view")
            }
            return view
        }

        // Optional: Called when the callout accessory (e.g., info button) is tapped
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            print("Coordinator: calloutAccessoryControlTapped for \(String(describing: view.annotation?.title ?? "nil"))")
            // Handle the tap, e.g., navigate to a detail view
            // You'd need to get info from the annotation (like its ID)
        }

         // Optional: Called when an annotation view is selected
         func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
             print("Coordinator: didSelect annotation \(String(describing: view.annotation?.title ?? "nil"))")
         }

         // Optional: Called when an annotation view is deselected
         func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
             print("Coordinator: didDeselect annotation \(String(describing: view.annotation?.title ?? "nil"))")
         }
    }
}

// MARK: - SwiftUI Content View

struct ContentView: View {
    // State for the map's region (bindable)
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020), // Apple Park
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02) // Zoom level
    )

    // State for annotations
    @State private var locations: [IdentifiablePlace] = [
        IdentifiablePlace(lat: 37.334_900, long: -122.009_020, name: "Apple Park"),
        IdentifiablePlace(lat: 37.331_820, long: -122.031_180, name: "Apple Campus (Infinite Loop)") // Old Campus
    ]

    var body: some View {
        NavigationView {
            VStack {
                // Display the MapViewRepresentable, passing the bindings/state
                MapViewRepresentable(region: $mapRegion, places: locations)
                    .ignoresSafeArea(edges: .top) // Allow map to go under nav bar

                // --- Debugging / Control Panel ---
                VStack(alignment: .leading) {
                    Text("Map Controls / Info")
                         .font(.headline)
                    // Display current region center from SwiftUI state
                    Text("Center: \(mapRegion.center.latitude, specifier: "%.4f"), \(mapRegion.center.longitude, specifier: "%.4f")")
                        .font(.caption)
                    Text("Zoom: \(mapRegion.span.latitudeDelta, specifier: "%.4f")")
                         .font(.caption)

                    HStack {
                         Button("Add Random Pin") {
                             addRandomLocation()
                         }
                         .buttonStyle(.bordered)

                        Button("Remove Last Pin") {
                            if !locations.isEmpty {
                                locations.removeLast()
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(locations.isEmpty)
                    }
                }
                .padding()
                .background(.thinMaterial) // Make controls stand out slightly
            }
            .navigationTitle("SwiftUI MapKit Bridge")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack) // Use stack style for consistent behavior
         // Request location permission when the view appears (or when needed)
         // Use .onAppear or a separate LocationManager class for production
         .onAppear(perform: requestLocationPermission)
    }

    // --- Helper Functions ---

    func addRandomLocation() {
        // Add a pin somewhere near the current center
        let randomLatOffset = Double.random(in: -0.01...0.01)
        let randomLonOffset = Double.random(in: -0.01...0.01)
        let newCoord = CLLocationCoordinate2D(
            latitude: mapRegion.center.latitude + randomLatOffset,
            longitude: mapRegion.center.longitude + randomLonOffset
        )
        let newPlace = IdentifiablePlace(lat: newCoord.latitude, long: newCoord.longitude, name: "Random Pin \(locations.count + 1)")
        locations.append(newPlace)
    }

     // Basic location permission request (Improve for production!)
    func requestLocationPermission() {
         let locationManager = CLLocationManager()
         locationManager.requestWhenInUseAuthorization()
     }
}

// MARK: - SwiftUI Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - App Entry Point (If this is the main file)
/*
@main
struct MapBridgeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
