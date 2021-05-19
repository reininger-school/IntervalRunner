//
//  ActivityWorkoutInterval.swift
//  intervalApp
//
//  Created by Reid Reininger on 5/3/21.
//

import Foundation

/*
 Represents an interval which expires when an activity is completed.
 */
class ActivityWorkoutInterval: WorkoutInterval {
    var completed = false {
        didSet {
            delegate?.workoutInterval(propertyChanged: self, property: "completed")
        }
    }
    
    init(label: String) {
        super.init(type: "Activity", label: label)
    }
    
    override func reset() {
        super.reset()
        completed = false
    }
    
    // Tell interval it is complete.
    func complete() {
        guard !paused else {return}
        completed = true
        delegate?.workoutInterval(expired: self)
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = ActivityWorkoutInterval(label: label)
        return copy
    }
}
