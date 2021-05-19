//
//  LocationWorkoutInterval.swift
//  intervalApp
//
//  Created by Reid Reininger on 5/3/21.
//

import Foundation
import MapKit
import CoreLocation

/*
 Represents an interval which expires when a given location is reached.
 */
class LocationWorkoutInterval: WorkoutInterval {
    private(set) var location: MKMapItem!
    
    init(label: String, location: MKMapItem) {
        self.location = location
        super.init(type: "Location", label: label)
    }
    
    init(label: String, locationName: String) {
        super.init(type: "Location", label: label)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = locationName
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: searchHandler)
    }
    
    override func update() {
        let currentLocation = LocationManager.main.lastLocation
        if currentLocation!.distance(from: location.placemark.location!) < 50 {
            delegate?.workoutInterval(expired: self)
        }
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = LocationWorkoutInterval(label: label, location: location)
        return copy
    }
    
    private func searchHandler (response: MKLocalSearch.Response?, error: Error?) {
        if let err = error {
            print("Error occured in search: \(err.localizedDescription)")
        } else if let resp = response {
            print("\(resp.mapItems.count) matches found")
            //self.mapView.removeAnnotations(self.mapView.annotations)
            location = resp.mapItems[0]
        }
    }
}
