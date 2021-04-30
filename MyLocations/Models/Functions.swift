//
//  Functions.swift
//  MyLocations
//
//  Created by Mohsin Ali Ayub on 24.04.21.
//

import Foundation
import CoreLocation

// Helper functions
func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

// Core Data Failure Notification
let coreDataSaveFailedNotification = Notification.Name("CoreDataSaveFailedNotification")

func fatalCoreDataError(_ error: Error) {
    print("*** Fatal Error: \(error)")
    NotificationCenter.default.post(name: coreDataSaveFailedNotification, object: nil)
}
