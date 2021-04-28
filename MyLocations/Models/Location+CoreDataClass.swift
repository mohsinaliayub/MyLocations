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
    
    var hasPhoto: Bool {
        photoID != nil
    }
    
    var photoURL: URL {
        assert(photoID != nil, "No photo ID set")
        let fileName = "Photo-\(photoID!.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(fileName)
    }
    
    var photoImage: UIImage? {
        UIImage(contentsOfFile: photoURL.path)
    }
    
    class var nextPhotoID: Int {
        let photoIDKey = "PhotoID"
        
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: photoIDKey) + 1
        userDefaults.set(currentID, forKey: photoIDKey)
        userDefaults.synchronize()
        return currentID
    }
    
    func removePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL)
            } catch {
                print("Error removing file: \(error)")
            }
        }
    }
    
    // MARK:- MKAnnotation
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
