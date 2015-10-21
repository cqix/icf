//
//  SecondViewController.swift
//  icf
//
//  Created by Patrick Gröller, Christian Koller, Helmut Kopf on 20.10.15.
//  Copyright © 2015 FH. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet weak var groupPicker: UIPickerView!
    let groupDataSource = GroupDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupPicker.dataSource = groupDataSource
        groupPicker.delegate = groupDataSource
        
        groupPicker.selectRow(groupDataSource.getSavedIndex(), inComponent: 0, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

