//
//  FlickrClient-Convenience.swift
//  VirtualTourist
//
//  Created by Manish Sharma on 2/20/16.
//  Copyright © 2016 CelG Mobile LLC. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    
    //Method for getting Photos for the PhotoAlbums
    func getFlickrPhotosForAlbum (lat: Double, lon: Double, page_number: Int, completionHandler: (results: AnyObject?, error: NSError?) -> Void){
        
        // Create Parameter dictionary
        let parameters = [
            FlickrClient.MethodArguments.ACCURACY: FlickrClient.Constants.ACCURACY,
            FlickrClient.MethodArguments.API_KEY: FlickrClient.Constants.API_KEY,
            FlickrClient.MethodArguments.DATA_FORMAT: FlickrClient.Constants.DATA_FORMAT,
            FlickrClient.MethodArguments.NO_JSON_CALLBACK: FlickrClient.Constants.NO_JSON_CALLBACK,
            FlickrClient.MethodArguments.METHOD_NAME: FlickrClient.Method.PHOTO_SEARCH,
            FlickrClient.MethodArguments.EXTRAS: FlickrClient.Constants.EXTRAS,
            FlickrClient.MethodArguments.LATITUDE: lat,
            FlickrClient.MethodArguments.LONGITUDE: lon,
            FlickrClient.MethodArguments.PER_PAGE: FlickrClient.Constants.PER_PAGE,
            FlickrClient.MethodArguments.PAGE: page_number
        ]
     
        self.getFlickrDataTaskMethod(parameters as! [String : AnyObject]) {data, error in
            if let error = error {
                print("Unable to get photo's for the album:\(error.userInfo)")
                completionHandler(results: nil, error: error)
                return
            }
            
            guard let resultData = data else{
                print("Did not receive valid data in getFlickrPhotosForAlbum")
                completionHandler(results: nil, error: NSError(domain: "Get Photos for Album", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid data received"]))
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = resultData[FlickrClient.JsonKeys.Stat] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(resultData)")
                completionHandler(results: nil, error: NSError(domain: "Flickr API Error", code: 2, userInfo: [NSLocalizedDescriptionKey: "Flickr API error in stat"]))
                return
            }
            
            // Guard: Get the Page Dictionary
            guard let flickrPageDict = resultData[FlickrClient.JsonKeys.TopLevelPhotos] as? [String: AnyObject] else {
                print("Error geting Top level directory - photos")
                completionHandler(results: nil, error: NSError(domain: "Getting top level photos", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unable to get Top level photos key"]))
                return
            }
            
            // Get the the total number of photos in the Album
            guard let totalPhotosInAlbum = flickrPageDict[FlickrClient.JsonKeys.Total] as? String else {
                print("Unable to find number of pages of photo's returned")
                completionHandler(results: nil, error: NSError(domain: "Getting total number of pages of Photos", code: 4, userInfo: [NSLocalizedDescriptionKey:"Unable to get total number of pages"]))
                return
            }
            print("TotalPictures are: \(totalPhotosInAlbum)")
            
            // Get Photo Dictionary
            guard let photosDict = flickrPageDict[FlickrClient.JsonKeys.PhotosDictInData] as? [[String: AnyObject]] else {
                print("Unable to get Photos Dict from downloaded Flickr Page")
                completionHandler(results: nil, error: NSError(domain: "Unable to extract photos Dict from downloaded Page", code: 5, userInfo: [NSLocalizedDescriptionKey: "Unable to extract photo Dict"]))
                return
            }
            print(photosDict.count)
            

            // Array to store URL of the photos in the page
            var photoURLs = [String]()

            for photo in photosDict {
                if let photoURL = photo[FlickrClient.JsonKeys.URL] as? String{
                    photoURLs.append(photoURL)
                }
            }
            print(photoURLs.count)
            completionHandler(results: photoURLs, error: nil)
        }
    }
    //Method for getting Photos for the PhotoAlbums
    func getFlickrTotalNumberOfPhotosInAlbum (lat: Double, lon: Double, page_number: Int, completionHandler: (results: AnyObject?, error: NSError?) -> Void){
        
        // Create Parameter dictionary
        let parameters = [
            FlickrClient.MethodArguments.ACCURACY: FlickrClient.Constants.ACCURACY,
            FlickrClient.MethodArguments.API_KEY: FlickrClient.Constants.API_KEY,
            FlickrClient.MethodArguments.DATA_FORMAT: FlickrClient.Constants.DATA_FORMAT,
            FlickrClient.MethodArguments.NO_JSON_CALLBACK: FlickrClient.Constants.NO_JSON_CALLBACK,
            FlickrClient.MethodArguments.METHOD_NAME: FlickrClient.Method.PHOTO_SEARCH,
            FlickrClient.MethodArguments.EXTRAS: FlickrClient.Constants.EXTRAS,
            FlickrClient.MethodArguments.LATITUDE: lat,
            FlickrClient.MethodArguments.LONGITUDE: lon,
            FlickrClient.MethodArguments.PER_PAGE: FlickrClient.Constants.PER_PAGE,
            FlickrClient.MethodArguments.PAGE: page_number
        ]
        
        self.getFlickrDataTaskMethod(parameters as! [String : AnyObject]) {data, error in
            if let error = error {
                print("Unable to get photo's for the album:\(error.userInfo)")
                completionHandler(results: nil, error: error)
                return
            }
            
            guard let resultData = data else{
                print("Did not receive valid data in getFlickrPhotosForAlbum")
                completionHandler(results: nil, error: NSError(domain: "Get Photos for Album", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid data received"]))
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = resultData[FlickrClient.JsonKeys.Stat] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(resultData)")
                completionHandler(results: nil, error: NSError(domain: "Flickr API Error", code: 2, userInfo: [NSLocalizedDescriptionKey: "Flickr API error in stat"]))
                return
            }
            
            // Guard: Get the Page Dictionary
            guard let flickrPageDict = resultData[FlickrClient.JsonKeys.TopLevelPhotos] as? [String: AnyObject] else {
                print("Error geting Top level directory - photos")
                completionHandler(results: nil, error: NSError(domain: "Getting top level photos", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unable to get Top level photos key"]))
                return
            }
            
            // Get the the total number of photos in the Album
            guard let totalPhotosInAlbum = flickrPageDict[FlickrClient.JsonKeys.Total] as? String else {
                print("Unable to find number of photo's in Album")
                completionHandler(results: nil, error: NSError(domain: "Getting total number of pages of Photos", code: 4, userInfo: [NSLocalizedDescriptionKey:"Unable to get total number of pages"]))
                return
            }
            print("TotalPictures are: \(totalPhotosInAlbum)")
            
            completionHandler(results: totalPhotosInAlbum, error: nil)
        }
    }

}
