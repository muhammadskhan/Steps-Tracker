//
//  SharedDataManager.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 11/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import Foundation
import WidgetKit

let sharedDataManager = SharedDataManager.shared

class SharedDataManager: NSObject {
    
    static let shared = SharedDataManager()
    
    var isSecondTime = sharedDefaults.bool(forKey: kIsFirstTime) {
        didSet {
            sharedDefaults.setValue(isSecondTime, forKey: kIsFirstTime)
        }
    }
    
    private override init() {
        super.init()
        
        self.checkIfSecondTime()
    }
    
    var stepsTarget: Int = sharedDefaults.integer(forKey: kStepsTargetKeyShared) {
        didSet {
            sharedDefaults.set(stepsTarget, forKey: kStepsTargetKeyShared)
        }
    }
    
    var distanceTarget: Int = sharedDefaults.integer(forKey: kDistanceTargetKey) {
        didSet {
            sharedDefaults.set(distanceTarget, forKey: kDistanceTargetKey)
        }
    }
    
    var healthKitSteps: Int = sharedDefaults.integer(forKey: kHealthKitSteps) {
        didSet {
            sharedDefaults.setValue(healthKitSteps, forKey: kHealthKitSteps)
        }
    }
    
    var healthKitDistance: Int = sharedDefaults.integer(forKey: kHealthKitDistance) {
        didSet {
            sharedDefaults.setValue(healthKitDistance, forKey: kHealthKitDistance)
        }
    }
    
    var appColor: AppColor {
        get {
            let appColor = sharedDefaults.string(forKey: kAppColor)
            return AppColor(rawValue: appColor ?? "") ?? .defaultColor
        }
        set {
            sharedDefaults.setValue(newValue.rawValue, forKey: kAppColor)
        }
    }
    
    //didSet not called on init but making a function to use inside init is working.
    func checkIfSecondTime() {
        if !isSecondTime {
            isSecondTime = true
            stepsTarget = 10000
            distanceTarget = 5000
        }
    }
}


fileprivate let kStepsTargetKeyShared = "com.StepsCalculator.DataManager.kStepsTargetShared"
fileprivate let kIsFirstTime = "com.StepsCalculator.DataManager.kIsFirstTime"
fileprivate let kDistanceTargetKey = "com.StepsCalculator.DataManager.kDistanceTargetKey"
fileprivate let kHealthKitSteps = "com.StepsCalculator.DataManager.kHealthKitSteps"
fileprivate let kHealthKitDistance = "com.StepsCalculator.DataManager.kHealthKitDistance"
fileprivate let kAppColor = "com.StepsCalculator.DataManager.kAppColor"

enum AppColor: String {
    case defaultColor = "Pink"
    case artyClickRed = "ArtyClickRed"
    case chromeYellow = "ChromeYellow"
    case neonBlue = "NeonBlue"
    case neonPink = "NeonPink"
    case purpleDaffodil = "PurpleDaffodil"
    case vividGreen = "VividGreen"
}
