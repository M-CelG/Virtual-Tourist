//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Manish Sharma on 2/21/16.
//  Copyright © 2016 CelG Mobile LLC. All rights reserved.
//

import UIKit
import MapKit

class CollectionViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Add Constraints
        addConstraints()
        
    }


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func addConstraints() {
        let heightConstraint = NSLayoutConstraint(item: mapView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.25, constant: 0)
        self.view.addConstraint(heightConstraint)
    }

}
