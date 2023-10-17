//
//  HealthKitManager.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 10/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import UIKit
import HealthKit
#if canImport(WidgetKit)
import WidgetKit
#endif

let healthKitManager = HealthKitManager.shared

protocol HealthKitDelegate: class {
    
    func didRecieveStepsData()
    func didRecieveDistanceData()
}

class HealthKitManager: NSObject {
    
    static let shared = HealthKitManager()
    var healthStore: HKHealthStore!
    var activityTypes: [HKQuantityType] = []
    
    var isAllowedAccess: Bool = false
    
    func getHealthStatus(_ completion: @escaping ((Bool) -> Void)) {
        
        healthStore.getRequestStatusForAuthorization(toShare: Set(), read: Set(activityTypes)) { (status, error) in
           
            self.isAllowedAccess = (status == .unnecessary)
            completion(status == .unnecessary)
        }
    }
    
    weak var delegate: HealthKitDelegate?
    
    private override init() {
        
        healthStore = HKHealthStore()
        
        if let stepsQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount),
           let distanceQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning) {
            activityTypes = [stepsQuantityType, distanceQuantityType]
        }
    }
    
    func startObservingData(finishBlock: @escaping (Error?) -> ()) {
        
        self.requestDataAccess { (error) in
            
            if error != nil {
                
                finishBlock(error!)
                return
            }
            
            for activityType in self.activityTypes {
                
                let query = HKObserverQuery(sampleType: activityType, predicate: nil) { (query, completionHandler, error) in
                    
                    completionHandler()
                    
                    if activityType.identifier == HKQuantityTypeIdentifier.stepCount.rawValue {
                        
                        self.todayManuallyAddedSteps { (manualEntry, error) in
                            if error != nil {
                                print("error")
                            } else {
                                self.getTodayStepsCount { (steps) in
                                    
                                    var realSteps = steps
                                    realSteps.todaysStepTaken = steps.todaysStepTaken - Int(manualEntry)
                                    if realSteps.todaysStepTaken > 0 {
                                        
                                        dataManager.healthKitSteps = realSteps.todaysStepTaken
                                        sharedDataManager.healthKitSteps = realSteps.todaysStepTaken
//                                        fsManager.updateSteps()
//                                        fsManager.updateTodayStepsRank(steps: realSteps.todaysStepTaken)
                                        if realSteps.todaysStepTaken > settingsManager.stepsTarget {
                                            
                                            if settingsManager.notificationStepsTargetCompletion {
                                                settingsManager.notificationStepsTargetCompletion = false
                                                DispatchQueue.main.async {
                                                    notificationManager.stepsTargetCompleted(stepsTaken: realSteps.todaysStepTaken)
                                                }
                                            }
                                        } else {
                                            settingsManager.notificationStepsTargetCompletion = true
                                        }
                                        DispatchQueue.main.async {
                                            self.delegate?.didRecieveStepsData()
                                        }
                                    }
                                }
                            }
                        }
                        
                    } else if activityType.identifier == HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue {
                        
                        self.todayManuallyAddedDistance { (manualEntry, error) in
                            if error != nil {
                                print("error")
                            } else {
                                self.getTodayDistance { (distance) in
                                    
                                    let realDistance = distance - manualEntry
                                    if realDistance > 0 {
                                        
                                        dataManager.healthKitDistance = Int(realDistance)
                                        sharedDataManager.healthKitDistance = Int(realDistance)
                                        
//                                        fsManager.updateDistance()
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                                            fsManager.updateTodayDistanceRank(distance: Int(realDistance))
//                                        }
                                        if dataManager.healthKitDistance > settingsManager.distanceTarget {
                                            
                                            if settingsManager.notificationDistanceTargetCompletion {
                                                settingsManager.notificationDistanceTargetCompletion = false
                                                DispatchQueue.main.async {
                                                    notificationManager.distanceTargetCompleted(distance: Int(realDistance))
                                                }
                                            }
                                        } else {
                                            settingsManager.notificationDistanceTargetCompletion = true
                                        }
                                        DispatchQueue.main.async {
                                            self.delegate?.didRecieveDistanceData()
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                        if error != nil {
                            
                            print(error as Any)
                        }
                        
                        finishBlock(error)
                    }
                }
                
                //execute query
                self.healthStore.execute(query)
                self.healthStore.enableBackgroundDelivery(for: activityType, frequency: .immediate) { (success, error) in
                    
                    if error != nil {
                        
                        print(error as Any)
                    }
                }
            }
        }
    }
    
    func requestDataAccess(finishBlock: @escaping (Error?) -> ()) {
        
        let types = activityTypes
        self.healthStore.requestAuthorization(toShare: nil, read: Set(types)) { (success, error) in
            
            DispatchQueue.main.async {
                
                finishBlock(error)
            }
        }
    }
    
    func observeHealthKitInBackground(_ application: UIApplication) {
        self.getHealthStatus { (allowed) in
            if allowed {
                BackgroundTask.run(application: application) { backgroundTask in
                   // Do something
                    self.startObservingData { (error) in
                     
                        backgroundTask.end()
                    }
                }
            } else {
                
                print("Permissions Denied")
            }
        }
    }
    
    func todayManuallyAddedSteps(completion: @escaping (Double, Error?) -> () ) {
        
        let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) // The type of data we are requesting
        
        let date = Date()
        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let newDate = cal.startOfDay(for: date)
        let predicate = HKQuery.predicateForSamples(withStart: newDate, end: Date(), options: []) // Our search predicate which will fetch all steps taken today
        
        // The actual HealthKit Query which will fetch all of the steps and add them up for us.
        
        let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
            var steps: Double = 0
            
            if results?.count ?? 0 > 0
            {
                for result in results as! [HKQuantitySample]
                {
                   
                    // checking and adding manually added steps
                    if result.sourceRevision.source.name == "Health" {
                        // these are manually added steps
                        steps += result.quantity.doubleValue(for: HKUnit.count())
                    }
                    else{
                        // these are auto detected steps which we do not want from using HKSampleQuery
                    }
                }
                print(steps)
            }
            completion(steps, error)
        }
        
        self.healthStore.execute(query)
    }
    
    func getTodayStepsCount( _ completion: @escaping (Steps) -> () ) {
        
        if HKHealthStore.isHealthDataAvailable() {
            
            guard let sampleType = HKCategoryType.quantityType(forIdentifier: .stepCount) else {
                return
            }
            
            let startDate = Calendar.current.startOfDay(for: Date())
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
            
            var interval = DateComponents()
            interval.day = 1
            
            let query = HKStatisticsCollectionQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startDate , intervalComponents: interval)
            
            query.initialResultsHandler = {
                query, result, error in
                
                if let myResult = result {
                    
                    myResult.enumerateStatistics(from: startDate, to: Date()) { (statistics, values) in
                        
                        if let count = statistics.sumQuantity() {
                            let value = count.doubleValue(for: HKUnit.count())
                            print("total steps are : \(value)")
                            //                                    steps = Int(value)
                            DispatchQueue.main.async {
                                var steps = Steps(stepsGoal: settingsManager.stepsTarget, date: Date())
                                steps.todaysStepTaken = Int(value)
                                completion(steps)
                            }
                        } else {
                            print("Zero Steps")
                            DispatchQueue.main.async {
                                
                                completion(Steps(stepsGoal: settingsManager.stepsTarget, date: Date()))
                            }
                        }
                    }
                }
            }
            self.healthStore.execute(query)
        }
    }
    
    func todayManuallyAddedDistance(completion: @escaping (Double, Error?) -> () ) {
        
        let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning) // The type of data we are requesting
        
        let date = Date()
        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let newDate = cal.startOfDay(for: date)
        let predicate = HKQuery.predicateForSamples(withStart: newDate, end: Date(), options: []) // Our search predicate which will fetch all steps taken today
        
        // The actual HealthKit Query which will fetch all of the steps and add them up for us.
        
        let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
            var steps: Double = 0
            
            if results?.count ?? 0 > 0
            {
                for result in results as! [HKQuantitySample]
                {
                   
                    // checking and adding manually added steps
                    if result.sourceRevision.source.name == "Health" {
                        // these are manually added steps
                        steps += result.quantity.doubleValue(for: HKUnit.meter())
                    }
                    else{
                        // these are auto detected steps which we do not want from using HKSampleQuery
                    }
                }
                print(steps)
            }
            completion(steps, error)
        }
        
        self.healthStore.execute(query)
    }
    
    func getTodayDistance(_ completion: @escaping (Double) -> () ) {
        
        if HKHealthStore.isHealthDataAvailable() {
            guard let type = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning) else {
                fatalError("Something went wrong retrieving quantity type distanceWalkingRunning")
            }
            let date =  Date()
            let cal = Calendar(identifier: Calendar.Identifier.gregorian)
            let newDate = cal.startOfDay(for: date)
            
            let predicate = HKQuery.predicateForSamples(withStart: newDate, end: Date(), options: .strictStartDate)
            
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
                var value: Double = 0
                
                if error != nil {
                    print("something went wrong")
                } else if let quantity = statistics?.sumQuantity() {
                    value = quantity.doubleValue(for: HKUnit.meter())
                }
                DispatchQueue.main.async {
                    completion(value)
                }
            }
            self.healthStore.execute(query)
        }
    }
    
    func getTopMostViewController() -> UIViewController? {
        
        var topMostController = UIApplication.shared.getKeyWindow()?.rootViewController
        while let presentedViewController = topMostController?.presentedViewController {
            topMostController = presentedViewController
        }
        
        // topController should now be your topmost view controller
        return topMostController
        
    }
    
    func getStepsCountForMonth(date: Date,_ completion: @escaping (Double) -> () ) {
        
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let startOfMonth = calendar.date(from: components)
        print(formatter.string(from: startOfMonth!)) // 2015-11-01
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.day = -1
        let endOfMonth = calendar.date(byAdding: comps2, to: startOfMonth!)
        print(formatter.string(from: endOfMonth!)) // 2015-11-30
        let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfMonth, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery.init(quantityType: stepsQuantityType,
                                                     quantitySamplePredicate: predicate,
                                                     options: .cumulativeSum,
                                                     anchorDate: startOfMonth!,
                                                     intervalComponents: DateComponents(month: 1))
        
        query.initialResultsHandler = { query, results, error in
            guard let statsCollection = results else {
                // Perform proper error handling here...
                return
            }
            
            statsCollection.enumerateStatistics(from: startOfMonth!, to: endOfMonth!) { statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let stepValue = quantity.doubleValue(for: HKUnit.count())
                    print(stepValue)
                    
                    // ...
                   completion(stepValue)
                } else {
                    completion(0.0)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func getStepsForHour(date: Date, hour: Int ,_ completion: @escaping (Steps) -> () ) {
        
        let read = Set([HKCategoryType.quantityType(forIdentifier: .stepCount)!])
        
        healthStore.requestAuthorization(toShare: nil, read: read) { (chk, error) in
            
            if chk {
                
                if HKHealthStore.isHealthDataAvailable() {
                    guard let type = HKSampleType.quantityType(forIdentifier: .stepCount) else {
                        fatalError("Something went wrong retrieving quantity type steps")
                    }
                    var minutes = 0
                    var endDateHour = 0
                    if hour == 23 {
                        minutes = 59
                        endDateHour = hour
                    } else {
                        minutes = 0
                        endDateHour = hour + 1
                    }
                    
                    let startDate = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: date)
                    let endDate = Calendar.current.date(bySettingHour: endDateHour, minute: minutes, second: 0, of: date)
                    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
                    let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
                        if let count = statistics?.sumQuantity() {
                            let value = count.doubleValue(for: HKUnit.count())
                            print("total steps are : \(value)")
                            //                                    steps = Int(value)
                            DispatchQueue.main.async {
                                var steps = Steps(stepsGoal: settingsManager.stepsTarget, date: date)
                                steps.todaysStepTaken = Int(value)
                                steps.percentage = Float(value/Double(steps.stepsGoal)) * 100
                                completion(steps)
                            }
                        }else{
                            print("Zero Steps")
                            DispatchQueue.main.async {
                                
                                completion(Steps(stepsGoal: settingsManager.stepsTarget, date: Date()))
                            }
                        }
                    }
                    self.healthStore.execute(query)
                }
            } else {
                
                print("Permission Rejected")
            }
        }
    }
    
    func getStepsCountFor(date: Date ,_ completion: @escaping (Steps) -> () ) {
        
        let read = Set([HKCategoryType.quantityType(forIdentifier: .stepCount)!])
        
        healthStore.requestAuthorization(toShare: nil, read: read) { (chk, error) in
            
            if chk {
                
                if HKHealthStore.isHealthDataAvailable() {
                    guard let type = HKSampleType.quantityType(forIdentifier: .stepCount) else {
                        fatalError("Something went wrong retrieving quantity type steps")
                    }
                    let cal = Calendar(identifier: Calendar.Identifier.gregorian)
                    let startDate = cal.startOfDay(for: date)
                    let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
                    let endOfDay = cal.startOfDay(for: endDate!)
                    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endOfDay, options: .strictStartDate)
                    let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
                        if let count = statistics?.sumQuantity() {
                            let value = count.doubleValue(for: HKUnit.count())
                            print("total steps are : \(value)")
                            //                                    steps = Int(value)
                            DispatchQueue.main.async {
                                var steps = Steps(stepsGoal: settingsManager.stepsTarget, date: date)
                                steps.todaysStepTaken = Int(value)
                                steps.percentage = Float(value/Double(steps.stepsGoal)) * 100
                                completion(steps)
                            }
                        }else{
                            print(date)
                            print("Zero Steps")
                            DispatchQueue.main.async {
                                
                                completion(Steps(stepsGoal: settingsManager.stepsTarget, date: Date()))
                            }
                        }
                    }
                    self.healthStore.execute(query)
                }
            } else {
                
                print("Permission Rejected")
            }
        }
        
    }
}
