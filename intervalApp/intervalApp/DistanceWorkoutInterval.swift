//
//  DistanceWorkoutInterval.swift
//  intervalApp
//
//  Created by Reid Reininger on 4/30/21.
//

import Foundation
import CoreLocation

// Provides total workout distance travelled.
protocol DistanceWorkoutIntervalDataSource {
    func totalWorkoutDistance() -> CLLocationDistance
}

/*
 Represents an interval which expires after travelling a certain distance.
 */
class DistanceWorkoutInterval: WorkoutInterval {
    var dataSource: DistanceWorkoutIntervalDataSource!
    private var lastUpdateTotalWorkoutDistance = CLLocationDistance(0)
    public private(set) var distanceInterval: CLLocationDistance
    
    public private(set) var elapsedIntervalDistance = CLLocationDistance(0) {
        didSet {
            delegate?.workoutInterval(propertyChanged: self, property: "elapsedIntervalDistance")
        }
    }
    
    init(label: String, distance: CLLocationDistance) {
        self.distanceInterval = distance
        super.init(type: "Distance", label: label)
    }
    
    override func start() {
        lastUpdateTotalWorkoutDistance = dataSource.totalWorkoutDistance()
        super.start()
    }
    
    override func reset() {
        super.reset()
        elapsedIntervalDistance = 0
    }
    
    override func update() {
        guard !paused else {return}
        let totalWorkoutDistance = dataSource.totalWorkoutDistance()
        elapsedIntervalDistance += totalWorkoutDistance - lastUpdateTotalWorkoutDistance
        if elapsedIntervalDistance >= distanceInterval {
            elapsedIntervalDistance = distanceInterval
            stop()
            delegate?.workoutInterval(expired: self)
        }
        lastUpdateTotalWorkoutDistance = totalWorkoutDistance
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = DistanceWorkoutInterval(label: label, distance: distanceInterval)
        return copy
    }
}
