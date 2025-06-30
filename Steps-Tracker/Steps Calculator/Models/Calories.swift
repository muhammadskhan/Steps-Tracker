//
//  Calories.swift
//  Steps Calculator (Now Calorie Calculator)
//
//  Created by Conversion Assistant
//

import Foundation

struct Calories: Codable {
    var todaysCaloriesBurned: Double = 0.0
    var caloriesGoal: Double = 2000.0 // default daily goal
    var percentage: Float = 0.0
    var date: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case todaysCaloriesBurned = "caloriesBurned"
        case caloriesGoal = "caloriesGoal"
        case percentage = "percentage"
        case date = "date"
    }
}