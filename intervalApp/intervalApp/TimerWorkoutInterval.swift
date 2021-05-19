//
//  TimerWorkouInterval.swift
//  intervalApp
//
//  Created by Reid Reininger on 4/16/21.
//

import Foundation

/*
 Provides total workout time.
 */
protocol TimerWorkoutIntervalDataSource {
    func totalWorkoutTime() -> TimeInterval
}

/*
 Represents a WorkoutInterval which expires after given amount of time.
 */
class TimerWorkoutInterval: WorkoutInterval {
    var dataSource: TimerWorkoutIntervalDataSource!
    private(set) var timerInterval: TimeInterval
    private var lastUpdateTotalWorkoutTime = TimeInterval(0)
    
    private(set) var elapsedIntervalTime = TimeInterval(0) {
        didSet {
            delegate?.workoutInterval(propertyChanged: self, property: "elapsedIntervalTime")
        }
    }
    
    init(label: String, time: TimeInterval) {
        self.timerInterval = time
        super.init(type: "Timer", label: label)
    }
    
    override func start() {
        lastUpdateTotalWorkoutTime = dataSource.totalWorkoutTime()
        super.start()
    }
    
    override func reset() {
        super.reset()
        elapsedIntervalTime = 0
    }
    
    override func update() {
        guard !paused else {return}
        let totalWorkoutTime = dataSource.totalWorkoutTime()
        elapsedIntervalTime += totalWorkoutTime - lastUpdateTotalWorkoutTime
        if elapsedIntervalTime >= timerInterval {
            elapsedIntervalTime = timerInterval
            stop()
            delegate?.workoutInterval(expired: self)
        }
        lastUpdateTotalWorkoutTime = totalWorkoutTime
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = TimerWorkoutInterval(label: label, time: timerInterval)
        return copy
    }
}
