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
    
    @IBOutlet weak var testview: UIView!
    
    
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
        let slider : StepSlider = StepSlider.init(frame: CGRect(x: 10, y: 10, width: testview.frame.size.width-20.0, height: 44))
        slider.maxCount = 4
        slider.index = 1
        slider.trackColor = UIColor.flatWhite
        slider.sliderCircleImage = UIImage(named: "Circle-Border")
        slider.labels = ["12H", "20H", "24H", "48H"]
        slider.labelColor = UIColor.darkText
        slider.adjustLabel = true
        
        testview.addSubview(slider)
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
