//
//  SettingsManager.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 10/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import Foundation

let settingsManager = SettingsManager.shared

class SettingsManager: NSObject {
    
    static let shared = SettingsManager()
    
    private override init() {
        super.init()
        
        self.checkIfWeightSet()
    }
    
    private var _isDistanceInMeters: Bool?
    
    var isWeightSet = defaults.bool(forKey: kSettingsIsWeightSet) {
        didSet {
            defaults.setValue(isWeightSet, forKey: kSettingsIsWeightSet)
        }
    }
    
    var isDistanceInMiles: Bool {
        
        get {
            
            if _isDistanceInMeters != nil {
                
                return _isDistanceInMeters!
            } else {
                
                _isDistanceInMeters = sharedDefaults.bool(forKey: kIsDistanceInMeters)
                
                return _isDistanceInMeters ?? true
            }
        } set {
            
            _isDistanceInMeters = newValue
            sharedDefaults.set(newValue, forKey: kIsDistanceInMeters)
        }
    }
    
    var stepsTarget: Int {
        
        get {
            
            return sharedDataManager.stepsTarget
        } set {
            
            sharedDataManager.stepsTarget = newValue
        }
    }
    
    var distanceTarget: Int {
        
        get {
            
            return sharedDataManager.distanceTarget
        } set {
            
            sharedDataManager.distanceTarget = newValue
        }
    }
    
    var bodyWeight: Int = defaults.integer(forKey: kSettingsBodyWeight) {
        didSet {
            defaults.setValue(bodyWeight, forKey: kSettingsBodyWeight)
        }
    }
    
    var notificationStepsTargetCompletion: Bool = defaults.bool(forKey: kNotificationStepsTargetCompletion) {
        didSet {
            defaults.setValue(notificationStepsTargetCompletion, forKey: kNotificationStepsTargetCompletion)
        }
    }
    
    var notificationDistanceTargetCompletion: Bool = defaults.bool(forKey: kNotificationDistanceTargetCompletion) {
        didSet {
            defaults.setValue(notificationDistanceTargetCompletion, forKey: kNotificationDistanceTargetCompletion)
        }
    }
    
    var notificationStepsTargetHalf: Bool = defaults.bool(forKey: kNotificationStepsTargetHalf) {
        didSet {
            defaults.setValue(notificationStepsTargetHalf, forKey: kNotificationStepsTargetHalf)
        }
    }
    
    var notificationDistanceTargetHalf: Bool = defaults.bool(forKey: kNotificationDistanceTargetHalf) {
        didSet {
            defaults.setValue(notificationDistanceTargetHalf, forKey: kNotificationDistanceTargetHalf)
        }
    }
    
    private func checkIfWeightSet() {
        
        if !isWeightSet {
            isWeightSet = true
            bodyWeight = 62
        }
    }
}

fileprivate let kIsDistanceInMeters = "com.swamtech.stepstracker.settingsManager.kDistanceInMeters"
fileprivate let kNotificationStepsTargetCompletion = "com.swamtech.stepstracker.settingsManager.kNotificationStepsTargetCompletion"
fileprivate let kNotificationDistanceTargetCompletion = "com.swamtech.stepstracker.settingsManager.kNotificationDistanceTargetCompletion"
fileprivate let kNotificationStepsTargetHalf = "com.swamtech.stepstracker.settingsManager.kNotificationStepsTargetHalf"
fileprivate let kNotificationDistanceTargetHalf = "com.swamtech.stepstracker.settingsManager.kNotificationDistanceTargetHalf"
fileprivate let kSettingsBodyWeight = "com.swamtech.stepstracker.settingsManager.kSettingsBodyWeight"
fileprivate let kSettingsIsWeightSet = "com.swamtech.stepstracker.settingsManager.kSettingsIsWeightSet"
