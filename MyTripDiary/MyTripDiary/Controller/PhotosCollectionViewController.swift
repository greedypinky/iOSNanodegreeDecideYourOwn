//
//  PhotosCollectionViewController.swift
//  MyTripDiary
//
//  Created by Man Wai  Law on 2019-05-05.
//  Copyright © 2019 Rita's company. All rights reserved.
//

import UIKit
import MapKit

private let reuseIdentifier = "PhotoCollectionViewCell"

class PhotosCollectionViewController: UIViewController {

    let activityView = UIActivityIndicatorView(style: .gray)
    // longtitude and latitude from the PIN
    var lat:Double!
    
    var lon:Double!
    
    var flickrUserID:String!
    
    @IBOutlet weak var searchByUserIDLabel: UILabel!
    
    @IBOutlet weak var userIDTextField: UITextField!
    
    @IBOutlet weak var placeName: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var loadPhotos: UIButton!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var flickrImages:[UIImage?] = []
    
    var noDataLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad!")
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        // https://codingwarrior.com/2018/02/05/ios-display-images-in-uicollectionview/
        addPin() // Add pin to the Map View
        setNoDataLabel() // Setup the No Data label
        if flickrImages.count == 0 {
            showNoDataLabel(show:true)
        }
        
        activityView.hidesWhenStopped = true
        activityView.center = photoCollectionView.center
        photoCollectionView.addSubview(activityView)
        // see if we can get the name from the Map's coordinate
        getPlaceName()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear!")
        // Set the delegate and datasource for the Collection View
       
        
        // showPhotos()
    }
    
    private func showPhotos() {
         let endpoint:URL
        // request Flickr photos
        print("Request Flickr photos using Flickr search request API")
        if let id = userIDTextField.text {
            endpoint =  FlickrClient.FlickrEndpoint.getSearch(lat: lat, lon: lon, per_page: 100, user_id: id).url
        } else {
            endpoint =  FlickrClient.FlickrEndpoint.getSearch(lat: lat, lon: lon, per_page: 100, user_id: nil).url
        }
            // user id can be nil
        let photoSearch = PhotoSearch(lat: lat, lon: lon, api_key: FlickrAPI.key, in_gallery: true, per_page: 100, page:1)
        FlickrClient.photoGetRequest(endpoint: endpoint, photoSearch: photoSearch, responseType: PhotoSearchResponse.self, completionHandler: handleGetResponse(res:error:))
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func load(_ sender: Any) {
        
        showNoDataLabel(show: false)
        photoCollectionView.superview?.bringSubviewToFront(activityView)
        activityView.startAnimating()
        
        flickrImages.removeAll() // reset the array to store new pictures
        showPhotos() // Send Flickr API Request to get the photos
        // TODO: Send Flickr Request to get photos
       // photoCollectionView.reloadData()
    }

    // MARK: Fetch Flickr photos request's handler methods
    func handleGetResponse(res:PhotoSearchResponse?, error:Error?) {
        guard let response = res else {
            let ac = UIAlertController(title: "Search Flickr photos", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            //  // Show No Image View
           // showNoDataLabel(show:true)
            // Stop Animation for the Indicator
           // activityView.stopAnimating()
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
            UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action) in
                // Show No Image View
                self.showNoDataLabel(show:true)
                // Stop Animation for the Indicator
                self.activityView.stopAnimating()
            }
            
            
            ac.addAction(okAction)
            //show(ac, sender: self)
            ac.view.center = self.view.center
            present(ac, animated: true, completion: nil)
            return
        }
        
        guard let count = response.photos.photo?.count, count > 0 else {
            // Show No Image View
            showNoDataLabel(show:true)
            // Stop Animation for the Indicator
            activityView.stopAnimating()
            return
        }
        
        print("===== How many pictures can we get ? \(count) =====")
        // We have Flickr photos
        showNoDataLabel(show:false)
        // let myGroup = DispatchGroup()

        for photoInfo in response.photos.photo! {
           // myGroup.enter()
            let photoURL:URL = FlickrClient.mapPhotoToURL(id: photoInfo.id, secret: photoInfo.secret, farmid: "\(photoInfo.farm)", serverid: photoInfo.server)
            // Download the photo from URL, save photo to core data (Optional - will do it later if have time!)
            print("map photo id: \(photoInfo.id)")
            print("mapped photo url: \(photoURL.absoluteString)")
            // Call another method to handle the photo download from the URL
            FlickrClient.photoImageDownload(url: photoURL, completionHandler: HandlePhotoSave(data:error:))
            
//            myGroup.notify(queue: .main) {
//                print("=======Finished all download =======")
//            }
        }
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1000) { [weak self] in
//            self?.photoCollectionView.reloadData()
//            self?.activityView.stopAnimating()
//        }
        
       // DispatchQueue.main.async {
        print(" Before view reload what is the count in the photo array? \(self.flickrImages.count)")
         self.photoCollectionView.reloadData()
         self.activityView.stopAnimating()
       // }
    }
    
    func HandlePhotoSave(data:Data?, error:Error?) {
        print("======== inside HandlePhotoSave ======")
        guard let data = data else {
            let ac = UIAlertController(title: "Loading photo error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action) in
                // tab OK to dismiss Alert Controller
                self.showNoDataLabel(show:true)
                self.dismiss(animated: true, completion: nil)
            }
            ac.addAction(action)
            self.present(ac, animated: true, completion: nil)
            return
        }
        
        let photoImage = UIImage(data: data)
        // Save image
        addPhoto(image: photoImage!)
        print("HandlePhotoSave: Download Finished!")
    }
    
    
    // MARK: UX Settings
    
    private func addPhoto(image:UIImage) {
        flickrImages.append(image)
        print("after append image array count? \(flickrImages.count)")
        
    }
    
    private func setNoDataLabel() {
    // Setup No Data label
        let frame = CGRect(x: 0, y: 0, width: photoCollectionView.bounds.width, height: photoCollectionView.bounds.height)
        noDataLabel = UILabel(frame: frame)
        view.addSubview(noDataLabel)
        noDataLabel.text = "No images! please tab Load Photos"
        noDataLabel.textAlignment = NSTextAlignment.center
        noDataLabel.font = UIFont.systemFont(ofSize: 18.0)
        noDataLabel.textColor = .black
        noDataLabel.sizeToFit()
    }
    
    // UX : set Navigation Header title
    private func setNavigationMenu() {
        navigationItem.title = "Flickr Photo"
    }
    
    // UX: set visibility of the NoDataLabel
    private func showNoDataLabel(show:Bool) {
        if show {
            noDataLabel.isHidden = false
            photoCollectionView.backgroundView = noDataLabel
        } else {
            noDataLabel.isHidden = true
            photoCollectionView.backgroundView = nil
        }
    }
    
    
    
    
    // UX: Set up the MapView to have the annotation of the selected place
    private func addPin() {
        let coordinate = CLLocationCoordinate2D(latitude:lat, longitude:lon)
        let annotation =  MKPointAnnotation()
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1,longitudeDelta: 0.1))
        annotation.coordinate = coordinate
        
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
    }
    
}

// MARK: Extension for UICollectionViewDelegate and UICollectionViewDataSource
// https://www.appcoda.com/ios-collection-view-tutorial/
extension PhotosCollectionViewController:UICollectionViewDataSource,UICollectionViewDelegate {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return flickrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        // TODO: Configure the cell - need to add the image view under the context view
        print("debug set image to collection view at : \(indexPath.row)")
        if let image = flickrImages[indexPath.row] {
         //cell.flickrImage.image = image
         cell.set(image: image)
         cell.noImage.isHidden = true
        } else {
          cell.set(image: nil)
          // cell.noImage.isHidden = false
          // cell.noImage.text = "no image"
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Open picture to view")
        // navigationPhotoView
        let vc = storyboard?.instantiateViewController(withIdentifier: "navigationPhotoView") as! UINavigationController
        // let vc = storyboard?.instantiateViewController(withIdentifier: "photoView") as! PhotoViewController
        let selectedImage = flickrImages[indexPath.row]
        let photo_vc = vc.topViewController as! PhotoViewController
        photo_vc.image = selectedImage
        // open a model view, now we try to use push
        //navigationController?.pushViewController(vc, animated: true)
        present(vc, animated: true, completion: nil)
    }
    
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return true
     }
     
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        print("CollectionView performAction method")
     }
    
    
    private func getPlaceName() {
        
        // Add below code to get address for touch coordinates.
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: lat, longitude: lon)
        geoCoder.reverseGeocodeLocation(location, completionHandler:
            {
                placemarks, error -> Void in
                
                // Place details
                guard let placeMark = placemarks?.first else { return }
                
                // Location name
                if let locationName = placeMark.location {
                    print(locationName)
                }
                // Street address
                if let street = placeMark.thoroughfare {
                    print(street)
                }
                // City
                if let city = placeMark.subAdministrativeArea {
                    print(city)
                }
                // Zip code
                if let zip = placeMark.isoCountryCode {
                    print(zip)
                }
                // Country
                if let country = placeMark.country {
                    print(country)
                }
                
                self.placeName.text = "\(String(describing: placeMark.subAdministrativeArea)) \(String(describing: placeMark.country))"
        })
        
    }
    
}



extension PhotosCollectionViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        userIDTextField.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        userIDTextField.resignFirstResponder()
    }
}
