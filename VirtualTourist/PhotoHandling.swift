//
//  PhotoHandling.swift
//  VirtualTourist
//
//  Created by Manish Sharma on 2/25/16.
//  Copyright © 2016 CelG Mobile LLC. All rights reserved.
//

/* This class is responsible to downloading Photos from Flickr, Storing them on
*  on disk, deleting particular photo from Photo Alblum, deleting all Photos
*/

import Foundation
import CoreData
import UIKit

class PhotoHandling: NSObject {
    
    // Shared Session
    var session = FlickrClient.sharedInstance().session
    // Shared Context for Core Data
    var context = CoreDataStackManager.sharedInstance().managedObjectContext
    
    // Function to get Photos of Photo Album all together
    func getPhotosForAlbum(album: PhotoAlbum, firstTime: Bool, completionHandler: (NSError? -> Void)) {
        // Get coordinates for the associated Pin
        let lat = album.associatedPin.lat as Double
        let lon = album.associatedPin.lon as Double
        // Get the current Page
        var currentPage = 0
        // Which page to fetch
        var pageToFetch:Int = 0
        // Total number of pages
        var pageTotal = 0

        
        // First update total number of photo's in Album
        FlickrClient.sharedInstance().getFlickrTotalNumberOfPhotosInAlbum(lat, lon: lon, page_number: currentPage) { data, error in
            if error != nil {
                print("Unable to get total number of pages in album")
            }
            
            if let albumPhotoCount = data as? String {
                self.context.performBlockAndWait(){
                    if let number = Int(albumPhotoCount) {
                        album.totalNumberOfPhotos = number
                        CoreDataStackManager.sharedInstance().saveContext()
                    } else {
                        print("Unable to get total photo count for the Album")
                    }
                }
                
            } else {
                print("Invalid data from Flickr")
            }
        }
        // Now get the Page number requested by the PhotoAlbum
        currentPage = Int(album.currentPageNumber)
        pageTotal = Int(album.totalNumberOfPhotos) / Int(FlickrClient.Constants.PER_PAGE)!
        if Int(album.totalNumberOfPhotos) % 20 != 0 {
            pageTotal += 1
        }
        if currentPage < pageTotal {
            pageToFetch = currentPage + 1
            self.context.performBlock(){
                album.currentPageNumber = pageToFetch
                CoreDataStackManager.sharedInstance().saveContext()
            }
        } else if currentPage == pageTotal {
            pageToFetch = 0
        }
        
        // Now get the URLs, then get Images and store them on local disk
        FlickrClient.sharedInstance().getFlickrPhotosForAlbum(lat, lon: lon, page_number: pageToFetch) { results, error in
            if let error = error {
                print("Houston we have issues:\(error)")
                completionHandler(error)
                return
            }
            
            guard let photoURLArray = results as? [String] else {
                print("Unable to get the URL Array")
                completionHandler(error)
                return
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                NSNotificationCenter.defaultCenter().postNotificationName("StartOfImageDownload", object: self, userInfo: nil)
                for (index, url) in photoURLArray.enumerate() {
                    FlickrClient.sharedInstance().taskForImageData(url) {data, error in
                        if error != nil {
                            print("Unable to get image for this url:\(url)")
                            return
                        }
                        guard let _ = data else {
                            print("Invalid Data for Image")
                            return
                        }
                        guard let image = UIImage(data: data!) else {
                            print("Unable to get Image from the Image Data")
                            return
                        }
                        let urlNSURL = NSURL(string: url)!
                        let imageName = urlNSURL.lastPathComponent
                        ImageCache().storeImage(image, withIdentifier: imageName!)
                        self.context.performBlockAndWait(){
                            let photo = Photo(fileName: imageName!, photoAlbum: album, insertIntoManagedObjectContext: self.context)
                            photo.photoAlbum = album
                            photo.url = url
                        }
                        if index == photoURLArray.count - 1 {
                            self.context.performBlock() {
                                CoreDataStackManager.sharedInstance().saveContext()
                            }
                            NSNotificationCenter.defaultCenter().postNotificationName("EndOfImageDownload", object: self, userInfo: nil)
                        }
                    }
                }
            }
        }
    }

    // The method get details for photos in Album but does not download
    func getPhotoURLsForAlbum(album: PhotoAlbum, firstTime: Bool, completionHandler: (NSError? -> Void)) {
        // Get coordinates for the associated Pin
        let lat = album.associatedPin.lat as Double
        let lon = album.associatedPin.lon as Double
        // Get the current Page
        var currentPage = 0
        // Which page to fetch
        var pageToFetch:Int = 0
        // Total number of pages
        var pageTotal = 0
        
        
        // First update total number of photo's in Album
        FlickrClient.sharedInstance().getFlickrTotalNumberOfPhotosInAlbum(lat, lon: lon, page_number: currentPage) { data, error in
            if error != nil {
                print("Unable to get total number of pages in album")
            }
            
            if let albumPhotoCount = data as? String {
                self.context.performBlockAndWait(){
                    if let number = Int(albumPhotoCount) {
                        album.totalNumberOfPhotos = number
                        CoreDataStackManager.sharedInstance().saveContext()
                    } else {
                        print("Unable to get total photo count for the Album")
                    }
                }
            } else {
                print("Invalid data from Flickr")
            }
        }
        
        // Now get the Page number requested by the PhotoAlbum
        currentPage = Int(album.currentPageNumber)
        pageTotal = Int(album.totalNumberOfPhotos) / Int(FlickrClient.Constants.PER_PAGE)!
        if Int(album.totalNumberOfPhotos) % 20 != 0 {
            pageTotal += 1
        }
        if currentPage < pageTotal {
            pageToFetch = currentPage + 1
            self.context.performBlock(){
                album.currentPageNumber = pageToFetch
                CoreDataStackManager.sharedInstance().saveContext()
            }
        } else if currentPage == pageTotal {
            pageToFetch = 0
        }

        
        // Now get the URLs, then get Images and store them on local disk
        FlickrClient.sharedInstance().getFlickrPhotosForAlbum(lat, lon: lon, page_number: pageToFetch) { results, error in
            if let error = error {
                print("Houston we have issues:\(error)")
                completionHandler(error)
                return
            }
            
            guard let photoURLArray = results as? [String] else {
                print("Unable to get the URL Array")
                completionHandler(error)
                return
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                NSNotificationCenter.defaultCenter().postNotificationName("StartOfImageDownload", object: self, userInfo: nil)
                for (index, url) in photoURLArray.enumerate() {
                    let urlNSURL = NSURL(string: url)!
                    let imageName = urlNSURL.lastPathComponent
                    self.context.performBlockAndWait(){
                        let photo = Photo(fileName: imageName!, photoAlbum: album, insertIntoManagedObjectContext: self.context)
                        photo.photoAlbum = album
                        photo.url = url
                    }
                    if index == photoURLArray.count - 1 {
                        self.context.performBlock() {
                            CoreDataStackManager.sharedInstance().saveContext()
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName("EndOfImageDownload", object: self, userInfo: nil)
                    }
                }
            }
        }
    }
    
    // This method returns filepath to store file on disk
    func pathToStoreImage(fileName: String) ->String {
        let manager = NSFileManager.defaultManager()
        let filePath = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        guard let url = filePath?.URLByAppendingPathComponent(fileName) else {
            print("Unable to provide path to store Image on Disk")
            return ""
        }
        
        return url.path!
    }
    
    // MARK: Class func to present User Alerts
    class func alertUser(controller: UIViewController, title: String, errorMsg: String, actionText: String) {
        let alertController = UIAlertController(title: title, message: errorMsg, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: actionText, style: .Cancel, handler: nil)
        alertController.addAction(alertAction)
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Mark: Single Instance
    class func sharedInstance() -> PhotoHandling {
        
        struct Singleton {
            
            static let sharedInstance = PhotoHandling()
        }
        return Singleton.sharedInstance
    }
    
}
