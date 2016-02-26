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
}
