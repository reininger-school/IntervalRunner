//
//  WorkoutInterval.swift
//  intervalApp
//
//  Created by Reid Reininger on 4/16/21.
//

import Foundation

/*
 Receives messages regarding interval expiration and changed properties.
 */
protocol WorkoutIntervalDelegate {
    func workoutInterval(expired: WorkoutInterval)
    func workoutInterval(propertyChanged: WorkoutInterval, property: String)
}

/*
 Represents an interval in a workout.
 */
class WorkoutInterval: NSCopying {
    
    var delegate: WorkoutIntervalDelegate?
    private(set) var type: String // String describing interval type
    
    var label: String {
        didSet {
            delegate?.workoutInterval(propertyChanged: self, property: "label")
        }
    }
    
    private(set) var paused = true {
        didSet {
            delegate?.workoutInterval(propertyChanged: self, property: "paused")
        }
    }
    
    init(type: String, label: String) {
        self.type = type
        self.label = label
    }
    
    // Start progressing.
    func start() {
        paused = false
    }
    
    // Stop progressing.
    func stop() {
        paused = true
    }

    // Reset progress.
    func reset() {
        paused = true
    }
    
    // Update progress.
    func update() {
        
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = WorkoutInterval(type: type, label: label)
        return copy
    }
}
