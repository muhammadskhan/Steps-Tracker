//
//  Distance.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 14/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import Foundation

struct Distance: Codable {
    
    var distanceTraveled: Int = 0
    var goal = 1000
    var percentage: Float = 0.0
    var date: Date = Date()
    
    enum CodingKeys: String, CodingKey {
      
        case distanceTraveled = "distanceTraveled"
        case goal = "distanceTarget"
        case date
    }
    
    var dictionary: [String: Any] {
        
        get {
            var dict = [String: Any]()
            dict["distanceTraveled"] = self.distanceTraveled
            dict["distanceTarget"] = self.goal
            return dict
        }
    }
}
