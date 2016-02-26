//
//  DraggablePointAnnotation.swift
//  VirtualTourist
//
//  Created by Manish Sharma on 2/22/16.
//  Copyright © 2016 CelG Mobile LLC. All rights reserved.
//

import UIKit
import MapKit

class Point: NSObject, MKAnnotation {
    
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        super.init()
    }
    var coordinate: CLLocationCoordinate2D {
        get {return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)}
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    func newCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coordinate = newCoordinate
    }
}


