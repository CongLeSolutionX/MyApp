//
//  DetailViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/24/24.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {

    let mapView = MKMapView()
    var location: CLLocationCoordinate2D? // Receive coordinates from InteractiveMapPin

    init(location: CLLocationCoordinate2D?) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Set up the map view
        mapView.delegate = self
        mapView.mapType = .standard // or .satellite, .hybrid, etc.
        view.addSubview(mapView)

        // Add constraints for the mapView to fill the entire view
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if let location = location {
            // Add annotation to the map location
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = "Location Detail"
            mapView.addAnnotation(annotation)

            // Set region for map view
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02) // Adjust zoom level as needed
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        } else {
            // Handle the case where location is nil (optional)
            print("Location not provided to DetailViewController")
            let alert = UIAlertController(title: "Error", message: "Location data was not received.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - MKMapViewDelegate (Optional, for customization)

extension DetailViewController: MKMapViewDelegate {
    // Customize annotations (optional) - Add custom annotation views & behavior
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil // Don't handle user location annotations
        }

        let identifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true // Enable callout to display the title
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) // button for 'more info'
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }


    // Handle callout button tap (optional)
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            // Handle the tap on the detail disclosure button (e.g., show more info)
            print("Disclosing location's detail!")
        }
    }
}
