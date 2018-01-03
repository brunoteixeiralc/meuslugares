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
