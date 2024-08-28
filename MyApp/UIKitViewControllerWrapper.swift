//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit
import CoreLocation

// Step 1a: UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyUIKitViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> MyUIKitViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return MyUIKitViewController()
    }
    
    func updateUIViewController(_ uiViewController: MyUIKitViewController, context: Context) {
        // Update the view controller if needed
    }
}

// Example UIKit view controller
class MyUIKitViewController: UIViewController {
    var userLocation = CLLocation(latitude: -33.865143, longitude: 151.209900)
    
    lazy var originalLocationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Original Location:\nLat \(userLocation.coordinate.latitude), Lon \(userLocation.coordinate.longitude)"
        return label
    }()
    
    lazy var updatedLocationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Updated Location:\nLat \(userLocation.coordinate.latitude), Lon \(userLocation.coordinate.longitude)"
        return label
    }()
    
    lazy var updateLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update Location", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(updateLocationButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        
        // Add UI elements to the view
        view.addSubview(originalLocationLabel)
        view.addSubview(updatedLocationLabel)
        view.addSubview(updateLocationButton)
        
        // Set up constraints
        setupConstraints()
    }
    
    func setupConstraints() {
        originalLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        updatedLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        updateLocationButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            originalLocationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            originalLocationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            originalLocationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            updatedLocationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            updatedLocationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            updatedLocationLabel.topAnchor.constraint(equalTo: originalLocationLabel.bottomAnchor, constant: 20),
            
            updateLocationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            updateLocationButton.topAnchor.constraint(equalTo: updatedLocationLabel.bottomAnchor, constant: 40),
            updateLocationButton.widthAnchor.constraint(equalToConstant: 200),
            updateLocationButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func updateLocationButtonTapped() {
        // Update the user location with a 1000-meter offset towards east (bearing of 90 degrees)
        // Triggered when the "Update Location" button is tapped.
            // This function updates the user's location by calling the 'updateLocation' function.

            // Update the user location with a specified offset.
            // The 'updateLocation' function takes 'location' as an inout parameter and 'offset' as an input parameter.
            // The 'inout' keyword allows the function to modify 'userLocation' directly.
        updateLocation(location: &userLocation, withOffset: 1000)
        
        // Update the updatedLocationLabel to reflect the new location coordinates.
        updatedLocationLabel.text = "Updated Location:\nLat \(userLocation.coordinate.latitude), Lon \(userLocation.coordinate.longitude)"
    }
    
    func updateLocation(location: inout CLLocation, withOffset offset: CLLocationDistance) {
        // The 'location' parameter is marked as 'inout', allowing this function to modify the original variable.
        // 'offset' is a regular input parameter, specifying the distance to move the location.

        // Calculate the new location using a fixed bearing of 90 degrees (east) and the given offset.
        location = location.coordinate.locationWithBearing(bearing: 90, distanceMeters: offset)
    }
}


// MARK: - CLLocationCoordinate2D
extension CLLocationCoordinate2D {
    func locationWithBearing(bearing: Double, distanceMeters: CLLocationDistance) -> CLLocation {
        let earthRadius: Double = 6371000 // Earth's radius in meters
        
        let bearingRadians = bearing * .pi / 180
        let distanceRadians = distanceMeters / earthRadius
        
        let lat1 = self.latitude * .pi / 180
        let lon1 = self.longitude * .pi / 180
        
        let newLat = asin(sin(lat1) * cos(distanceRadians) + cos(lat1) * sin(distanceRadians) * cos(bearingRadians))
        let newLon = lon1 + atan2(sin(bearingRadians) * sin(distanceRadians) * cos(lat1), cos(distanceRadians) - sin(lat1) * sin(newLat))
        
        let newLatitude = newLat * 180 / .pi
        let newLongitude = newLon * 180 / .pi
        
        return CLLocation(latitude: newLatitude, longitude: newLongitude)
    }
}
