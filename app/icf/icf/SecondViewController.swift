//
//  SecondViewController.swift
//  icf
//
//  Created by Patrick Gröller, Christian Koller, Helmut Kopf on 20.10.15.
//  Copyright © 2015 FH. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet weak var coursePicker: UIPickerView!
    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet weak var groupPicker: UIPickerView!
    
    @IBOutlet weak var lecturerNameText: UITextField!
    
    let groupDataSource = GroupDataSource()
    let yearDataSource = YearDataSource()
    let courseDataSource = CourseDataSource()
    let lecturerNameDataSource = LecturerNameDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coursePicker.dataSource = courseDataSource
        coursePicker.delegate = courseDataSource
        coursePicker.selectRow(courseDataSource.getSavedIndex(), inComponent: 0, animated: true)
        
        yearPicker.dataSource = yearDataSource
        yearPicker.delegate = yearDataSource
        yearPicker.selectRow(yearDataSource.getSavedIndex(), inComponent: 0, animated: true)
        
        groupPicker.dataSource = groupDataSource
        groupPicker.delegate = groupDataSource
        groupPicker.selectRow(groupDataSource.getSavedIndex(), inComponent: 0, animated: true)
        
        lecturerNameText.text = lecturerNameDataSource.getSavedText()
        lecturerNameText.delegate = lecturerNameDataSource
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

