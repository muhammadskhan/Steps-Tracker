//
//  Constants.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 10/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import Foundation
import UIKit


let defaults = UserDefaults.standard
var sharedDefaults = UserDefaults(suiteName: "group.com.swamtech.stepstrackerapp")!

struct Constants {
    
    struct AppColors {
        
        static var primaryColor: UIColor {
            get {
                switch sharedDataManager.appColor {
                case .defaultColor:
                    return defaultPink
                case .artyClickRed:
                    return artyClickRed
                case .chromeYellow:
                    return chromeYellow
                case .neonBlue:
                    return neonBlue
                case .neonPink:
                    return neonPink
                case .purpleDaffodil:
                    return purpleDaffodil
                case .vividGreen:
                    return vividGreen
                }
            }
        }
        
        static var ringGradient2nd: UIColor {
            get {
                switch sharedDataManager.appColor {
                case .defaultColor:
                    return defaultGradient
                case .artyClickRed:
                    return artyClickRedGradient
                case .chromeYellow:
                    return chromeYellowGradient
                case .neonBlue:
                    return neonBlueGradient
                case .neonPink:
                    return neonPinkGradient
                case .purpleDaffodil:
                    return purpleDaffodilGradient
                case .vividGreen:
                    return vividGreenGradient
                }
            }
        }
        
        static var textColor: UIColor {
            get {
                return UIColor(named: "TextColor")!
            }
        }
        
        static var gradientBlue1st: UIColor {
            get {
                return UIColor(named: "GradientBlue1st")!
            }
        }
        
        static var gradientBlue2nd: UIColor {
            get {
                return UIColor(named: "GradientBlue2nd")!
            }
        }
        
        static var unSelectedColor: UIColor {
            get {
                return UIColor(named: "UnSelected")!
            }
        }
        
        static let artyClickRed = UIColor(named: "ArtyClickRed")!
        static let artyClickRedGradient = UIColor(named: "ArtyClickRedGradient")!
        static let chromeYellow = UIColor(named: "ChromeYellow")!
        static let chromeYellowGradient = UIColor(named: "ChromeYellowGradient")!
        static let neonBlue = UIColor(named: "NeonBlue")!
        static let neonBlueGradient = UIColor(named: "NeonBlueGradient")!
        static let neonPink = UIColor(named: "NeonPink")!
        static let neonPinkGradient = UIColor(named: "NeonPinkGradient")!
        static let purpleDaffodil = UIColor(named: "PurpleDaffodil")!
        static let purpleDaffodilGradient = UIColor(named: "PurpleDaffodilGradient")!
        static let vividGreen = UIColor(named: "VividGreen")!
        static let vividGreenGradient = UIColor(named: "VividGreenGradient")!
        static let defaultPink = UIColor(named: "PrimaryColor")!
        static let defaultGradient = UIColor(named: "GradientSecondColor")!
    }
    
    struct Icons {
        
        static let calendarGray = UIImage(named: "calendar-gray")!
        static let calendarPink = UIImage(named: "calendar-pink")!
        static let settingsGray = UIImage(named: "settings-gray")!
        static let settingsPink = UIImage(named: "settings-pink")!
        static let indicator0 = UIImage(named: "IndicatorLines")!
        static var indicator10: UIImage? {
            get {
                let imageName = "IndicatorLines\(sharedDataManager.appColor.rawValue)10"
                return UIImage(named: imageName)
            }
        }
        static var indicator20: UIImage? {
            get {
                let imageName = "IndicatorLines\(sharedDataManager.appColor.rawValue)20"
                return UIImage(named: imageName)
            }
        }
        static var indicator30: UIImage? {
            get {
                let imageName = "IndicatorLines\(sharedDataManager.appColor.rawValue)30"
                return UIImage(named: imageName)
            }
        }
        static var indicator40: UIImage? {
            get {
                let imageName = "IndicatorLines\(sharedDataManager.appColor.rawValue)40"
                return UIImage(named: imageName)
            }
        }
        static var indicator50: UIImage? {
            get {
                let imageName = "IndicatorLines\(sharedDataManager.appColor.rawValue)50"
                return UIImage(named: imageName)
            }
        }
        static var indicator60: UIImage? {
            get {
                let imageName = "IndicatorLines\(sharedDataManager.appColor.rawValue)60"
                return UIImage(named: imageName)
            }
        }
        static var indicator70: UIImage? {
            get {
                let imageName = "IndicatorLines\(sharedDataManager.appColor.rawValue)70"
                return UIImage(named: imageName)
            }
        }
        
        static var indicator80: UIImage? {
            get {
                let imageName = "IndicatorLines\(sharedDataManager.appColor.rawValue)80"
                return UIImage(named: imageName)
            }
        }
        
        static var indicator90: UIImage? {
            get {
                let imageName = "IndicatorLines\(sharedDataManager.appColor.rawValue)90"
                return UIImage(named: imageName)
            }
        }
        
        static let checked = UIImage(named: "checked")!
        static let forwardOpen = UIImage(named: "forwardOpen")!
        
        static var home: UIImage? {
            get {
                let imageName = "home\(sharedDataManager.appColor.rawValue)"
                return UIImage(named: imageName)
            }
        }
        
        static var ranking: UIImage? {
            get {
                let imageName = "ranking\(sharedDataManager.appColor.rawValue)"
                return UIImage(named: imageName)
            }
        }
        
        static var article: UIImage? {
            get {
                let imageName = "article\(sharedDataManager.appColor.rawValue)"
                return UIImage(named: imageName)
            }
        }
        
        static var minus: UIImage? {
            get {
                let imageName = "minus\(sharedDataManager.appColor.rawValue)"
                return UIImage(named: imageName)
            }
        }
        
        static var plus: UIImage? {
            get {
                let imageName = "plus\(sharedDataManager.appColor.rawValue)"
                return UIImage(named: imageName)
            }
        }
        
        static var widget: UIImage? {
            get {
                let imageName = "widget\(sharedDataManager.appColor.rawValue)"
                return UIImage(named: imageName)
            }
        }
        
        static var logout: UIImage? {
            get {
                let imageName = "logout\(sharedDataManager.appColor.rawValue)"
                return UIImage(named: imageName)
            }
        }
        
        static var manWalking: UIImage? {
            get {
                let imageName = "man-walking\(sharedDataManager.appColor.rawValue)"
                return UIImage(named: imageName)
            }
        }
        
        static var fire: UIImage? {
            get {
                let imageName = "fire\(sharedDataManager.appColor.rawValue)"
                return UIImage(named: imageName)
            }
        }
        
        static var top: UIImage? {
            get {
                let imageName = "top\(sharedDataManager.appColor.rawValue)"
                return UIImage(named: imageName)
            }
        }
        
        static var bottom: UIImage? {
            get {
                let imageName = "bottom\(sharedDataManager.appColor.rawValue)"
                return UIImage(named: imageName)
            }
        }
        
        static var logo: UIImage? {
            get {
                let imageName = "logo\(sharedDataManager.appColor.rawValue)"
                return UIImage(named: imageName)
            }
        }
        
        static var greenCheck: UIImage = UIImage(named: "greenCheck")!
        
        static var appIconArtyClickRed = UIImage(named: "AppIconArtyClickRed")!
        static var appIconChromeYellow = UIImage(named: "AppIconChromeYellow")!
        static var appIconNeonBlue = UIImage(named: "AppIconNeonBlue")!
        static var appIconNeonPink = UIImage(named: "AppIconNeonPink")!
        static var appIconPurpleDaffodil = UIImage(named: "AppIconPurpleDaffodil")!
        static var appIconVividGreen = UIImage(named: "AppIconVividGreen")!
        static var appIconPink = UIImage(named: "AppIconPink")!
    }
    
    struct AnalyticEvents {
        
        static let sharedProgress = "shared_progress"
        static let sharedApp = "share_app"
        static let widgetAdded = "widget_added"
    }
    
    static let testAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    static let homeScreenAdUnitID = "ca-app-pub-4506845038813812/6218356623"
    static let interstitialAdUnitID = "ca-app-pub-4506845038813812/6545659685"
    static let interstitialTestAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    static let rankingInterstitialAdUnitID = "ca-app-pub-4506845038813812/3195343391"
    static let adAppID = "ca-app-pub-4506845038813812~1520741328"
    static let appstoreLink = "https://apps.apple.com/us/app/my-steps-tracker/id1531692664"
    static let appName = "Steps Tracker"
    static let termsOfUseLink = "https://nomanharoonnomanharoon.github.io/StepsTracker/"
    static let privacyPolicy = "https://steps-tracker.flycricket.io/privacy.html"
    static let askAIURL = "https://apps.apple.com/pk/app/ask-ai-intelligent-chatbot/id1661075748"
    struct GenericStrings {
        
        static let somethingWentWrong = "Something went wrong while processing your request"
        static let requestTimedOut = "Request Timed Out"
        static let internetNotFound = "No Internet Connection"
    }
    
    struct ServiceConfiguration {
        
        static let baseURL = "https://stepstracker.prismic.io/api/v2"
    }
    
    static let purchasesApiKey = "VVXXhTKuOWbUIxhSLByVmzPwsLLpbLVt"
    static let proEntitlementIdentifier = "pro"
}

enum FirestoreCollections: String {
    
    case users = "users"
    case userInfo = "userInfo"
    case steps = "steps"
    case distance = "distance"
}

//(weight/1947) * stepstaken = calories burned.
