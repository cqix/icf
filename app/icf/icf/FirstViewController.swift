//
//  FirstViewController.swift
//  icf
//
//  Created by Patrick Gröller, Christian Koller, Helmut Kopf on 20.10.15.
//  Copyright © 2015 FH. All rights reserved.
//

import UIKit
import AudioToolbox

class FirstViewController: UIViewController {
    
    let uuid = NSUUID().UUIDString

    @IBOutlet weak var LabelMain: UILabel!
    
    let typeDataSource = TypeDataSource()
    let groupDataSource = GroupDataSource()
    let yearDataSource = YearDataSource()
    let courseDataSource = CourseDataSource()
    let lecturerNameDataSource = LecturerNameDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        LabelMain.text = "UUID: "+uuid

        //Send after 10 seconds
        let localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertAction = "Testing notifications on iOS8"
        localNotification.alertBody = "Local notifications are working"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 10)
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.category = "invite"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        */
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (typeDataSource.getSavedIndex() != 0) {
            dispatch_async(dispatch_get_main_queue()) {
                self.LabelMain.text = "Willkommen "+self.lecturerNameDataSource.getSavedText()
            }
            return
        }
        
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
                            let json = JSON(data: dataFromString)
                            let info = json[0];
                            dispatch_async(dispatch_get_main_queue()) {
                                if let lecturer = info["lecturer"].string {
                                    self.LabelMain.text = "Referent: "+lecturer
                                } else {
                                    print("Error missing lecturer")
                                }
                                if let course = info["course"].string {
                                    self.LabelMain.text = self.LabelMain.text!+"\nLV: "+course
                                } else {
                                    print("Error missing course")
                                }
                                if let location = info["location"].string {
                                    self.LabelMain.text = self.LabelMain.text!+"\nOrt: "+location
                                } else {
                                    print("Error missing location")
                                }
                                if let start = info["start"].string {
                                    self.LabelMain.text = self.LabelMain.text!+"\nZeit: "+start
                                } else {
                                    print("Error missing start")
                                }
                                if let end = info["end"].string {
                                    self.LabelMain.text = self.LabelMain.text!+" - "+end
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

