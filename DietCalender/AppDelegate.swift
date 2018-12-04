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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        do {
            _ = try Realm()
            print("Realm Database location: ",Realm.Configuration.defaultConfiguration.fileURL!)
        } catch {
            print("Realm Initiation Error: \(error)")
        }
        
        askForAllowNotification()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        // schedule notifications for tomorrow
        
        scheduleNotificationForTomorrow()
        
        print("successfully scheduled notification!")
    }
    
    func scheduleNotificationForTomorrow(){
        // fetch latest food had from realm, if it is in today
        let food = "KFC Fried Chicken"
        
        // create notification
        let content = UNMutableNotificationContent()
        
        //adding title, subtitle, body and badge
        content.title = "How was the \(food) you had yesterday?"
        content.subtitle = "Food Rating"
        content.body = "\(food)"
        content.badge = 1
        
        //it will be called after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: "joytest", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        
        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
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
    
    func hasNotificationBeenScheduled() -> Bool {
        
        
        
        return false
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

