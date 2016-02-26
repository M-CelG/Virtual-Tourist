//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Manish Sharma on 2/19/16.
//  Copyright © 2016 CelG Mobile LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var count = 0
    var session: NSURLSession!
    var annotations = [MKAnnotation]()
    // Array to store Photo URL Array
//    var tempPhotoURL = [String]()
//    var tempImage: UIImage!
//    var tempTotalPhotos = 0
//    var tempImageData: NSData!
    // Test Segue Identifier
    let testSegue = "TestSegue"
    // To store total number of Pins
    var newPinID = 0
    // Current Number of pins
    var currentPinID = 0
    //User Defaults
    let defaults = NSUserDefaults.standardUserDefaults()
    

    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var longPressGesture: UILongPressGestureRecognizer!
    
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Get Shared Core Data Context
        context = CoreDataStackManager.sharedInstance().managedObjectContext
        
        // Add Annotations
        addAnnotations()
        
        //Get Shared Session
        session = FlickrClient.sharedInstance().session
        
       //Access Current pin count
//        if defaults.integerForKey("Total Pins") != 0 {
//            currentPinsCountInUserDefaults = count
//        }
        
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        //Retrive the Users last save config for Map View
        restoreMapRegion(true)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(false)
        
        // Save the current Pin count in User Defaults
//        defaults.setInteger(currentPinsCountInUserDefaults, forKey: "Total Pins")
        
        // Save the current state of the map in the NSUser Defaults
        saveMapRegion()
        
    }
    
    // Method to drop and new pin
    
    @IBAction func dropNewPin(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.Began {
            let coordinate = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
//            let annotation = Point(latitude: coordinate.latitude, longitude: coordinate.longitude)
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            //Core Data 
            // Create Pin
            
            currentPinID = self.defaults.integerForKey("Total Pins")
            print("This is current Pin ID\(currentPinID)")
            newPinID = currentPinID + 1
            print("This is new Pin ID\(newPinID)")
            let pin = Pin(lat: coordinate.latitude, lon: coordinate.longitude, id: newPinID, context: context)
            //Create PhotoAlbum for the pin
            let photoAlbum = PhotoAlbum(pin: pin, insertIntoManagedObjectContext: context)
            photoAlbum.associatedPin = pin
            print("\(coordinate.latitude)"+"\(coordinate.longitude)")
            // new Pin ID as current Pin ID
            defaults.setInteger(newPinID, forKey: "Total Pins")
            // Save Pin and PhotoAlbum
            CoreDataStackManager.sharedInstance().saveContext()
            // Download the photos for the album
            PhotoHandling.sharedInstance().getPhotosForAlbum(photoAlbum, firstTime: true)
            
        }
    }
    
    // Method to retrieve Pin information from Core data and add annotation to Map View
    func addAnnotations() {
        
        var fetchedPins = [Pin]()
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        do {
            
            fetchedPins = try context.executeFetchRequest(fetchRequest) as! [Pin]
            
        } catch let error as NSError {
            print("Error during fetch operation:\(error.userInfo)")
            // Alert User
        }
        
        // Iterate over the fetched Pins from Core Data to create annotations
        for pin in fetchedPins {
            // Extract Annotation coordinate from Pin
//            let annotation = Point(latitude: pin.lat as Double, longitude: pin.lon as Double)
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: pin.lat as Double, longitude: pin.lon as Double)
            annotation.coordinate = coordinate
            // Append to Annotation Array
            annotations.append(annotation)
        }
        // Add annotations to the map view
        mapView.addAnnotations(annotations)
    }
    
    
    // Mark: Map View Delegates
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pinView") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
        } else {
            pinView!.annotation = annotation
            
        }
        pinView!.draggable = true
        return pinView
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {

        
        print("\(view.annotation!.coordinate)")
//        fetchAlbumForAnnotation("\(view.annotation!.coordinate.latitude)"+"\(view.annotation!.coordinate.longitude)")
        let testVC = storyboard?.instantiateViewControllerWithIdentifier("TestViewController") as! TestViewController
        
        testVC.name = "\(view.annotation!.coordinate.latitude)"+"\(view.annotation!.coordinate.longitude)"
        print(testVC.name)
        self.navigationController!.pushViewController(testVC, animated: false)
    }
    
    // Save MapView region whenever user changes it
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
    

//    // Get Image URL array from Flickr for particular lat/lon and page number
//    func getImageURLFromFlickr(lat: Double, lon: Double, page: Int) {
//        
//        FlickrClient.sharedInstance().getFlickrPhotosForAlbum(lat, lon: lon, page_number: page) { [unowned self] results, error in
//            if let error = error {
//                print("Houston we have issues:\(error)")
//                return
//            }
//            
//            guard let photoURLArray = results as? [String] else {
//                print("Unable to get the URL Array")
//                return
//            }
//            self.tempPhotoURL = photoURLArray
//            print("Here is picture count:\(photoURLArray.count)")
//            
//        }
//    }
    
//    // Get the total number of pages in the Album
//    func getTotalNumberOfPhotosInAlbum(lat: Double, lon: Double, page: Int){
//        FlickrClient.sharedInstance().getFlickrTotalNumberOfPhotosInAlbum(lat, lon: lon, page_number: page) {[unowned self] data, error in
//            if error != nil {
//                print("Unable to get total number of pages in album")
//            }
//            
//            guard let albumPhotoCount = data as? String else {
//                print("Invalid data from Flickr")
//                return
//            }
//            self.tempTotalPhotos = Int(albumPhotoCount)!
//            print("total photos in MapViewController:\(self.tempTotalPhotos)")
//        }
//    }
    
    // Download Images from URL
//    func downloadImagesFromURL(photoAlbum: PhotoAlbum) {
//        //Iterate over temp Photo URL Array
//        
//        for (index, url) in tempPhotoURL.enumerate() {
//
//            FlickrClient.sharedInstance().taskForImageData(url) {[unowned self] data, error in
//                if error != nil {
//                    print("Unable to get image for this url:\(url)")
//                    return
//                }
//                guard let newData = data else {
//                    print("Invalid Data for Image")
//                    return
//                }
//                guard let image = UIImage(data: newData) else {
//                    print("Unable to get Image from the Image Data")
//                    return
//                }
//                self.tempImage = image
//                self.tempImageData = newData
//            }
//            let imageName = photoAlbum.name + "\(index)"
//            let filePath = pathToStoreImage(imageName)
//            tempImageData.writeToFile(filePath, atomically: true)
//            let photo = Photo(url: filePath, photoAlbum: photoAlbum, insertIntoManagedObjectContext: context)
//            photo.photoAlbum = photoAlbum
//            context.insertObject(photo)
//            CoreDataStackManager.sharedInstance().saveContext()
//            
//        }
//    }
 
    
//    func pathToStoreImage(fileName: String) ->String {
//        let manager = NSFileManager.defaultManager()
//        let filePath = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
//        guard let url = filePath?.URLByAppendingPathComponent(fileName) else {
//            print("Unable to provide path to store Image on Disk")
//            return ""
//        }
//        
//        return url.path!
//    }
    
    //Method to fetch album data
    func fetchAlbumForAnnotation(name: String) {
        let fetchRequest = NSFetchRequest(entityName: "PhotoAlbum")
        print("\(name)")
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.returnsObjectsAsFaults = false
        
        var albumArray = [PhotoAlbum]()
        do {
            albumArray = try context.executeFetchRequest(fetchRequest) as! [PhotoAlbum]
        } catch let error as NSError {
            print("Error in get PhotoAlbum: \(error.userInfo)")
        }
        if albumArray.isEmpty {
            print("Unable to fetch PhotoAlbum for the pin")
        } else {
            print("\(albumArray)")
        
            // Fetch request for Photos
            
            let fetchPhoto = NSFetchRequest(entityName: "Photo")
            fetchPhoto.predicate = NSPredicate(format: "photoAlbum == %@", albumArray[0])
            fetchPhoto.returnsObjectsAsFaults = false
            
            var photoArray = [Photo]()
            
            do {
                photoArray = try context.executeFetchRequest(fetchPhoto) as! [Photo]
            } catch {
                print("Unable to fetch photos from the Album")
            }
            print("Here is photo Array \(photoArray)")
        }
        
        
        
    }
    // Map View Save region functions
    func saveMapRegion() {
        
        // Place the "center" and "span" of the map into a dictionary
        // The "span" is the width and height of the map in degrees.
        // It represents the zoom level of the map.
        
        let dictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        
        // Archive the dictionary into the filePath
        defaults.setObject(dictionary, forKey: "MapViewRegion")
    }
    
    func restoreMapRegion(animated: Bool) {
        
        // if we can unarchive a dictionary, we will use it to set the map back to its
        // previous center and span
        if let regionDictionary = defaults.objectForKey("MapViewRegion") {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            print("lat: \(latitude), lon: \(longitude), latD: \(latitudeDelta), lonD: \(longitudeDelta)")
            
            mapView.setRegion(savedRegion, animated: animated)
        }
    }
    

}

