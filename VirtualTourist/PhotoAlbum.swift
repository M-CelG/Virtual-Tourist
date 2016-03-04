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
    
    @NSManaged var id: String
    @NSManaged var photos: [Photo]
    @NSManaged var associatedPin: Pin
    @NSManaged var totalNumberOfPhotos: NSNumber
    @NSManaged var currentPageNumber: NSNumber
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(pin: Pin, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("PhotoAlbum", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = pin.id
        associatedPin = pin
        totalNumberOfPhotos = 0
        currentPageNumber = 1
    }
}
