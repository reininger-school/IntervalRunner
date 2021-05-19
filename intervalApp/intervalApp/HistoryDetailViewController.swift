//
//  HistoryDetailViewController.swift
//  intervalApp
//
//  Created by Reid Reininger on 5/4/21.
//

import UIKit
import MapKit
import CoreData

/*
 Controls detailed view of a workout history.
 */
class HistoryDetailViewController: UIViewController {
    @IBOutlet weak var burnedCaloriesLabel: UILabel!
    @IBOutlet weak var intervalTable: UITableView!
    @IBOutlet weak var elapsedDistanceLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var workoutLabel: UINavigationItem!
    
    var history: NSManagedObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // time, distane, calories
        title = history.value(forKey: "label") as? String
        elapsedTimeLabel.text = history.value(forKey: "time") as? String
        elapsedDistanceLabel.text = history.value(forKey: "distance") as? String
        burnedCaloriesLabel.text = history.value(forKey: "calories") as? String
    }
}
