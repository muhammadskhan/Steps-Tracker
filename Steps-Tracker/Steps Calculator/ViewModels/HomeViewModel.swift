//
//  HomeViewModel.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 09/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import Foundation
import HealthKit

protocol HomeUIUpdatesDelegate: NSObject {
    
    func updateStepsUI(steps: Steps, animation: Bool)
    func updateDistanceProgressBar(distance: Distance)
    func showCustomHealthKitPopup()
}

class HomeViewModel: NSObject {
    
    weak var delegate: HomeUIUpdatesDelegate?
    var healthStore = HKHealthStore()
    init(viewDelegate: HomeUIUpdatesDelegate) {
        delegate = viewDelegate
    }
    
    func authorizeHealthKit() {
        
        healthKitManager.getHealthStatus { (allowed) in
            
            if !allowed {
                DispatchQueue.main.async {
                    
                    self.delegate?.showCustomHealthKitPopup()
                }
                return
            } else {
                
                healthKitManager.todayManuallyAddedSteps { (manualEntry, error) in
                    if error != nil {
                        print("error")
                    } else {
                        healthKitManager.getTodayStepsCount { (steps) in
                            
                            var realSteps = steps
                            realSteps.todaysStepTaken = steps.todaysStepTaken - Int(manualEntry)
                            sharedDataManager.healthKitSteps = realSteps.todaysStepTaken
                            DispatchQueue.main.async {
                                self.delegate?.updateStepsUI(steps: realSteps, animation: true)
                            }
                        }
                    }
                }
                
                healthKitManager.todayManuallyAddedDistance { (manualEntry, error) in
                    if error != nil {
                        print("error")
                    } else {
                        healthKitManager.getTodayDistance { (res) in
                            var distance = Distance(goal: settingsManager.distanceTarget, date: Date())
                            distance.distanceTraveled = Int(res) - Int(manualEntry)
                            sharedDataManager.healthKitDistance = distance.distanceTraveled
                            distance.percentage = Float(Double(distance.distanceTraveled)/Double(distance.goal)) * 100
                            DispatchQueue.main.async {
                                self.delegate?.updateDistanceProgressBar(distance: distance)
                            }
                        }
                    }
                }

            }
        }
    }
    
    func getStepsCountForMonth(date: Date,_ completion: @escaping ([Steps]) -> () ) {
        
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
                                                     intervalComponents: DateComponents(day: 1))
        
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
                }
            }
        }
    }
    
    func fetchStepsCountFor(date: Date) {
        
        getStepsCountFor(date: date) { (steps) in
            
            self.delegate?.updateStepsUI(steps: steps, animation: true)
        }
    }
    
    private func getStepsCountFor(date: Date ,_ completion: @escaping (Steps) -> () ) {
        
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
                                var steps = Steps(stepsGoal: settingsManager.stepsTarget, date: Date())
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
    
    func getDistanceFor(date: Date,_ completion: @escaping (Double) -> () ) {
        
        let read = Set([HKCategoryType.quantityType(forIdentifier: .distanceWalkingRunning)!])
        
        healthStore.requestAuthorization(toShare: nil, read: read) { (chk, error) in
            
            if chk {
                
                if HKHealthStore.isHealthDataAvailable() {
                    guard let type = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning) else {
                        fatalError("Something went wrong retrieving quantity type distanceWalkingRunning")
                    }
                    let cal = Calendar(identifier: Calendar.Identifier.gregorian)
                    let startDate = cal.startOfDay(for: date)
                    let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
                    let endOfDay = cal.startOfDay(for: endDate!)
                    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endOfDay, options: .strictStartDate)
                    
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
            } else {
                
                print("Permission Rejected")
            }
        }
    }
}

































