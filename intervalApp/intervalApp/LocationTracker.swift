//
//  LocationTracker.swift
//  intervalApp
//
//  Created by Reid Reininger on 4/30/21.
//
//  Responsible for handling the users location data.
//

import Foundation
import CoreLocation

class LocationManager: CLLocationManagerDelegate {
    func isEqual(_ object: Any?) -> Bool {
        <#code#>
    }
    
    var hash: Int
    
    var superclass: AnyClass?
    
    func `self`() -> Self {
        <#code#>
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        <#code#>
    }
    
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        <#code#>
    }
    
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        <#code#>
    }
    
    func isProxy() -> Bool {
        <#code#>
    }
    
    func isKind(of aClass: AnyClass) -> Bool {
        <#code#>
    }
    
    func isMember(of aClass: AnyClass) -> Bool {
        <#code#>
    }
    
    func conforms(to aProtocol: Protocol) -> Bool {
        <#code#>
    }
    
    func responds(to aSelector: Selector!) -> Bool {
        <#code#>
    }
    
    var description: String
    
    var locationManager = CLLocationManager()
    
    init() {
        initializeLocation()
    }
    
    func initializeLocation() { // called from start up method
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("location authorized")
        case .denied, .restricted:
            print("location not authorized")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("unknown location authorization")
        }
    }
    
    // Delegate method called whenever location authorization status changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if ((status == .authorizedAlways) || (status == .authorizedWhenInUse)) {
            print("location changed to authorized")
        } else {
            print("location changed to not authorized")
            self.stopLocation()
        }
    }
    
    func startLocation () {
        let status = locationManager.authorizationStatus
        if (status == .authorizedAlways) ||
            (status == .authorizedWhenInUse) {
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopLocation () {
        locationManager.stopUpdatingLocation()
    }
    
    // Delegate method called when location changes
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        var locationStr = "Location (lat,long): "
        if let latitude = location?.coordinate.latitude {
            locationStr += String(format: "%.6f", latitude)
        } else {locationStr += "?"}
        if let longitude = location?.coordinate.longitude {
            locationStr += String(format: ", %.6f", longitude)
        } else {locationStr += ", ?"}
        print(locationStr)
    }
    
    // Delegate method called if location unavailable (recommended)
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("locationManager error: \(error.localizedDescription)")
    }
}
