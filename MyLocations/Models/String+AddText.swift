//
//  String+AddText.swift
//  MyLocations
//
//  Created by Mohsin Ali Ayub on 29.04.21.
//

import Foundation

extension String {
    
    mutating func add(text: String?, separatedBy separator: String = "") {
        guard let text = text else {
            return
        }
        
        if !isEmpty {
            self += separator
        }
        self += text
    }
}
