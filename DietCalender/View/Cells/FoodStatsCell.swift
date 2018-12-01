//
//  FoodStatsCell.swift
//  DietCalender
//
//  Created by Beethoven on 30/11/18.
//  Copyright © 2018 Jiayi Liu. All rights reserved.
//

import UIKit
import ChameleonFramework

class FoodStatsCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var safeScoreLabel: UILabel!
    @IBOutlet weak var unsafeScoreLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
