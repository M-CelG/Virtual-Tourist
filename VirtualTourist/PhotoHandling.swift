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
    
    func getPhotosForAlbum(album: PhotoAlbum, firstTime: Bool) {
        // Get coordinates for the associated Pin
        let lat = album.associatedPin.lat
        let lon = album.associatedPin.lon
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
            
            guard let albumPhotoCount = data as? String else {
                print("Invalid data from Flickr")
                return
            }
            dispatch_async(dispatch_get_main_queue()){
                if let number = Int(albumPhotoCount) {
                    album.totalNumberOfPhotos = number
                    CoreDataStackManager.sharedInstance().saveContext()
                } else {
                    print("Unable to get total photo count for the Album")
                }
            }

        }
        // Now get the Page number requested by the PhotoAlbum
        currentPage = album.currentPageNumber
        if firstTime {
            pageToFetch = 1
        } else {
            pageTotal = Int(album.totalNumberOfPhotos) / Int(FlickrClient.Constants.PER_PAGE)!
            if Int(album.totalNumberOfPhotos) % 20 != 0 {
                pageTotal += 1
            }
            if currentPage < pageTotal {
                pageToFetch = currentPage + 1
                album.currentPageNumber = pageToFetch
                CoreDataStackManager.sharedInstance().saveContext()
            } else if currentPage == pageTotal {
                pageToFetch = 0
            }
        }
        
        // Now get the URLs, then get Images and store them on local disk
        FlickrClient.sharedInstance().getFlickrPhotosForAlbum(lat, lon: lon, page_number: pageToFetch) { results, error in
            if let error = error {
                print("Houston we have issues:\(error)")
                return
            }
            
            guard let photoURLArray = results as? [String] else {
                print("Unable to get the URL Array")
                return
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                NSNotificationCenter.defaultCenter().postNotificationName("StartOfImageDownload", object: self, userInfo: nil)
                for (index, url) in photoURLArray.enumerate() {
                    FlickrClient.sharedInstance().taskForImageData(url) {data, error in
//                        print("Here is each URL\(url)")
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
                        let photo = Photo(url: imageName!, photoAlbum: album, insertIntoManagedObjectContext: self.context)
                        photo.photoAlbum = album
                        if index == photoURLArray.count - 1 {
                            CoreDataStackManager.sharedInstance().saveContext()
                            NSNotificationCenter.defaultCenter().postNotificationName("EndOfImageDownload", object: self, userInfo: nil)
                        }
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
    
    // Mark: Single Instance
    class func sharedInstance() -> PhotoHandling {
        
        struct Singleton {
            
            static let sharedInstance = PhotoHandling()
        }
        return Singleton.sharedInstance
    }
    
}
