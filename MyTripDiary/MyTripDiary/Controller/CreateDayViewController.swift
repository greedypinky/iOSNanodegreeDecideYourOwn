//
//  CreateDayViewController.swift
//  MyTripDiary
//
//  Created by Man Wai  Law on 2019-05-20.
//  Copyright © 2019 Rita's company. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// https://uxplanet.org/modality-the-one-ux-concept-you-need-to-understand-when-designing-intuitive-user-interfaces-e5e941c7acb1
// Want to have a full-screen modal view
class CreateDayViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var dataPicker: UIDatePicker!
    @IBOutlet weak var daySummary: UITextView!
    
    @IBOutlet weak var saveButton: UIButton!
    var isDeletePinMode:Bool = false
    
    // need to remember the Lat and Lon in the CoreData too
    
    @IBOutlet weak var mapView: MKMapView!
    var currentAnnotation:MKAnnotation?
    var date:Date!
    var summary:String!
    var editMode:Bool = false
    var isCreate:Bool = false
    var trip:Trip!
    var currentDay:Day!
    var pins:[Pin] = []
    var dataController:DataController {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.dataController
    }
    var updateResultController:NSFetchedResultsController<Day>!
    let dateFormatter: DateFormatter = {
        
        let df = DateFormatter()
        df.dateStyle = DateFormatter.Style.medium
        return df
    }()
    
    var headerTitle:String {
        get {
            return editMode ? "Create Day (Edit)":"Create Day"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
       setNavigationMenu()
        
       setMapViewGesture()
        
       setDatePickForDateOnly()
        
       daySummary.delegate = self
        
        if editMode {
            initViewData()
        }
    }
    
    private func initViewData() {
        if let day = currentDay {
            dataPicker.date = day.date!
            daySummary.text = day.summary
            pins = day.pins?.allObjects as! [Pin]
            initPinFromCoreData()
        }
    
    }
    
    
    private func initPinFromCoreData() {
        // Set pins to the map
        if pins.count > 0 {
            addDeletePinButton()
        }
        
        for pin in pins {
            let location = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longtitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = "Tab to get Flickr photos"
            mapView.addAnnotation(annotation)
        }
    }
    
    
    private func setNavigationMenu() {
        let cancelButton = UIBarButtonItem(image: nil, style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancel))
        cancelButton.title = "Cancel"
        navigationItem.setLeftBarButton(cancelButton, animated: true)
        navigationItem.title = headerTitle
    }
    
    private func addDeletePinButton() {
        let deletePinButton = UIBarButtonItem(image: nil, style: UIBarButtonItem.Style.plain, target: self, action: #selector(updateButtonStates))
        deletePinButton.title = "Delete pin"
        navigationItem.setRightBarButton(deletePinButton, animated: true)
    }
    
    private func updateNavBarRightButton(isEdit:Bool) {
        if isEdit {
            navigationItem.rightBarButtonItem?.title = "Done"
        } else {
            navigationItem.rightBarButtonItem?.title = "Delete Pin"
        }
    }
    
    private func setMapViewGesture() {
        var longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPinToTheMap))
        // Tapping and holding the map drops a new pin. Users can place any number of pins on the map.
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
        mapView.delegate = self
        
    }
    
    private func setDatePickForDateOnly() {
        dataPicker.datePickerMode = UIDatePicker.Mode.date
    }
    
    @objc private func updateButtonStates() {
        if (navigationItem.rightBarButtonItem?.title == "Delete pin") {
            print("update nav right button!")
            updateNavBarRightButton(isEdit:true)
            isDeletePinMode = true
        } else {
            updateNavBarRightButton(isEdit:false)
            isDeletePinMode = false
        }
        // update the UX of the save button
    }
    
    @objc private func addPinToTheMap(longPressGestureRecongnizer:UIGestureRecognizer) {
        
        print("add pin to map")
        if (longPressGestureRecongnizer.state == UIGestureRecognizer.State.began)
        {
            print("addPinToMap is called when long press gesture is detected!")
            let touchPointAtMapView = longPressGestureRecongnizer.location(in: mapView)
            // transfer the touchpoint to map coordinate
            let mapCoordinate = mapView.convert(touchPointAtMapView, toCoordinateFrom: mapView)
            let location = CLLocationCoordinate2D(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
            let annotation = MKPointAnnotation()
            
           
            //add pin to the map
            annotation.coordinate = location
            annotation.title = "Tab to get Flickr photos" // title for the Callout
            mapView.addAnnotation(annotation)
            // When pins are dropped on the map, the pins are persisted in the Pins array and save in the Core data when Save button is selected.
            print("Save pin to core data only when it does not save before!")
            addPin(lat: location.latitude, lon: location.longitude)
            // update the navigation bar's right button
            if pins.count > 0 {
                addDeletePinButton()
            }
        }
    }
    
    private func addNavigationButton(){
        var title:String {
             get {
                if !editMode {
                    return  "Create Day"
                }
                else {
                    return "Create Day (Edit)"
                }
            }
        }
        
//        let rightButton = UIBarButtonItem(title: title, style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveOrEdit))
//        navigationItem.setRightBarButtonItems([rightButton], animated: true)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancel) )
        navigationItem.setLeftBarButton(cancelButton, animated: true)
        navigationController?.title = headerTitle
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc private func cancel() {
        // dismiss this view
        dismiss(animated: true, completion: nil)
    }
    
    // add a new day to core data
    private func addDay(date:Date, summary:String) {
        if !editMode {
            let day = Day(context: dataController.viewContext)
            day.createDate = Date()
            day.date = date
            day.summary = summary
            day.trip = trip // must set the trip, otherwise cannot create relationship with the Trip object
            // day.addToPins(Pins)
            day.addToPins(NSSet(array: pins))
            currentDay = day
        } else {
            
           currentDay.date = date
           currentDay.summary = summary
        }
        try? dataController.viewContext.save()
        
    }
    
    private func addPin(lat:Double, lon:Double) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = lat
        pin.longtitude = lon
        // pin.day = currentDay
        // try? dataController.viewContext.save()
        pins.append(pin)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // for Pin rendering
        let annotationID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView()
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type:.detailDisclosure)
            pinView?.animatesDrop = true
            
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // TODO: when in Edit mode and user select the pin
        // Remove it from the MapView!
        print("MapView - did select a PIN!")
        let annotation = view.annotation

        var tabLocationLongtitude = annotation?.coordinate.longitude
        var tabLocationLatitude = annotation?.coordinate.latitude
        print("PIN did select with lat \(tabLocationLatitude) and long \(tabLocationLongtitude)")
        
        guard !isDeletePinMode else {
            // removePin(annotation: annotation)
            removePinAlert(annotation:view.annotation!)
            return
        }
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // TODO: Add the action when the call out is tapped
        if !isCreate {
            if (control == view.rightCalloutAccessoryView) {
                guard !isDeletePinMode else {
                    // removePin(annotation: annotation)
                    removePinAlert(annotation:view.annotation!)
                    return
                }
                currentAnnotation = view.annotation
                let app = UIApplication.shared
                if let lat = view.annotation?.coordinate.latitude, let lon = view.annotation?.coordinate.longitude {
                    // TODO: can open a new view based on the PIN coordinate
                    print("Will open the search photo view here based on the Coordinate!")
                    
                   let vc = storyboard?.instantiateViewController(withIdentifier: "photosCollectionView") as! PhotosCollectionViewController
                    // for DEBUG usage
                    // 58.3019444,-134.4197221
                    //vc.lat = 58.3019444
                    //vc.lon = -134.4197221
                   vc.lat = lat
                   vc.lon = lon
                   //present(vc, animated: true, completion: nil)
                   // performSegue(withIdentifier: "photosNavigationController", sender: self)
                   navigationController?.pushViewController(vc, animated: true)
                
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // prepare segue
        
        
    }
    
    func removePinAlert(annotation:MKAnnotation) {
        
        let alert = UIAlertController(title: "Remove pin?", message: "Are you sure you want to remove the pin from Map?", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.removePin(annotation: annotation)
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
        
    }

    private func removePin(annotation:MKAnnotation) {
        print("will remove annotation!")
        // When a pin is tapped, remove the annotation from the mapView
        mapView.removeAnnotation(annotation)

        for pin in pins {
            if (pin.latitude == annotation.coordinate.latitude && pin.longtitude == annotation.coordinate.longitude) {
                let index = pins.firstIndex(of: pin)
                pins.remove(at: index!)
                print("removed from the pins array!")
                break
            }
            
        }
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        print("save changes to CoreData!")
        let selectedDate = dataPicker.date
        let summary = daySummary.text
        addDay(date: selectedDate, summary: summary!)
        dismiss(animated: true, completion: nil)
    }
    
}


extension CreateDayViewController:UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
        mapView.deselectAnnotation(currentAnnotation, animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return range.location < 500
    }
}
