//
//  Photo.swift
//  VirtualTourist
//
//  Created by Manish Sharma on 2/19/16.
//  Copyright © 2016 CelG Mobile LLC. All rights reserved.
//

import CoreData

class Photo: NSManagedObject {
    
    @NSManaged var localURL: String
    @NSManaged var photoAlbum : PhotoAlbum
    @NSManaged var name: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(url: String, photoAlbum: PhotoAlbum, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        localURL = url
        self.photoAlbum = photoAlbum
        name = photoAlbum.name
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        print("This Photo item is now Deinitialized")
        let filePath = pathForIdentifier(localURL)
        do {
            try NSFileManager.defaultManager().removeItemAtPath(filePath)
        } catch {
            print("Error deleting file from harddisk")
        }
    }
    
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
    
}
