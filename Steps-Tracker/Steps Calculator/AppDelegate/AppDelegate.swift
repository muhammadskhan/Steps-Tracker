//
//  AppDelegate.swift
//  Steps Calculator
//
//  Created by Haseeb Javed on 24/08/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import UIKit
import FirebaseCore
import UserNotifications
import FirebaseMessaging
import GoogleMobileAds
import IQKeyboardManagerSwift
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        

        dataManager.noOfOpens += 1
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        FirebaseApp.configure()
        
        //push notifications
        Messaging.messaging().delegate = self
        registerForPushNotifications(application: application)
        GetDocumentRef().getDocumentRef { (res) in } failure: { (err) in }
        navigationManager.showCustomLaunch()
        SVProgressHUD.setDefaultMaskType(.black)
        window?.makeKeyAndVisible()
        
        healthKitManager.observeHealthKitInBackground(application)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        IQKeyboardManager.shared.enable = true
        purchasesManager.configureSDK()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    
    private func registerForPushNotifications(application: UIApplication) {
        
        let center  = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
            if error == nil{
                DispatchQueue.main.async(execute: {
                    application.registerForRemoteNotifications()
                })
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    //MARK:- UNUser Notification Delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo)
    }
    
    //MARK:- Messaging Delegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        defaults.setValue(fcmToken, forKey: "fcmToken")
        fsManager.updateFCMToken()
    }
}

extension AppDelegate {
    
    //User can recieve the notification even if the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
    }
}
