//
//  LocationManager.swift
//  intervalApp
//
//  Created by Reid Reininger on 5/1/21.
//

import Foundation
import CoreLocation
import NotificationCenter
import UIKit

protocol LocationManagerDelegate {
    func locationManager(didUpdateLocation location: CLLocation)
}

/*
 Singleton for managing CLLocationManager.
 */
final class LocationManager: NSObject, CLLocationManagerDelegate {
    static let main = LocationManager()
    var delegate: LocationManagerDelegate?
    let locationManager = CLLocationManager()
    var lastLocation: CLLocation? = nil
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Start location updates.
    func startLocation() {
        let status = locationManager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            lastLocation = nil
            locationManager.startUpdatingLocation()
        } else {

        }
    }
    
    // Stop location updates.
    func stopLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if ((status == .authorizedAlways) || (status == .authorizedWhenInUse)) {
            print("location changed to authorized")
        } else {
            print("location changed to not authorized")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
        delegate?.locationManager(didUpdateLocation: lastLocation!)
    }
    
    func locationServicesAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Got to device settings to enable location services for this app.", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            // do nothing
        })
        alert.addAction(okayAction)
        alert.preferredAction = okayAction // only affects .alert style
        return alert
    }
}
