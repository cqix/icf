//
//  BreakDataSource.swift
//  icf
//
//  Created by Patrick Gröller, Christian Koller, Helmut Kopf on 21.10.15.
//  Copyright © 2015 FH. All rights reserved.
//

import UIKit

class BreakDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let keyName = "Break"
    let pickerItems = ["1", "2", "3", "4", "5"];
    
    override init() {
        super.init()
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(3, forKey: keyName)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Get row count from pickerItems
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerItems.count
    }
    
    //Get item from pickerItems
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerItems[row]
    }
    
    //Save selected
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(row, forKey: keyName)
        ServerComm.sharedInstance.send()
    }
    
    func getSavedIndex() -> Int {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.integerForKey(keyName)
    }

}