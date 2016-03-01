//
//  ImageCache.swift
//  VirtualTourist
//
//  Created by Manish Sharma on 2/25/16.
//  Copyright © 2016 CelG Mobile LLC. All rights reserved.
//

import Foundation
import UIKit


class ImageCache {
    
    
    func retriveImageWithIdentifier(fileName: String?) -> UIImage? {
        
        // If the identifier is nil, or empty, return nil
        if fileName == nil || fileName! == "" {
            return nil
        }
        
        let path = pathForIdentifier(fileName!)
        
        // First try the memory cache
        if let image = NSCache().objectForKey(path) as? UIImage {
            return image
        }
        
        // Next Try the hard drive
        print("Trying to open Image: \(fileName)")
        if let image = UIImage(contentsOfFile: path) {
            return image
        }
        
        return nil
    }
    
    // MARK: - Saving images
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        
        // If the image is nil, remove images from the cache
        if image == nil {
            NSCache().removeObjectForKey(path)
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch _ {}
            
            return
        }
        
        // Otherwise, keep the image in memory
        NSCache().setObject(image!, forKey: path)
        
        // And in documents directory
        let data = UIImagePNGRepresentation(image!)!
        data.writeToFile(path, atomically: true)
    }
    
    // MARK: - Helper
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
}