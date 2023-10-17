//
//  Steps.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 09/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import Foundation

struct Steps: Codable {
    
    var todaysStepTaken: Int = 0
    var stepsGoal = 10000
    var percentage: Float = 0.0
    var date: Date = Date()
    
    enum CodingKeys: String, CodingKey {
      
        case todaysStepTaken = "stepsTaken"
        case stepsGoal = "stepsTarget"
        case date
    }
    
    var dictionary: [String: Any] {
        
        get {
            var dict = [String: Any]()
            dict["stepsTaken"] = self.todaysStepTaken
            dict["stepsTarget"] = self.stepsGoal
            
            return dict
        }
    }
}
