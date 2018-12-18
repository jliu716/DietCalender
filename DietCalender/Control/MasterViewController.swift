//
//  MasterViewController.swift
//  DietCalender
//
//  Created by Beethoven on 14/12/18.
//  Copyright © 2018 Jiayi Liu. All rights reserved.
//

import UIKit
import FontAwesome_swift

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var items : [[[String:String]]] = []
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMenu()
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func loadMenu(){
        items = [
            [
                ["icon":String.fontAwesomeIcon(name: FontAwesome.calendarAlt), "title":"Calender", "vc":"ViewController"],
                ["icon":String.fontAwesomeIcon(name: FontAwesome.chartBar), "title":"Food Stats", "vc":"FoodListViewController"],
            ],
            [
                ["icon":String.fontAwesomeIcon(name: FontAwesome.cog), "title":"Configuration", "vc":"SettingsViewController"]
            ],
            [
                ["icon":String.fontAwesomeIcon(name: FontAwesome.lifeRing), "title":"Help", "vc":"TutorialViewController"],
                ["icon":String.fontAwesomeIcon(name: FontAwesome.info), "title":"About", "vc":"AboutViewController"]
            ]
        ]
    }
    
    
    // MARK:- TABLE VIEW PROTOCOLS
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "   User Data"
        case 1:
            return "   Settings"
        case 2:
            return "   Help"
        default:
            return "   1"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : MasterTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MasterTableViewCell
        
        let item : [String:String] = items[indexPath.section][indexPath.row]
        
        cell.titleLabel.text = item["title"]
        cell.iconLabel.text = item["icon"]
        cell.iconLabel.font = UIFont.fontAwesome(ofSize: 20.0, style: FontAwesomeStyle.solid)
        
        return cell
    }

    
    // MARK:- handle navigation to other VC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item : [String:String] = items[indexPath.section][indexPath.row]
        let vc : String = item["vc"] ?? "ViewController"
        let storyboard : UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let destVC : UIViewController = storyboard.instantiateViewController(withIdentifier: vc)
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let nav : UINavigationController = delegate.slidingViewController?.topViewController as! UINavigationController
        
        if let topVC : String = nav.topViewController?.restorationIdentifier {
            if topVC != vc {
                nav.show(destVC, sender: self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    delegate.slidingViewController?.resetTopView(animated: true)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
