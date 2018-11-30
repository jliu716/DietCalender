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

class FoodListViewController: UIViewController {

    // 
    let realm = try! Realm()
    
    // TODO:- ib outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // TODO:- vars 
    
    
    // MARK: DataSource
    var foodGroup : [[Event]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // assign deletegates
        self.searchBar.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // TODO:- configure looks
        self.loadData()
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
        
        })
        
        let black = UIAlertAction(title: "Blacklist Only", style: .default, handler: { (action) in    
            
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

extension FoodListViewController: UIActionSheetDelegate {
    
}

extension FoodListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(foodGroup.count)
        return foodGroup.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "FoodCell")!
        
        let items : [Event] = foodGroup[indexPath.row]
        
        cell.textLabel?.text = items[0].title
        cell.detailTextLabel?.text = "\(items.count)"

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

