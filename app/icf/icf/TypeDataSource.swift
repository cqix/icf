//
//  TypeDataSource.swift
//  icf
//
//  Created by Patrick Gröller, Christian Koller, Helmut Kopf on 09.01.16.
//  Copyright © 2016 FH. All rights reserved.
//
// are you a lecturer or a student
import UIKit

class TypeDataSource: NSObject {
    
    let keyName = "Type"
    
    func saveIndex(value: Int) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(value, forKey: keyName)
    }
    
    func getSavedIndex() -> Int {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.integerForKey(keyName)
    }
    
    
}