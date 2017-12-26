//
//  Location+CoreDataProperties.swift
//  meuslugares
//
//  Created by Bruno Lemgruber on 26/12/2017.
//  Copyright © 2017 Bruno Lemgruber. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var category: String
    @NSManaged public var date: Date
    @NSManaged public var latitude: Double
    @NSManaged public var locationDescription: String
    @NSManaged public var longitude: Double
    @NSManaged public var placeMark: CLPlacemark?

}
