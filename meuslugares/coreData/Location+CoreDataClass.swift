//
//  Location+CoreDataClass.swift
//  meuslugares
//
//  Created by Bruno Lemgruber on 26/12/2017.
//  Copyright © 2017 Bruno Lemgruber. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject {

    var hasPhoto: Bool {
        return photoID != nil
    }
    
    var photoURL: URL {
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    class func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID") + 1
        userDefaults.set(currentID, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
}

extension Location: MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D{
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    public var title: String?{
        if locationDescription.isEmpty{
            return "(Sem descrição)"
        }else{
            return locationDescription
        }
    }
    
    public var subtitle: String?{
        return category
    }
}
