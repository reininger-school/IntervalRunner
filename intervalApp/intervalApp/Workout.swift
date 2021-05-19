//
//  Workout.swift
//  intervalApp
//
//  Created by Reid Reininger on 4/15/21.
//

import Foundation
import CoreLocation

/*
 Delegate is notified of several workout changes.
 */
protocol WorkoutDelegate {
    func workout(workoutIntervalPropertyChanged: WorkoutInterval, property: String)
    func workout(workoutIntervalExpired: WorkoutInterval)
    func workout(propertyChanged: Workout, property: String?)
    func workout(expired: Workout)
}

/*
 Represents a workout composed of intervals.
 */
class Workout: WorkoutIntervalDelegate, TimerWorkoutIntervalDataSource, DistanceWorkoutIntervalDataSource {
    
    var delegate: WorkoutDelegate?
    private(set) var intervals: [WorkoutInterval] = []
    private(set) var expiredIntervals: [WorkoutInterval] = []
    private(set) var workoutLocations: [CLLocation?] = [nil]
    private(set) var timer: Timer? // drives the workout update() calls.
    
    var label: String {
        didSet {
            delegate?.workout(propertyChanged: self, property: "label")
        }
    }
    
    private(set) var distance = CLLocationDistance(0) { // total distance travelled during the workout in meters.
        didSet {
            delegate?.workout(propertyChanged: self, property: "distance")
        }
    }
    
    private(set) var calories = 0.0 { // total Calories burned during the workout.
        didSet {
            delegate?.workout(propertyChanged: self, property: "calories")
        }
    }
    
    private(set) var time = TimeInterval(0) { // total time elapsed during the workout.
        didSet {
            delegate?.workout(propertyChanged: self, property: "time")
        }
    }
    
    private(set) var paused = true { // represents if the workouot is currently paused.
        didSet {
            delegate?.workout(propertyChanged: self, property: "paused")
        }
    }
    
    init(label: String = "New Workout") {
        self.label = label
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: handleTick)
    }
    
    func stop() {
        intervals.first?.stop()
        workoutLocations.append(nil)
        paused = true
    }
    
    func start() {
        paused = false
        intervals.first?.start()
    }
    
    func reset() {
        stop()
        for interval in intervals {
            interval.reset()
        }
        for interval in expiredIntervals {
            interval.reset()
        }
        
        // reset workout metrics
        calories = 0
        distance = 0
        time = 0
        workoutLocations = [nil]
        
        // move all expired intervals back to unexpired intervals.
        expiredIntervals.append(contentsOf: intervals)
        intervals = expiredIntervals
        expiredIntervals = []
    }
    
    func addInterval(_ interval: WorkoutInterval) {
        interval.delegate = self
        if let timerInterval = interval as? TimerWorkoutInterval {
            timerInterval.dataSource = self
        }
        if let distanceInterval = interval as? DistanceWorkoutInterval {
            distanceInterval.dataSource = self
        }
        intervals.append(interval)
        delegate?.workout(propertyChanged: self, property: "intervals")
    }
    
    func removeInterval(_ at: Int) {
        intervals.remove(at: at)
        delegate?.workout(propertyChanged: self, property: "intervals")
    }
    
    func removeAllIntervals() {
        intervals.removeAll()
        delegate?.workout(propertyChanged: self, property: "intervals")
    }
    
    /*
    WorkoutIntervalDelegate functions
    */
    func workoutInterval(expired: WorkoutInterval) {
        expiredIntervals.append(expired)
        delegate?.workout(workoutIntervalExpired: expired)
        removeInterval(0)
        if let interval = intervals.first { // start next interval
            interval.start()
        } else { // if no more intervals stop workout
            paused = true
            delegate?.workout(expired: self)
        }
    }
    
    func workoutInterval(propertyChanged: WorkoutInterval, property: String) {
        delegate?.workout(workoutIntervalPropertyChanged: propertyChanged, property: property)
    }
    
    /*
     WorkoutInterval data source functions
     */
    func totalWorkoutDistance() -> CLLocationDistance {
        return distance
    }
    
    func totalWorkoutTime() -> TimeInterval {
        return time
    }
    
    /*
     Location tracking related functions
     */
    func addWorkoutLocation(location: CLLocation) {
        guard !paused else {return}
        if let lastWorkoutLocation = workoutLocations.last! {
            distance += lastWorkoutLocation.distance(from: location)
        }
        workoutLocations.append(location)
    }
    
    /*
     private functions
     */
    private func updateCalories() {
        let met = 7.0 // MET activity multiplier
        let weight = 70.0 // weight in kilograms
        let pace = 10000.0 // meters per hour
        let adjustedTime = distance / Double(pace)
        calories = met * weight * adjustedTime
    }
    
    private func handleTick(timer: Timer) {
        guard !paused else {return}
        // distance is not updated here because it is updated by LocationManager updates
        time = time.advanced(by: timer.timeInterval)
        updateCalories()
        intervals.first?.update()
    }
}
