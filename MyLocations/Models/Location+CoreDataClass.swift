//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Mohsin Ali Ayub on 26.04.21.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var title: String? {
        return locationDescription.isEmpty ? "(No Description)" : locationDescription
    }
    
    public var subtitle: String? {
        return category
    }
    

}
