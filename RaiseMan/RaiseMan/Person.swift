//
//  Person.swift
//  RaiseMan
//
//  Created by Sweta on 25/09/18.
//  Copyright © 2018 Sweta. All rights reserved.
//

import Cocoa

class Person: NSObject {
    @objc dynamic var personName:String = "New Person"
    @objc dynamic var expectedRaise:Float = 0.05
    
    override func setNilValueForKey(_ key: String) {
        if key == "expectedRaise" {
            expectedRaise = 0.0
        }else{
            super.setNilValueForKey(key)
        }
    }
}
