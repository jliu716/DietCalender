//
//  JLEventCell.swift
//  DietCalender
//
//  Created by Beethoven on 21/11/18.
//  Copyright © 2018 Jiayi Liu. All rights reserved.
//

import UIKit

class JLEventCell: UITableViewCell {

    @IBOutlet weak var categoryLine: UIView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    
    var event: Event! {
        didSet {
            titleLabel.text = event.title
            noteLabel.text = event.note
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            startTimeLabel.text = dateFormatter.string(from: event.startTime)
            endTimeLabel.text = dateFormatter.string(from: event.endTime)
            categoryLine.backgroundColor = event.categoryColor
        }
    }
    
}
