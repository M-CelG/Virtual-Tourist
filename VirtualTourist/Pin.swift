//
//  Pin.swift
//  VirtualTourist
//
//  Created by Manish Sharma on 2/19/16.
//  Copyright © 2016 CelG Mobile LLC. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Pin: NSManagedObject, MKAnnotation {
    
    struct Keys {
        static let ID = "id"
        static let Lat = "lat"
        static let Lon = "lon"
        static let PhotoAlbum = "photoAlbum"
//        static let Name = "name"
    }
    
    @NSManaged var id: String
    @NSManaged var lat: NSNumber
    @NSManaged var lon: NSNumber
    @NSManaged var photoAlbum : PhotoAlbum?
//    @NSManaged var name: String
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(lat: Double, lon: Double, id: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
//        self.name = "\(lat)" + "\(lon)"
        self.id = id
        self.lat = lat
        self.lon = lon
    }
    var coordinate: CLLocationCoordinate2D {
        get {return CLLocationCoordinate2D(latitude: lat as Double, longitude: lon as Double)}
        set {
            lat = newValue.latitude
            lon = newValue.longitude
        }
    }
    
}
