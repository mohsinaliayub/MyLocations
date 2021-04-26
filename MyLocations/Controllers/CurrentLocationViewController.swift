//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Mohsin Ali Ayub on 15.04.21.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    // outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    // properties
    var managedObjectContext: NSManagedObjectContext!
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    
    var timer: Timer?
    
    let tagLocationSegueIdentifier = "TagLocation"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hiding the navigation bar
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateLabels()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // showing the navigation bar again
        navigationController?.isNavigationBarHidden = false
    }
    
    func updateLabels() {
        guard let location = location else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            
            // show information if there was an error
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
            
            return
        }
        
        latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
        tagButton.isHidden = false
        messageLabel.text = ""
        configureGetButton()
        
        // displaying geocoding information to user
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else if performingReverseGeocoding {
            addressLabel.text = "Searching for Address..."
        } else if lastGeocodingError != nil {
            addressLabel.text = "Error Finding Address"
        } else {
            addressLabel.text = "No Address Found"
        }
    }
    
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    
    @objc func didTimeout() {
        print("*** Time out ***")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
        }
    }
    
    func startLocationManager() {
        if !CLLocationManager.locationServicesEnabled() {
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        updatingLocation = true
        
        timer = Timer(timeInterval: 60, target: self, selector: #selector(didTimeout), userInfo: nil, repeats: false)
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    // MARK:- Actions
    @IBAction func getLocation() {
        // requesting permission to access location
        let authStatus = locationManager.authorizationStatus
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        // if access to location services is disabled or denied, show an alert
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        // if everything is fine, start getting location updates
        if updatingLocation {
            stopLocationManager()
        } else {
            lastLocationError = nil
            location = nil
            startLocationManager()
        }
        updateLabels()
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tagLocationSegueIdentifier {
            let controller = segue.destination as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    // MARK:- CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError: \(error.localizedDescription)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations: \(newLocation)")
        
        // checking if the location we got is cached, if it is, then ignore the result
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        // if reading is not more accurate, discard it
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        // finding distance between old and new location
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        // if it's the first new reading, then take it
        // if new reading is more accurate than last one, take it
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            // clearing out previous errors and saving new location
            lastLocationError = nil
            location = newLocation
            
            // if our new location meets our desired accuracy, stop location updates
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done ***")
                stopLocationManager()
                
                // force reverse geocoding for last result
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            updateLabels()
            performReverseGeocoding(on: newLocation)
        } else if distance < 1 {
            // if it has been more than 10 seconds since we received a good reading,
            // stop location manager
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            
            if timeInterval > 10 {
                print("*** Force Done! ***")
                stopLocationManager()
                updateLabels()
            }
        }
    }
    
    // MARK:- Helper Methods
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func performReverseGeocoding(on newLocation: CLLocation) {
        if performingReverseGeocoding {
            return
        }
        
        performingReverseGeocoding = true
        
        geocoder.reverseGeocodeLocation(newLocation) { (placemarks, error) in
            self.lastGeocodingError = error
            if error == nil, let p = placemarks, !p.isEmpty {
                self.placemark = p.last
            } else {
                self.placemark = nil
            }
            
            self.performingReverseGeocoding = false
            self.updateLabels()
        }
    }

}
