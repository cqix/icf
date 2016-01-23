//
//  SpeedDataSource.swift
//  icf
//
//  Created by Patrick Gröller, Christian Koller, Helmut Kopf on 21.10.15.
//  Copyright © 2015 FH. All rights reserved.
//

import UIKit

class SpeedDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let pickerItems = ["1", "2", "3", "4", "5"];
    
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
    
}