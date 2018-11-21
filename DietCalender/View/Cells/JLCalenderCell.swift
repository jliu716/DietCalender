//
//  JLCalenderCell.swift
//  DietCalender
//
//  Created by Beethoven on 21/11/18.
//  Copyright © 2018 Jiayi Liu. All rights reserved.
//

import UIKit
import JTAppleCalendar

class JLCalenderCell: JTAppleCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var selectedView: UIView!
    
}

