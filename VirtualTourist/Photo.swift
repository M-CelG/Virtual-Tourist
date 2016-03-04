//
//  Photo.swift
//  VirtualTourist
//
//  Created by Manish Sharma on 2/19/16.
//  Copyright © 2016 CelG Mobile LLC. All rights reserved.
//

import CoreData

class Photo: NSManagedObject {
    
    @NSManaged var fileName: String
    @NSManaged var photoAlbum : PhotoAlbum
    @NSManaged var id: String
    @NSManaged var url: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(fileName: String, photoAlbum: PhotoAlbum, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.fileName = fileName
        self.photoAlbum = photoAlbum
        id = photoAlbum.id
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        let filePath = pathForIdentifier(fileName)
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
