//
//  Event.swift
//  DietCalender
//
//  Created by Beethoven on 21/11/18.
//  Copyright © 2018 Jiayi Liu. All rights reserved.
//

import Foundation

import UIKit

struct Event {
    var title: String
    var note: String
    var startTime: Date
    var endTime: Date
    var categoryColor: UIColor
}

// random events
extension Event {
    init(fromStartDate: Date) {
        title = ["Meet Willard", "Buy a milk", "Read a book"].randomElement()!
        note = ["hurry", "In office", "In New york city"].randomElement()!
        categoryColor = [.red, .orange, .purple, .blue, .black].randomElement()!
        
        let day = [Int](0...27).randomElement()!
        let hour = [Int](0...23).randomElement()!
        let startDate = Calendar.current.date(byAdding: .day, value: day, to: fromStartDate)!
        
        
        startTime = Calendar.current.date(byAdding: .hour, value: hour, to: startDate)!
        endTime = Calendar.current.date(byAdding: .hour, value: 1, to: startTime)!
    }
}


extension Event : Equatable {
    static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs.startTime == rhs.startTime
    }
}

extension Event : Comparable {
    static func <(lhs: Event, rhs: Event) -> Bool {
        return lhs.startTime < rhs.startTime
    }
}
