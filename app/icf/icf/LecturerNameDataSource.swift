//
//  LecturerNameDataSource.swift
//  icf
//
//  Created by Patrick Gröller, Christian Koller, Helmut Kopf on 09.01.16.
//  Copyright © 2016 FH. All rights reserved.
//

import UIKit

class LecturerNameDataSource: NSObject, UITextFieldDelegate {
    
    let keyName = "LecturerName"
    
    func textFieldDidEndEditing(textField: UITextField) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(textField.text, forKey: keyName)
    }
    
    func getSavedText() -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        let value = defaults.stringForKey(keyName)
        if (value==nil) {
            return ""
        } else {
            return value!
        }
    }

    
}