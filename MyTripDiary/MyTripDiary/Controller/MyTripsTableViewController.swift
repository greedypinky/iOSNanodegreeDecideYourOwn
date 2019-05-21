//
//  MyTripsTableViewController.swift
//  MyTripDiary
//
//  Created by Man Wai  Law on 2019-05-05.
//  Copyright © 2019 Rita's company. All rights reserved.
//

import UIKit
import CoreData


class MyTripsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var noDataLabel:UILabel! // show no data when no trip data
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTrip: UIToolbar!
    var dataController:DataController {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.dataController
    }
    
    let cellIdentifier = "tripCell"
    
    // results object
    var fetchedResultsController:NSFetchedResultsController<Trip>!
    // activity indicator
    var indicator = UIActivityIndicatorView()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.title = "My Trips"
        setEmptyMessage("No Trip yet!")
        setActivityIndicator()
        //activityView.center = CGPoint(tableView.frame.size., tableView.frame.size.width/2)
        //setupFetchedResultsController()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
       
        
    }
    
    // when user click back button to go back to this view again
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        indicator.startAnimating()
        
        setupFetchedResultsController()
        if let indexPath = tableView.indexPathForSelectedRow {
            // deselect the row when table re-appear
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }

    @IBAction func addTripFromToolBar(_ sender: Any) {
        
        showCreateTripAlertController()
    }
    
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let numOfSection = fetchedResultsController.sections?.count ?? 0
        print("number of section \(numOfSection)")
        return numOfSection
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let numOfRows = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        print("number of objects \(numOfRows) in section \(section)")
        return numOfRows
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trip = fetchedResultsController.object(at: indexPath)
        // Default cell content already have the label, the detail and the image
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TripCell
        cell.textLabel?.text = trip.name
        cell.detailTextLabel?.text = trip.desc
        
        if let count = trip.days?.count {
            let pageString = count == 1 ? "day" : "days"
            //cell.pageCountLabel.text = "\(count) \(pageString)"
        }
        
        //
        //        // Configure cell
        //        cell.textPreviewLabel.attributedText = aNote.attributedText
        //
        //        if let creationDate = aNote.creationDate {
        //            cell.dateLabel.text = dateFormatter.string(from: creationDate)
        //        }
        //
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        // delete the row
        case .delete:
            print("editing style is? ¥(editingStyle)")
            deleteTripAtIndexPath(indexpath: indexPath)
        default:()
        }
    }
    
//    private func showDeleteAlert() {
//        let alert = UIAlertController(title: "Delete Trip?", message: "Are you sure you want to delete the current trip?", preferredStyle: .alert)
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
//            guard let strongSelf = self else { return }
//            strongSelf.onDelete?()
//        }
//
//        alert.addAction(cancelAction)
//        alert.addAction(deleteAction)
//        present(alert, animated: true, completion: nil)
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//    }
    
 
    func showCreateTripAlertController() {
        let alert = UIAlertController(title: "Create trip", message: "Enter a name for the trip", preferredStyle: .alert)
        // Create actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let name = alert.textFields?.first?.text, let desc = alert.textFields?.last?.text {
                // save action will add the trip to core data
                self?.addTripToCoreData(name: name, desc:desc)
            }
        }
        // Add a text field
        alert.addTextField { textField in
            textField.placeholder = "Name"
            // when text field is not empty, enable the Save Action
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                if let text = textField.text, !text.isEmpty {
                    saveAction.isEnabled = true
                } else {
                    saveAction.isEnabled = false
                }
            }
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Description"
            // when text field is not empty, enable the Save Action
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                if let text = textField.text, !text.isEmpty {
                    saveAction.isEnabled = true
                } else {
                    saveAction.isEnabled = false
                }
            }
        }
        saveAction.isEnabled = false
        // Add the actions to the alert controller
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        // need to present the controller otherwise it will not show
        present(alert, animated: true, completion: nil)
    }
    
    func setEmptyMessage(_ message: String) {
        let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        noDataLabel.text = message
        noDataLabel.textColor = .black
        noDataLabel.numberOfLines = 0;
        noDataLabel.textAlignment = .center;
        noDataLabel.font = UIFont.systemFont(ofSize: 18.0)
        noDataLabel.sizeToFit()
        
        tableView.backgroundView = noDataLabel;
        tableView.separatorStyle = .none;
    }
    
    func resetTableBackgroundView() {
        tableView.backgroundView = nil
        tableView.separatorStyle = .singleLine
    }
    
    
    
    func setActivityIndicator() {
        indicator.color = .black
            indicator.frame = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
        indicator.center = tableView.center
        tableView.addSubview(indicator)
        indicator.bringSubviewToFront(tableView)
    }
    
}

// MARK: - Extension implements NSFetchedResultsControllerDelegate

extension MyTripsTableViewController:NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
             print("NSFetchedResultsControllerDelegate didChange for Insert at \(newIndexPath)!")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            print("NSFetchedResultsControllerDelegate didChange for Delete at \(indexPath)!")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type \(type.rawValue), Only.insert or .delete is allowed!")
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    /* The moment endUpdates is called, the UITable will ask the dataSource for the number of sections and rows again. If your number of sections and row feeds directly from the dataSource, then number sections and rows, plus insertions, minus deletions must equal the numbers returned by the end calls for numberOfSections and numberOfRowsInSection.
    */
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: - Core Data related functions
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Trip> = Trip.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "trips")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            
            if (fetchedResultsController.fetchedObjects?.count)! > 0 {
                resetTableBackgroundView()
            }
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // Add Trip to Core Data
    func addTripToCoreData(name:String, desc:String) {
        let tripToBeAdded = Trip(context: dataController.viewContext)
        tripToBeAdded.createdDate = Date()
        tripToBeAdded.name = name
        tripToBeAdded.desc = desc
        dataController.viewContext.insert(tripToBeAdded)
        try! dataController.viewContext.save()
    }
    
    // Delete Trip from Core Data
    func deleteTripAtIndexPath(indexpath:IndexPath) {
        
        let tripToDelete:Trip = fetchedResultsController.object(at: indexpath)
        dataController.viewContext.delete(tripToDelete)
        try! dataController.viewContext.save()
    }

    private func prepareNoDataLabel() {
        let frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height)
        noDataLabel = UILabel(frame: frame)
        view.addSubview(noDataLabel)
        noDataLabel.text = "No Trip!"
        noDataLabel.textAlignment = NSTextAlignment.center
        noDataLabel.font = UIFont.systemFont(ofSize: 18.0)
        noDataLabel.textColor = .black
        noDataLabel.sizeToFit()
    }
    
    private func showNoDataLabel(show:Bool) {
        if show {
            noDataLabel.isHidden = false
            tableView.backgroundView = noDataLabel
        } else {
            noDataLabel.isHidden = true
            tableView.backgroundView = nil
        }
    }
}


