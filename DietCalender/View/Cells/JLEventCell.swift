//
//  JLEventCell.swift
//  DietCalender
//
//  Created by Beethoven on 21/11/18.
//  Copyright © 2018 Jiayi Liu. All rights reserved.
//

import UIKit
import SwipeCellKit
import ChameleonFramework

class JLEventCell: SwipeTableViewCell {

    @IBOutlet weak var categoryLine: UIView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var event: Event! {
        didSet {
            titleLabel.text = event.title
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            startTimeLabel.text = dateFormatter.string(from: event.startTime)
            categoryLine.backgroundColor = event.isRated ? (event.isSafe ? UIColor.flatGreen : UIColor.flatRed) : UIColor.flatYellow
            
            self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
}
