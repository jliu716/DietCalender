//
//  ViewController.swift
//  DietCalender
//
//  Created by Beethoven on 20/11/18.
//  Copyright © 2018 Jiayi Liu. All rights reserved.
//

import UIKit
import JTAppleCalendar
import SwipeCellKit
import ChameleonFramework
import RealmSwift
import FontAwesome_swift

class ViewController: SlidingTopViewController {
    
    let realm = try! Realm()
    let config : UserDefaults = UserDefaults.standard
    
    // MARK: Outlets
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showTodayButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    
    @IBOutlet weak var separatorViewTopConstraint: NSLayoutConstraint!
    
    // MARK: DataSource
    var scheduleGroup : [String: [Event]]? {
        didSet {
            calendarView.reloadData()
            tableView.reloadData()
        }
    }
    
    var events: [Event] {
        guard let selectedDate = calendarView.selectedDates.first else {
            return []
        }
        
        guard let data = scheduleGroup?[self.formatter.string(from: selectedDate)] else {
            return []
        }
        
        return data
    }
    
    var totalEvents : Results<Event>?
    
    // MARK: Config
    let formatter = DateFormatter()
    let dateFormatterString = "yyyy MM dd"
    let numOfRowsInCalendar = 6
    let calendarCellIdentifier = "CellView"
    let scheduleCellIdentifier = "detail"
    
    var iii: Date?
    
    // MARK: Helpers
    var numOfRowIsSix: Bool {
        get {
            return calendarView.visibleDates().outdates.count < 7
        }
    }
    
    var currentMonthSymbol: String {
        get {
            let startDate = (calendarView.visibleDates().monthDates.first?.date)!
            let month = Calendar.current.dateComponents([.month], from: startDate).month!
            let monthString = DateFormatter().monthSymbols[month-1]
            return monthString
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewNibs()
        
        showTodayButton.target = self
        showTodayButton.action = #selector(showTodayWithAnimate)
        showToday(animate: false)
        
        let gesturer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        calendarView.addGestureRecognizer(gesturer)
        
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer) {
        let point = gesture.location(in: calendarView)
        guard let cellStatus = calendarView.cellStatus(at: point) else {
            return
        }
        
        if calendarView.selectedDates.first != cellStatus.date {
            calendarView.deselectAllDates()
            calendarView.selectDates([cellStatus.date])
        }
    }
    
    func setupViewNibs() {
        let myNib = UINib(nibName: "JLCalenderCell", bundle: Bundle.main)
        calendarView.register(myNib, forCellWithReuseIdentifier: calendarCellIdentifier)
        
        
        let myNib2 = UINib(nibName: "JLEventCell", bundle: Bundle.main)
        tableView.register(myNib2, forCellReuseIdentifier: scheduleCellIdentifier)
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        
        let year = Calendar.current.component(.year, from: startDate)
        title = "\(year) \(currentMonthSymbol)"
    }
    
    // MARK:- IB Actions
    @IBAction func addButtonPressed(_ sender: Any) {
        var input : UITextField = UITextField()
        let alert = UIAlertController(title: "What did you eat?", message: "Enter name of the food(can be separated by comma)", preferredStyle: .alert)
        
        // action:YES
        let confirm = UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            
            let items = input.text!.split(separator: ",")
            for item in items {
                // allocate item
                let newItem : Event = Event(value: ["isSafe":true,"title" : item.trimmingCharacters(in: CharacterSet.whitespaces).capitalized, "startTime": Date()])
                if let asSafe : Bool = self.config.value(forKey: Constants.AutoFlagAsSafe) as? Bool {
                    newItem.isSafe = asSafe
                }
                
                // find out time stamp for this date
                let selectedDate : Date = self.calendarView.selectedDates[0]
                let startOfToday = Calendar.current.startOfDay(for: Date())
                let diffInDays : Int = Calendar.current.dateComponents([.day], from: startOfToday, to:selectedDate).day!
                newItem.startTime = Calendar.current.date(byAdding: .day, value: diffInDays, to: Date()) ?? Date()
                self.saveSomeObject(obejct: newItem)
            }
        })
        // action:NO
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "What did you eat?"
            alertTextField.spellCheckingType =  .yes
            alertTextField.autocorrectionType = .yes
            
            if let spellCheck : Bool = self.config.value(forKey: Constants.SpellCheckIsOn) as? Bool {
                alertTextField.spellCheckingType = spellCheck ? .yes : .no
            }
            
            if let autoCorrect : Bool = self.config.value(forKey: Constants.AutoCorrectIsOn) as? Bool {
                alertTextField.autocorrectionType = autoCorrect ? .yes : .no
            }
            input = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        if tableView.isEditing{
            if tableView!.indexPathsForSelectedRows != nil {
                presentActionSheet()
            }else{
                tableView.setEditing(false, animated: true)
            }
        }else{
            tableView.setEditing(true, animated: true)
        }
        let button : UIBarButtonItem = sender as! UIBarButtonItem
        button.title = tableView.isEditing ? "Action" : "Edit"
    }
    
    func presentActionSheet(){
        // TODO:- present alert as action sheet
        let alert = UIAlertController(title: "Bulk Action", message: nil, preferredStyle: .actionSheet)
        
        // action:YES
        let white = UIAlertAction(title: "Whitelist", style: .default, handler: { (action) in
            do {
                try self.realm.write({
                    for x : IndexPath in (self.tableView?.indexPathsForSelectedRows)! {
                        let event = self.events[x.row]
                        event.isRated = true
                        event.isSafe = true
                    }
                    self.getSchedule()
                })
                self.tableView.setEditing(false, animated: true)
            }catch{print("Unable to delete this event due to: \n \(error)")}
        })
        
        let black = UIAlertAction(title: "Blacklist", style: .default, handler: { (action) in
            do {
                try self.realm.write({
                    for x : IndexPath in (self.tableView?.indexPathsForSelectedRows)! {
                        let event = self.events[x.row]
                        event.isRated = true
                        event.isSafe = false
                    }
                    self.getSchedule()
                })
                self.tableView.setEditing(false, animated: true)
            }catch{print("Unable to delete this event due to: \n \(error)")}
        })
        
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler:{ (action) in
            do {
                try self.realm.write({
                    for x : IndexPath in (self.tableView?.indexPathsForSelectedRows)! {
                        let event = self.events[x.row]
                        self.realm.delete(event)
                    }
                    self.getSchedule()
                })
                self.tableView.setEditing(false, animated: true)
            }catch{print("Unable to delete this event due to: \n \(error)")}
        })
        
        // action:NO
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(white)
        alert.addAction(black)
        alert.addAction(delete)
        
        present(alert, animated: true, completion: nil)
    }
}


// MARK: Helpers
extension ViewController {
    func select(onVisibleDates visibleDates: DateSegmentInfo) {
        guard let firstDateInMonth = visibleDates.monthDates.first?.date else
        { return }
        
        if firstDateInMonth.isThisMonth() {
            calendarView.selectDates([Date()])
        } else {
            calendarView.selectDates([firstDateInMonth])
        }
    }
    
    // MARK:- SAVE AND LOAD 
    func saveSomeObject (obejct theObject:Object) {
        do {
            try realm.write {
                realm.add(theObject)
                self.getSchedule()
            }
            defer {
                if let next : Int = (self.events.index(of: (theObject as! Event))) {
                    self.tableView.insertRows(at: [IndexPath(item: next, section: 0)], with: .left)                    
                }else{
                    self.tableView.reloadData()
                    self.calendarView.reloadData()
                }
            }
        }catch{
            print("Error saving object to realm: \(error)")
        }
    }
}

// MARK: Button events
extension ViewController {
    @objc func showTodayWithAnimate() {
        showToday(animate: true)
    }
    
    func showToday(animate:Bool) {
        calendarView.scrollToDate(Date(), triggerScrollToDateDelegate: true, animateScroll: animate, preferredScrollPosition: nil, extraAddedOffset: 0) { [unowned self] in
            self.getSchedule()
            self.calendarView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
                self.setupViewsOfCalendar(from: visibleDates)
            }
            
            self.adjustCalendarViewHeight()
            self.calendarView.selectDates([Date()])
        }
    }
}

// MARK: Dynamic CalendarView's height
extension ViewController {
    func adjustCalendarViewHeight() {
        adjustCalendarViewHeight(higher: self.numOfRowIsSix)
    }
    
    func adjustCalendarViewHeight(higher: Bool) {
        separatorViewTopConstraint.constant = higher ? 0 : -calendarView.frame.height / CGFloat(numOfRowsInCalendar)
    }
}

// MARK: Prepere dataSource
extension ViewController {
    func getSchedule() {
        // fill schedule with events
        if let startDate = calendarView.visibleDates().monthDates.first?.date  {
            let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)
            getSchedule(fromDate: startDate, toDate: endDate!)
        }
    }
    
    
    func getSchedule(fromDate: Date, toDate: Date) {
        totalEvents = realm.objects(Event.self).filter(NSPredicate(format: "%@ < startTime AND startTime < %@", fromDate as CVarArg, toDate as CVarArg))
        // group events by day of month
        scheduleGroup = totalEvents?.group{self.formatter.string(from: $0.startTime)}
    }
}


// MARK: CalendarCell's ui config
extension ViewController {
    
    func numberOfUnratedEntriesForDate(date : Date) -> Int {
        let startDate = date
        let endDate = NSCalendar.current.date(byAdding: .hour, value: 24, to: startDate)
        let events = realm.objects(Event.self).filter(NSPredicate(format: "%@ < startTime AND startTime < %@ AND isRated == NO", startDate as CVarArg, endDate! as CVarArg))
        return events.count
    }
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let myCustomCell = view as? JLCalenderCell else { return }
        
        let numberLabel : UILabel = myCustomCell.notificationBadge
        numberLabel.layer.masksToBounds = true
        numberLabel.layer.cornerRadius = numberLabel.bounds.width / 2.0
        
        if !NSCalendar.current.isDateInToday(cellState.date) {
            let number = numberOfUnratedEntriesForDate(date: cellState.date)
            if ("\(number)" != "0"){
                numberLabel.isHidden = false
                numberLabel.text = "\(number)"
            }else{
                numberLabel.isHidden = true
            }
        }
        
        
        myCustomCell.dayLabel.text = cellState.text
        let cellHidden = cellState.dateBelongsTo != .thisMonth
        
        myCustomCell.isHidden = cellHidden
        
        if Calendar.current.isDateInToday(cellState.date) {
            myCustomCell.selectedView.backgroundColor = UIColor.flatGreen
        }else{
            myCustomCell.selectedView.backgroundColor = UIColor.black
        }
        
        handleCellTextColor(view: myCustomCell, cellState: cellState)
        handleCellSelection(view: myCustomCell, cellState: cellState)
        
        if let events = scheduleGroup?[formatter.string(from: cellState.date)] {
            myCustomCell.eventView.isHidden = false
            let badDay = events.contains { (x) -> Bool in
                return !x.isSafe
            }
            myCustomCell.eventView.backgroundColor = badDay ? UIColor.flatRed : UIColor.flatGreen
            myCustomCell.selectedView.backgroundColor = badDay ? UIColor.flatRed : UIColor.flatGreen
        }
        else {
            myCustomCell.eventView.isHidden = true
        }
    }
    
    func handleCellSelection(view: JLCalenderCell, cellState: CellState) {
        view.selectedView.isHidden = !cellState.isSelected
    }
    
    func handleCellTextColor(view: JLCalenderCell, cellState: CellState) {
        if cellState.isSelected {
            view.dayLabel.textColor = UIColor.white
        }
        else {
            view.dayLabel.textColor = UIColor.black
            if cellState.day == .sunday || cellState.day == .saturday {
                view.dayLabel.textColor = UIColor.gray
            }
        }
        
        if Calendar.current.isDateInToday(cellState.date) {
            if cellState.isSelected {
                view.dayLabel.textColor = UIColor.white
            }
            else {
                view.dayLabel.textColor = UIColor.flatGreen
            }
        }
    }
}

// MARK: JTAppleCalendarViewDataSource
extension ViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = dateFormatterString
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2030 02 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: numOfRowsInCalendar,
                                                 calendar: Calendar.current,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: .sunday,
                                                 hasStrictBoundaries: true)
        return parameters
    }
}

// MARK: JTAppleCalendarViewDelegate
extension ViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: calendarCellIdentifier, for: indexPath) as! JLCalenderCell
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: calendarCellIdentifier, for: indexPath) as! JLCalenderCell
        configureCell(view: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
        if visibleDates.monthDates.first?.date == iii {
            return
        }
        
        iii = visibleDates.monthDates.first?.date
        
        getSchedule()
        select(onVisibleDates: visibleDates)
        
        view.layoutIfNeeded()
        
        adjustCalendarViewHeight()
        
        UIView.animate(withDuration: 0.5) { [unowned self] in
            self.view.layoutIfNeeded()
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
        
        tableView.reloadData()
        tableView.contentOffset = CGPoint()
        
        // if date is in future, disable addButton
        let testcase = NSCalendar.current.compare(date, to: Date(), toGranularity: Calendar.Component.hour).rawValue
        if (testcase == 1){
            addButton.isEnabled = false
        }else{
            addButton.isEnabled = true
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
}

// MARK: UITableViewDataSource
extension ViewController : UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate{

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: scheduleCellIdentifier, for: indexPath) as! JLEventCell
        cell.selectionStyle = .blue
        cell.tintColor = UIColor.flatYellow
        cell.event = events[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        editButton.isEnabled = (events.count != 0)
        return events.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    // MARK:- table view cell interactions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let paths : [IndexPath] = tableView.indexPathsForSelectedRows ?? []
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        // initiate action when swipe from right
        guard orientation == .left else { return nil }
        
        // grab the event
        let event = events[indexPath.row]
                
        // delete
        let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
            do {
                try self.realm.write({ 
                    self.realm.delete(event)
                    self.getSchedule()
                })
            }catch{print("Unable to delete this event due to: \n \(error)")}
        }
        deleteAction.hidesWhenSelected = true
        deleteAction.image = UIImage(named: "trash")
        deleteAction.backgroundColor = UIColor.flatGrayDark
        
        // flag
        let flagActionSafe = SwipeAction(style: .default, title: nil) { (action, indexPath) in
            do {
                try self.realm.write({
                    event.isSafe = true
                    event.isRated = true
                })
                defer {
                    tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                    self.calendarView.reloadData()
                }
            }catch{
                print("Unable to flag this event due to: \n \(error)")
            }
        }
        flagActionSafe.hidesWhenSelected = true
        flagActionSafe.image = UIImage(named: "flag")
        flagActionSafe.backgroundColor = UIColor.flatGreen
        
        let flagActionUnsafe = SwipeAction(style: .default, title: nil) { (action, indexPath) in
            do {
                try self.realm.write({
                    event.isSafe = false
                    event.isRated = true
                })
                defer {
                    tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                    self.calendarView.reloadData()
                }
            }catch{
                print("Unable to flag this event due to: \n \(error)")
            }
        }
        flagActionUnsafe.hidesWhenSelected = true
        flagActionUnsafe.image = UIImage(named: "flag")
        flagActionUnsafe.backgroundColor = UIColor.flatRed
        
        return (event.isRated) ? [deleteAction, (event.isSafe ?  flagActionUnsafe : flagActionSafe)] : [deleteAction, flagActionUnsafe, flagActionSafe]
    }
}


