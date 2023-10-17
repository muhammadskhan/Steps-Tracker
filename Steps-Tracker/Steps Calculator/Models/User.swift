//
//  User.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 09/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import Foundation

struct User: Codable {
    
    var userId = ""
    var userName = ""
    var userEmail = ""
    var steps = Steps()
    var distance = Distance()
}
