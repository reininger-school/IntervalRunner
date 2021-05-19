<h1>IntervalRunner</h1>
<p>
IntervalRunner helps athletes plan, complete, and record workouts. The primary focus is on interval training, where users must complete an activity in a specified interval. I have yet to find an app that offers the customization I want for these intervals. For example, I may want an interval to expire after a period of time, and the next interval to expire after walking or running a certain distance or reaching a specific location.
</p>

<h2>Build</h2>
<p>
Open and run in Xcode on macOS. Recommended to run on simulator using iPhone 11 or 12.
</p>

<h2>Use Documentation</h2>
<h3>Workout Table View</h2>
<p>
Provides a table showing all created workouts. These workouts are persisted in CoreData. Workouts can be deleted by swiping on them. New workouts are added by tapping the “+” in the navigation bar. Workouts can be edited or started by tapping on them. The TabBarController at the bottom allows for navigating between the WorkoutTableView and HistoryTableView.
</p>

<h3>Workout View</h3>
<p>
The WorkoutView allows users to edit and start workouts. It displays workout information such as the workout label in the navigation bar, the user’s location, a polyline of the user’s location while the workout is active, the elapsed time, distance travelled, calories burned, and workout intervals.
</p>
<p>
The workout label can be changed by entering a new label in the UITextField labeled “Change workout label here”. This change is immediately reflected in the navigation bar. A user can add intervals to the workout by tapping “+” in the navigation bar. A user can start the workout by tapping the green start button at the bottom of the view. This turns to a red stop button when the workout is in progress. A notification appears when an interval or the entire workout expires. Intervals cannot be edited or added once a workout has begun. The workout must end before any changed to workout can be made, other than the label.
</p>
<p>
Expired intervals are shown under the “Expired Intervals” header in the TableView.
All intervals can be cleared by tapping the “Clear Intervals” button. This will present an alert to confirm the action. At any time the workout is paused (after having been started), the user can tap the back button in the navigation bar. This presents an alert asking to save or don’t save the workout in the workout history before navigating back to the WorkoutTableView.
</p>

<h3>Add Interval View</h3>
<p>
This view allows the user to add intervals to the workout. A label is given to the interval in the “Label” UITextField. The interval type is selected using the UIPickerView labeled “Interval Type”. The UI changes to display to appropriate data entry elements for the selected interval type. Once the data has been entered for the interval, users tap the blue “Add Interval” button to append the interval to the TableView below. Intervals can be removed from the TableView by swiping. The intervals in the TableView will be appended to the TableView in the WorkoutView after tapping “Save” in the navigation bar. Alternatively, press “Cancel” in the navigation bar to not add any intervals. To append the intervals in the TableView multiple times, increment the repeat counter at the bottom of the View.
</p>

<h3>History View</h3>
<p>
The HistoryTableView displays all recorded workout histories and is persisted in CoreData. Each row has the label of the workout and the time the workout was saved. Swiping a row deletes the history. Tapping a row segues to the HistoryDetailView which provides more information about the workout such as the time, distance, and calories. There is a MKMapView in the HistoryDetailView however the location of the workout is not recorded. This is saved for future work. Note saving the workout map information was not a proposal requirement. Requirement 18 states “[persisted] data includes total distance, time, and calories burned.”
</p>

<h2>Demonstrated Skills</h2>
<ul>
  <li>Persisting data with Core Data</li>
  <li>Accessing sensor data</li>
  <li>Sending notifications</li>
  <li>Tracing routes and placing pins on a mapKitView</li>
  <li>Using segues</li>
  <li>Using dynamic tableViews with various prototype cells</li>
  <li>Using and displaying info on a mapView</li>
  <li>Using timers</li>
  <li>Updating UI elements</li>
</ul>
