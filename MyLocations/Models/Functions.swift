//
//  Functions.swift
//  MyLocations
//
//  Created by Mohsin Ali Ayub on 24.04.21.
//

import Foundation
import CoreLocation

// Helper functions
func string(from placemark: CLPlacemark) -> String {
    var line1 = ""
    
    // additional street-level information
    if let s = placemark.subThoroughfare {
        line1 += s + " "
    }
    
    // street address
    if let s = placemark.thoroughfare {
        line1 += s + ", "
    }
    
    var line2 = ""
    
    // city
    if let s = placemark.locality {
        line2 += s + ", "
    }
    
    // state
    if let s = placemark.administrativeArea {
        line2 += s + " "
    }
    
    // postal code
    if let s = placemark.postalCode {
        line2 += s + ", "
    }
    
    if let s = placemark.country {
        line2 += s
    }
    
    return line1 + "\n" + line2
}
