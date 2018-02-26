//
//  Data.swift
//  Accelerometer
//
//  Created by Kushal Ashok on 2/25/18.
//  Copyright © 2018 Kushal Ashok. All rights reserved.
//

import UIKit
import RealmSwift
import Foundation

class Data: Object, RealmObject {
    @objc dynamic var date = Date()
    @objc dynamic var dateString = ""
    @objc dynamic var xAcceleration = 0.0
    @objc dynamic var yAcceleration = 0.0
    @objc dynamic var zAcceleration = 0.0
    @objc dynamic var xZeroCrossings = 0
    @objc dynamic var yZeroCrossings = 0
    @objc dynamic var zZeroCrossings = 0
    
    override class func primaryKey() -> String {
        return "dateString"
    }
}
