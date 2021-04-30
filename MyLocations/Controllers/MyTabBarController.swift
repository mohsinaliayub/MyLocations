//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Mohsin Ali Ayub on 29.04.21.
//

import UIKit

class MyTabBarController: UITabBarController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return nil
    }

}
