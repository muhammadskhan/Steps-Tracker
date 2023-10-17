//
//  LocalNotificationManager.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 05/10/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import Foundation
import NotificationCenter
let notificationManager = NotificationManager.shared

class NotificationManager: NSObject {
    
    static let shared = NotificationManager()
    
    private override init() {
        
    }
    
    func stepsTargetCompleted(stepsTaken: Int) {
        
        //creating the notification content
        let content = UNMutableNotificationContent()

        //adding title, subtitle, body and badge
        content.title = Constants.appName
        content.subtitle = "Congrats 👏"
        content.body = "You have completed your steps 🚶‍♂️ target for today. Your total steps are \(stepsTaken)"

        //getting the notification trigger
        //it will be called after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        //getting the notification request
        let request = UNNotificationRequest(identifier: "StepsTargetCompleted", content: content, trigger: trigger)

        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func distanceTargetCompleted(distance: Int) {
        
        //creating the notification content
        let content = UNMutableNotificationContent()

        let distanceString = self.getDistanceString(distance: distance)
        //adding title, subtitle, body and badge
        content.title = Constants.appName
        content.subtitle = "Congrats 👏"
        content.body = "You have completed your distance 🚶‍♂️ target for today. Your traveled distance is \(distanceString)"

        //getting the notification trigger
        //it will be called after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        //getting the notification request
        let request = UNNotificationRequest(identifier: "DistanceTargetCompleted", content: content, trigger: trigger)

        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func stepsTarget50Percent(stepsTaken: Int) {
        
        //creating the notification content
        let content = UNMutableNotificationContent()

        //adding title, subtitle, body and badge
        content.title = Constants.appName
        content.subtitle = "Congrats 👏"
        content.body = "You have done 50% of your steps 🚶‍♂️ target for today. Your total steps are \(stepsTaken)"

        //getting the notification trigger
        //it will be called after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        //getting the notification request
        let request = UNNotificationRequest(identifier: "StepsHalfTarget", content: content, trigger: trigger)

        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func distanceTarget50Percent(distance: Int) {
        
        //creating the notification content
        let content = UNMutableNotificationContent()

        //adding title, subtitle, body and badge
        content.title = Constants.appName
        content.subtitle = "Congrats 👏"
        content.body = "You have done 50% distance 🚶‍♂️ of your target for today. Your traveled distance is \(distance)"

        //getting the notification trigger
        //it will be called after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        //getting the notification request
        let request = UNNotificationRequest(identifier: "DistanceHalfTarget", content: content, trigger: trigger)

        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    //MARK:- Helper Methods
    func convertToMiles(meters: Int) -> Float {
        
        return (Float(meters)/1609.344)
    }
    
    func convertToKM(meters: Int) -> Float {
        
        return (Float(meters)/1000)
    }

    func getDistanceString(distance: Int) -> String {
        
        var traveledDistanceString = ""
        if settingsManager.isDistanceInMiles {
            
            let distance = convertToMiles(meters: distance).convertToString()
            traveledDistanceString = String(format: "%@ mi", distance)
        } else {
            
            let distance = convertToKM(meters: distance).convertToString()
            traveledDistanceString = String(format: "%@ km", distance)
        }
        
        return traveledDistanceString
    }
}
