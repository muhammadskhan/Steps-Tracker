//
//  FirebaseError.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 12/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import Foundation

struct FirebaseError: Error {
    
    var title: String?
    var code: Int
    var errorDescription: String? { return _description }
    var failureReason: String? { return _description }
    
    private var _description: String
    
    init(_ error: Error?) {
        self.title = "Error"
        self._description = error?.localizedDescription ?? "Unknown Error"
        self.code = 0
    }
    
    init(title: String?, description: String, code: Int) {
        self.title = title ?? "Error"
        self._description = description
        self.code = code
    }
    
    static var notFound = FirebaseError(title: "Not Found", description: "Record not Found!", code: 404)
}
