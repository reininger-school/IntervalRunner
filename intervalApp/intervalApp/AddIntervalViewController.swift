//
//  AddIntervalViewController.swift
//  intervalApp
//
//  Created by Reid Reininger on 4/16/21.
//

import UIKit
import CoreLocation
import MapKit

/*
 Controls the view for adding an interval to a workout.
 */
class AddIntervalViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var intervalPicker: UIPickerView!
    @IBOutlet weak var intervalTable: UITableView!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var repeatStepper: UIStepper!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var dataEntryField: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var locationTableView: UITableView!
    
    var repeats: Int!
    
    let intervalTypes = ["Timer", "Distance", "Location", "Activity"]
    var intervals: [WorkoutInterval] = []
    private var intervalList: [WorkoutInterval] = []
    var locations: [MKMapItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        labelTextField.delegate = self
        intervalPicker.delegate = self
        intervalPicker.dataSource = self
        intervalTable.delegate = self
        intervalTable.dataSource = self
        dataEntryField.delegate = self
        searchBar.delegate = self
        locationTableView.delegate = self
        locationTableView.dataSource = self
        locationTableView.register(UITableViewCell.self, forCellReuseIdentifier: "basicCell")
        intervalTable.register(UITableViewCell.self, forCellReuseIdentifier: "basicCell")
        
        repeats = Int(repeatStepper.value)
        repeatLabel.text = "Repeat: \(repeats!)"
        
        hideAllVariableElements()
        timePicker.isHidden = false
        saveButton.isEnabled = false
    }
    
    func hideAllVariableElements() {
        timeLabel.isHidden = true
        timePicker.isHidden = true
        dataEntryField.isHidden = true
        searchBar.isHidden = true
        locationTableView.isHidden = true
    }
    
    /*
     UI actions
     */
    @IBAction func repeatStepperChanged(_ sender: Any) {
        repeats = Int(repeatStepper.value)
        repeatLabel.text = "Repeat: \(repeats!)"
    }
    
    @IBAction func addTapped(_ sender: Any) {
        var newInterval: WorkoutInterval?
        switch intervalTypes[intervalPicker.selectedRow(inComponent: 0)] {
        case "Timer":
            let time = Int(timePicker.countDownDuration)
            newInterval = TimerWorkoutInterval(label: labelTextField.text ?? "Interval", time: TimeInterval(time))
        case "Distance":
            let distance = CLLocationDistance(dataEntryField.text!)
            newInterval = DistanceWorkoutInterval(label: labelTextField.text ?? "Interval", distance: distance ?? 0)
        case "Activity":
            newInterval = ActivityWorkoutInterval(label: labelTextField.text ?? "Interval")
        case "Location":
            if let selectedRow = locationTableView.indexPathForSelectedRow {
                let location = locations[selectedRow.row]
                newInterval = LocationWorkoutInterval(label: labelTextField.text ?? "Interval", location: location)
            }
        default:
            newInterval = nil
        }
        if let newInterval = newInterval{
            intervalList.append(newInterval)
            intervalTable.reloadData()
        }
    }
    
    /*
     PickerViewDelegate functions
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return intervalTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return intervalTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        hideAllVariableElements()
        switch row {
        case 0: // timer
            timePicker.isHidden = false
        case 1: // distance
            //timeLabel.text = "Distance"
            timeLabel.isHidden = false
            dataEntryField.isHidden = false
        case 2: // location
            searchBar.isHidden = false
            locationTableView.isHidden = false
        case 3: // activity
            print("Activity")
        default:
            print()
        }
    }
    
    /*
     TableViewDelegate functions. Note there are two tableViews managed.
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === intervalTable {
            saveButton.isEnabled = !intervalList.isEmpty
            return intervalList.count
        } else if tableView === locationTableView {
            return locations.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === intervalTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            let interval = intervalList[indexPath.row]
            if let timerInterval = interval as? TimerWorkoutInterval {
                cell.textLabel?.text = "\(timerInterval.label) \(Utility.main.formatTime(time: timerInterval.timerInterval))"
                cell.detailTextLabel?.text = "\(timerInterval.timerInterval)"
            }
            if let distanceInterval = interval as? DistanceWorkoutInterval {
                cell.textLabel?.text = "\(distanceInterval.label) \(String.init(format: "%.0lf", distanceInterval.distanceInterval)) M"
            }
            if let activityInterval = interval as? ActivityWorkoutInterval {
                cell.textLabel?.text = "\(activityInterval.label)"
            }
            if let locationInterval = interval as? LocationWorkoutInterval {
                cell.textLabel?.text = "\(locationInterval.label) \(locationInterval.location.name!)"
            }
            return cell
        } else if tableView === locationTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            let item = locations[indexPath.row]
            cell.textLabel?.text = "\(item.name!), \(String.init(format: "%.0lf", item.placemark.location!.distance(from: LocationManager.main.lastLocation!))) M"
            return cell
        }
        return UITableViewCell()
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            intervalList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    /*
     Searchbar delegate functions
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let query = searchBar.text {
            searchMap(query)
        }
    }
    
    func searchMap(_ query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: searchHandler)
    }
    
    func searchHandler (response: MKLocalSearch.Response?, error: Error?) {
        if let err = error {
            print("Error occured in search: \(err.localizedDescription)")
        } else if let resp = response {
            print("\(resp.mapItems.count) matches found")
            //self.mapView.removeAnnotations(self.mapView.annotations)
            locations = resp.mapItems
            locationTableView.reloadData()
        }
    }
    
    /*
     TextFieldDelegeate functions
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    /*
     Segue functions
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        for _ in 0..<repeats {
            for interval in intervalList {
                intervals.append(interval.copy() as! WorkoutInterval)
            }
        }
    }
}
