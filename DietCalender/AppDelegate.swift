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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let formatter = DateFormatter()
    let dateFormatterString = "yyyy MM dd"
    
    
    
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
        
        return true
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
    
    func askForAllowNotification(){
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if(settings.authorizationStatus != .authorized)
            {
                print("Push not authorized yet")
                //requesting for authorization
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
                    print("Fail to get notification allowed")
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
        print("user reacted to notification:\n\(response)")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("application becomes active!")
        UIApplication.shared.applicationIconBadgeNumber = 0
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            if requests.count > 0 {
                print("There is already notification scheduled!")
                center.removeAllPendingNotificationRequests()
            }
            
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

