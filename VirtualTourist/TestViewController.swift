//
//  TestViewController.swift
//  VirtualTourist
//
//  Created by Manish Sharma on 2/25/16.
//  Copyright © 2016 CelG Mobile LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class TestViewController: UIViewController {
    
    // Set Context
    var context: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var count = 0
    
    @IBOutlet weak var imageView: UIImageView!
    
    var photos = [Photo]()
    
    //Pin information
    var name = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.  
//        fetchPhotoAlbum(name)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        //Print name
        print("this is in TestVC \(name)")
        //Perform Fetch for Photos
        fetchPhotoAlbum(name)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if !photos.isEmpty {
            imageView.image = ImageCache().retriveImageWithIdentifier(photos[0].localURL)
        }

    }

    @IBAction func nextImage(sender: AnyObject) {
        
        if photos.isEmpty {
            print("No Photos to show")
        } else {
            print("\(photos.count)")
            if count < photos.count {
                imageView.image = ImageCache().retriveImageWithIdentifier(photos[count].localURL)
//                imageView.image = UIImage(contentsOfFile: photos[count].localURL)
                print(photos[count].localURL)
                ++count
            } else {
                count = 0
            }
        }
        

    }

    func fetchPhotoAlbum(name: String) {
//        let fetchRequest = NSFetchRequest(entityName: "PhotoAlbum")
//        print(name)
//        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
//        fetchRequest.returnsObjectsAsFaults = false
        
//        var photoAlbum = [PhotoAlbum]()
//        do {
//            photoAlbum = try context.executeFetchRequest(fetchRequest) as! [PhotoAlbum]
//        } catch {
//            print("Unable to find the PhotoAlbum")
//        }
//        
//        if photoAlbum.isEmpty {
//            print("PhotoAlbum is empty")
//        } else {
//            print("\(photoAlbum[0])")
        let fetchPhotosRequest = NSFetchRequest(entityName: "Photo")
        fetchPhotosRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchPhotosRequest.returnsObjectsAsFaults = false
        
        do {
            photos = try context.executeFetchRequest(fetchPhotosRequest) as! [Photo]
        } catch {
            print("Did not get Photos")
        }
        print(photos)
        print("Got Photo")
            
//        }
        
        
        

    
    }
    
}
