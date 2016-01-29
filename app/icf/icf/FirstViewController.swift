//
//  FirstViewController.swift
//  icf
//
//  Created by Patrick Gröller, Christian Koller, Helmut Kopf on 20.10.15.
//  Copyright © 2015 FH. All rights reserved.
//

import UIKit
import AudioToolbox
import CoreSpotlight
import MobileCoreServices

class FirstViewController: UIViewController {

    let typeDataSource = TypeDataSource()
    let groupDataSource = GroupDataSource()
    let yearDataSource = YearDataSource()
    let courseDataSource = CourseDataSource()
    let lecturerNameDataSource = LecturerNameDataSource()
    
    let speedDataSource = SpeedDataSource()
    let contentDataSource = ContentDataSource()
    let breakDataSource = BreakDataSource()
    
    @IBOutlet weak var speedPicker: UIPickerView!
    @IBOutlet weak var contentPicker: UIPickerView!
    @IBOutlet weak var breakPicker: UIPickerView!
    @IBOutlet weak var textMain: UITextView!
    
    //Spotlight
    internal var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(
            itemContentType: kUTTypeText as String )
        attributeSet.title = "InstantCourseFeedback"
        attributeSet.contentDescription = "FH"
        
        return attributeSet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ServerComm.sharedInstance.setup(speedDataSource, cs: contentDataSource, bs: breakDataSource)
        
        //Spotlight register
        let item = CSSearchableItem (uniqueIdentifier: "icfmain", domainIdentifier: "at.fh-joanneum.icf", attributeSet: attributeSet)

        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item]) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
        
        speedPicker.dataSource = speedDataSource
        speedPicker.delegate = speedDataSource
        speedPicker.selectRow(2, inComponent: 0, animated: true)
        
        contentPicker.dataSource = contentDataSource
        contentPicker.delegate = contentDataSource
        contentPicker.selectRow(2, inComponent: 0, animated: true)
        
        breakPicker.dataSource = breakDataSource
        breakPicker.delegate = breakDataSource
        breakPicker.selectRow(2, inComponent: 0, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
                
        if (typeDataSource.getSavedIndex() != 0) {
            dispatch_async(dispatch_get_main_queue()) {
                self.speedPicker.userInteractionEnabled = false
                self.contentPicker.userInteractionEnabled = false
                self.breakPicker.userInteractionEnabled = false
                self.textMain.text = "Willkommen "+self.lecturerNameDataSource.getSavedText()
            }
            loadCurrentForLecturer()
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.speedPicker.userInteractionEnabled = true
                self.contentPicker.userInteractionEnabled = true
                self.breakPicker.userInteractionEnabled = true
            }
            loadCurrentForStudent()
        }

    }
    
    func loadCurrentForStudent() {
        let urlComponents = NSURLComponents(string: "http://localhost:7777/courses")!
        urlComponents.queryItems = [
            NSURLQueryItem(name: "study", value: courseDataSource.getSavedAsText()),
            NSURLQueryItem(name: "year", value: yearDataSource.getSavedAsText()),
            NSURLQueryItem(name: "group", value: groupDataSource.getSavedAsText())
        ]
        dispatch_async(
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                print("block executed in the background.")
                if let url = urlComponents.URL {
                    do {
                        let contents = try  String(contentsOfURL: url)
                        print("We got: "+contents)
                        if let dataFromString = contents.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                            let dateNow = NSDate()
                            let dateNowFormatter = NSDateFormatter()
                            dateNowFormatter.dateFormat = "yyyy-MM-dd "
                            let dateNowStr = dateNowFormatter.stringFromDate(dateNow)
                
                            let json = JSON(data: dataFromString)
                            var current:JSON = nil
                            for (_, info):(String, JSON) in json {
                                let start_date = dateFormatter.dateFromString(dateNowStr+info["start"].string!)
                                let end_date = dateFormatter.dateFromString(dateNowStr+info["end"].string!)
                                if (dateNow.compare(start_date!)==NSComparisonResult.OrderedDescending && dateNow.compare(end_date!)==NSComparisonResult.OrderedAscending) {
                                    current = info
                                }
                            }
                
                            if (current==nil) {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.textMain.text = "No current course!"
                                }
                                return
                            }
                
                
                            dispatch_async(dispatch_get_main_queue()) {
                                if let lecturer = current["lecturer"].string {
                                    self.textMain.text = "Referent: "+lecturer
                                    ServerComm.sharedInstance.setLecturer(lecturer)
                                } else {
                                    print("Error missing lecturer")
                                }
                                if let course = current["course"].string {
                                    self.textMain.text = self.textMain.text!+"\nLV: "+course
                                } else {
                                    print("Error missing course")
                                }
                                if let location = current["location"].string {
                                    self.textMain.text = self.textMain.text!+"\nOrt: "+location
                                } else {
                                    print("Error missing location")
                                }
                                if let start = current["start"].string {
                                    self.textMain.text = self.textMain.text!+"\nZeit: "+start
                                } else {
                                    print("Error missing start")
                                }
                                if let end = current["end"].string {
                                    self.textMain.text = self.textMain.text!+" - "+end
                                    ServerComm.sharedInstance.setEndTime(end)
                                } else {
                                    print("Error missing end")
                                }
                            }
                        } else {
                            print("Error decoding json")
                        }
                
                    } catch let error {
                        print("Error \(error)")
                    }
                } else {
                    print("Url is invalid")
                }
            }
        )
    }
    
    func loadCurrentForLecturer() {
        let urlComponents = NSURLComponents(string: "http://localhost:7777/feedback")!
        urlComponents.queryItems = [
            NSURLQueryItem(name: "lecturer", value: lecturerNameDataSource.getSavedText()),
        ]
        dispatch_async(
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                print("block executed in the background.")
                if let url = urlComponents.URL {
                    do {
                        let contents = try  String(contentsOfURL: url)
                        print("We got: "+contents)
                        if let dataFromString = contents.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                            let json = JSON(data: dataFromString)
                            
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                if let speed = json["voting"]["speed"].int {
                                    self.speedPicker.selectRow(speed-1, inComponent: 0, animated: true)
                                } else {
                                    print("Error missing speed")
                                }
                                if let content = json["voting"]["content"].int {
                                    self.contentPicker.selectRow(content-1, inComponent: 0, animated: true)
                                } else {
                                    print("Error missing speed")
                                }
                                if let breakProp = json["voting"]["breakProp"].int {
                                    self.breakPicker.selectRow(breakProp-1, inComponent: 0, animated: true)
                                } else {
                                    print("Error missing breakProp")
                                }
                            }
                        } else {
                            print("Error decoding json")
                        }
                        
                    } catch let error {
                        print("Error \(error)")
                    }
                } else {
                    print("Url is invalid")
                }
            }
        )
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

