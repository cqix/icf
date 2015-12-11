//
//  icfTests.swift
//  icfTests
//
//  Created by Patrick Gröller, Christian Koller, Helmut Kopf on 20.10.15.
//  Copyright © 2015 FH. All rights reserved.
//

import XCTest
@testable import icf

class icfTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let expectation = expectationWithDescription("Whatever")
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            print("Start")
            sleep(4)
            print("End")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5) { (err: NSError?) in
            if let e=err{
                print("We wait, but timeout \(e)")
            } else {
                print("OK")
            }
        }
        print("Note done")

        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            sleep(arc4random_uniform(4) + 1)
        }
    }
    
}
