//
//  WorkoutTableViewController.swift
//  intervalApp
//
//  Created by Reid Reininger on 4/16/21.
//

import UIKit
import CoreData

/*
 Controls the view displaying all workouts.
 */
class WorkoutTableViewController: UITableViewController {
    
    var workouts: [Workout] = []
    var managedObjectContext: NSManagedObjectContext!
    var appDelegate: AppDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        loadWorkouts()
    }

    /*
     TableViewDataSource functions
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath)
        let workout = workouts[indexPath.row]
        cell.textLabel?.text = workout.label
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            workouts.remove(at: indexPath.row) // delete Workout
            deleteWorkout(fetchWorkouts()[indexPath.row]) // delete PersistedWorkout from CoreData
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    /*
     Segue functions
     */
    @IBAction func UnwindFromWorkoutView (sender: UIStoryboardSegue) {
        let sourceVC = sender.source as! WorkoutViewController
        // manage CoreData
        if sourceVC.newWorkout { // if brand new workout
            persistNewWorkout(workout: sourceVC.workout)
        } else { // if edited workout
            let row = workouts.firstIndex(where: {(workout) -> Bool in
                workout === sourceVC.workout
            })
            deleteWorkout(fetchWorkouts()[row!]) // delete old PersistedWorkout
            persistNewWorkout(workout: sourceVC.workout) // add updataed PersistedWorkout
            loadWorkouts() // reload workouts to fix order in table
        }
        
        self.hidesBottomBarWhenPushed = false
        self.tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var workout: Workout? = nil
        let workoutVC = segue.destination as! WorkoutViewController
        if segue.identifier == "toExistingWorkout" {
            workout = workouts[self.tableView.indexPathForSelectedRow!.row]
            workoutVC.newWorkout = false
        } else if segue.identifier == "toNewWorkout" {
            workout = Workout()
            workouts.append(workout!)
            workoutVC.newWorkout = true
        }
        workoutVC.workout = workout
        self.hidesBottomBarWhenPushed = true
    }
    
    /*
     CoreData functions
     */
    func fetchWorkouts() -> [PersistedWorkout] {
        let fetchRequest = NSFetchRequest<PersistedWorkout>(entityName: "Workout")
        var workouts: [PersistedWorkout] = []
        do {
            workouts = try self.managedObjectContext.fetch(fetchRequest)
        } catch {
            print("getPlayers error: \(error)")
        }
        return workouts
    }
    
    func loadWorkouts() {
        let workoutData = fetchWorkouts()
        workouts.removeAll()
        for workout in workoutData {
            let intervals = workout.has?.array as! [PersistedInterval]
            let newWorkout = Workout.init(label: workout.value(forKey: "label") as! String)
            workouts.append(newWorkout)
            // fetch interval data
            for interval in intervals {
                var newInterval: WorkoutInterval? = nil
                switch interval.type {
                case "Timer":
                    newInterval = TimerWorkoutInterval(label: interval.label!, time: interval.data)
                case "Distance":
                    newInterval = DistanceWorkoutInterval(label: interval.label!, distance: interval.data)
                case "Activity":
                    newInterval = ActivityWorkoutInterval(label: interval.label!)
                case "Location":
                    newInterval = LocationWorkoutInterval(label: interval.label!, locationName: interval.location!)
                default:
                    newInterval = nil
                }
                newWorkout.addInterval(newInterval!)
            }
        }
    }
    
    // Create new PersistedWorkout in CoreData
    func persistNewWorkout(workout: Workout) {
        let workoutData = PersistedWorkout(context: managedObjectContext)
        workoutData.label = workout.label
        
        for interval in workout.intervals {
            let intervalData = PersistedInterval(context: managedObjectContext)
            intervalData.label = interval.label
            intervalData.type = interval.type
            if let timerInterval = interval as? TimerWorkoutInterval {
                intervalData.data = timerInterval.timerInterval
            }
            if let distanceInterval = interval as? DistanceWorkoutInterval {
                intervalData.data = distanceInterval.distanceInterval
            }
            if let locationInterval = interval as? LocationWorkoutInterval {
                intervalData.location = locationInterval.location.name
            }
            workoutData.addToHas(intervalData)
        }
        appDelegate.saveContext()
    }
    
    // delete PersistedWorkout form CoreData
    func deleteWorkout(_ workout: NSManagedObject) {
        managedObjectContext.delete(workout)
        appDelegate.saveContext()
    }
}
