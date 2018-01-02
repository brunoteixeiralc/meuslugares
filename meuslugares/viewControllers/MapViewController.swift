//
//  MapViewController.swift
//  meuslugares
//
//  Created by Bruno Lemgruber on 02/01/2018.
//  Copyright © 2018 Bruno Lemgruber. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateLocations(){
        
    }
    
    @IBAction func showUser(){
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func showLocations(){
        
    }
}
