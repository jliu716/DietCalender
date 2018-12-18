//
//  SettingsViewController.swift
//  DietCalender
//
//  Created by Beethoven on 14/12/18.
//  Copyright © 2018 Jiayi Liu. All rights reserved.
//

import UIKit
import FontAwesome_swift
import StepSlider
import ChameleonFramework

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var sliderViewOne: UIView!
    @IBOutlet weak var sliderViewTwo: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawNavigationBar()
        drawStepSlider()
    }
    
    
    func drawNavigationBar(){
        let menu : UIBarButtonItem = UIBarButtonItem(title: String.fontAwesomeIcon(name: FontAwesome.bars), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.anchorRight))
        menu.setTitleTextAttributes([NSAttributedString.Key.font:UIFont.fontAwesome(ofSize: 20.0, style: FontAwesomeStyle.solid)], for: UIControl.State.normal)
        menu.setTitleTextAttributes([NSAttributedString.Key.font:UIFont.fontAwesome(ofSize: 18.0, style: FontAwesomeStyle.solid)], for: UIControl.State.highlighted)

        self.navigationItem.leftBarButtonItem = menu
    }
    
    func drawStepSlider(){
        // auto-flag
        let sliderOne : StepSlider = StepSlider.init(frame: CGRect(x: 10, y: 10, width: sliderViewOne.frame.size.width-20.0, height: 44))
        sliderOne.maxCount = 4
        sliderOne.index = 1
        sliderOne.trackColor = UIColor.flatWhite
        sliderOne.sliderCircleImage = UIImage(named: "Circle-Border")
        sliderOne.labels = ["12H", "20H", "24H", "48H"]
        sliderOne.labelColor = UIColor.darkText
        sliderOne.adjustLabel = true
        
        sliderViewOne.addSubview(sliderOne)
        
        // notfication
        let sliderTwo : StepSlider = StepSlider.init(frame: CGRect(x: 10, y: 10, width: sliderViewOne.frame.size.width-20.0, height: 44))
        sliderTwo.maxCount = 4
        sliderTwo.index = 1
        sliderTwo.trackColor = UIColor.flatWhite
        sliderTwo.sliderCircleImage = UIImage(named: "Circle-Border")
        sliderTwo.labels = ["12H", "16H", "20H", "24H"]
        sliderTwo.labelColor = UIColor.darkText
        sliderTwo.adjustLabel = true
        
        sliderViewTwo.addSubview(sliderTwo)
    }
    
    @objc func anchorRight() {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.anchorRight()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
