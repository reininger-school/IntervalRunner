//
//  Utility.swift
//  intervalApp
//
//  Created by Reid Reininger on 4/16/21.
//

import Foundation

/*
 Global utility functions.
 */
class Utility {
    static let main = Utility()
    private init() {}
    
    func formatTime(time: TimeInterval) -> String {
        let seconds = Int(time)
        if seconds >= 100 * 3600 {
            return "99:59:59"
        } else if seconds >= 3600 {
            return String(format: "%02d:%02d:%02d", time / 3600, (seconds / 60) % 60, seconds % 60)
        } else {
            return String(format: "%02d:%02d", (seconds / 60) % 60, seconds % 60)
        }
    }
}
