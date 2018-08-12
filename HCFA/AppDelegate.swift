//
//  AppDelegate.swift
//  HCFA
//
//  Created by Collin Price on 12/28/17.
//  Copyright © 2017 Collin Price. All rights reserved.
//

import UIKit
import AWSCore
import AWSMobileClient
import UserNotifications
import EventKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        registerForPushNotifications()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Navigation bar appearances
        let barAppearance = UINavigationBar.appearance()
        barAppearance.barTintColor = redColor
        barAppearance.backgroundColor = redColor
        barAppearance.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.white,
             NSAttributedStringKey.font: UIFont(name: "Montserrat-Medium", size: window!.frame.width/18)!]
        
        // Navigation bar button appearances
        let itemAppearance = UIBarButtonItem.appearance()
        itemAppearance.tintColor = .white
        itemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white,
                                               NSAttributedStringKey.font: UIFont(name: "Montserrat-Medium",
                                                                                  size: window!.frame.width/24)!],
                                              for: .normal)
        itemAppearance.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Montserrat-Medium",
                                                                                  size: window!.frame.width/24)!],
                                              for: .highlighted)
        
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            let aps = notification["aps"] as! [String: AnyObject]
            print(aps)
        }
        
        window?.rootViewController = SignInVC()
        window?.makeKeyAndVisible()
        
        // Instantiate AWSMobileClient to establish AWS user credentials
        return AWSMobileClient.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application( _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                      fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        print(aps)
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let loadedToken = tokenParts.joined()

        print("Device Token: \(loadedToken)")
        
        defaults.set(loadedToken, forKey: "loadedAPNToken")
        
        if let userToken = defaults.string(forKey: "userAPNToken") {
            let uid = defaults.integer(forKey: "uid")
            if loadedToken != userToken && uid != 0 {
                API.updateAPNToken(uid: 0, token: defaults.string(forKey: "token")!, apnToken: loadedToken) {
                    response, data in
                    
                    if response == .Success {
                        defaults.set(loadedToken, forKey: "userAPNToken")
                    }
                }
            }
        }
        
        EKEventStore().requestAccess(to: .event, completion: {_, _ in })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 1. Print out error if PNs registration not successful
        print("Failed to register for remote notifications with error: \(error)")
        
        EKEventStore().requestAccess(to: .event, completion: {_, _ in })
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted for push notifications: \(granted)")
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
