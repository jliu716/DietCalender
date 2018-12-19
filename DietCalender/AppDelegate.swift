//
//  AppDelegate.swift
//  DietCalender
//
//  Created by Beethoven on 20/11/18.
//  Copyright © 2018 Jiayi Liu. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import ECSlidingViewController
import FontAwesome_swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window : UIWindow?
    let formatter = DateFormatter()
    let dateFormatterString = "yyyy MM dd"
    var slidingViewController : ECSlidingViewController?
    let config : UserDefaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // configure dateformatter
        formatter.dateFormat = dateFormatterString
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        // Override point for customization after application launch.
        do {
            _ = try Realm()
            print("Realm Database location: ",Realm.Configuration.defaultConfiguration.fileURL!)
        } catch {
            print("Realm Initiation Error: \(error)")
        }
        
        // notifi
        askForAllowNotification()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        
        // setup window with master detail view controllers
        window = UIWindow(frame: UIScreen.main.bounds)
        
        //
        let storyboard : UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let topVC : ViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let underVC : MasterViewController = storyboard.instantiateViewController(withIdentifier: "MasterViewController") as! MasterViewController
        
        
        let navigationController : UINavigationController = UINavigationController(rootViewController: topVC)
        navigationController.navigationBar.barStyle = .default
        navigationController.navigationBar.tintColor = UIColor.black
        let menu : UIBarButtonItem = UIBarButtonItem(title: String.fontAwesomeIcon(name: FontAwesome.bars), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.anchorRight))
        menu.setTitleTextAttributes([NSAttributedString.Key.font:UIFont.fontAwesome(ofSize: 20.0, style: FontAwesomeStyle.solid)], for: UIControl.State.normal)
        topVC.navigationItem.leftBarButtonItem  = menu;
        
        self.slidingViewController = ECSlidingViewController.sliding(withTopViewController: navigationController)
        self.slidingViewController?.underLeftViewController = underVC
        
//        navigationController.view.addGestureRecognizer((self.slidingViewController?.panGesture)!)
        
        self.slidingViewController?.anchorRightPeekAmount  = 150.0;
        self.slidingViewController?.anchorLeftRevealAmount = 250.0;
        
        self.window?.rootViewController = self.slidingViewController
        
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    @objc func anchorRight() {
        let masterVisible : Bool = self.slidingViewController?.underLeftViewController?.view.isTopViewInWindow() ?? false
        if masterVisible {
            self.slidingViewController?.resetTopView(animated: true)
        }else{
            self.slidingViewController?.anchorTopViewToRight(animated: true)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // schedule notifications for tomorrow
        self.scheduleNotificationForTomorrow()
    }
    
    // MARK:- HANDLE NOTIFICATIONS
    
    func scheduleNotificationForTomorrow(){
        var food = "KFC"
        do {
            let realm = try Realm()
            // find latest unrated food entry
            if let foodLast = realm.objects(Event.self).filter(NSPredicate(format: "isRated == NO")).sorted(byKeyPath: "startTime").last {
                // is it today
                if (NSCalendar.current.isDateInToday(foodLast.startTime)) {
                    food = foodLast.title
                    let notificationID : String = self.formatter.string(from: foodLast.startTime)
                    
                    // create notification
                    let content = UNMutableNotificationContent()
                    
                    //adding title, subtitle, body and badge
                    content.title = "\(food)"
                    content.body = "Do you want to whitelist \(food) you had yesterday?"
                    content.badge = 1
                    content.sound = UNNotificationSound.defaultCritical
                    
                    //it will be triggered after 20 hours
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600 * 20, repeats: false)
                    
                    //getting the notification request
                    let request = UNNotificationRequest(identifier: "\(notificationID)", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().delegate = self
                    
                    //adding the notification to notification center
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                        if let error = error {
                            print("can't add notification due to:\n\t\(error)")
                        }else{
                            print("notification added:\n\t\(notificationID)\t")
                        }
                    })
                }
            }
        } catch {
            print("Realm Initiation Error: \(error)")
        }
    }
    
    func intervalToScheduleANotification(timeStamp:Date) -> TimeInterval {
        var defaultInterval : Double = 3600 * 20
        
        let six_today : Date = NSCalendar.current.date(bySettingHour: 6,minute: 0, second: 0, of: Date())!
        let nine_today : Date = NSCalendar.current.date(bySettingHour: 9,minute: 0, second: 0, of: Date())!
        let twelve_today : Date = NSCalendar.current.date(bySettingHour: 12,minute: 0, second: 0, of: Date())!
        let twenty_today : Date = NSCalendar.current.date(bySettingHour: 20,minute: 0, second: 0, of: Date())!
        
        if six_today <= timeStamp && timeStamp < nine_today {
            defaultInterval = 3600 * 8 // breakfast
        }else if nine_today <= timeStamp && timeStamp < twelve_today {
            defaultInterval = 3600 * 24 // lunch
        }else if twelve_today <= timeStamp && timeStamp < twenty_today {
            defaultInterval = 3600 * 20 // dinner
        }
        
        return defaultInterval
    }
    
    func askForAllowNotification(){
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if(settings.authorizationStatus != .authorized)
            {
                print("Push not authorized yet")
                //requesting for authorization
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
                    self.config.setValue(didAllow, forKey: Constants.NotificationIsOn)
                })
            }
            else
            {
                print("Push notification enabled!")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // potentially useful contents of response
        /*
        response.actionIdentifier
        response.notification.date
        response.notification.request.content.badge
        response.notification.request.identifier
        */
//        print("user reacted to notification:\n\(response)")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // clear the icon badge number
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // auto-tag events over 36 hours and unrated
        do {
            let realm = try Realm()
            try realm.write {
                let expirateDate = NSCalendar.current.date(byAdding: .hour, value: -48, to: Date())
                let expiraePredicate = NSPredicate(format: "startTime < %@ AND isRated == NO", expirateDate! as CVarArg)
                let totalEvents : Results<Event> = realm.objects(Event.self).filter(expiraePredicate)
                for x in totalEvents {
                    x.isRated = true
                }
            }
        } catch {}
        
        // check if notification is scheduled to today, if YES then cancel it
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            for req in requests {
                if let dateIssued : Date = self.formatter.date(from: req.identifier) {
                    if NSCalendar.current.isDateInToday(dateIssued){
                        center.removePendingNotificationRequests(withIdentifiers: [req.identifier])
                    }
                }
            }
            
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

