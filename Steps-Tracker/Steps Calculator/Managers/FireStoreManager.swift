//
//  FireStoreManager.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 11/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

let fsManager = FireStoreManager.shared

typealias FSHandler<T> = (_ result: T?, _ error: FirebaseError?) -> ()
class FireStoreManager {
    
    static let shared = FireStoreManager()
    
    let db: Firestore!
    let userRef: CollectionReference!
    let rankingRef: CollectionReference!
    let feedbackRef: CollectionReference!
    
    private init () {
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        userRef = db.collection("users")
        rankingRef = db.collection("ranking")
        feedbackRef = db.collection("feedback")
    }
    
    func createUser(user: User, completion: @escaping FSHandler<String>) {
        
        userRef.document(user.userId).setData([
            "userInfo": [
                "email": user.userEmail,
                "fcmToken": defaults.string(forKey: "fcmToken"),
                "name": user.userName]
        ]) { err in
            if let err = err {
                
                //Failure
                DispatchQueue.main.async {
                    completion(nil,FirebaseError(err))
                }
            } else {
                
                //Success
                DispatchQueue.main.async {
                    completion("Success",nil)
                }
            }
        }
    }
    
    func updateFCMToken() {
        
        if let user = dataManager.user {
            userRef.document(user.userId).setData([
                "userInfo": [
                    "email": user.userEmail,
                    "fcmToken": defaults.string(forKey: "fcmToken"),
                    "name": user.userName]
            ])
        }
    }
    
    func getUserInfo(withId userId: String, completion: @escaping FSHandler<User>) {
        
        var user = User()
        let docRef = userRef.document(userId)
        docRef.getDocument { (document, error) in
            
            if let document = document, document.exists {
                
                if let dataDictionary = document.data() {
                    if let userInfo = dataDictionary[FirestoreCollections.userInfo.rawValue] as? [String: Any] {
                        
                        user.userId = userId
                        user.userName = userInfo["name"] as? String ?? ""
                        user.userEmail = userInfo["email"] as? String ?? ""
                    }
                    DispatchQueue.main.async {
                        completion(user, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, FirebaseError(error))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, FirebaseError(error))
                }
            }
        }
    }
    
    //MARK:- Save Steps Data
    func updateSteps() {
        
        guard let userId = dataManager.user?.userId else {
            
            return
        }
        
        guard let todayTimeStamp = self.getTodayTimeStamp(timeZone: .current) else {
            
            return
        }
        
        guard let timeStampForHours = self.getTimeStampFromToday() else {
            
            return
        }
        
        userRef.document(userId).collection(FirestoreCollections.steps.rawValue).document(String(todayTimeStamp)).updateData([
            "values": FieldValue.arrayUnion([[
                "count": dataManager.healthKitSteps,
                "goal": settingsManager.stepsTarget,
                "time": timeStampForHours,
                "date": todayTimeStamp
            ]])
        ]) { (error) in
            if let _ = error {
                
                //Error maybe document is not present lets create a new document.
                DispatchQueue.main.async {
                    self.setupSteps()
                }
            } else {
                
                //Success
            }
        }
    }
    
    private func setupSteps() {
        
        guard let userId = dataManager.user?.userId else {
            
            return
        }
        
        guard let todayTimeStamp = self.getTodayTimeStamp(timeZone: .current) else {
            
            return
        }
        
        guard let timeStampForHours = self.getTimeStampFromToday() else {
            
            return
        }
        userRef.document(userId).collection(FirestoreCollections.steps.rawValue).document(String(todayTimeStamp)).setData([
            "values": FieldValue.arrayUnion([[
                "count": dataManager.healthKitSteps,
                "goal": settingsManager.stepsTarget,
                "time": timeStampForHours,
                "date": todayTimeStamp
            ]])
        ])
    }
    
    //MARK:- Save Distance Data
    func updateDistance() {
        
        guard let userId = dataManager.user?.userId else {
            
            return
        }
        
        guard let todayTimeStamp = self.getTodayTimeStamp(timeZone: .current) else {
            
            return
        }
        
        guard let timeStampForHours = self.getTimeStampFromToday() else {
            
            return
        }
        userRef.document(userId).collection(FirestoreCollections.distance.rawValue).document(String(todayTimeStamp)).updateData([
            "values": FieldValue.arrayUnion([[
                "count": dataManager.healthKitDistance,
                "goal": settingsManager.distanceTarget,
                "time": timeStampForHours,
                "date": todayTimeStamp
            ]])
        ]) { (error) in
            if let _ = error {
                
                //Error maybe document is not present lets create a new document.
                DispatchQueue.main.async {
                    self.setupDistance()
                }
            } else {
                
                //Success
            }
        }
    }
    
    private func setupDistance() {
        
        guard let userId = dataManager.user?.userId else {
            
            return
        }
        
        guard let todayTimeStamp = self.getTodayTimeStamp(timeZone: .current) else {
            
            return
        }
        
        guard let timeStampForHours = self.getTimeStampFromToday() else {
            
            return
        }
        userRef.document(userId).collection(FirestoreCollections.distance.rawValue).document(String(todayTimeStamp)).setData([
            "values": FieldValue.arrayUnion([[
                "count": dataManager.healthKitDistance,
                "goal": settingsManager.distanceTarget,
                "time": timeStampForHours,
                "date": todayTimeStamp
            ]])
        ])
    }
    
    //MARK:- Today Distance Rank
    func updateTodayDistanceRank(distance: Int) {
        
        guard let user = dataManager.user else {
            
            return
        }
        
        guard let todayTimeStamp = self.getTodayTimeStamp(timeZone: TimeZone(identifier: "UTC")!) else {
            
            return
        }
        let todayDate = self.getDateString()
        rankingRef.document(todayDate).collection("user").document(user.userId).updateData([
            "distance": distance,
            "email": user.userEmail,
            "name": user.userName,
            "date": todayTimeStamp
        ]) { (error) in
            if let _ = error {
                
                //Error maybe document is not present lets create a new document.
                DispatchQueue.main.async {
                    self.setupTodayDistanceRank(distance: distance)
                }
            } else {
                
                //Success
            }
        }
    }
    
    private func setupTodayDistanceRank(distance: Int) {
        
        guard let user = dataManager.user else {
            
            return
        }
        
        guard let todayTimeStamp = self.getTodayTimeStamp(timeZone: TimeZone(identifier: "UTC")!) else {
            
            return
        }
        let todayDate = self.getDateString()
        rankingRef.document(todayDate).collection("user").document(user.userId).setData([
            "distance": distance,
            "email": user.userEmail,
            "name": user.userName,
            "date": todayTimeStamp
        ])
    }
    
    //MARK:- Today Steps Rank
    func updateTodayStepsRank(steps: Int) {
        
        guard let user = dataManager.user else {
            
            return
        }
        
        guard let todayTimeStamp = self.getTodayTimeStamp(timeZone: TimeZone(identifier: "UTC")!) else {
            
            return
        }
        let todayDate = self.getDateString()
        rankingRef.document(todayDate).collection("user").document(user.userId).updateData([
            "steps": steps,
            "email": user.userEmail,
            "name": user.userName,
            "date": todayTimeStamp
        ]) { (error) in
            if let _ = error {
                
                //Error maybe document is not present lets create a new document.
                DispatchQueue.main.async {
                    self.setupTodayStepsRank(steps: steps)
                }
            } else {
                
                //Success
            }
        }
    }
    
    private func setupTodayStepsRank(steps: Int) {
        
        guard let user = dataManager.user else {
            
            return
        }
        
        guard let todayTimeStamp = self.getTodayTimeStamp(timeZone: TimeZone(identifier: "UTC")!) else {
            
            return
        }
        
        let todayDate = self.getDateString()
        rankingRef.document(todayDate).collection("user").document(user.userId).setData([
            "steps": steps,
            "email": user.userEmail,
            "name": user.userName,
            "date": todayTimeStamp
        ])
    }
    
    func getTopTenStepsRank(completion: @escaping FSHandler<[Ranking]>) {
        
        let todayDate = self.getDateString()
        rankingRef.document(todayDate).collection("user").order(by: "steps", descending: true).limit(to: 10).getDocuments { (snapshot, err) in
            
            if err == nil {
                var topTens = [Ranking]()
                if let rankingArray = snapshot?.documents {
                    for ranking in rankingArray {
                        let rankDict = ranking.data()
                        topTens.append(Ranking(dict: rankDict))
                    }
                }
                completion(topTens, nil)
            } else {
                completion(nil, FirebaseError(err))
            }
        }
    }
    
    func getTopTenDistanceRank(completion: @escaping FSHandler<[Ranking]>) {
        
        let todayDate = self.getDateString()
        rankingRef.document(todayDate).collection("user").order(by: "distance", descending: true).limit(to: 10).getDocuments { (snapshot, err) in
            
            if err == nil {
                var topTens = [Ranking]()
                if let rankingArray = snapshot?.documents {
                    for ranking in rankingArray {
                        let rankDict = ranking.data()
                        topTens.append(Ranking(dict: rankDict))
                    }
                }
                completion(topTens, nil)
            } else {
                completion(nil, FirebaseError(err))
            }
        }
    }
    
    func getYesterdayTopTenStepsRank(completion: @escaping FSHandler<[Ranking]>) {
        
        let yesterdayDate = self.getDateString(shouldReturnToday: false)
        rankingRef.document(yesterdayDate).collection("user").order(by: "steps", descending: true).limit(to: 10).getDocuments { (snapshot, err) in
            
            if err == nil {
                var topTens = [Ranking]()
                if let rankingArray = snapshot?.documents {
                    for ranking in rankingArray {
                        let rankDict = ranking.data()
                        topTens.append(Ranking(dict: rankDict))
                    }
                }
                completion(topTens, nil)
            } else {
                completion(nil, FirebaseError(err))
            }
        }
    }
    
    func getYesterdayTopTenDistanceRank(completion: @escaping FSHandler<[Ranking]>) {
        
        let yesterdayDate = self.getDateString(shouldReturnToday: false)
        rankingRef.document(yesterdayDate).collection("user").order(by: "distance", descending: true).limit(to: 10).getDocuments { (snapshot, err) in
            
            if err == nil {
                var topTens = [Ranking]()
                if let rankingArray = snapshot?.documents {
                    for ranking in rankingArray {
                        let rankDict = ranking.data()
                        topTens.append(Ranking(dict: rankDict))
                    }
                }
                completion(topTens, nil)
            } else {
                completion(nil, FirebaseError(err))
            }
        }
    }
    
    func getUserRankInfoForYesterday(completion: @escaping FSHandler<Ranking>) {
        
        guard let user = dataManager.user else {
            
            return
        }
        let date = getDateString(shouldReturnToday: false)
        rankingRef.document(date).collection("user").document(user.userId).getDocument { (document, error) in
            
            if let document = document, document.exists {
                
                if let dataDictionary = document.data() {
                    let rank = Ranking(dict: dataDictionary)
                    completion(rank, nil)
                } else {
                    
                    completion(nil, FirebaseError(error))
                }
            } else {
                
                completion(nil, FirebaseError(error))
            }
        }
    }
    
    func sendFeedback(review: String) {
        
        guard let user = dataManager.user else {
            
            return
        }
        
        feedbackRef.document(user.userId).setData([
            
            "review": review,
            "userId": user.userId
        ])
    }
    
    //MARK:- Helper Methods
    func getDateString(shouldReturnToday: Bool = true) -> String {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDateString = formatter.string(from: now)
        
        if shouldReturnToday {
            return todayDateString
        } else {
            guard let yesterdayDate = yesterday else {
                return todayDateString
            }
            let yesterdayDateString = formatter.string(from: yesterdayDate)
            return yesterdayDateString
        }
    }
    
    func getTodayTimeStamp(timeZone: TimeZone) -> Double? {
        
        let now = Date()

        let formatter = DateFormatter()
        
        formatter.timeZone = timeZone
        
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        
        let dateString = formatter.string(from: now)
        
        // optional
        guard let date = formatter.date(from: dateString) else {
                        
            return nil
        }
        return date.timeIntervalSince1970
    }
    
    func getTimeStampFromToday() -> Double? {
        
        guard let todayDate = self.getTodayDateFor12Am() else {
            return nil
        }
        let currentDate = Date()
        return currentDate.timeIntervalSince(todayDate)
    }
    
    private func getTodayDateFor12Am() -> Date? {
        
        let now = Date()

        let formatter = DateFormatter()
        
        formatter.timeZone = TimeZone.current
        
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: now)
        
        // optional
        return formatter.date(from: dateString)
    }
    
    func deleteUser(completion: @escaping FSHandler<Bool>) {
        let user = Auth.auth().currentUser

        user?.delete { error in
          if let error = error {
            // An error happened.
              completion(false, FirebaseError(error))
          } else {
            // Account deleted.
              completion(true, nil)
          }
        }
    }
}
