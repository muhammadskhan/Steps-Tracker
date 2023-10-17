//
//  AlertManager.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 17/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import Foundation
import UIKit

struct Alert {
    
    //Alert Static strings
    static let internetAlertMessage = "Please check your internet connection and try again"
    static let internetAlertTitle = "Internet Failure"
    
    //Show Alert
    static func showAlert(on vc:UIViewController?, with title:String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            
            vc?.present(alert, animated: true, completion: nil)
        }
    }
    
    static func showAlertFor(seconds: TimeInterval, vc: UIViewController, with title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            
            vc.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                vc.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    static func showAlert(on vc:UIViewController?, withTitle title:String, message:String, completion: @escaping (Bool) -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {_ in
            completion(true)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in
            completion(false)
        }))
        
        DispatchQueue.main.async {
            
            vc?.present(alert, animated: true, completion: nil)
        }
    }
}
