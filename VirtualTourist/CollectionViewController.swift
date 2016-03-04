//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Manish Sharma on 2/21/16.
//  Copyright © 2016 CelG Mobile LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CollectionViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Zoom level setting for Map View
    private struct ZoomLevel {
        let latitudeInMeters = 15000.0
        let longitudeInMeters = 15000.0
    }

    
    // IB Outlets to connect the UI Items
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    //Indexes to Manage Batch processing of changes for collectionView
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    // NSIndexPath array to keep track of Selected Indexes
    var selectedIndexPaths: [NSIndexPath]!
    // Pin id will be used to pass Pin information
    var id: String!
    //Shared Core Data Context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the Index path tracking arrays
        selectedIndexPaths = [NSIndexPath]()
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        // Add Constraints
        addConstraints()
        
        // Perform Fetch with Fetched Results Controller
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error during performFetch. Here is error User Info \(error.userInfo)")
        }
        
        // Assign Delegate to fetchedResultsController
        fetchedResultsController.delegate = self
        
        // Collection View Data Source and Delegate assignment
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Annotate Map
        let annotation = MKPointAnnotation()
        annotation.coordinate = getCoordinatesForPin(id)
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, ZoomLevel().latitudeInMeters, ZoomLevel().longitudeInMeters)
        mapView.setRegion(region, animated: true)
        
        //Register for Notification center for start and end of Image download
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startOfImageDownload", name: "StartOfImageDownload", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUIPostImageDownload", name: "EndOfImageDownload", object: nil)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        //De-Register for notifications
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "StartOfImageDownload", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "EndOfImageDownload", object: nil)
    }
    
    // Create layout for the cells in collection view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Configure the cell layout
        let cellLayout = UICollectionViewFlowLayout()
        cellLayout.sectionInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        cellLayout.minimumInteritemSpacing = 3.0
        cellLayout.minimumLineSpacing = 3.0
        
        let width = floor((self.collectionView.frame.size.width/3) - 4)
        cellLayout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = cellLayout
    }
    
    // Create Fetched Result Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fileName", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "id == %@", self.id)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)

        
        return fetchedResultsController
    }()
    
    // MARK: -  Configure Cell
    
    func configureCell(cell: PhotoCollectionViewCell, atIndexPath path: NSIndexPath) {
        let photo = fetchedResultsController.objectAtIndexPath(path) as! Photo
        
        cell.activityIndicator.startAnimating()
        
        let filePath = PhotoHandling.sharedInstance().pathToStoreImage(photo.fileName)
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            cell.activityIndicator.stopAnimating()
            cell.imageView.image = ImageCache().retriveImageWithIdentifier(photo.fileName)
        } else {
            cell.imageView.image = UIImage(named: "PlaceHolder")
            FlickrClient.sharedInstance().taskForImageData(photo.url) {data, error in
                if error != nil {
                    print("Unable to download this particular Image: \(photo.url)")
                    return
                }
                
                if let image = UIImage(data: data!) {
                    dispatch_async(dispatch_get_main_queue()) {
                        ImageCache().storeImage(image, withIdentifier: photo.fileName)
                        cell.imageView.image = image
                        cell.activityIndicator.stopAnimating()
                    }
                } else {
                    print("Unable to get this image as data is invalid: \(photo.url)")
                }
                
            }
        }
    }
    
    // MARK: - Collection View Data Source and Delegates
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photoCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        configureCell(photoCell, atIndexPath: indexPath)
        
        return photoCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("The cell was selected")
        //Remove Photo from Collection
        if let photo = fetchedResultsController.objectAtIndexPath(indexPath) as? Photo {
            sharedContext.deleteObject(photo)
            CoreDataStackManager.sharedInstance().saveContext()
        }
        
    }
    
    // MARK: Delegate for Fetched Results Controller
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        //Reset all the tracking indexes at the start of the change
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                insertedIndexPaths.append(newIndexPath!)
            case .Delete:
                deletedIndexPaths.append(indexPath!)
            case .Update:
                updatedIndexPaths.append(indexPath!)
            default:
                break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
         // Perform bulk changes in Collection View
        collectionView.performBatchUpdates({() in
            for index in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([index])
            }
            for index in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([index])
            }
            for index in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([index])
            }
            
        }, completion: nil)
    }
    
    // MARK: - Get pin Data for map view
    func getCoordinatesForPin(id: String) -> CLLocationCoordinate2D {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.predicate = NSPredicate(format: "id == %@", self.id)
        
        var fetchedPin = [Pin]()
        
        do {
            
            fetchedPin = try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
            
        } catch let error as NSError {
            
            print("Unable to Fetch Pin information from Core Data:\(error.userInfo)")
            
        }
        
        if !fetchedPin.isEmpty {
            for pin in fetchedPin {
                let coordinate = CLLocationCoordinate2D(latitude: pin.lat as Double , longitude: pin.lon as Double)
                return coordinate
            }
        } else {
            print("Unable to get coordinates for the pin. Returning centre of US")
            
        }

        return CLLocationCoordinate2DMake(44.58, 103.46)
    }
    
    // Constraint for map view so that its height changes with screen size
    func addConstraints() {
        let heightConstraint = NSLayoutConstraint(item: mapView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.25, constant: 0)
        self.view.addConstraint(heightConstraint)
    }
    
    @IBAction func getNewCollection(sender: UIBarButtonItem) {
        // Disable New Collection Button
        newCollectionButton.enabled = false
        
        // Get all the photos in the Fetched Results Controller
        let photos = fetchedResultsController.fetchedObjects as! [Photo]
        
        // Delete all the current photos
        for photo in photos{
            sharedContext.deleteObject(photo)
        }
        
        // Get the Album details for next fetch
        let fetchAlbumRequest = NSFetchRequest(entityName: "PhotoAlbum")
        fetchAlbumRequest.predicate = NSPredicate(format: "id == %@", id)
        var album = [PhotoAlbum]()
        
        do {
            album = try sharedContext.executeFetchRequest(fetchAlbumRequest) as! [PhotoAlbum]
        } catch let error as NSError {
            print("Unable to get Album ID for new collection: \(error.userInfo)")
            PhotoHandling.alertUser(self, title: "New Collection", errorMsg: "Unable to find Photo Album", actionText: "Retry")
            newCollectionButton.enabled = true
        }
        if !album.isEmpty {
            for thisAlbum in album{
                PhotoHandling.sharedInstance().getPhotoURLsForAlbum(thisAlbum, firstTime: false) {error in
                    if error != nil {
                        dispatch_async(dispatch_get_main_queue()){
                            PhotoHandling.alertUser(self, title: "New Collection", errorMsg: "Unable to Download Photos", actionText: "Retry")
                            self.newCollectionButton.enabled = true
                        }
                    }
                }
            }
        }
    }
    
    // Function is called when new collection download starts
    func startOfImageDownload(){
        dispatch_async(dispatch_get_main_queue()) {
            if self.newCollectionButton.enabled == true {
                self.newCollectionButton.enabled = false
            }
        
        }
    }
    
    // Function is called with new collection download is finished
    func updateUIPostImageDownload(){
        dispatch_async(dispatch_get_main_queue()) {
            self.newCollectionButton.enabled = true
        }
    }
}
