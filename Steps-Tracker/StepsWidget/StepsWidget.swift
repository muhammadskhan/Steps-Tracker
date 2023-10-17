//
//  StepsWidget.swift
//  StepsWidget
//
//  Created by Shahryar Khan on 9/1/20.
//  Copyright © 2020 HxB. All rights reserved.
//

import WidgetKit
import SwiftUI
import HealthKit

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        
        let stepsAndDistance = StepsAndDistance()
        stepsAndDistance.todaysDistance = sharedDataManager.healthKitDistance
        stepsAndDistance.todaysStepTaken = sharedDataManager.healthKitSteps
        return SimpleEntry(date: Date(),counter: 0, steps: stepsAndDistance)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let stepsAndDistance = StepsAndDistance()
        stepsAndDistance.todaysDistance = sharedDataManager.healthKitDistance
        stepsAndDistance.todaysStepTaken = sharedDataManager.healthKitSteps
        let entry = SimpleEntry(date: Date(),counter: 0, steps: stepsAndDistance)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let stepsAndDistance = StepsAndDistance()
        stepsAndDistance.todaysDistance = sharedDataManager.healthKitDistance
        stepsAndDistance.todaysStepTaken = sharedDataManager.healthKitSteps
        // Generate a timeline of fifteen minutes apart, starting from the current date.
        
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 20, to: Date()) ?? Date()
        
        let entry = SimpleEntry(date: refreshDate,counter: 0, steps: stepsAndDistance)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        entry.getData {
            completion(timeline)
        }
    }
}

class StepsAndDistance: ObservableObject {
    
    @Published var todaysStepTaken: Int = 0
    var stepsGoal = 10000
    @Published var todaysDistance: Int = 0
}

class GetTodaySteps {
    
    var healthStore = HKHealthStore()
    var isStepsDataFetched = false
    var isDistanceDataFetched = false
    var activityTypes: [HKQuantityType] = []
    private(set) static var shared: GetTodaySteps = GetTodaySteps()
    init() {
        if let stepsQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount),
           let distanceQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning) {
            activityTypes = [stepsQuantityType, distanceQuantityType]
        }
    }
    
    func getData( _ completion: @escaping (StepsAndDistance) -> () ) {
        
        for activityType in self.activityTypes {
            
            let query = HKObserverQuery(sampleType: activityType, predicate: nil) { (query, completionHandler, error) in
                
                completionHandler()
                
                if activityType.identifier == HKQuantityTypeIdentifier.stepCount.rawValue {
                    
                    self.getTodayStepsCount { (steps) in
                        
                        
                        sharedDataManager.healthKitSteps = Int(steps)
                        let stepsAndDistance = StepsAndDistance()
                        stepsAndDistance.todaysDistance = sharedDataManager.healthKitDistance
                        stepsAndDistance.todaysStepTaken = sharedDataManager.healthKitSteps
                        self.isStepsDataFetched = true
                        if self.isStepsDataFetched && self.isDistanceDataFetched {
                            self.isDistanceDataFetched = false
                            self.isStepsDataFetched = false
                        }
                        completion(stepsAndDistance)
                    }
                    
                } else if activityType.identifier == HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue {
                    
                    
                    self.getTodayDistance { (distance) in
                        
                        sharedDataManager.healthKitDistance = Int(distance)
                        let stepsAndDistance = StepsAndDistance()
                        stepsAndDistance.todaysDistance = sharedDataManager.healthKitDistance
                        stepsAndDistance.todaysStepTaken = sharedDataManager.healthKitSteps
                        self.isDistanceDataFetched = true
                        if self.isStepsDataFetched && self.isDistanceDataFetched {
                            self.isDistanceDataFetched = false
                            self.isStepsDataFetched = false
                        }
                        completion(stepsAndDistance)
                    }
                }
            }
            
            //execute query
            self.healthStore.execute(query)
        }
    }
    
    private func getTodayStepsCount( _ completion: @escaping (Double) -> () ) {
        
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
                                
                                completion(value)
                            }
                        } else {
                            print("Zero Steps")
                            DispatchQueue.main.async {
                                
                                completion(0.0)
                            }
                        }
                    }
                }
            }
            self.healthStore.execute(query)
        }
    }
    
    private func getTodayDistance(_ completion: @escaping (Double) -> () ) {
        
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
}

class SimpleEntry: TimelineEntry {
    
    let date: Date
    let counter: Int
    var steps = StepsAndDistance()
    var healthStore = HKHealthStore()
    
    internal init(date: Date, counter: Int, steps: StepsAndDistance = StepsAndDistance()) {
        self.date = date
        self.counter = counter
        self.steps = steps
    }
    
    func getData(completion: @escaping () -> ()) {
        GetTodaySteps.shared.getData({ (steps) in
            self.steps = steps
            completion()
        })
    }
}

struct StepsWidgetEntryView : View {
    
    @Environment(\.widgetFamily) var widgetFamily

    var entry: Provider.Entry
    
    @AppStorage("com.StepsCalculator.DataManager.kStepsTargetShared", store: UserDefaults(suiteName: "group.com.swamtech.stepstrackerapp")) var stepsTarget: Int = 10000
    
    @AppStorage("com.StepsCalculator.DataManager.kDistanceTargetKey", store: UserDefaults(suiteName: "group.com.swamtech.stepstrackerapp")) var distanceTarget: Int = 10000
    
    @AppStorage("com.swamtech.stepstracker.settingsManager.kDistanceInMeters", store: UserDefaults(suiteName: "group.com.swamtech.stepstrackerapp")) var isDistanceInMeters: Bool = false
    var body: some View {
        //Text("\(entry.counter)")
        let ringColor = Constants.AppColors.primaryColor
        let ring2ndColor = Constants.AppColors.ringGradient2nd
        let normalText = Constants.AppColors.textColor
        HStack{
            VStack{
                ZStack {
                    VStack {
                        Text("\(entry.steps.todaysStepTaken)")
                            .font(.system(size: 22, weight: .bold, design: .default))
                        Text("Goal \(stepsTarget)")
                            .font(.system(size: 10, weight: .medium, design: .default)).padding(.top, -8).foregroundColor(Color(normalText))
                    }
                    
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(style: StrokeStyle(lineWidth: 12.5, lineCap: .round, lineJoin: .round))
                        .opacity(0.3)
                        .foregroundColor(.gray)
                        .rotationEffect(Angle(degrees: 135.0))
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(min(Float(Float(entry.steps.todaysStepTaken)/Float(stepsTarget)) * 0.75, 0.75)))
                        .stroke(LinearGradient(gradient: Gradient(colors: [Color(ringColor), Color(ring2ndColor)]), startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 12.5, lineCap: .round, lineJoin: .round))
                        .rotationEffect(Angle(degrees: 135.0))
                    
                }.padding(EdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 10))
                
                Text("Steps")
                    .font(.system(size: 14, weight: .medium, design: .default)).foregroundColor(Color(ringColor)).frame(width: 80, height: 12, alignment: .center).padding(.bottom, 12).padding(.top, -8)
            }
            if widgetFamily == .systemMedium {
                VStack{
                    ZStack {
                        VStack {
                            if isDistanceInMeters {
                                    
                                Text("\(Float(Double(entry.steps.todaysDistance)/1609.344).convertToString())")
                                    .font(.system(size: 22, weight: .bold, design: .default))
                                Text("Goal \(Float(Double(distanceTarget)/1609.344).convertToString()) mi")
                                    .font(.system(size: 10, weight: .medium, design: .default)).padding(.top, -8).foregroundColor(Color(normalText))
                            } else {
                                
                                Text("\(Float(Double(entry.steps.todaysDistance)/1000.0).convertToString())")
                                    .font(.system(size: 22, weight: .bold, design: .default))
                                Text("Goal \(Float(Double(distanceTarget)/1000.0).convertToString()) km")
                                    .font(.system(size: 10, weight: .medium, design: .default)).padding(.top, -8).foregroundColor(Color(normalText))
                            }
                            
                        }
                        
                        Circle()
                            .trim(from: 0, to: 0.75)
                            .stroke(style: StrokeStyle(lineWidth: 12.5, lineCap: .round, lineJoin: .round))
                            .opacity(0.3)
                            .foregroundColor(.gray)
                            .rotationEffect(Angle(degrees: 135.0))
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(min(Float(Float(entry.steps.todaysDistance)/Float(distanceTarget)) * 0.75, 0.75)))
                            .stroke(LinearGradient(gradient: Gradient(colors: [Color(ringColor), Color(ring2ndColor)]), startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 12.5, lineCap: .round, lineJoin: .round))
                            .rotationEffect(Angle(degrees: 135.0))
                        
                    }.padding(EdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 10))
                    
                    Text("Distance")
                        .font(.system(size: 14, weight: .medium, design: .default)).foregroundColor(Color(ringColor)).frame(width: 80, height: 12, alignment: .center).padding(.bottom, 12).padding(.top, -8)
                }
            }
        }
    }
}

@main
struct StepsWidget: Widget {
    let kind: String = "StepsWidget"

    var body: some WidgetConfiguration {
        
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StepsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Steps Tracker")
        .description("Track your steps")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct StepsWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StepsWidgetEntryView(entry: SimpleEntry(date: Date(), counter: 0))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            StepsWidgetEntryView(entry: SimpleEntry(date: Date(), counter: 0))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}

extension Float {
    
    func convertToString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self)) ?? ""
    }
}
