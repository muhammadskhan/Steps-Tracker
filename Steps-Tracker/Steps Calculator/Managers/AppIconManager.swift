//
//  AppIconManager.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 22/06/2021.
//  Copyright © 2021 HxB. All rights reserved.
//

import Foundation
import UIKit

let appIconManager = AppIconManager.shared

class AppIconManager: NSObject {
    
    static let shared = AppIconManager()
    
    private override init() {
        
    }
    
    var current: BMAppIcon {
        return BMAppIcon.allCases.first(where: {
            $0.name == UIApplication.shared.alternateIconName
        }) ?? .classic
    }
    
    func setIcon(_ appIcon: BMAppIcon, completion: ((Bool) -> Void)? = nil) {
        
        guard current != appIcon,
              UIApplication.shared.supportsAlternateIcons
        else { return }
        
        UIApplication.shared.setAlternateIconName(appIcon.name) { error in
            if let error = error {
                print("Error setting alternate icon \(appIcon.name ?? ""): \(error.localizedDescription)")
            }
            completion?(error != nil)
        }
    }
}

enum BMAppIcon: CaseIterable {
    case classic,
         artyClickRed,
         chromeYellow,
         neonBlue,
         neonPink,
         purpleDaffodil,
         vividGreen
    
    var name: String? {
        switch self {
        case .classic:
            return nil
        case .artyClickRed:
            return "AppIconArtyClickRed"
        case .chromeYellow:
            return "AppIconChromeYellow"
        case .neonBlue:
            return "AppIconNeonBlue"
        case .neonPink:
            return "AppIconNeonPink"
        case .purpleDaffodil:
            return "AppIconPurpleDaffodil"
        case .vividGreen:
            return "AppIconVividGreen"
        }
        
    }
    
    var preview: UIImage {
        switch self {
        case .classic:
            return Constants.Icons.appIconPink
        case .artyClickRed:
            return Constants.Icons.appIconArtyClickRed
        case .chromeYellow:
            return Constants.Icons.appIconChromeYellow
        case .neonBlue:
            return Constants.Icons.appIconNeonBlue
        case .neonPink:
            return Constants.Icons.appIconNeonPink
        case .purpleDaffodil:
            return Constants.Icons.appIconPurpleDaffodil
        case .vividGreen:
            return Constants.Icons.appIconVividGreen
        }
    }
}
