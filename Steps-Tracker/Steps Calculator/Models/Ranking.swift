//
//  Ranking.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 07/10/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import Foundation

struct Ranking {
    
    var name = ""
    var steps = 0
    var distance = ""
    var email = ""
    
    init(dict: [String: Any]) {
        self.name = dict["name"] as? String ?? ""
        self.steps = dict["steps"] as? Int ?? 0
        self.email = dict["email"] as? String ?? ""
        if settingsManager.isDistanceInMiles {
            let distanceString = convertToMiles(meters: dict["distance"] as? Int ?? 0).convertToString()
            self.distance = String(format: "%@ mi", distanceString)
        } else {
            let distanceString = self.convertToKM(meters: dict["distance"] as? Int ?? 0).convertToString()
            self.distance = String(format: "%@ km", distanceString)
        }
    }
    
    private func convertToMiles(meters: Int) -> Float {
        
        return (Float(meters)/1609.344)
    }
    
    private func convertToKM(meters: Int) -> Float {
        
        return (Float(meters)/1000)
    }
    
}
