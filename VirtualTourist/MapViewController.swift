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
    // Test Segue Identifier
    let testSegue = "TestSegue"
    //movement of pin allowed
    let movementAllowed: CGFloat = 100.00
    // To store total number of Pin
    var newPinID = 0
    // Current Number of pins
    var currentPinID = 0
    //User Defaults
    let defaults = NSUserDefaults.standardUserDefaults()
    // To store reference to new Pin
    var newPin: Pin!
    
    
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
        
        //Allowable movement of the longPressGesture
        longPressGesture.allowableMovement = movementAllowed
        
        // Assign MapView Delegate property to self
        mapView.delegate = self
        
        //Restore Map Appearance
        restoreMapRegion(true)
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(false)
//        
//        //Retrive the Users last save config for Map View
//        restoreMapRegion(true)
//    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(false)
        
        // Save the current Pin count in User Defaults
//        defaults.setInteger(currentPinsCountInUserDefaults, forKey: "Total Pins")
        
        // Save the current state of the map in the NSUser Defaults
//        saveMapRegion()
        // Save changes in context before the view disappears
        
    }
    
    // Method to drop and new pin
    
    @IBAction func dropNewPin(sender: UILongPressGestureRecognizer) {

        
        if sender.state == UIGestureRecognizerState.Began {
            let coordinate = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)
            currentPinID = self.defaults.integerForKey("Total Pins")
            print("This is current Pin ID\(currentPinID)")
            newPinID = currentPinID + 1
            print("This is new Pin ID\(newPinID)")
            let pin = Pin(lat: coordinate.latitude, lon: coordinate.longitude, id: String(newPinID), context: context)
            // Create Associated
            let photoAlbum = PhotoAlbum(pin: pin, insertIntoManagedObjectContext: context)
            photoAlbum.associatedPin = pin
            // Save Pin and PhotoAlbum
            CoreDataStackManager.sharedInstance().saveContext()
            newPin = pin
            print("OriginalPin: \(pin.coordinate)")
            mapView.addAnnotation(pin)
        }
        
        if sender.state == UIGestureRecognizerState.Changed {
            mapView.removeAnnotation(newPin)
            newPin.coordinate = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)
            print("newPin: \(newPin.coordinate)")
            mapView.addAnnotation(newPin)
        }
        // Delete the create Pin in Began state if Gesture is cancelled
        if sender.state == UIGestureRecognizerState.Cancelled {
            let fetchAlbumRequest = NSFetchRequest(entityName: "Pin")
            fetchAlbumRequest.predicate = NSPredicate(format: "id == %@", String(newPinID))
            var pins = [Pin]()
            do {
                pins = try context.executeFetchRequest(fetchAlbumRequest) as! [Pin]
            } catch let error as NSError {
                print("Unable to get pin to delete in Map View:\(error.userInfo)")
            }
            
            if !pins.isEmpty {
                for pin in pins {
                    context.deleteObject(pin)
                }
            }
        }
        
        if sender.state == UIGestureRecognizerState.Ended {
            let fetchAlbumRequest = NSFetchRequest(entityName: "PhotoAlbum")
            fetchAlbumRequest.predicate = NSPredicate(format: "id == %@", String(newPinID))
            var photoAlbum = [PhotoAlbum]()
            do {
                photoAlbum = try context.executeFetchRequest(fetchAlbumRequest) as! [PhotoAlbum]
            } catch let error as NSError {
                print("Unable to get Photo Album for this pin in Map View:\(error.userInfo)")
            }
            
            if !photoAlbum.isEmpty {
                for album in photoAlbum {
                    PhotoHandling.sharedInstance().getPhotosForAlbum(album, firstTime: true)
                }
            }
            // Download the photos for the album
            
        }
        
            defaults.setInteger(newPinID, forKey: "Total Pins")
   
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
            // Append to annotation array
            annotations.append(pin)
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
//        pinView!.draggable = true
        return pinView
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("In Map View didSelectAnnotation: \(view.annotation!.coordinate)")
        let collectionVC = storyboard?.instantiateViewControllerWithIdentifier("CollectionViewController") as! CollectionViewController
        let pin = view.annotation as! Pin
        
        collectionVC.id = pin.id
        
        self.navigationController!.pushViewController(collectionVC, animated: false)
    }
    
    
    // Save MapView region whenever user changes it
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
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

