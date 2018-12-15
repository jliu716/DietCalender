//
//  FoodListViewController.swift
//  DietCalender
//
//  Created by Beethoven on 28/11/18.
//  Copyright © 2018 Jiayi Liu. All rights reserved.
//

import UIKit
import ChameleonFramework
import RealmSwift
import FontAwesome_swift

class FoodListViewController: UIViewController {

    // 
    let realm = try! Realm()
    
    // TODO:- ib outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    
    // TODO:- vars 
    
    
    // MARK: DataSource
    var foodGroup : [[Event]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawButtons()
        drawNavigationBar()
        
        // assign deletegates
        self.searchBar.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.contentInset.top = 5.0

        // register nibs
        let cellNib = UINib(nibName: "FoodStatsCell", bundle: Bundle.main)
        tableView.register(cellNib, forCellReuseIdentifier: "FoodCell")
        
        // TODO:- configure looks
        self.loadData()
    }
    
    func drawButtons() {
        filterButton.title = String.fontAwesomeIcon(name: FontAwesome.filter)
        filterButton.setTitleTextAttributes([NSAttributedString.Key.font:UIFont.fontAwesome(ofSize: 20.0, style: FontAwesomeStyle.solid)], for: UIControl.State.normal)
    }
    
    func drawNavigationBar(){
        let menu : UIBarButtonItem = UIBarButtonItem(title: String.fontAwesomeIcon(name: FontAwesome.bars), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.anchorRight))
        menu.setTitleTextAttributes([NSAttributedString.Key.font:UIFont.fontAwesome(ofSize: 20.0, style: FontAwesomeStyle.solid)], for: UIControl.State.normal)
        menu.setTitleTextAttributes([NSAttributedString.Key.font:UIFont.fontAwesome(ofSize: 18.0, style: FontAwesomeStyle.solid)], for: UIControl.State.highlighted)
        self.navigationItem.leftBarButtonItem = menu
    }
    
    @objc func anchorRight() {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.anchorRight()
    }
    
    // TODO:- load foods 
    func loadData(with predicate:NSPredicate = NSPredicate(), filtered:Bool = false){
        var totalEvents : Results<Event> = realm.objects(Event.self)
        if (filtered){
            totalEvents = totalEvents.filter(predicate)
        }
        foodGroup = []
        let group = totalEvents.group{$0.title.trimmingCharacters(in: CharacterSet.whitespaces).lowercased()}
        group.forEach { (arg: (key: String, value: [Event])) in            
            let (_, value) = arg
            foodGroup.append(value)
        }
        self.tableView.reloadData()
    }
    
    // TODO:- ib actions
    @IBAction func filterPressed(_ sender: Any) {
        // TODO:- present alert as action sheet
        let alert = UIAlertController(title: "Filter", message: nil, preferredStyle: .actionSheet)
        
        // action:YES
        let white = UIAlertAction(title: "Whitelist Only", style: .default, handler: { (action) in    
            self.loadData(with: NSPredicate(format: "isSafe == YES"), filtered: true)
        })
        
        let black = UIAlertAction(title: "Blacklist Only", style: .default, handler: { (action) in    
            self.loadData(with: NSPredicate(format: "isSafe == NO"), filtered: true)
        })
        
        // action:NO
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(white)
        alert.addAction(black)
                
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func goToCalenderPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

extension FoodListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodGroup.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : FoodStatsCell = tableView.dequeueReusableCell(withIdentifier: "FoodCell") as! FoodStatsCell

        // cell appearance
        cell.safeScoreLabel.layer.masksToBounds = true
        cell.unsafeScoreLabel.layer.masksToBounds = true
        cell.safeScoreLabel.layer.cornerRadius = cell.safeScoreLabel.bounds.width / 2.0
        cell.unsafeScoreLabel.layer.cornerRadius = cell.unsafeScoreLabel.bounds.width / 2.0
        
        
        // context
        let items : [Event] = foodGroup[indexPath.row]
        
        cell.titleLabel.text = items[0].title
        
        let safeCount = items.group{$0.isSafe}[true]?.count
        let unsafeCount = items.group{$0.isSafe}[false]?.count

        cell.safeScoreLabel.text = "\(safeCount ?? 0)"
        cell.unsafeScoreLabel.text = "\(unsafeCount ?? 0)"
        
        // cell appearance
        if ("\(safeCount ?? 0)" == "0") {
            cell.safeScoreLabel.backgroundColor = UIColor.white
            cell.safeScoreLabel.layer.borderWidth = 1
            cell.safeScoreLabel.layer.borderColor = UIColor.flatGreen.cgColor
            cell.safeScoreLabel.textColor = UIColor.flatGreen
        }else{
            cell.safeScoreLabel.backgroundColor = UIColor.flatGreen
            cell.safeScoreLabel.layer.borderColor = UIColor.flatGreen.cgColor
            cell.safeScoreLabel.textColor = UIColor.white
        }
        
        if ("\(unsafeCount ?? 0)" == "0") {
            cell.unsafeScoreLabel.backgroundColor = UIColor.white
            cell.unsafeScoreLabel.layer.borderWidth = 1
            cell.unsafeScoreLabel.layer.borderColor = UIColor.flatRed.cgColor
            cell.unsafeScoreLabel.textColor = UIColor.flatRed
        }else{
            cell.unsafeScoreLabel.backgroundColor = UIColor.flatRed
            cell.unsafeScoreLabel.layer.borderColor = UIColor.flatRed.cgColor
            cell.unsafeScoreLabel.textColor = UIColor.white
        }
        
        

        return cell
    
    }
}

extension FoodListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension FoodListViewController: UISearchBarDelegate {
    
    // TODO:- user is typing
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (!searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
            loadData(with: NSPredicate(format: "title CONTAINS[cd] %@", searchText), filtered: true)
        }else{
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            self.loadData()
        }
    }
    
}

