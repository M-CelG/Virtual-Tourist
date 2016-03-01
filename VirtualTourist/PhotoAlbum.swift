//
//  PhotoAlbum.swift
//  VirtualTourist
//
//  Created by Manish Sharma on 2/20/16.
//  Copyright © 2016 CelG Mobile LLC. All rights reserved.
//

import Foundation
import CoreData

class PhotoAlbum: NSManagedObject {
    
    @NSManaged var id: Int
    @NSManaged var photos: [Photo]
    @NSManaged var associatedPin: Pin
    @NSManaged var totalNumberOfPhotos: Int
    @NSManaged var currentPageNumber: Int
    @NSManaged var name: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(pin: Pin, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("PhotoAlbum", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        name = pin.name
        id = pin.id
        associatedPin = pin
        totalNumberOfPhotos = 0
        currentPageNumber = 1
    }
}
