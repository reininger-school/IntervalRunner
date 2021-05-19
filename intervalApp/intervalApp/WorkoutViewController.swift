//
//  WorkoutViewController.swift
//  intervalApp
//
//  Created by Reid Reininger on 4/16/21.
//

import Foundation
import UIKit
import MapKit
import CoreData

/*
 Controls view when editing and running a workout.
 */
class WorkoutViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, WorkoutDelegate, LocationManagerDelegate, SwitchTableViewCellDelegate {
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var addIntervalButton: UIBarButtonItem!
    @IBOutlet weak var workoutTextfield: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var distanceTraveledLabel: UILabel!
    @IBOutlet weak var caloriesBurnedLabel: UILabel!
    @IBOutlet weak var clearIntervalsButton: UIButton!
    @IBOutlet weak var intervalTable: UITableView!
    @IBOutlet weak var startStopButton: UIButton!
    
    var workout: Workout!
    var newWorkout: Bool! // for segue purposes, marks workout as new or edited
    private var workoutHasStarted = false
    private var managedObjectContext: NSManagedObjectContext!
    private var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        workoutTextfield.delegate = self
        mapView.delegate = self
        intervalTable.delegate = self
        intervalTable.dataSource = self
        workout.delegate = self
        LocationManager.main.delegate = self
        LocationManager.main.startLocation()
        
        self.title = workout.label
        updateElapsedTimeLabel()
        updateDistanceTravelledLabel()
        updateCaloriesBurnedLabel()
        startMapTracking()
        if workout.intervals.isEmpty {
            startStopButton.isEnabled = false
        }
        
        //coredata
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
    }
    
    /*
     UI action functions
     */
    @IBAction func backButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Would you like to save your progress for this run?", message: "Going back will reset your progress for this workout.", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) in
            self.persistHistory()
            self.workout.reset()
            self.performSegue(withIdentifier: "unwindToWorkoutTableView", sender: self)
        })
        
        let backAction = UIAlertAction(title: "Don't Save", style: .destructive, handler: { (action) in
            self.workout.reset()
            self.performSegue(withIdentifier: "unwindToWorkoutTableView", sender: self)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            // do nothing
        })
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addAction(backAction)
        alert.preferredAction = saveAction // only affects .alert style
        
        if workoutHasStarted {
            present(alert, animated: true, completion: nil)
        } else {
            workout.reset()
            self.performSegue(withIdentifier: "unwindToWorkoutTableView", sender: self)
        }
    }
    
    @IBAction func startStopTapped(_ sender: Any) {
        if workout.paused {
            workoutHasStarted = true
            clearIntervalsButton.isEnabled = false
            workout.start()
        } else {
            workout.stop()
        }
    }
    
    @IBAction func workoutTextFieldEditingDidEnd(_ sender: UITextField) {
        if let newName = workoutTextfield.text, !newName.isEmpty {
            workout.label = newName
            workoutTextfield.text = nil
        }
    }
    
    @IBAction func clearIntervalsTapped(_ sender: Any) {
        guard !workout.intervals.isEmpty || !workout.expiredIntervals.isEmpty else {return}
        let alert = UIAlertController(title: "Delete all intervals?", message: "This action cannot be undone.", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.workout.removeAllIntervals()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            // do nothing
        })
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        alert.preferredAction = deleteAction // only affects .alert style
        
        present(alert, animated: true, completion: nil)
    }
    
    /*
    UITableView delegate & datasource functions.
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return workout.expiredIntervals.isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Intervals"
        } else if section == 1 {
            return "Expired Intervals"
        }
        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return workout.intervals.count
        } else if section == 1 {
            return workout.expiredIntervals.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let interval = workout.intervals[indexPath.row]
            if let timerInterval = interval as? TimerWorkoutInterval {
                let cell = tableView.dequeueReusableCell(withIdentifier: "progressCell", for: indexPath) as! ProgressCell
                updateTimerIntervalProgressCell(cell: cell, interval: timerInterval)
                return cell
            }
            if let distanceInterval = interval as? DistanceWorkoutInterval {
                let cell = tableView.dequeueReusableCell(withIdentifier: "progressCell", for: indexPath) as! ProgressCell
                updateDistanceIntervalProgressCell(cell: cell, interval: distanceInterval)
                return cell
            }
            if interval is ActivityWorkoutInterval {
                let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! SwitchTableViewCell
                cell.label.text = interval.label
                cell.delegate = self
                return cell
            }
            if let locationInterval = interval as? LocationWorkoutInterval {
                let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell")
                updateLocationIntervalUITableViewCell(cell: cell!, interval: locationInterval)
                let annotation = MKPointAnnotation()
                annotation.coordinate = locationInterval.location.placemark.location!.coordinate
                annotation.title = locationInterval.location.placemark.name
                self.mapView.addAnnotation(annotation)
                return cell!
            }
        } else if indexPath.section == 1 {
            let interval = workout.expiredIntervals[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell")
            if let timerInterval = interval as? TimerWorkoutInterval {
                cell?.textLabel?.text = "\(timerInterval.label) \(Utility.main.formatTime(time: timerInterval.timerInterval))"
            }
            if let distanceInterval = interval as? DistanceWorkoutInterval {
                cell?.textLabel?.text = "\(distanceInterval.label) \(String.init(format: "%.0lf", distanceInterval.distanceInterval)) M"
            }
            if let locationInterval = interval as? LocationWorkoutInterval {
                cell?.textLabel?.text = "\(locationInterval.label) \(locationInterval.location.name!)"
            }
            if let activityInterval = interval as? ActivityWorkoutInterval {
                cell?.textLabel?.text = "\(activityInterval.label)"
            }
            cell?.detailTextLabel?.text = nil
            return cell!
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if workoutHasStarted {
            return false
        }
        return indexPath.section == 0
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            workout.removeInterval(indexPath.row)
        }
    }
    
    /*
     Workout delegate and data source functions
     */
    func workout(workoutIntervalPropertyChanged: WorkoutInterval, property: String) {
        let cell = getCell(interval: workoutIntervalPropertyChanged)
        if property == "elapsedIntervalTime" {
            if let progressCell = cell as? ProgressCell {
                let interval = workoutIntervalPropertyChanged as! TimerWorkoutInterval
                updateTimerIntervalProgressCell(cell: progressCell, interval: interval)
            }
        }
        else if property == "elapsedIntervalDistance" {
            if let progressCell = cell as? ProgressCell {
                let interval = workoutIntervalPropertyChanged as! DistanceWorkoutInterval
                updateDistanceIntervalProgressCell(cell: progressCell, interval: interval)
            }
        } else if property == "paused" {
            if let interval = workoutIntervalPropertyChanged as? ActivityWorkoutInterval {
                if let switchCell = cell as? SwitchTableViewCell {
                    switchCell.`switch`.isUserInteractionEnabled = !interval.paused
                }
            }
        }
    }
    
    func workout(workoutIntervalExpired: WorkoutInterval) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { (settings) in
            if settings.alertSetting == .enabled {
                self.notify(interval: workoutIntervalExpired)
            } else {
                print("notifications disabled")
            }
        })
    }
    
    func workout(propertyChanged: Workout, property: String?) {
        switch property {
        case "paused":
            backButton.isEnabled = workout.paused
            if workout.paused {
                startStopButton.setTitle("Start", for: .normal)
                startStopButton.backgroundColor = UIColor.systemGreen
            } else {
                addIntervalButton.isEnabled = false
                startStopButton.setTitle("Stop", for: .normal)
                startStopButton.backgroundColor = UIColor.systemRed
            }
        case "distance":
            distanceTraveledLabel.text = String(format: "%4.0f M", workout.distance)
            for interval in workout.intervals {
                if let locationInterval = interval as? LocationWorkoutInterval {
                    let cell = getCell(interval: locationInterval)
                    let distance = locationInterval.location.placemark.location?.distance(from: LocationManager.main.lastLocation!)
                    cell?.detailTextLabel?.text = String.init(format: "%.0lf", distance!)
                }
            }
            mapPolyLine()
        case "calories":
            caloriesBurnedLabel.text = "\(String.init(format: "%.0lf", workout.calories)) Cal"
        case "time":
            elapsedTimeLabel.text = Utility.main.formatTime(time: workout.time)
        case "label":
            self.title = workout.label
        case "intervals":
            startStopButton.isEnabled = !workout.intervals.isEmpty
            self.intervalTable.reloadData()
        default:
            print("\(property ?? "Unknown") changed")
        }
    }
    
    func workout(expired: Workout) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { (settings) in
            if settings.alertSetting == .enabled {
                self.notify(workout: expired)
            } else {
                print("notifications disabled")
            }
        })
        mapView.showsUserLocation = false
    }
    
    func workout(lastWorkoutLocation: Workout) -> CLLocation? {
        return LocationManager.main.lastLocation
    }
    
    /*
     Interval and Workout expiration notification functions
     */
    func notify(interval: WorkoutInterval) {
        print("notify")
        let content = UNMutableNotificationContent()
        content.title = "\(interval.label) interval expired"
        content.body = "\(interval.type)"
        content.categoryIdentifier = "notify"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "expiredInterval", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { (error) in
            if let err = error {
                print(err.localizedDescription)
            }
        })
    }
    
    func notify(workout: Workout) {
        print("notify")
        let content = UNMutableNotificationContent()
        content.title = "\(workout.label) workout expired"
        content.body = "Good job!"
        content.categoryIdentifier = "notify"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "expiredInterval", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { (error) in
            if let err = error {
                print(err.localizedDescription)
            }
        })
    }
    
    /*
     LocationManager functions
     */
    func locationManager(didUpdateLocation location: CLLocation) {
        workout.addWorkoutLocation(location: location)
    }
    
    /*
     MapView functions
     */
    func mapPolyLine() {
        var coordinates: [CLLocationCoordinate2D] = []
        for location in workout.workoutLocations {
            if let location = location {
                coordinates.append(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
            }
        }
        let myPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(myPolyline)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .blue
            testlineRenderer.lineWidth = 2.0
            return testlineRenderer
        }
        return MKOverlayRenderer()
    }
    
    func startMapTracking() {
        if LocationManager.main.locationManager.authorizationStatus == .notDetermined ||
            LocationManager.main.locationManager.authorizationStatus == .denied {
            let alert = LocationManager.main.locationServicesAlert()
            present(alert, animated: true, completion: nil)
        }
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    /*
     CoreData functions
     */
    func persistHistory() {
        let history = NSEntityDescription.insertNewObject(forEntityName: "History", into: self.managedObjectContext)
        history.setValue(workout.label, forKey: "label")
        history.setValue(String.init(format: "%.0lf", workout.distance), forKey: "distance")
        history.setValue(String.init(format: "%.0lf", workout.calories), forKey: "calories")
        history.setValue(Utility.main.formatTime(time: workout.time), forKey: "time")
        let date = NSDate().description
        history.setValue(date, forKey: "date")
        appDelegate.saveContext()
    }
    
    /*
     Segue functions
     */
    @IBAction func UnwindFromAddIntervalView (sender: UIStoryboardSegue) {
        if sender.identifier == "saveFromAddInterval" {
            let segue = sender.source as! AddIntervalViewController
            for interval in segue.intervals {
                workout.addInterval(interval)
            }
            self.intervalTable.reloadData()
        }
    }
    
    /*
     TextFieldDelegate functions
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    /*
     SwitchTableViewCellDelegate functions
     */
    func switchTableViewCell(switchValueChanged: SwitchTableViewCell) {
        if switchValueChanged.`switch`.isOn {
            switchValueChanged.`switch`.isUserInteractionEnabled = false
        }
        let index = intervalTable.indexPath(for: switchValueChanged)?.row
        if let interval = workout.intervals[index!] as? ActivityWorkoutInterval {
            interval.complete()
        }
    }
    
    /*
     Private functions
     */
    private func updateElapsedTimeLabel() {
        elapsedTimeLabel.text = Utility.main.formatTime(time: workout.time)
    }
    
    private func updateDistanceTravelledLabel() {
        distanceTraveledLabel.text = String(format: "%4.0f M", workout.distance)
    }
    
    private func updateCaloriesBurnedLabel() {
        caloriesBurnedLabel.text = "\(String.init(format: "%.0lf", workout.calories)) Cal"
    }
    
    /*
     Update interval cell functions
     */
    private func getCell(interval find: WorkoutInterval) -> UITableViewCell? {
        var section = 0
        var index = workout.intervals.firstIndex { (interval: WorkoutInterval) -> Bool in
            interval === find
        }
        if index == nil {
            index = workout.expiredIntervals.firstIndex { (interval: WorkoutInterval) -> Bool in
                interval === find
            }
            section = 1
        }
        if let index = index {
            let indexPath = IndexPath(row: index, section: section)
            return intervalTable.cellForRow(at: indexPath)
            //return intervalTable.visibleCells[index]
        }
        return nil
    }
    
    private func updateTimerIntervalProgressCell(cell: ProgressCell, interval: TimerWorkoutInterval) {
        cell.label.text = "\(interval.label) \(Utility.main.formatTime(time: interval.timerInterval - interval.elapsedIntervalTime))"
        let progress = Float(interval.elapsedIntervalTime) / Float(interval.timerInterval)
        cell.progressView.setProgress((progress), animated: true)
    }
    
    private func updateDistanceIntervalProgressCell(cell: ProgressCell, interval: DistanceWorkoutInterval) {
        cell.label.text = "\(interval.label) \(String.init(format: "%.0lf", interval.distanceInterval - interval.elapsedIntervalDistance))"
        let progress = Float(interval.elapsedIntervalDistance) / Float(interval.distanceInterval)
        cell.progressView.setProgress(progress, animated: true)
    }
    
    private func updateLocationIntervalUITableViewCell(cell: UITableViewCell, interval: LocationWorkoutInterval) {
        cell.textLabel?.text = "\(interval.label) \(interval.location.name!)"
        cell.detailTextLabel?.text = String.init(format: "%.0lf", LocationManager.main.locationManager.location!.distance(from: interval.location.placemark.location!))
    }
}
