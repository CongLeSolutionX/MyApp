//
//  GoogleMapView.swift
//  MyApp
//
//  Created by Cong Le on 3/19/25.
//

import SwiftUI
import MapKit

// --- Data Models ---

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct RouteOption: Identifiable {
    let id = UUID()
    let travelTime: String
    let eta: String
    let distance: String
    let description: String
}

// --- View Models ---

class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.8688, longitude: -118.0941), // Example: Buena Park, CA
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @Published var selectedRouteType: RouteType = .automobile

    // Dummy data for locations and routes
    let locations: [Location] = [
        Location(name: "My Location", coordinate: CLLocationCoordinate2D(latitude: 33.8823, longitude: -118.1100)), // Example coordinates
        Location(name: "H Mart", coordinate: CLLocationCoordinate2D(latitude: 33.8615, longitude: -118.0354))     // Example coordinates
    ]

    let routeOptions: [RouteOption] = [
        RouteOption(travelTime: "31 min", eta: "8:26 AM", distance: "11 mi", description: "Fastest"),
        RouteOption(travelTime: "33 min", eta: "8:28 AM", distance: "12 mi", description: "Via I-5 N")
    ]

    enum RouteType: String, CaseIterable, Identifiable {
        case automobile = "car.fill"
        case walking = "figure.walk"
        case transit = "tram.fill"
        case cycling = "bicycle"
        case other = "ellipsis"

        var id: String { self.rawValue }
    }
}

// --- Views ---

struct GoogleMapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var isDirectionsExpanded = false
    @State private var searchText = "" // For a future search bar implementation
    @State private var isHMartInfoShowing = false

    var body: some View {
        ZStack(alignment: .top) {
            MapView(region: $viewModel.region, locations: viewModel.locations, selectedRouteType: viewModel.selectedRouteType)
                .ignoresSafeArea()

            HStack {
                Spacer()
                VStack(spacing: 10) {
                    // Map Settings Button
                    Button(action: {
                        // Handle map settings (layers, etc.)
                    }) {
                        Image(systemName: "square.3.stack.3d")
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                    // Share Location
                    Button(action: {
                         // Handle location
                    }) {
                        Image(systemName: "paperplane.circle.fill")
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                    
                }
                .padding(.trailing)
            }

            // Overlay the DirectionsView at the bottom
            VStack {
                Spacer()
                DirectionsView(
                    viewModel: viewModel,
                    isDirectionsExpanded: $isDirectionsExpanded,
                    searchText: $searchText,
                    isHMartInfoShowing: $isHMartInfoShowing
                )
            }
        }
        .sheet(isPresented: $isHMartInfoShowing) {
           HMartInfoView(isPresented: $isHMartInfoShowing)
        }
    }
}

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let locations: [Location]
    var selectedRouteType: MapViewModel.RouteType

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        mapView.showsUserLocation = true

        // Add annotations for locations
        for location in locations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = location.name
            mapView.addAnnotation(annotation)
        }

        // Example: Add a basic route (you'd normally get this from MKDirections)
        if locations.count >= 2 {
            addRoute(to: mapView, from: locations[0].coordinate, to: locations[1].coordinate)
        }

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update route overlay based on selected route type
        if let overlay = uiView.overlays.first(where: { $0 is MKPolyline }) as? MKPolyline {
            if let renderer = uiView.renderer(for: overlay) as? MKPolylineRenderer {
                switch selectedRouteType {
                case .automobile:
                    renderer.strokeColor = UIColor.systemBlue
                    renderer.lineWidth = 5
                case .walking:
                    renderer.strokeColor = UIColor.systemGreen
                    renderer.lineWidth = 3
                    renderer.lineDashPattern = [5, 5]  // Example: Dashed line
                case .transit:
                    renderer.strokeColor = UIColor.systemOrange
                    renderer.lineWidth = 4
                case .cycling:
                    renderer.strokeColor = UIColor.systemPurple
                    renderer.lineWidth = 4
                case .other:
                    renderer.strokeColor = UIColor.systemGray
                    renderer.lineWidth = 2
                }
            }
        }

        uiView.region = region
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        // Customize annotation views (if needed)
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil // Use default user location view
            }

            let identifier = "LocationPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                (annotationView as? MKMarkerAnnotationView)?.canShowCallout = true
                (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .systemBlue // Customize pin color

                // Example: Add a custom button to the callout (if needed)
                let detailButton = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = detailButton

            } else {
                annotationView?.annotation = annotation
            }

            return annotationView
        }

        // Handle callout accessory control tap (e.g., to show details)
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let annotation = view.annotation as? MKPointAnnotation {
                print("Tapped on \(annotation.title ?? "") details")
                // Here, you might navigate to a detail view, show an alert, etc.
                //  parent.isHMartInfoShowing = true

            }
        }

        // Customize the route overlay (if needed)
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.systemBlue // Initial color
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay) // Default renderer
        }
    }

    // Helper function to add a route to the map
    private func addRoute(to mapView: MKMapView, from startCoordinate: CLLocationCoordinate2D, to endCoordinate: CLLocationCoordinate2D) {
        let startPlacemark = MKPlacemark(coordinate: startCoordinate)
        let endPlacemark = MKPlacemark(coordinate: endCoordinate)

        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: startPlacemark)
        directionRequest.destination = MKMapItem(placemark: endPlacemark)
        directionRequest.transportType = .automobile // Default to automobile

        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Error getting directions: \(error.localizedDescription)")
                }
                return
            }

            // Assuming you want to display the first route
            if let route = response.routes.first {
                mapView.addOverlay(route.polyline, level: .aboveRoads)

                // Optionally, zoom to fit the route
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
            }
        }
    }
}

struct DirectionsView: View {
    @ObservedObject var viewModel: MapViewModel
    @Binding var isDirectionsExpanded: Bool
    @Binding var searchText: String // Added for search bar
    @Binding var isHMartInfoShowing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Handle Bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .frame(maxWidth: .infinity) // Center the handle

            VStack(alignment: .leading) {
                HStack {
                    Text("Directions")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isDirectionsExpanded.toggle()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title2)
                    }
                }
                .padding([.horizontal, .top])

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(MapViewModel.RouteType.allCases) { routeType in
                            Button(action: {
                                withAnimation {
                                    viewModel.selectedRouteType = routeType
                                }
                            }) {
                                Image(systemName: routeType.rawValue)
                                    .font(.title2)
                                    .padding(8)
                                    .background(viewModel.selectedRouteType == routeType ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(viewModel.selectedRouteType == routeType ? .white : .black)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Start and Destination Entry (Simplified)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text("My Location")
                    }
                    Divider()
                    HStack {
                        Button(action: {
                            isHMartInfoShowing = true
                        }) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.orange)
                            Text("H Mart")
                        }
                    }
                    Divider()
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                        Text("Add Stop")
                    }

                }
                .padding(.horizontal)
                .padding(.vertical, 5)

                // "Now" and "Avoid" buttons (Simplified)
                HStack {
                    Button(action: {}) {
                        Text("Now")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    Spacer()
                    Button(action: {}) {
                        Text("Avoid")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)

                // Route Options
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(viewModel.routeOptions) { option in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(option.travelTime)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text("\(option.eta) \u{2022} \(option.distance)")
                                    Text(option.description)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button(action: {
                                    // Handle selecting this route
                                }) {
                                    Text("GO")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.vertical, 8)
                            Divider()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .background(Color(UIColor.systemBackground)) // Use system background for correct light/dark mode
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.bottom, isDirectionsExpanded ? 0 : -300) // Slide up/down animation
            .animation(.easeInOut, value: isDirectionsExpanded) // Explicit animation modifier
            .frame(maxWidth: .infinity) // Ensure it expands to fill available width

        }
    }
}

// H Mart Information
struct HMartInfoView: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // Image Placeholder
                    Image(systemName: "photo") // Replace with an actual image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipped()

                    VStack(alignment: .leading) {
                        Text("H Mart")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Korean Grocery Store \u{2022} Buena Park, California")
                            .font(.caption)
                            .foregroundColor(.gray)

                        HStack {
                            Button(action: {
                                // Handle Add Stop
                            }) {
                                VStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Stop")
                                }
                            }
                            .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Button(action: {
                                // Handle Call
                            }) {
                                VStack {
                                    Image(systemName: "phone.fill")
                                    Text("Call")
                                }
                            }
                            .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Button(action: {
                                // Handle Website
                            }) {
                                VStack {
                                    Image(systemName: "globe")
                                    Text("Website")
                                }
                            }
                            .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Button(action: {
                                // Handle Order
                            }) {
                                VStack {
                                    Image(systemName: "bag.fill")
                                    Text("Order")
                                }
                            }
                            .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Button(action: {
                                // Handle More
                            }) {
                                VStack {
                                    Image(systemName: "ellipsis.circle.fill")
                                    Text("More")
                                }
                            }
                            .foregroundColor(.blue)
                        }
                        .padding(.vertical)
                        
                        Divider()
                        HStack {
                            Text("HOURS").bold()
                            Spacer()
                            Text("Opening Soon").foregroundColor(.green)
                        }
                        .padding(.vertical, 4)
                        Divider()
                        
                        HStack {
                            Text("RATINGS").bold()
                            Spacer()
                            Button("👍 Rate"){
                                
                            }.foregroundColor(.blue)
                            
                        }
                        .padding(.vertical, 4)
                        Divider()
                        
                        HStack {
                            Text("COST").bold()
                            Spacer()
                            Text("$$").foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                        Divider()
                        
                        HStack {
                            Text("DISTANCE").bold()
                            Spacer()
                            Text("9.5 mi").foregroundColor(.gray)
                        }
                    }
                    .padding()

                    // Placeholder for multiple images
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<5) { _ in // Display five images
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .clipped()
                                    .padding(.trailing, 5) // Padding between the images
                            }
                        }
                    }
                    .padding(.horizontal) // Padding for the scroll view
                    .padding(.bottom) // Padding at the bottom
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                       
                        Text("H Mart").font(.headline)
                        
                        Button(action: {
                           // Handle share
                        }){
                            Image(systemName: "square.and.arrow.up")
                        }
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
        }
    }
}

struct GoogleMapView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleMapView()
    }
}
