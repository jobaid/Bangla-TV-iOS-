//
//  AppDelegate.swift
//  Bangla TV
//
//  Created by Jobaid on 9/28/16.
//  Copyright © 2016 Jobaid. All rights reserved.
//

import UIKit
import OneSignal
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
      
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "d186a243-b207-4754-8047-282585229bac", handleNotificationReceived: { (notification) in
            print("Received Notification - \(notification?.payload.notificationID)")
            }, handleNotificationAction: { (result) in
                
                // This block gets called when the user reacts to a notification received
                let payload = result?.notification.payload
                var fullMessage = payload?.title
                
                //Try to fetch the action selected
                if let actionSelected = result?.action.actionID {
                    fullMessage =  fullMessage! + "\nPressed ButtonId:\(actionSelected)"
                }
                
                print(fullMessage)
                
            }, settings: [kOSSettingsKeyAutoPrompt : true, kOSSettingsKeyInAppAlerts : true])
        
        OneSignal.registerForPushNotifications()
        
        OneSignal.IdsAvailable({ (userId, pushToken) in
            print("UserId:%@", userId)
            if (pushToken != nil) {
                print("pushToken:%@", pushToken)
            }
        })
        
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

