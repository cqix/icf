//
//  ServerComm.swift
//  icf
//
//  Created by Christian Koller on 23.01.16.
//  Copyright © 2016 FH. All rights reserved.
//

import Foundation

class ServerComm {
    
    var sp:SpeedDataSource?
    var cs:ContentDataSource?
    var bs:BreakDataSource?
    let uuid = NSUUID().UUIDString
    
    var lecturer:String?
    var endTime:String?
    
    static let sharedInstance = ServerComm()
    
    func setup(sp:SpeedDataSource, cs:ContentDataSource, bs:BreakDataSource) {
        self.sp = sp
        self.cs = cs
        self.bs = bs
    }
    
    func send()
    {
        let urlComponents = NSURLComponents(string: "http://localhost:7777/vote")!
        urlComponents.queryItems = [
            NSURLQueryItem(name: "token", value: uuid),
            NSURLQueryItem(name: "lecturer", value: lecturer),
            NSURLQueryItem(name: "time", value: endTime),
            NSURLQueryItem(name: "speed", value: String(sp!.getSavedIndex())),
            NSURLQueryItem(name: "content", value: String(cs!.getSavedIndex())),
            NSURLQueryItem(name: "break", value: String(bs!.getSavedIndex()))
        ]
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