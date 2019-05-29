//
//  DaysTableViewController.swift
//  MyTripDiary
//
//  Created by Man Wai  Law on 2019-05-05.
//  Copyright © 2019 Rita's company. All rights reserved.
//

import UIKit
import CoreData

class DaysTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    // @IBOutlet var tableView: UITableView!
    var noDataLabel:UILabel! // show no data label when no day
    var rightBarButton:UIBarButtonItem?
    var trip:Trip!
    //var days:[Day] = [] // store Day NSManagedObject if saved in the Core Data
    var fetchedResultsController:NSFetchedResultsController<Day>!
    var dataController:DataController {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.dataController
    }
    
    var isAdd:Bool = true
    
    // return a date formatter
    let dateFormatter: DateFormatter = {
        
        let df = DateFormatter()
        df.dateStyle = DateFormatter.Style.medium
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        addNavigationButton()
        setupFetchedResultsController()
        //setupFetchedResultsController()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("############ DaysTableViewController ##############")
        print("viewWillAppear is called!")
        tableView.register(DayCell.self, forCellReuseIdentifier: "daycell")
        setupFetchedResultsController()
        // addNavigationButton()
        tableView.reloadData()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    private func addNavigationButton(){
        let addButton = UIBarButtonItem(image: UIImage(named: "icon_addpin"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(add))
        navigationItem.setRightBarButtonItems([addButton], animated: true)
        navigationController?.title = "Days of trip"
    }
    
    // MARK: - Table view data source
/*
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
        let day = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "daycell", for: indexPath) as! DayCell
        var label:String = ""
        if let date = day.date {
            let dayWithFormat = dateFormatter.string(from: date)
            // show Day 1 05/12/2019
            label = "Day \(indexPath) \(dayWithFormat)"
            
        } else {
            label = "Day \(indexPath)"
        }
        
        return cell
    }
    */
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

    
    // Override to support editing the table view.
    /*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print("editing style is? \(editingStyle)")
        switch editingStyle {
            // delete the row
            case .delete:
                print("In delete case >>>>>>")
                deleteDay(at: indexPath)
            default:()
        }

    } */
    

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
    
    // MARK: - Core Data:add and delete Day function
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Day> = Day.fetchRequest()
        let predicate = NSPredicate(format: "trip == %@", trip)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(trip)-days")
        // remember to set the delegate otherwise the tableview cannot be updated when coredata has changes.
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            if (fetchedResultsController.fetchedObjects?.count)! > 0 {
                resetTableBackgroundView()
            } else {
                setEmptyMessage("No Day!")
            }
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    @objc func add() {
        // TODO: We do not have a create day page yet you idiot!!
        let vc:UINavigationController = storyboard?.instantiateViewController(withIdentifier: "createDayNavigationController") as! UINavigationController
        let createDayVC = vc.topViewController as! CreateDayViewController
        createDayVC.editMode = false
        createDayVC.trip = trip
        present(vc, animated: true, completion: nil)
    }
    

    

    // add a new day to core data
//    private func addDay(date:Date, summary:String) {
//       let day = Day(context: dataController.viewContext)
//       day.date = date
//       day.summary = summary
//       day.trip = trip // must set the trip, otherwise cannot create relationship with the Trip object
//       try? dataController.viewContext.save()
//    }
    
    // get the object at indexpath and delete from the core data
    private func deleteDay(at indexPath:IndexPath) {
        let dayToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(dayToDelete)
        try? dataController.viewContext.save()
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
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let numOfSection = fetchedResultsController.sections?.count ?? 1
        print("DaysTableViewController Data Source Delegate: number of section \(numOfSection)")
        return numOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let numOfRows = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        print("DaysTableViewController Data Source Delegate: number of objects \(numOfRows) in section \(section)")
        return numOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let day = fetchedResultsController.object(at: indexPath)
       // let cell = tableView.dequeueReusableCell(withIdentifier: "daycell", for: indexPath) as! DayCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "daycell", for: indexPath)
        var label:String = ""
        if let date = day.date {
            let dayWithFormat = dateFormatter.string(from: date)
            // show Day 1 05/12/2019
            label = "Day \(indexPath.row) \(dayWithFormat)"
            
        } else {
            label = "Day \(indexPath.row)"
        }
        print("what is the label? \(label)")
        //cell.title?.text = label
        cell.detailTextLabel?.text = "TESTING 1234"
        cell.textLabel?.text = label
        return cell
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print("editing style is? \(editingStyle)")
        switch editingStyle {
        // delete the row
        case .delete:
            print("In delete case >>>>>>")
            deleteDay(at: indexPath)
        default:()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc:UINavigationController = storyboard?.instantiateViewController(withIdentifier: "createDayNavigationController") as! UINavigationController
        let createDayVC = vc.topViewController as! CreateDayViewController
        createDayVC.editMode = true
        // TODO: Need to get the Core Datainfo and init the View as well !!
        let selectedDay:Day = fetchedResultsController.object(at: indexPath)
        // ... set data
        /*
         createDate = "2019-05-28 00:25:05 +0000";
         date = "2019-06-28 00:25:00 +0000";
         photos = "<relationship fault: 0x600001d81c00 'photos'>";
         pins = "<relationship fault: 0x600001d81cc0 'pins'>";
         summary = Test;
         trip = "0x9d3d21f31cc291a0 <x-coredata://CC688AF1-8501-449C-A562-B109FE243367/Trip/p1>";
         */
        // TODO: date need to get the date
        print("can we get the date? \(selectedDay.date!)")
        //createDayVC.date = selectedDay.date!
        //createDayVC.summary = selectedDay.summary
        createDayVC.currentDay = selectedDay
        createDayVC.trip = trip
        present(vc, animated: true, completion: nil)
    }
    
    
}

/*
extension DaysTableViewController:UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let numOfSection = fetchedResultsController.sections?.count ?? 1
        print("DaysTableViewController Data Source Delegate: number of section \(numOfSection)")
        return numOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let numOfRows = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        print("DaysTableViewController Data Source Delegate: number of objects \(numOfRows) in section \(section)")
        return numOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let day = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "daycell", for: indexPath) as! DayCell
        var label:String = ""
        if let date = day.date {
            let dayWithFormat = dateFormatter.string(from: date)
            // show Day 1 05/12/2019
            label = "Day \(indexPath.row) \(dayWithFormat)"
            
        } else {
            label = "Day \(indexPath.row)"
        }
        print("what is the label? \(label)")
        cell.title?.text = label
        return cell
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print("editing style is? \(editingStyle)")
        switch editingStyle {
        // delete the row
        case .delete:
            print("In delete case >>>>>>")
            deleteDay(at: indexPath)
        default:()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc:UINavigationController = storyboard?.instantiateViewController(withIdentifier: "createDayNavigationController") as! UINavigationController
        let createDayVC = vc.topViewController as! CreateDayViewController
        createDayVC.editMode = true
        // TODO: Need to get the Core Datainfo and init the View as well !!
        let selectedDay:Day = fetchedResultsController.object(at: indexPath)
        // ... set data
        createDayVC.dataPicker.date = selectedDay.date!
        createDayVC.daySummary.text = selectedDay.summary
        createDayVC.trip = trip
        present(vc, animated: true, completion: nil)
    }
    
    
}

extension DaysTableViewController:UITableViewDelegate {
    
    
}
 */

// MARK: NSFetchedResultsControllerDelete to keep the tableview in sync with the core data update
extension DaysTableViewController:NSFetchedResultsControllerDelegate {
    
    // react to the Core Data change type to update the table view accordingly
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            // Only insert uses newIndexPath!
            print("didChange delegate callback: insert into newIndexPath \(newIndexPath)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
             print("didChange delegate callback: delete at indexPath \(indexPath)")
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
        case .insert:
            print("didChange delegate callback: insert section \(sectionIndex)")
            tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
