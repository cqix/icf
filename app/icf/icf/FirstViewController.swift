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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*
        let urlString = "https://de.wikipedia.org/w/index.php?title=Fubar&printable=yes"
        dispatch_async(
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                print("block executed in the background.")
                if let url = NSURL(string: urlString) {
                    do {
                        let contents = try  String(contentsOfURL: url)
                            print("We got: "+contents)
                            dispatch_async(dispatch_get_main_queue()) {
                                self.LabelMain.text = contents
                                
                                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                            }
                        
                    } catch let error {
                        print("Error \(error)")
                    }
                } else {
                    print("Url is invalid")
                }
            }
        )
        */
        LabelMain.text = "UUID: "+uuid
        
        //Send after 10 seconds
        let localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertAction = "Testing notifications on iOS8"
        localNotification.alertBody = "Local notifications are working"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 10)
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.category = "invite"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

