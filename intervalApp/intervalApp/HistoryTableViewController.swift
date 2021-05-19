//
//  TableViewController.swift
//  FileDemo
//
//  Created by Reid Reininger on 4/8/21.
//

import UIKit
import CoreData

/*
 Controls view displaying all workout histories.
 */
class HistoryTableViewController: UITableViewController, AppDelegateDelegate {
    
    var histories: [NSManagedObject] = []
    var managedObjectContext: NSManagedObjectContext!
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate.delegate = self
        managedObjectContext = appDelegate.persistentContainer.viewContext
        histories = fetchHistories()
        tableView.reloadData()
    }
    
    /*
     CoreData functions
     */
    func fetchHistories() -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "History")
        var histories: [NSManagedObject] = []
        do {
            histories = try self.managedObjectContext.fetch(fetchRequest)
        } catch {
            print("getPlayers error: \(error)")
        }
        print("Histories fetched: \(histories.count)")
        return histories
    }
    
    func deleteHistory(_ history: NSManagedObject) {
        managedObjectContext.delete(history)
        appDelegate.saveContext()
    }
    
    func contextDidSave() {
        self.histories = fetchHistories()
        tableView.reloadData()
    }
    
    /*
     TableViewDelegate functions
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let history = histories[indexPath.row]
        cell.textLabel?.text = history.value(forKey: "label") as? String
        cell.detailTextLabel?.text = "\(history.value(forKey: "date") as! String)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let history = histories[indexPath.row]
            histories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            deleteHistory(history)
        }
    }
    
    /*
     Segue functions
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailViewSegue" {
            let detailVC = segue.destination as! HistoryDetailViewController
            detailVC.history = histories[self.tableView.indexPathForSelectedRow!.row]
            self.hidesBottomBarWhenPushed = true
        }
        
    }
    
    @IBAction func UnwindFromDetailView (sender: UIStoryboardSegue) {
        self.hidesBottomBarWhenPushed = false
    }
}
