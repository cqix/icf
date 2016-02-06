//
//  ServerComm.swift
//  icf
//
//  Created by Patrick Gröller, Christian Koller, Helmut Kopf on 21.10.15.
//  Copyright © 2016 FH. All rights reserved.
//
// Sends requests to the server
import Foundation

class ServerComm {
    
    var sp:SpeedDataSource?
    var cs:ContentDataSource?
    var bs:BreakDataSource?
    let uuid = NSUUID().UUIDString
    
    var lecturer:String?
    var endTime:String?
    
    static let sharedInstance = ServerComm()
    
    //Setup data sources
    func setup(sp:SpeedDataSource, cs:ContentDataSource, bs:BreakDataSource) {
        self.sp = sp
        self.cs = cs
        self.bs = bs
    }
    
    //Send to server
    func send()
    {
        let urlComponents = NSURLComponents(string: CommSettings.address+"/vote")!
        urlComponents.queryItems = [
            NSURLQueryItem(name: "token", value: uuid),
            NSURLQueryItem(name: "lecturer", value: lecturer),
            NSURLQueryItem(name: "time", value: endTime),
            NSURLQueryItem(name: "speed", value: String(sp!.getSavedIndex()+1)),
            NSURLQueryItem(name: "content", value: String(cs!.getSavedIndex()+1)),
            NSURLQueryItem(name: "break", value: String(bs!.getSavedIndex()+1))
        ]
        print("Url \(urlComponents)")
        dispatch_async(
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                print("block executed in the background.")
                if let url = urlComponents.URL {
                    do {
                        let contents = try  String(contentsOfURL: url)
                        print("We got: "+contents)
                        
                    } catch let error {
                        print("Error \(error)")
                    }
                } else {
                    print("Url is invalid")
                }
            }
        )
    }
    
    func setLecturer(lec:String) {
        self.lecturer = lec
    }

    func setEndTime(et:String) {
        self.endTime = et
    }

}