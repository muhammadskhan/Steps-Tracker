//
//  DataManager.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 10/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import Foundation

let dataManager = DataManager.shared

class DataManager: NSObject {
    
    static let shared = DataManager()
    
    private override init() {
        
    }
    
    func isLoggedIn() -> Bool {
        
        return user != nil
    }
    
    var userId: String = ""
    
    private var _user: User?
    var user: User? {
        
        get {
            
            if _user != nil {
                
                return _user
            }
            if let data = UserDefaults.standard.value(forKey:kCurrentActiveUser) as? Data {
                
                let currentUser = try? PropertyListDecoder().decode(User.self, from: data)
                _user = currentUser
                return currentUser ?? nil
            }
            
            return nil
        } set {
            
            _user = newValue
            defaults.set(try? PropertyListEncoder().encode(newValue), forKey: kCurrentActiveUser)
        }
    }
    
    var prismicRef = defaults.string(forKey: kPrismicRef) {
        didSet {
            defaults.setValue(prismicRef, forKey: kPrismicRef)
        }
    }
    
    var isMonthlySubsActive = defaults.bool(forKey: kIsMonthlyActive) {
        didSet {
            defaults.setValue(isMonthlySubsActive, forKey: kIsMonthlyActive)
        }
    }
    
    private var _healthKitSteps = 0
    var healthKitSteps: Int {
        
        get {
            if _healthKitSteps == 0 {
                
                _healthKitSteps = defaults.integer(forKey: kHealthKitSteps)
                return _healthKitSteps
            }
            return _healthKitSteps
        } set {
            
            _healthKitSteps = newValue
            defaults.setValue(newValue, forKey: kHealthKitSteps)
        }
    }
    
    func updateSteps(steps: Steps) {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: date)
        defaults.set(try? PropertyListEncoder().encode(steps), forKey: dateString)
    }
    
    func getSteps(date: Date) -> Steps? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: date)
        if let data = UserDefaults.standard.value(forKey:dateString) as? Data {
            
            return try? PropertyListDecoder().decode(Steps.self, from: data)
        }
        return nil
    }
    
    
    private var _healthKitDistance = 0
    var healthKitDistance: Int {
        
        get {
            
            if _healthKitDistance == 0 {
                
                _healthKitDistance = defaults.integer(forKey: kHealthKitDistance)
                return _healthKitDistance
            }
            return _healthKitDistance
            
        } set {
            
            _healthKitDistance = newValue
            defaults.setValue(newValue, forKey: kHealthKitDistance)
        }
    }
    
    func clearDefaults() {
        
        if let appDomain = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: appDomain)
            defaults.removePersistentDomain(forName: "group.com.swamtech.stepstrackerapp")
        }
        sharedDefaults.removeSuite(named: "group.com.swamtech.stepstrackerapp")
    }
    
    var noOfOpens: Int = defaults.integer(forKey: kOpensApp) {
        didSet {
            defaults.set(noOfOpens, forKey: kOpensApp)
        }
    }
    
    var promotionAppLink: String = defaults.string(forKey: kPromotionAppLink) ?? "" {
        didSet {
            defaults.setValue(promotionAppLink, forKey: kPromotionAppLink)
        }
    }
    
    var promotionAppIconUrl: String = defaults.string(forKey: kPromotionAppIconUrl) ?? "" {
        didSet {
            defaults.setValue(promotionAppIconUrl, forKey: kPromotionAppIconUrl)
        }
    }
    
    var promotionText: String = defaults.string(forKey: kPromotionText) ?? "" {
        didSet {
            defaults.setValue(promotionText, forKey: kPromotionText)
        }
    }
    
    var shouldShowCustomPromtion = defaults.bool(forKey: kShouldShowCustomPromtion) {
        didSet {
            defaults.setValue(shouldShowCustomPromtion, forKey: kShouldShowCustomPromtion)
        }
    }
    
    var widgetAddedEventLogged: Bool = defaults.bool(forKey: kWidgetAddedEventLogged) {
        didSet {
            defaults.setValue(widgetAddedEventLogged, forKey: kWidgetAddedEventLogged)
        }
    }
    
    var isNotificationStepsTargetCompletedDisplayed: Bool = defaults.bool(forKey: kIsNotificationStepsTargetCompletedDisplayed) {
        didSet {
            defaults.setValue(isNotificationStepsTargetCompletedDisplayed, forKey: kIsNotificationStepsTargetCompletedDisplayed)
        }
    }
    
    var isNotificationStepsTargetHalfDisplayed: Bool = defaults.bool(forKey: kIsNotificationStepsTargetHalfDisplayed) {
        didSet {
            defaults.setValue(isNotificationStepsTargetHalfDisplayed, forKey: kIsNotificationStepsTargetHalfDisplayed)
        }
    }
    
    var isNotificationDistanceTargetCompletedDisplayed: Bool = defaults.bool(forKey: kIsNotificationDistanceTargetCompletedDisplayed) {
        didSet {
            defaults.setValue(isNotificationDistanceTargetCompletedDisplayed, forKey: kIsNotificationDistanceTargetCompletedDisplayed)
        }
    }
    
    var isNotificationDistanceTargetHalfDisplayed: Bool = defaults.bool(forKey: kIsNotificationDistanceTargetHalfDisplayed) {
        didSet {
            defaults.setValue(isNotificationDistanceTargetHalfDisplayed, forKey: kIsNotificationDistanceTargetHalfDisplayed)
        }
    }
    
    var isReviewDone: Bool = defaults.bool(forKey: kIsReviewDone) {
        didSet {
            defaults.setValue(isReviewDone, forKey: kIsReviewDone)
        }
    }
}

fileprivate let kIsReviewDone = "com.stepstracker.DataManager.kIsReviewDone"
fileprivate let kOpensApp = "com.stepstracker.DataManager.kOpensApp"
fileprivate let kStepsTargetKey = "com.StepsCalculator.DataManager.kStepsTarget"
fileprivate let kHealthKitSteps = "com.StepsCalculator.DataManager.kHealthKitSteps"
fileprivate let kHealthKitDistance = "com.StepsCalculator.DataManager.kHealthKitDistance"
fileprivate let kCurrentActiveUser = "com.StepsTracker.DataManager.kCurrentActiveUser"
fileprivate let kWidgetAddedEventLogged = "com.StepsTracker.DataManager.kWidgetAddedEventLogged"
fileprivate let kIsNotificationStepsTargetCompletedDisplayed = "com.StepsTracker.DataManager.kIsNotificationStepsTargetCompletedDisplayed"
fileprivate let kIsNotificationStepsTargetHalfDisplayed = "com.StepsTracker.DataManager.kIsNotificationStepsTargetHalfDisplayed"
fileprivate let kIsNotificationDistanceTargetCompletedDisplayed = "com.StepsTracker.DataManager.kIsNotificationDistanceTargetCompletedDisplayed"
fileprivate let kIsNotificationDistanceTargetHalfDisplayed = "com.StepsTracker.DataManager.kIsNotificationDistanceTargetHalfDisplayed"
fileprivate let kPrismicRef = "com.StepsTracker.DataManager.kPrismicRef"
fileprivate let kPromotionAppIconUrl = "com.StepsTracker.DataManager.promotionAppIconUrl"
fileprivate let kPromotionAppLink = "com.StepsTracker.DataManager.promotionAppLink"
fileprivate let kPromotionText = "com.StepsTracker.DataManager.promotionText"
fileprivate let kShouldShowCustomPromtion = "com.StepsTracker.DataManager.shouldShowCustomPromtion"
fileprivate let kIsMonthlyActive = "com.StepsTracker.DataManager.kIsMonthlyActive"
