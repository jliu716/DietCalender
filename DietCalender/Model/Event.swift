//
//  Event.swift
//  DietCalender
//
//  Created by Beethoven on 21/11/18.
//  Copyright © 2018 Jiayi Liu. All rights reserved.
//

import Foundation
import ChameleonFramework
import RealmSwift

// random events
class Event : Object{
    @objc dynamic var title : String = ""
    @objc dynamic var startTime : Date = Date()
    @objc dynamic var isSafe : Bool = true
    @objc dynamic var isRated : Bool = false
}
