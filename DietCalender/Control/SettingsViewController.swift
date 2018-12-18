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
    
    @IBOutlet weak var autoFlagSegmentControl: UISegmentedControl!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    let config : UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadUserSettings()
        drawNavigationBar()
        drawStepSlider()
    }
    
    func reloadUserSettings(){
        if (config.value(forKey: Constants.Config.AutoFlagAsSafe) == nil) {
            config.setValue(true, forKey: Constants.Config.AutoFlagAsSafe)
        }
        
        if (config.value(forKey: Constants.Config.AutoFlagWindow) == nil) {
            config.setValue(3, forKey: Constants.Config.AutoFlagWindow)
        }
        
        if (config.value(forKey: Constants.Config.NotificationIsOn) == nil) {
            config.setValue(true, forKey: Constants.Config.NotificationIsOn)
        }
        
        if (config.value(forKey: Constants.Config.NotificationInterval) == nil) {
            config.setValue(1, forKey: Constants.Config.NotificationInterval)
        }
        
        defer{
            autoFlagSegmentControl.selectedSegmentIndex = (config.value(forKey: Constants.Config.AutoFlagAsSafe) as! Bool == true) ? 0 : 1
            
            notificationSwitch.setOn(config.value(forKey: Constants.Config.NotificationIsOn) as! Bool, animated: false)
        }

        
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
        sliderOne.index = config.value(forKey: Constants.Config.AutoFlagWindow) as! UInt
        sliderOne.trackColor = UIColor.flatWhite
        sliderOne.sliderCircleImage = UIImage(named: "Circle-Border")
        sliderOne.labels = ["12H", "20H", "24H", "48H"]
        sliderOne.labelColor = UIColor.darkText
        sliderOne.adjustLabel = true
        
        sliderViewOne.addSubview(sliderOne)
        sliderOne.enableHapticFeedback = true
        sliderOne.addTarget(self, action: #selector(self.sliderOneChanged(sender:)), for: UIControl.Event.valueChanged)
        
        // notfication
        let sliderTwo : StepSlider = StepSlider.init(frame: CGRect(x: 10, y: 10, width: sliderViewOne.frame.size.width-20.0, height: 44))
        sliderTwo.maxCount = 4
        sliderTwo.index = config.value(forKey: Constants.Config.NotificationInterval) as! UInt
        sliderTwo.trackColor = UIColor.flatWhite
        sliderTwo.sliderCircleImage = UIImage(named: "Circle-Border")
        sliderTwo.labels = ["12H", "16H", "20H", "24H"]
        sliderTwo.labelColor = UIColor.darkText
        sliderTwo.adjustLabel = true
        sliderTwo.enableHapticFeedback = true
        sliderTwo.addTarget(self, action: #selector(self.sliderTwoChanged(sender:)), for: UIControl.Event.valueChanged)
        
        sliderViewTwo.addSubview(sliderTwo)
    }
    
    @objc func sliderOneChanged(sender:StepSlider) {
        config.setValue(sender.index, forKey: Constants.Config.AutoFlagWindow)
    }
    
    @objc func sliderTwoChanged(sender:StepSlider) {
        config.setValue(sender.index, forKey: Constants.Config.NotificationInterval)
    }
    
    @objc func anchorRight() {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.anchorRight()
    }
    
    // MARK:- handle IB Actions
    @IBAction func autoFlagSegmentFlipped(_ sender: Any) {
        
    }
    
    @IBAction func notificationSwitchFlipped(_ sender: Any) {
        
    }
    

}
